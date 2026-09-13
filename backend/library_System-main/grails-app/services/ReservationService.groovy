package librarysystem

import grails.gorm.transactions.Transactional

@Transactional
class ReservationService {

    MembershipService membershipService

    Reservation get(Serializable id) { Reservation.get(id) }
    List<Reservation> list(Map params = [:]) { Reservation.list(params) }
    Long count() { Reservation.count() }

    Reservation createReservation(User user, Book book) {
        if (!user) throw new IllegalArgumentException('يجب تسجيل الدخول لحجز كتاب.')
        if (!book) throw new IllegalArgumentException('الكتاب غير موجود.')
        if (!book.active) throw new IllegalStateException('الكتاب غير متاح حاليًا.')
        if (!user.enabled || user.accountLocked || user.accountExpired) {
            throw new IllegalStateException('الحساب غير مؤهل للحجز حاليًا.')
        }

        Reservation existing = Reservation.findByUserAndBookAndStatusInList(
            user, book, ['WAITING', 'READY', 'PAID', 'CONFIRMED'])
        if (existing) throw new IllegalStateException('لديك حجز فعال لهذا الكتاب بالفعل.')

        Reservation reservation = new Reservation(
            user: user,
            book: book,
            reservationDate: new Date(),
            status: 'WAITING',
            fulfillmentMethod: 'PICKUP',
            fulfillmentStatus: 'WAITING_FOR_COPY',
            feeAmount: currentBorrowingFee(user, book)
        ).save(flush: true, failOnError: true)

        allocateAvailableCopies(book)
        reservation.refresh()
        reservation
    }

    Reservation getNextWaitingReservation(Book book) {
        Reservation.findByBookAndStatus(
            book, 'WAITING', [sort: 'reservationDate', order: 'asc'])
    }

    Reservation assignCopy(Book book, BookCopy bookCopy) {
        validateAvailableCopy(book, bookCopy)
        Reservation reservation = getNextWaitingReservation(book)
        if (!reservation) return null
        prepareReservation(reservation, bookCopy)
    }

    Reservation assignCopyToReservation(Long reservationId, Long bookCopyId) {
        Reservation reservation = Reservation.get(reservationId)
        if (!reservation) throw new IllegalArgumentException('الحجز غير موجود.')
        if (reservation.status != 'WAITING') {
            throw new IllegalStateException('يمكن تجهيز الحجوزات الموجودة في قائمة الانتظار فقط.')
        }

        BookCopy bookCopy = BookCopy.get(bookCopyId)
        if (!bookCopy) throw new IllegalArgumentException('نسخة الكتاب غير موجودة.')
        validateAvailableCopy(reservation.book, bookCopy)
        prepareReservation(reservation, bookCopy)
    }

    Reservation updateFulfillmentPreference(Long id, String method, String deliveryAddress) {
        expireReadyReservations()
        Reservation reservation = Reservation.lock(id)
        if (!reservation) throw new IllegalArgumentException('الحجز غير موجود.')
        if (reservation.status != 'READY') {
            throw new IllegalStateException('هذا الحجز غير جاهز للتأكيد حاليًا.')
        }

        String normalized = method?.toUpperCase() in ['PICKUP', 'DELIVERY'] ? method.toUpperCase() : 'PICKUP'
        String address = deliveryAddress?.trim()
        if (normalized == 'DELIVERY' && !address) {
            throw new IllegalArgumentException('أدخل عنوان التوصيل قبل التأكيد.')
        }

        reservation.fulfillmentMethod = normalized
        reservation.deliveryAddress = normalized == 'DELIVERY' ? address : null
        reservation.feeAmount = currentBorrowingFee(reservation.user, reservation.book)
        reservation.fulfillmentStatus = reservation.feeAmount > BigDecimal.ZERO ?
            'AWAITING_PAYMENT' : 'AWAITING_CONFIRM'
        reservation.save(flush: true, failOnError: true)
        reservation
    }

    Reservation refreshReadyReservationFee(Long id) {
        expireReadyReservations()
        Reservation reservation = Reservation.lock(id)
        if (!reservation) throw new IllegalArgumentException('الحجز غير موجود.')
        if (reservation.status == 'READY') {
            reservation.feeAmount = currentBorrowingFee(reservation.user, reservation.book)
            reservation.fulfillmentStatus = reservation.feeAmount > BigDecimal.ZERO ?
                'AWAITING_PAYMENT' : 'AWAITING_CONFIRM'
            reservation.save(flush: true, failOnError: true)
        }
        reservation
    }

