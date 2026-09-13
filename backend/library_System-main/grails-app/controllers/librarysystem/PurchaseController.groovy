package librarysystem

import grails.plugin.springsecurity.SpringSecurityService
import grails.plugin.springsecurity.annotation.Secured

@Secured(['ROLE_USER', 'ROLE_ADMIN'])
class PurchaseController {

    SpringSecurityService springSecurityService
    PurchaseService purchaseService
    PaymentService paymentService

    static allowedMethods = [buy: 'POST', saveCounterSale: 'POST', updateFulfillment: 'POST']

    def index() {
        User currentUser = springSecurityService.currentUser as User
        List<Purchase> purchases = isAdmin(currentUser) ?
            Purchase.list(sort: 'purchaseDate', order: 'desc') :
            Purchase.findAllByUser(currentUser, [sort: 'purchaseDate', order: 'desc'])
        respond purchases, model: [isAdmin: isAdmin(currentUser)]
    }

    def show(Long id) {
        Purchase purchase = purchaseService.get(id)
        if (!purchase) { notFound(); return }
        User currentUser = springSecurityService.currentUser as User
        if (!isAdmin(currentUser) && purchase.user?.id != currentUser.id) { render status: 403; return }
        Payment payment = Payment.findByPurposeAndTargetIdAndStatus('PURCHASE', purchase.id, 'COMPLETED')
        respond purchase, model: [isAdmin: isAdmin(currentUser), payment: payment]
    }

    @Secured(['ROLE_USER'])
    def buy(Long bookId) {
        User user = springSecurityService.currentUser as User
        Book book = Book.get(bookId)
        if (!book) { flash.message = 'الكتاب غير موجود.'; redirect controller: 'book', action: 'index'; return }
        try {
            String type = params.purchaseType?.toUpperCase()
            Integer quantity = params.int('quantity') ?: 1
            Purchase purchase = purchaseService.createPurchase(
                user, book, type, quantity, params.fulfillmentMethod, params.deliveryAddress)
            redirect controller: 'payment', action: 'checkout', params: [purpose: 'PURCHASE', targetId: purchase.id]
        } catch (Exception e) {
            flash.message = e.message
            redirect controller: 'book', action: 'show', id: book.id
        }
    }

    @Secured(['ROLE_ADMIN'])
    def counterSale() {
        render view: 'counterSale', model: [
            userList: User.list(sort: 'username', order: 'asc').findAll { it.authorities*.authority.contains('ROLE_USER') },
            bookList: Book.findAllByActive(true, [sort: 'title', order: 'asc'])
        ]
    }

    @Secured(['ROLE_ADMIN'])
    def saveCounterSale() {
        User user = User.get(params.long('userId'))
        Book book = Book.get(params.long('bookId'))
        try {
            Purchase purchase = purchaseService.createPurchase(
                user, book, params.purchaseType?.toUpperCase(), params.int('quantity') ?: 1,
                params.fulfillmentMethod, params.deliveryAddress)
            paymentService.recordCounterPurchase(user, purchase.id, params.paymentMethod ?: 'CASH', params.notes)
            flash.message = 'تم تسجيل عملية البيع والدفع من الكاونتر.'
            redirect action: 'show', id: purchase.id
        } catch (Exception e) {
            flash.message = e.message
            redirect action: 'counterSale'
        }
    }

    @Secured(['ROLE_ADMIN'])
    def updateFulfillment(Long id) {
        try {
            purchaseService.updateFulfillment(id, params.fulfillmentStatus)
            flash.message = 'تم تحديث حالة تجهيز الطلب.'
        } catch (Exception e) { flash.message = e.message }
        redirect action: 'show', id: id
    }

    private boolean isAdmin(User user) { user?.authorities*.authority?.contains('ROLE_ADMIN') }
    protected void notFound() { render status: 404 }
}
