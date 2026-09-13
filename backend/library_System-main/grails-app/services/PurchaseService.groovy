package librarysystem

import grails.gorm.transactions.Transactional
import java.math.RoundingMode

@Transactional
class PurchaseService {

    DigitalAccessService digitalAccessService

    Purchase get(Serializable id) { Purchase.get(id) }
    List<Purchase> list(Map params = [:]) { Purchase.list(params) }
    Long count() { Purchase.count() }

    Purchase createPurchase(User user, Book book, String purchaseType, Integer quantity,
                            String fulfillmentMethod = 'PICKUP', String deliveryAddress = null) {
        validateBasic(user, book, purchaseType, quantity)

        BigDecimal unitPrice
        String method
        String address = deliveryAddress?.trim()

        if (purchaseType == 'PHYSICAL') {
            if (book.physicalSalePrice == null) throw new IllegalStateException('النسخة الورقية غير متاحة للبيع.')
            if ((book.physicalSaleStock ?: 0) < quantity) throw new IllegalStateException('الكمية المطلوبة غير متوفرة في المخزون.')
            unitPrice = book.physicalSalePrice
            method = fulfillmentMethod?.toUpperCase() in ['PICKUP', 'DELIVERY'] ? fulfillmentMethod.toUpperCase() : 'PICKUP'
            if (method == 'DELIVERY' && !address) throw new IllegalArgumentException('أدخل عنوان التوصيل.')
        } else {
            validateDigitalOwnership(user, book)
            quantity = 1
            unitPrice = book.digitalPurchasePrice
            method = 'DIGITAL'
        }

        BigDecimal totalAmount = unitPrice.multiply(BigDecimal.valueOf(quantity)).setScale(2, RoundingMode.HALF_UP)

        new Purchase(
            user: user,
            book: book,
            purchaseType: purchaseType,
            quantity: quantity,
            unitPrice: unitPrice,
            totalAmount: totalAmount,
            purchaseDate: new Date(),
            status: 'PENDING',
            fulfillmentMethod: method,
            fulfillmentStatus: 'AWAITING_PAYMENT',
            deliveryAddress: method == 'DELIVERY' ? address : null
        ).save(flush: true, failOnError: true)
    }

    Purchase completePurchase(Long id) {
        Purchase purchase = Purchase.get(id)
        if (!purchase) throw new IllegalArgumentException('عملية الشراء غير موجودة.')
        if (purchase.status == 'COMPLETED') return purchase
        if (purchase.status != 'PENDING') throw new IllegalStateException('عملية الشراء لم تعد بانتظار الدفع.')

        Book book = Book.lock(purchase.book.id)
        if (!book || book.active != true) throw new IllegalStateException('الكتاب لم يعد متاحًا.')

        if (purchase.purchaseType == 'PHYSICAL') {
            if ((book.physicalSaleStock ?: 0) < purchase.quantity) {
                throw new IllegalStateException('نفدت الكمية المطلوبة قبل إتمام الدفع. لم يتم تأكيد الشراء.')
            }
            book.physicalSaleStock = (book.physicalSaleStock ?: 0) - purchase.quantity
            book.save(flush: true, failOnError: true)
            purchase.fulfillmentStatus = 'PREPARING'
        } else {
            validateDigitalOwnership(purchase.user, book)
            digitalAccessService.grantPurchaseAccess(purchase.user, book)
            purchase.fulfillmentStatus = 'DIGITAL_GRANTED'
        }

        purchase.status = 'COMPLETED'
        purchase.save(flush: true, failOnError: true)
        purchase
    }

    Purchase cancelPendingPurchase(Long id) {
        Purchase purchase = Purchase.get(id)
        if (!purchase) return null
        if (purchase.status != 'PENDING') throw new IllegalStateException('لا يمكن إلغاء هذه العملية في حالتها الحالية.')
        purchase.status = 'CANCELLED'
        purchase.fulfillmentStatus = 'CANCELLED'
        purchase.save(flush: true, failOnError: true)
        purchase
    }

    Purchase updateFulfillment(Long id, String newStatus) {
        Purchase purchase = Purchase.get(id)
        if (!purchase) throw new IllegalArgumentException('عملية الشراء غير موجودة.')
        if (purchase.status != 'COMPLETED' || purchase.purchaseType != 'PHYSICAL') {
            throw new IllegalStateException('هذه العملية لا تحتاج إدارة استلام أو توصيل.')
        }

        List allowed = purchase.fulfillmentMethod == 'DELIVERY' ?
            ['PREPARING', 'OUT_FOR_DELIVERY', 'FULFILLED'] :
            ['PREPARING', 'READY_FOR_PICKUP', 'FULFILLED']

        if (!(newStatus in allowed)) throw new IllegalArgumentException('حالة التجهيز غير صالحة.')
        purchase.fulfillmentStatus = newStatus
        purchase.save(flush: true, failOnError: true)
        purchase
    }

    BigDecimal totalSales() {
        Purchase.findAllByStatus('COMPLETED').sum { it.totalAmount ?: BigDecimal.ZERO } ?: BigDecimal.ZERO
    }

    Long countCompletedPurchases() { Purchase.countByStatus('COMPLETED') }

    private void validateBasic(User user, Book book, String purchaseType, Integer quantity) {
        if (!user) throw new IllegalArgumentException('يجب تسجيل الدخول لإتمام الشراء.')
        if (!book) throw new IllegalArgumentException('الكتاب غير موجود.')
        if (book.active != true) throw new IllegalStateException('هذا الكتاب غير متاح حاليًا.')
        if (!(purchaseType in ['PHYSICAL', 'DIGITAL'])) throw new IllegalArgumentException('اختر نوع نسخة صالحًا.')
        if (quantity == null || quantity < 1) throw new IllegalArgumentException('الكمية يجب أن تكون 1 على الأقل.')
        if (purchaseType == 'DIGITAL' && (!book.digitalAvailable || book.digitalPurchasePrice == null)) {
            throw new IllegalStateException('النسخة الرقمية غير متاحة للشراء.')
        }
    }

    private void validateDigitalOwnership(User user, Book book) {
        Purchase existingPurchase = Purchase.findByUserAndBookAndPurchaseTypeAndStatus(user, book, 'DIGITAL', 'COMPLETED')
        DigitalAccess existingAccess = DigitalAccess.findByUserAndBookAndAccessTypeAndStatus(user, book, 'PURCHASE', 'ACTIVE')
        if (existingPurchase || existingAccess) throw new IllegalStateException('أنت تملك النسخة الرقمية من هذا الكتاب بالفعل.')
    }
}