    Reservation confirmIncludedBorrowing(Long id) {
        expireReadyReservations()
        Reservation reservation = Reservation.lock(id)
        if (!reservation) throw new IllegalArgumentException('الحجز غير موجود.')
        if (reservation.status == 'CONFIRMED') return reservation
        if (reservation.status != 'READY') {
            throw new IllegalStateException('الحجز لم يعد جاهزًا للتأكيد.')
        }
        if (!reservation.assignedCopy || reservation.assignedCopy.status != 'RESERVED') {
            throw new IllegalStateException('النسخة المخصصة لهذا الحجز لم تعد محفوظة.')
        }

        BigDecimal fee = currentBorrowingFee(reservation.user, reservation.book)
        reservation.feeAmount = fee
        if (fee > BigDecimal.ZERO) {
            reservation.save(flush: true, failOnError: true)
            throw new IllegalStateException('هذا الحجز يحتاج دفع رسوم الاستعارة قبل التأكيد.')
        }

        reservation.status = 'CONFIRMED'
        reservation.paidAt = null
        reservation.fulfillmentStatus = reservation.fulfillmentMethod == 'DELIVERY' ?
            'PREPARING_DELIVERY' : 'READY_FOR_PICKUP'
        reservation.readyUntil = reservation.fulfillmentMethod == 'PICKUP' ? daysFromNow(3) : null
        reservation.save(flush: true, failOnError: true)
        reservation
    }

    Reservation confirmPayment(Long id, BigDecimal expectedFee = null) {
        expireReadyReservations()
        Reservation reservation = Reservation.lock(id)
        if (!reservation) throw new IllegalArgumentException('الحجز غير موجود.')
        if (reservation.status == 'PAID') return reservation
        if (reservation.status != 'READY') {
            throw new IllegalStateException('الحجز لم يعد جاهزًا للدفع.')
        }
        if (!reservation.assignedCopy || reservation.assignedCopy.status != 'RESERVED') {
            throw new IllegalStateException('النسخة المخصصة لهذا الحجز لم تعد محفوظة. راجع إدارة المكتبة.')
        }

        BigDecimal fee = currentBorrowingFee(reservation.user, reservation.book)
        reservation.feeAmount = fee
        if (fee <= BigDecimal.ZERO) {
            reservation.fulfillmentStatus = 'AWAITING_CONFIRM'
            reservation.save(flush: true, failOnError: true)
            throw new IllegalStateException('هذا الحجز أصبح مشمولًا بدون رسوم؛ لا يحتاج عملية دفع.')
        }
        if (expectedFee != null && fee.compareTo(expectedFee) != 0) {
            reservation.fulfillmentStatus = 'AWAITING_PAYMENT'
            reservation.save(flush: true, failOnError: true)
            throw new IllegalStateException('تغيّرت رسوم الاستعارة قبل تأكيد الدفع. أعد فتح الحجز لمراجعة السعر الجديد.')
        }

        reservation.status = 'PAID'
        reservation.paidAt = new Date()
        reservation.fulfillmentStatus = reservation.fulfillmentMethod == 'DELIVERY' ?
            'PREPARING_DELIVERY' : 'READY_FOR_PICKUP'
        // Paid reservations are not auto-expired because that would require a refund workflow.
        reservation.readyUntil = null
        reservation.save(flush: true, failOnError: true)
        reservation
    }

    Reservation markOutForDelivery(Long id) {
        Reservation reservation = Reservation.get(id)
        if (!reservation) throw new IllegalArgumentException('الحجز غير موجود.')
        if (!(reservation.status in ['PAID', 'CONFIRMED']) || reservation.fulfillmentMethod != 'DELIVERY') {
            throw new IllegalStateException('هذا الحجز غير جاهز للتوصيل.')
        }
        reservation.fulfillmentStatus = 'OUT_FOR_DELIVERY'
        reservation.save(flush: true, failOnError: true)
        reservation
    }

    Reservation fulfillReservation(Long id) {
        Reservation reservation = Reservation.get(id)
        if (!reservation) return null
        if (!(reservation.status in ['PAID', 'CONFIRMED'])) {
            throw new IllegalStateException('يجب تأكيد الحجز أو دفع رسومه قبل تسليم الكتاب.')
        }
        reservation.status = 'FULFILLED'
        reservation.fulfillmentStatus = 'HANDED_OVER'
        reservation.save(flush: true, failOnError: true)
        reservation
    }

