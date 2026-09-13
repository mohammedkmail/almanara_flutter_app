package librarysystem

import grails.gorm.transactions.Transactional
import java.math.RoundingMode

@Transactional
class PaymentService {

    BraintreeGatewayService braintreeGatewayService
    CheckoutIntentService checkoutIntentService
    PurchaseService purchaseService
    RoomReservationService roomReservationService
    ReservationService reservationService
    BorrowingService borrowingService
    MembershipService membershipService
    DigitalAccessService digitalAccessService

    String clientToken() {
        braintreeGatewayService.clientToken()
    }

    boolean isOnlineGatewayConfigured() {
        braintreeGatewayService.configured
    }

    Payment processOnlinePayment(User user, String purpose, Long targetId, String checkoutToken,
                                 String paymentMethodNonce) {
        if (!user) throw new IllegalArgumentException('يجب تسجيل الدخول لإتمام الدفع.')
        String normalized = purpose?.trim()?.toUpperCase()
        if (!(normalized in ['PURCHASE', 'ROOM_RESERVATION', 'BOOK_RESERVATION', 'DIGITAL_RENTAL', 'MEMBERSHIP'])) {
            throw new IllegalArgumentException('نوع عملية الدفع غير صالح.')
        }

        String reference = generateReference()
        BigDecimal amount
        Closure finalizeOperation
        Closure<Long> resolvedTargetId
        CheckoutIntent intent = null

        if (normalized == 'PURCHASE') {
            Purchase purchase = Purchase.lock(targetId)
            validateOwnership(purchase?.user, user)
            if (!purchase || purchase.status != 'PENDING') throw new IllegalStateException('عملية الشراء لم تعد بانتظار الدفع.')
            Book lockedBook = Book.lock(purchase.book.id)
            if (purchase.purchaseType == 'PHYSICAL' && (lockedBook.physicalSaleStock ?: 0) < purchase.quantity) {
                throw new IllegalStateException('الكمية المطلوبة نفدت قبل الدفع. لم يتم خصم أي مبلغ.')
            }
            if (purchase.purchaseType == 'DIGITAL' &&
                (DigitalAccess.findByUserAndBookAndAccessTypeAndStatus(user, lockedBook, 'PURCHASE', 'ACTIVE') ||
                 Purchase.findByUserAndBookAndPurchaseTypeAndStatus(user, lockedBook, 'DIGITAL', 'COMPLETED'))) {
                throw new IllegalStateException('أنت تملك النسخة الرقمية بالفعل.')
            }
            amount = purchase.totalAmount
            finalizeOperation = { purchaseService.completePurchase(purchase.id) }
            resolvedTargetId = { purchase.id }

        } else if (normalized == 'BOOK_RESERVATION') {
            reservationService.expireReadyReservations()
            Reservation reservation = Reservation.lock(targetId)
            validateOwnership(reservation?.user, user)
            if (!reservation || reservation.status != 'READY') throw new IllegalStateException('حجز الكتاب لم يعد جاهزًا للدفع.')
            if (!reservation.assignedCopy || reservation.assignedCopy.status != 'RESERVED') {
                throw new IllegalStateException('النسخة المخصصة للحجز لم تعد متاحة.')
            }

            BigDecimal quotedAmount = reservation.feeAmount ?: BigDecimal.ZERO
            BigDecimal currentAmount = membershipService.borrowingFeeFor(user, reservation.book)

            if (currentAmount.setScale(2, RoundingMode.HALF_UP) != quotedAmount.setScale(2, RoundingMode.HALF_UP)) {
                reservation.feeAmount = currentAmount
                reservation.fulfillmentStatus = currentAmount > BigDecimal.ZERO ?
                    'AWAITING_PAYMENT' : 'AWAITING_CONFIRM'
                reservation.save(flush: true, failOnError: true)

                if (currentAmount <= BigDecimal.ZERO) {
                    throw new IllegalStateException('أصبحت الاستعارة مشمولة بدون رسوم. ارجع إلى الحجز وأكمل التأكيد مباشرة.')
                }
                throw new IllegalStateException('تغيّرت رسوم الاستعارة. أعد فتح الحجز لمراجعة السعر الجديد قبل الدفع.')
            }

            amount = currentAmount
            if (amount <= BigDecimal.ZERO) {
                throw new IllegalStateException('هذا الحجز مشمول بدون رسوم. ارجع إلى الحجز وأكمل التأكيد مباشرة.')
            }

            finalizeOperation = { reservationService.confirmPayment(reservation.id, amount) }
            resolvedTargetId = { reservation.id }

        } else if (normalized == 'MEMBERSHIP') {
            Membership membership = Membership.lock(targetId)
            validateOwnership(membership?.user, user)
            if (!membership || membership.status != 'PENDING') throw new IllegalStateException('طلب العضوية لم يعد بانتظار الدفع.')

            Map membershipPricing = membershipService.validatePendingMembershipForPayment(membership)
            BigDecimal verifiedMembershipPrice = membershipPricing.totalPrice as BigDecimal
            if (membership.price.setScale(2, RoundingMode.HALF_UP) != verifiedMembershipPrice.setScale(2, RoundingMode.HALF_UP)) {
                throw new IllegalStateException('تغيّر سعر العضوية. أعد فتح طلب العضوية قبل الدفع.')
            }

            amount = verifiedMembershipPrice
            finalizeOperation = { membershipService.activateMembership(membership.id) }
            resolvedTargetId = { membership.id }

        } else {
            intent = checkoutIntentService.findOpen(checkoutToken, user)
            if (!intent || intent.purpose != normalized) throw new IllegalStateException('جلسة الدفع انتهت أو لم تعد صالحة.')
            Map payload = checkoutIntentService.payload(intent)
            amount = intent.amount

            if (normalized == 'ROOM_RESERVATION') {
                Long roomId = (payload.studyRoomId as Number)?.longValue()
                Date startTime = new Date((payload.startTime as Number).longValue())
                Date endTime = new Date((payload.endTime as Number).longValue())
                StudyRoom lockedRoom = StudyRoom.lock(roomId)
                if (!lockedRoom) throw new IllegalStateException('غرفة الدراسة لم تعد موجودة.')
                Map quote = roomReservationService.quote(user, lockedRoom, startTime, endTime)
                if (quote.totalPrice.setScale(2, RoundingMode.HALF_UP) != amount.setScale(2, RoundingMode.HALF_UP)) {
                    throw new IllegalStateException('تغيّر سعر الحجز. أعد فتح صفحة الحجز قبل الدفع.')
                }
                Map holder = [:]
                finalizeOperation = {
                    RoomReservation reservation = roomReservationService.createConfirmedReservation(
                        user, lockedRoom.id, startTime, endTime, amount)
                    holder.id = reservation.id
                    checkoutIntentService.complete(intent)
                    reservation
                }
                resolvedTargetId = { holder.id as Long }

            } else {
                Long bookId = (payload.bookId as Number)?.longValue()
                Integer rentalDays = (payload.rentalDays as Number)?.intValue()
                Book lockedBook = Book.lock(bookId)
                if (!lockedBook || lockedBook.active != true) throw new IllegalStateException('الكتاب لم يعد متاحًا.')
                BigDecimal currentAmount = digitalAccessService.calculateRentalPrice(lockedBook, rentalDays)
                if (currentAmount.setScale(2, RoundingMode.HALF_UP) != amount.setScale(2, RoundingMode.HALF_UP)) {
                    throw new IllegalStateException('تغيّر سعر الاستئجار الرقمي. أعد المحاولة.')
                }
                if (digitalAccessService.canAccessBook(user, lockedBook)) {
                    throw new IllegalStateException('لديك وصول فعال لهذا الكتاب بالفعل.')
                }
                Map holder = [:]
                finalizeOperation = {
                    DigitalAccess access = digitalAccessService.grantPaidRentalAccess(user, lockedBook, rentalDays, amount)
                    holder.id = access.id
                    checkoutIntentService.complete(intent)
                    access
                }
                resolvedTargetId = { holder.id as Long }
            }
        }

        Map gatewayResult = braintreeGatewayService.sale(amount, paymentMethodNonce, reference)
        try {
            finalizeOperation.call()
            Long finalTargetId = resolvedTargetId.call()
            Payment payment = new Payment(
                referenceCode: reference,
                provider: 'BRAINTREE',
                providerTransactionId: gatewayResult.transactionId,
                purpose: normalized,
                targetId: finalTargetId,
                amount: amount,
                currency: 'USD',
                paymentMethod: 'CARD',
                cardBrand: gatewayResult.cardBrand,
                cardLastFour: gatewayResult.lastFour,
                cardholderName: gatewayResult.cardholderName,
                channel: 'ONLINE',
                status: 'COMPLETED',
                paidAt: new Date(),
                user: user
            )
            payment.save(flush: true, failOnError: true)
            payment
        } catch (Exception e) {
            braintreeGatewayService.voidTransactionQuietly(gatewayResult.transactionId as String)
            throw e
        }
    }

