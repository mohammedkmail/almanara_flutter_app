package librarysystem

import grails.gorm.transactions.Transactional

@Transactional
class BorrowingService {

    ReservationService reservationService
    MembershipService membershipService

    Borrowing get(Serializable id) { Borrowing.get(id) }
    List<Borrowing> list(Map params = [:]) { Borrowing.list(params) }
    Long count() { Borrowing.count() }

    Borrowing borrowBookAtCounter(User user, BookCopy bookCopy) {
        validateBorrower(user)
        if (!bookCopy) throw new IllegalArgumentException('اختر نسخة كتاب.')
        BookCopy lockedCopy = BookCopy.lock(bookCopy.id)
        if (lockedCopy.status != 'AVAILABLE') throw new IllegalStateException('هذه النسخة لم تعد متاحة.')

        Reservation waitingReservation = Reservation.findByBookAndStatus(
            lockedCopy.book, 'WAITING', [sort: 'reservationDate', order: 'asc'])
        if (waitingReservation) {
            throw new IllegalStateException('يوجد حجز أقدم بانتظار نسخة من هذا الكتاب. سلّم النسخة حسب ترتيب الحجوزات أولًا.')
        }

        ensureCopyIsNotBorrowed(lockedCopy)
        createBorrowing(user, lockedCopy, 'COUNTER', 'PICKUP')
    }

    Borrowing borrowReservation(Long reservationId) {
        reservationService.expireReadyReservations()
        Reservation reservation = reservationService.get(reservationId)
        if (!reservation) throw new IllegalArgumentException('الحجز غير موجود.')
        if (!(reservation.status in ['PAID', 'CONFIRMED'])) {
            throw new IllegalStateException('يجب تأكيد الحجز أو دفع رسومه قبل تسليم الكتاب.')
        }
        if (!reservation.assignedCopy) throw new IllegalStateException('لا توجد نسخة مخصصة لهذا الحجز.')

        User user = reservation.user
        validateBorrower(user)
        BookCopy bookCopy = BookCopy.lock(reservation.assignedCopy.id)
        if (bookCopy.status != 'RESERVED') throw new IllegalStateException('النسخة المخصصة لم تعد محجوزة.')
        ensureCopyIsNotBorrowed(bookCopy)

        Borrowing borrowing = createBorrowingRecord(user, bookCopy, 'RESERVATION', reservation.fulfillmentMethod)
        bookCopy.status = 'BORROWED'
        bookCopy.save(flush: true, failOnError: true)
        reservationService.fulfillReservation(reservation.id)
        borrowing
    }

    Borrowing returnBook(Long id) {
        Borrowing borrowing = Borrowing.get(id)
        if (!borrowing) return null
        if (!(borrowing.status in ['ACTIVE', 'OVERDUE'])) {
            throw new IllegalStateException('هذه الاستعارة مغلقة بالفعل.')
        }

        Date returnDate = new Date()
        borrowing.returnDate = returnDate
        borrowing.status = 'RETURNED'

        if (returnDate > borrowing.dueDate) {
            long lateDays = Math.ceil((returnDate.time - borrowing.dueDate.time) / (1000.0 * 60 * 60 * 24)) as long
            borrowing.lateFee = BigDecimal.valueOf(lateDays)
        } else {
            borrowing.lateFee = BigDecimal.ZERO
        }
        borrowing.save(flush: true, failOnError: true)

        BookCopy returnedCopy = borrowing.bookCopy
        if (returnedCopy) {
            Book book = returnedCopy.book
            returnedCopy.status = 'AVAILABLE'
            returnedCopy.save(flush: true, failOnError: true)
            if (book) reservationService.assignCopy(book, returnedCopy)
        }
        borrowing
    }

    void updateOverdueBorrowings() {
        Date now = new Date()
        Borrowing.findAllByStatusAndDueDateLessThan('ACTIVE', now).each { Borrowing borrowing ->
            borrowing.status = 'OVERDUE'
            borrowing.save(flush: true, failOnError: true)
        }
    }

    Long countActiveBorrowings() { updateOverdueBorrowings(); Borrowing.countByStatus('ACTIVE') }
    Long countOverdueBorrowings() { updateOverdueBorrowings(); Borrowing.countByStatus('OVERDUE') }

    BigDecimal counterBorrowingFee(User user, BookCopy bookCopy) {
        membershipService.borrowingFeeFor(user, bookCopy?.book)
    }

    private Borrowing createBorrowing(User user, BookCopy bookCopy, String origin, String fulfillmentMethod) {
        Borrowing borrowing = createBorrowingRecord(user, bookCopy, origin, fulfillmentMethod)
        bookCopy.status = 'BORROWED'
        bookCopy.save(flush: true, failOnError: true)
        borrowing
    }

    private Borrowing createBorrowingRecord(User user, BookCopy bookCopy, String origin, String fulfillmentMethod) {
        Date borrowDate = new Date()
        Calendar dueCalendar = Calendar.getInstance()
        dueCalendar.time = borrowDate
        dueCalendar.add(Calendar.DAY_OF_MONTH, 14)

        new Borrowing(
            user: user,
            bookCopy: bookCopy,
            borrowDate: borrowDate,
            dueDate: dueCalendar.time,
            status: 'ACTIVE',
            lateFee: BigDecimal.ZERO,
            origin: origin,
            fulfillmentMethod: fulfillmentMethod ?: 'PICKUP'
        ).save(flush: true, failOnError: true)
    }

    private void validateBorrower(User user) {
        if (!user) throw new IllegalArgumentException('المستخدم مطلوب.')
        if (!user.enabled || user.accountLocked || user.accountExpired) {
            throw new IllegalStateException('الحساب غير مؤهل للاستعارة حاليًا.')
        }
    }

    private void ensureCopyIsNotBorrowed(BookCopy bookCopy) {
        Borrowing openBorrowing = Borrowing.findByBookCopyAndStatusInList(bookCopy, ['ACTIVE', 'OVERDUE'])
        if (openBorrowing) throw new IllegalStateException('هذه النسخة مرتبطة باستعارة مفتوحة بالفعل.')
    }
}