    Reservation cancelReservation(Long id, boolean adminOverride = false) {
        Reservation reservation = Reservation.get(id)
        if (!reservation) return null
        if (reservation.status in ['FULFILLED', 'EXPIRED', 'CANCELLED']) {
            throw new IllegalStateException('لا يمكن إلغاء هذا الحجز.')
        }
        if (reservation.status == 'PAID' && !adminOverride) {
            throw new IllegalStateException('الحجز مدفوع؛ تواصل مع الإدارة لمعالجة الإلغاء والاسترداد.')
        }
        if (reservation.fulfillmentStatus == 'OUT_FOR_DELIVERY' && !adminOverride) {
            throw new IllegalStateException('لا يمكن إلغاء الحجز بعد خروجه للتوصيل. تواصل مع الإدارة.')
        }

        releaseCopyAndContinueQueue(reservation)
        reservation.status = 'CANCELLED'
        reservation.fulfillmentStatus = 'CANCELLED'
        reservation.save(flush: true, failOnError: true)
        reservation
    }

    void expireReadyReservations() {
        Date now = new Date()
        List<Reservation> expiredReservations = []
        expiredReservations.addAll(Reservation.findAllByStatusAndReadyUntilLessThan('READY', now))
        expiredReservations.addAll(
            Reservation.findAllByStatusAndReadyUntilLessThan('CONFIRMED', now).findAll {
                it.fulfillmentMethod == 'PICKUP'
            }
        )

        expiredReservations.each { Reservation reservation ->
            BookCopy releasedCopy = reservation.assignedCopy
            Book book = reservation.book
            reservation.assignedCopy = null
            reservation.status = 'EXPIRED'
            reservation.fulfillmentStatus = 'CANCELLED'
            reservation.save(flush: true, failOnError: true)

            if (releasedCopy) {
                releasedCopy.status = 'AVAILABLE'
                releasedCopy.save(flush: true, failOnError: true)
                assignCopy(book, releasedCopy)
            }
        }
    }

    Long countWaitingReservations() {
        expireReadyReservations()
        Reservation.countByStatus('WAITING')
    }


    private void allocateAvailableCopies(Book book) {
        while (true) {
            Reservation nextWaiting = getNextWaitingReservation(book)
            BookCopy availableCopy = BookCopy.findByBookAndStatus(
                book, 'AVAILABLE', [sort: 'copyCode', order: 'asc'])
            if (!nextWaiting || !availableCopy) return
            prepareReservation(nextWaiting, availableCopy)
        }
    }

    private Reservation prepareReservation(Reservation reservation, BookCopy bookCopy) {
        BookCopy lockedCopy = BookCopy.lock(bookCopy?.id)
        if (!lockedCopy) throw new IllegalArgumentException('نسخة الكتاب غير موجودة.')
        validateAvailableCopy(reservation.book, lockedCopy)

        reservation.assignedCopy = lockedCopy
        reservation.status = 'READY'
        reservation.readyUntil = daysFromNow(2)
        reservation.feeAmount = currentBorrowingFee(reservation.user, reservation.book)
        reservation.fulfillmentStatus = reservation.feeAmount > BigDecimal.ZERO ?
            'AWAITING_PAYMENT' : 'AWAITING_CONFIRM'
        reservation.save(flush: true, failOnError: true)

        lockedCopy.status = 'RESERVED'
        lockedCopy.save(flush: true, failOnError: true)
        reservation
    }

    private void releaseCopyAndContinueQueue(Reservation reservation) {
        BookCopy releasedCopy = reservation.assignedCopy
        Book book = reservation.book
        if (releasedCopy) {
            reservation.assignedCopy = null
            releasedCopy.status = 'AVAILABLE'
            releasedCopy.save(flush: true, failOnError: true)
            assignCopy(book, releasedCopy)
        }
    }

    private void validateAvailableCopy(Book book, BookCopy bookCopy) {
        if (!book || !bookCopy) throw new IllegalArgumentException('الكتاب والنسخة مطلوبان.')
        if (bookCopy.book?.id != book.id) throw new IllegalArgumentException('النسخة المختارة لا تتبع هذا الكتاب.')
        if (bookCopy.status != 'AVAILABLE') throw new IllegalStateException('هذه النسخة غير متاحة حاليًا.')
    }

    private BigDecimal currentBorrowingFee(User user, Book book) {
        membershipService.borrowingFeeFor(user, book)
    }

    private Date daysFromNow(int days) {
        Calendar calendar = Calendar.getInstance()
        calendar.add(Calendar.DAY_OF_MONTH, days)
        calendar.time
    }
}