    Payment recordCounterPurchase(User user, Long purchaseId, String method, String notes = null) {
        Purchase purchase = Purchase.lock(purchaseId)
        validateOwnership(purchase?.user, user)
        if (!purchase || purchase.status != 'PENDING') throw new IllegalStateException('عملية الشراء ليست بانتظار الدفع.')
        Payment payment = createCounterPayment(user, 'PURCHASE', purchase.id, purchase.totalAmount, method, notes)
        purchaseService.completePurchase(purchase.id)
        payment
    }

    Map recordCounterBorrowing(User user, Long bookCopyId, String method, String notes = null) {
        BookCopy copy = BookCopy.get(bookCopyId)
        if (!copy) throw new IllegalArgumentException('نسخة الكتاب غير موجودة.')
        BigDecimal amount = borrowingService.counterBorrowingFee(user, copy)
        Borrowing borrowing = borrowingService.borrowBookAtCounter(user, copy)
        Payment payment = amount > BigDecimal.ZERO ?
            createCounterPayment(user, 'BORROWING', borrowing.id, amount, method, notes) : null
        [borrowing: borrowing, payment: payment]
    }

    Map recordCounterReservationHandover(Long reservationId, String method, String notes = null) {
        reservationService.expireReadyReservations()
        Reservation reservation = reservationService.refreshReadyReservationFee(reservationId)
        if (!reservation) throw new IllegalArgumentException('الحجز غير موجود.')

        if (reservation.status == 'READY') {
            BigDecimal amount = reservation.feeAmount ?: BigDecimal.ZERO
            Payment payment = null

            if (amount > BigDecimal.ZERO) {
                payment = createCounterPayment(
                    reservation.user, 'BOOK_RESERVATION', reservation.id,
                    amount, method, notes)
                reservationService.confirmPayment(reservation.id, amount)
            } else {
                reservationService.confirmIncludedBorrowing(reservation.id)
            }

            Borrowing borrowing = borrowingService.borrowReservation(reservation.id)
            return [borrowing: borrowing, payment: payment]
        }

        if (reservation.status in ['PAID', 'CONFIRMED']) {
            boolean wasPaid = reservation.status == 'PAID'
            Payment payment = wasPaid ?
                Payment.findByPurposeAndTargetIdAndStatus('BOOK_RESERVATION', reservation.id, 'COMPLETED') : null
            Borrowing borrowing = borrowingService.borrowReservation(reservation.id)
            return [borrowing: borrowing, payment: payment]
        }

        throw new IllegalStateException('الحجز غير جاهز للتسليم.')
    }

