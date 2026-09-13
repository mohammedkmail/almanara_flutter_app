package librarysystem

import grails.plugin.springsecurity.SpringSecurityService
import grails.plugin.springsecurity.annotation.Secured

@Secured(['ROLE_USER', 'ROLE_ADMIN'])
class BorrowingController {

    SpringSecurityService springSecurityService
    BorrowingService borrowingService
    PaymentService paymentService

    static allowedMethods = [borrow: 'POST', returnBook: 'POST']

    def index() {
        borrowingService.updateOverdueBorrowings()
        User currentUser = springSecurityService.currentUser as User
        boolean admin = isAdmin(currentUser)
        List<Borrowing> borrowingList
        List<User> userList = []
        List<BookCopy> availableCopyList = []

        if (admin) {
            borrowingList = Borrowing.list(sort: 'borrowDate', order: 'desc')
            userList = User.list(sort: 'username', order: 'asc').findAll { it.authorities*.authority.contains('ROLE_USER') }
            availableCopyList = BookCopy.findAllByStatus('AVAILABLE', [sort: 'copyCode', order: 'asc'])
        } else {
            borrowingList = Borrowing.findAllByUser(currentUser, [sort: 'borrowDate', order: 'desc'])
        }
        respond borrowingList, model: [isAdmin: admin, userList: userList, availableCopyList: availableCopyList]
    }

    def show(Long id) {
        borrowingService.updateOverdueBorrowings()
        Borrowing borrowing = borrowingService.get(id)
        if (!borrowing) { notFound(); return }
        User currentUser = springSecurityService.currentUser as User
        if (!isAdmin(currentUser) && borrowing.user?.id != currentUser.id) { render status: 403; return }
        Payment payment = Payment.findByPurposeAndTargetIdAndStatus('BORROWING', borrowing.id, 'COMPLETED')
        respond borrowing, model: [isAdmin: isAdmin(currentUser), payment: payment]
    }

    @Secured(['ROLE_ADMIN'])
    def borrow(Long userId, Long bookCopyId) {
        User borrower = User.get(userId)
        BookCopy copy = BookCopy.get(bookCopyId)
        if (!borrower || !copy) {
            flash.message = !borrower ? 'المستخدم غير موجود.' : 'نسخة الكتاب غير موجودة.'
            redirect action: 'index'; return
        }
        try {
            Map result = paymentService.recordCounterBorrowing(
                borrower, copy.id, params.paymentMethod ?: 'CASH', params.notes)
            flash.message = result.payment ?
                'تم تسجيل الدفع والاستعارة المباشرة من الكاونتر.' :
                'تم بدء الاستعارة بدون رسوم ضمن مزايا العضوية.'
            redirect action: 'show', id: result.borrowing.id
        } catch (Exception e) {
            flash.message = e.message
            redirect action: 'index'
        }
    }

    @Secured(['ROLE_ADMIN'])
    def returnBook(Long id) {
        try {
            Borrowing borrowing = borrowingService.returnBook(id)
            if (!borrowing) { notFound(); return }
            flash.message = 'تم تسجيل إرجاع الكتاب وتحديث توفر النسخة.'
            redirect action: 'show', id: borrowing.id
        } catch (Exception e) {
            flash.message = e.message
            redirect action: 'show', id: id
        }
    }

    private boolean isAdmin(User user) { user?.authorities*.authority?.contains('ROLE_ADMIN') }
    protected void notFound() { render status: 404 }
}
