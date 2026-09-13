package librarysystem

import grails.plugin.springsecurity.SpringSecurityService
import grails.plugin.springsecurity.annotation.Secured

@Secured(['ROLE_USER', 'ROLE_ADMIN'])
class PaymentController {

    SpringSecurityService springSecurityService
    PaymentService paymentService
    PurchaseService purchaseService
    ReservationService reservationService
    MembershipService membershipService
    CheckoutIntentService checkoutIntentService

    static allowedMethods = [process: 'POST', cancel: 'POST']

    def index() {
        User currentUser = springSecurityService.currentUser as User
        List<Payment> payments = isAdmin(currentUser) ?
            Payment.list(sort: 'dateCreated', order: 'desc') :
            Payment.findAllByUser(currentUser, [sort: 'dateCreated', order: 'desc'])
        respond payments, model: [isAdmin: isAdmin(currentUser)]
    }

    def show(Long id) {
        Payment payment = Payment.get(id)
        if (!payment) { notFound(); return }
        User currentUser = springSecurityService.currentUser as User
        if (!isAdmin(currentUser) && payment.user?.id != currentUser.id) { render status: 403; return }
        respond payment, model: [isAdmin: isAdmin(currentUser)]
    }

    @Secured(['ROLE_USER'])
    def checkout(String purpose, Long targetId, String checkoutToken) {
        User currentUser = springSecurityService.currentUser as User
        Map target = resolveTarget(currentUser, purpose, targetId, checkoutToken)
        if (!target) {
            flash.message = 'عملية الدفع غير موجودة أو لم تعد متاحة.'
            redirect controller: 'dashboard', action: 'index'
            return
        }

        boolean configured = paymentService.onlineGatewayConfigured
        String clientToken = null
        if (configured) {
            try { clientToken = paymentService.clientToken() }
            catch (Exception e) {

                println '========== BRAINTREE CLIENT TOKEN ERROR =========='
                println e.class.name
                println e.message
                println '=================================================='

                configured = false
                target.gatewayError = e.message
            }
        }

        render view: 'checkout', model: target + [
            purpose: purpose?.toUpperCase(), targetId: targetId, checkoutToken: checkoutToken,
            gatewayConfigured: configured, clientToken: clientToken
        ]
    }

    @Secured(['ROLE_USER'])
    def process() {
        User currentUser = springSecurityService.currentUser as User
        try {
            Payment payment = paymentService.processOnlinePayment(
                currentUser,
                params.purpose,
                params.long('targetId'),
                params.checkoutToken,
                params.paymentMethodNonce
            )
            flash.message = "تم الدفع بنجاح عبر Braintree Sandbox. رقم العملية ${payment.referenceCode}."
            redirectAfterPayment(payment)
        } catch (Exception e) {
            log.error('فشلت عملية الدفع عبر Braintree Sandbox', e)
            flash.message = (e instanceof IllegalArgumentException || e instanceof IllegalStateException)
                ? e.message
                : 'تعذر إتمام عملية الدفع الآن. لم يتم تأكيد العملية، حاول مرة أخرى.'
            redirect action: 'checkout', params: [
                purpose: params.purpose,
                targetId: params.targetId,
                checkoutToken: params.checkoutToken
            ]
        }
    }

    @Secured(['ROLE_USER'])
    def cancel() {
        User currentUser = springSecurityService.currentUser as User
        try {
            paymentService.cancelCheckout(currentUser, params.purpose, params.long('targetId'), params.checkoutToken)
            flash.message = 'تم إلغاء صفحة الدفع دون خصم أي مبلغ.'
        } catch (Exception e) {
            flash.message = e.message
        }
        redirect controller: 'dashboard', action: 'index'
    }