    Payment createCounterPayment(User user, String purpose, Long targetId, BigDecimal amount,
                                 String method, String notes = null) {
        String normalizedMethod = method?.toUpperCase() in ['CASH', 'CARD'] ? method.toUpperCase() : 'CASH'
        new Payment(
            referenceCode: generateReference('POS'),
            provider: 'COUNTER',
            providerTransactionId: null,
            purpose: purpose,
            targetId: targetId,
            amount: amount ?: BigDecimal.ZERO,
            currency: 'USD',
            paymentMethod: normalizedMethod,
            channel: 'COUNTER',
            status: 'COMPLETED',
            notes: notes?.trim(),
            paidAt: new Date(),
            user: user
        ).save(flush: true, failOnError: true)
    }

    void cancelCheckout(User user, String purpose, Long targetId, String checkoutToken) {
        String normalized = purpose?.toUpperCase()
        if (normalized == 'PURCHASE') {
            Purchase purchase = purchaseService.get(targetId)
            validateOwnership(purchase?.user, user)
            purchaseService.cancelPendingPurchase(targetId)
        } else if (normalized == 'MEMBERSHIP') {
            Membership membership = membershipService.get(targetId)
            validateOwnership(membership?.user, user)
            if (!membership || membership.status != 'PENDING') {
                throw new IllegalStateException('يمكن إلغاء طلب العضوية من صفحة الدفع فقط قبل إتمام الدفع.')
            }
            membershipService.cancelMembership(targetId)
        } else if (normalized in ['ROOM_RESERVATION', 'DIGITAL_RENTAL']) {
            CheckoutIntent intent = checkoutIntentService.findOpen(checkoutToken, user)
            if (intent) checkoutIntentService.cancel(intent)
        }
        // BOOK_RESERVATION remains READY when the customer simply leaves checkout.
    }

    private void validateOwnership(User owner, User currentUser) {
        if (!owner || !currentUser || owner.id != currentUser.id) {
            throw new IllegalStateException('هذه العملية لا تخص حسابك.')
        }
    }

    private String generateReference(String prefix = 'MN') {
        "${prefix}-${System.currentTimeMillis()}-${UUID.randomUUID().toString().substring(0, 6).toUpperCase()}"
    }
}
