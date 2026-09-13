package librarysystem

import grails.plugin.springsecurity.SpringSecurityService
import grails.plugin.springsecurity.annotation.Secured

@Secured(['ROLE_USER', 'ROLE_ADMIN'])
class DigitalAccessController {

    SpringSecurityService springSecurityService
    DigitalAccessService digitalAccessService
    MembershipService membershipService
    CheckoutIntentService checkoutIntentService

    static allowedMethods = [rent: 'POST']

    def index() {
        digitalAccessService.expireOldRentals()
        User user = springSecurityService.currentUser as User
        boolean admin = isAdmin(user)
        if (admin) {
            respond DigitalAccess.list(sort: 'startDate', order: 'desc'), model: [isAdmin: true]
            return
        }

        Map<Long, Map> items = [:]
        DigitalAccess.findAllByUser(user, [sort: 'startDate', order: 'desc']).each { DigitalAccess access ->
            if (!access.book) return
            if (access.accessType == 'PURCHASE' && access.status == 'ACTIVE') {
                items[access.book.id] = [book: access.book, source: 'PURCHASE', access: access, endDate: null, permanent: true]
            } else if (access.accessType == 'RENTAL' && access.status == 'ACTIVE' && access.endDate?.after(new Date())) {
                if (!items.containsKey(access.book.id)) items[access.book.id] = [book: access.book, source: 'RENTAL', access: access, endDate: access.endDate, permanent: false]
            }
        }
        if (membershipService.hasActiveMembership(user)) {
            Book.findAllByMembershipIncludedAndDigitalAvailableAndActive(true, true, true, [sort: 'title', order: 'asc']).each { Book book ->
                if (!items.containsKey(book.id)) items[book.id] = [book: book, source: 'MEMBERSHIP', access: null, endDate: null, permanent: false]
            }
        }
        render view: 'index', model: [isAdmin: false, digitalLibraryItems: items.values().toList().sort { it.book?.title?.toLowerCase() }]
    }

    def show(Long id) {
        digitalAccessService.expireOldRentals()
        DigitalAccess access = DigitalAccess.get(id)
        if (!access) { notFound(); return }
        User user = springSecurityService.currentUser as User
        boolean admin = isAdmin(user)
        if (!admin && access.user?.id != user.id) { render status: 403; return }
        Payment payment = Payment.findByPurposeAndTargetIdAndStatus('DIGITAL_RENTAL', access.id, 'COMPLETED')
        respond access, model: [isAdmin: admin, canRead: !admin && digitalAccessService.canAccessBook(user, access.book), payment: payment]
    }

    @Secured(['ROLE_USER'])
    def read(Long bookId) {
        User user = springSecurityService.currentUser as User
        Book book = Book.get(bookId)
        if (!book) { notFound(); return }
        if (!digitalAccessService.canAccessBook(user, book)) {
            flash.message = 'لا تملك وصولًا رقميًا فعالًا لهذا الكتاب.'
            redirect controller: 'book', action: 'show', id: book.id; return
        }
        render view: 'read', model: [book: book]
    }

    @Secured(['ROLE_USER'])
    def rent(Long bookId, Integer rentalDays) {
        User user = springSecurityService.currentUser as User
        Book book = Book.get(bookId)
        if (!book) { notFound(); return }
        int days = rentalDays ?: 1
        try {
            if (book.active != true || !book.digitalAvailable || book.digitalRentalPrice == null) throw new IllegalStateException('الاستئجار الرقمي غير متاح لهذا الكتاب.')
            if (days < 1 || days > 30) throw new IllegalArgumentException('مدة الاستئجار من يوم إلى 30 يومًا.')
            if (digitalAccessService.canAccessBook(user, book)) throw new IllegalStateException('لديك وصول فعال لهذا الكتاب بالفعل.')
            BigDecimal amount = digitalAccessService.calculateRentalPrice(book, days)
            CheckoutIntent intent = checkoutIntentService.createIntent(user, 'DIGITAL_RENTAL', amount, book.title,
                "استئجار رقمي لمدة ${days} يوم", [bookId: book.id, rentalDays: days])
            redirect controller: 'payment', action: 'checkout', params: [purpose: 'DIGITAL_RENTAL', checkoutToken: intent.token]
        } catch (Exception e) {
            flash.message = e.message
            redirect controller: 'book', action: 'show', id: book.id
        }
    }

    private boolean isAdmin(User user) { user?.authorities*.authority?.contains('ROLE_ADMIN') }
    protected void notFound() { render status: 404 }
}
