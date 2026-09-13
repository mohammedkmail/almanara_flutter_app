package librarysystem

import grails.gorm.transactions.Transactional
import java.math.RoundingMode

@Transactional
class DigitalAccessService {

    MembershipService membershipService

    DigitalAccess get(Serializable id) { DigitalAccess.get(id) }
    List<DigitalAccess> list(Map params = [:]) { DigitalAccess.list(params) }
    Long count() { DigitalAccess.count() }

    BigDecimal calculateRentalPrice(Book book, Integer rentalDays) {
        if (!book || book.digitalRentalPrice == null || !rentalDays || rentalDays < 1) return BigDecimal.ZERO
        book.digitalRentalPrice.multiply(BigDecimal.valueOf(rentalDays)).setScale(2, RoundingMode.HALF_UP)
    }

    DigitalAccess grantPaidRentalAccess(User user, Book book, Integer rentalDays, BigDecimal paidAmount) {
        if (!user) throw new IllegalArgumentException('المستخدم مطلوب.')
        if (!book) throw new IllegalArgumentException('الكتاب غير موجود.')
        if (book.active != true || !book.digitalAvailable || book.digitalRentalPrice == null) throw new IllegalStateException('الاستئجار الرقمي غير متاح لهذا الكتاب.')
        if (!rentalDays || rentalDays < 1 || rentalDays > 30) throw new IllegalArgumentException('مدة الاستئجار الرقمي من يوم إلى 30 يومًا.')

        expireOldRentals()
        if (canAccessBook(user, book)) throw new IllegalStateException('لديك وصول فعال لهذا الكتاب بالفعل.')

        Date startDate = new Date()
        Calendar endCalendar = Calendar.getInstance()
        endCalendar.time = startDate
        endCalendar.add(Calendar.DAY_OF_MONTH, rentalDays)
        Date endDate = endCalendar.time
        new DigitalAccess(
            user: user,
            book: book,
            accessType: 'RENTAL',
            startDate: startDate,
            endDate: endDate,
            status: 'ACTIVE',
            paidAmount: paidAmount ?: BigDecimal.ZERO
        ).save(flush: true, failOnError: true)
    }

    DigitalAccess grantPurchaseAccess(User user, Book book) {
        if (!user) throw new IllegalArgumentException('المستخدم مطلوب.')
        if (!book || book.active != true || !book.digitalAvailable) throw new IllegalStateException('النسخة الرقمية غير متاحة.')
        DigitalAccess existing = DigitalAccess.findByUserAndBookAndAccessType(user, book, 'PURCHASE')
        if (existing) return existing
        new DigitalAccess(
            user: user,
            book: book,
            accessType: 'PURCHASE',
            startDate: new Date(),
            endDate: null,
            status: 'ACTIVE',
            paidAmount: book.digitalPurchasePrice ?: BigDecimal.ZERO
        ).save(flush: true, failOnError: true)
    }

    boolean canAccessBook(User user, Book book) {
        if (!user || !book || !book.digitalAvailable) return false
        if (DigitalAccess.findByUserAndBookAndAccessTypeAndStatus(user, book, 'PURCHASE', 'ACTIVE')) return true
        Date now = new Date()
        if (DigitalAccess.findAllByUserAndBookAndAccessTypeAndStatus(user, book, 'RENTAL', 'ACTIVE')
            .any { it.endDate && it.endDate >= now }) return true
        book.active == true && book.membershipIncluded && membershipService.hasActiveMembership(user)
    }

    void expireOldRentals() {
        Date now = new Date()
        DigitalAccess.findAllByAccessTypeAndStatus('RENTAL', 'ACTIVE').findAll { it.endDate && it.endDate < now }.each {
            it.status = 'EXPIRED'
            it.save(flush: true, failOnError: true)
        }
    }
}