    private Map resolveTarget(User user, String purpose, Long targetId, String checkoutToken) {
        String normalized = purpose?.toUpperCase()
        if (normalized == 'PURCHASE') {
            Purchase purchase = purchaseService.get(targetId)
            if (!purchase || purchase.user?.id != user?.id || purchase.status != 'PENDING') return null
            return [
                amount: purchase.totalAmount,
                targetTitle: purchase.book?.title,
                targetDescription: purchase.purchaseType == 'DIGITAL' ? 'شراء نسخة رقمية' : 'شراء نسخة ورقية',
                targetIcon: 'bi-bag-check',
                summaryLines: [
                    [label: 'الكمية', value: purchase.quantity],
                    [label: 'طريقة الاستلام', value: purchase.fulfillmentMethod == 'DELIVERY' ? 'توصيل' : (purchase.fulfillmentMethod == 'DIGITAL' ? 'وصول رقمي' : 'استلام من المكتبة')]
                ]
            ]
        }
        if (normalized == 'BOOK_RESERVATION') {
            reservationService.expireReadyReservations()
            Reservation reservation = reservationService.get(targetId)
            if (!reservation || reservation.user?.id != user?.id || reservation.status != 'READY') return null
            reservation = reservationService.refreshReadyReservationFee(targetId)
            if ((reservation.feeAmount ?: BigDecimal.ZERO) <= BigDecimal.ZERO) return null
            return [
                amount: reservation.feeAmount,
                targetTitle: reservation.book?.title,
                targetDescription: 'تأكيد استعارة كتاب متاح الآن',
                targetIcon: 'bi-bookmark-check',
                summaryLines: [
                    [label: 'النسخة', value: reservation.assignedCopy?.copyCode],
                    [label: 'الاستلام', value: reservation.fulfillmentMethod == 'DELIVERY' ? 'توصيل' : 'من المكتبة']
                ]
            ]
        }
        if (normalized == 'MEMBERSHIP') {
            Membership membership = membershipService.get(targetId)
            if (!membership || membership.user?.id != user?.id || membership.status != 'PENDING') return null
            try {
                membershipService.validatePendingMembershipForPayment(membership)
            } catch (IllegalArgumentException | IllegalStateException ignored) {
                return null
            }
            return [
                amount: membership.price,
                targetTitle: 'عضوية المنارة',
                targetDescription: 'تفعيل العضوية للفترة المختارة',
                targetIcon: 'bi-person-badge',
                summaryLines: [
                    [label: 'من', value: membership.startDate ? new java.text.SimpleDateFormat('dd/MM/yyyy').format(membership.startDate) : null],
                    [label: 'حتى', value: membership.endDate ? new java.text.SimpleDateFormat('dd/MM/yyyy').format(membership.endDate) : null]
                ]
            ]
        }
        if (normalized in ['ROOM_RESERVATION', 'DIGITAL_RENTAL']) {
            CheckoutIntent intent = checkoutIntentService.findOpen(checkoutToken, user)
            if (!intent || intent.purpose != normalized) return null
            Map payload = checkoutIntentService.payload(intent)
            List summary = []
            if (normalized == 'ROOM_RESERVATION') {
                summary = [
                    [label: 'البداية', value: new java.text.SimpleDateFormat('dd/MM/yyyy HH:mm').format(new Date((payload.startTime as Number).longValue()))],
                    [label: 'النهاية', value: new java.text.SimpleDateFormat('dd/MM/yyyy HH:mm').format(new Date((payload.endTime as Number).longValue()))],
                    [label: 'الخصم', value: "${payload.discountPercentage ?: 0}%"]
                ]
            } else {
                summary = [[label: 'مدة الاستئجار', value: "${payload.rentalDays} يوم"]]
            }
            return [amount: intent.amount, targetTitle: intent.title, targetDescription: intent.description,
                    targetIcon: normalized == 'ROOM_RESERVATION' ? 'bi-door-open' : 'bi-tablet', summaryLines: summary]
        }
        null
    }

    private void redirectAfterPayment(Payment payment) {
        switch (payment.purpose) {
            case 'PURCHASE': redirect controller: 'purchase', action: 'show', id: payment.targetId; break
            case 'BOOK_RESERVATION': redirect controller: 'reservation', action: 'show', id: payment.targetId; break
            case 'MEMBERSHIP': redirect controller: 'membership', action: 'show', id: payment.targetId; break
            case 'ROOM_RESERVATION': redirect controller: 'roomReservation', action: 'show', id: payment.targetId; break
            case 'DIGITAL_RENTAL': redirect controller: 'digitalAccess', action: 'show', id: payment.targetId; break
            default: redirect action: 'show', id: payment.id
        }
    }

    private boolean isAdmin(User user) { user?.authorities*.authority?.contains('ROLE_ADMIN') }
    protected void notFound() { render status: 404 }
}
