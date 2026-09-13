package librarysystem

import grails.plugin.springsecurity.SpringSecurityService
import grails.plugin.springsecurity.annotation.Secured

@Secured(['ROLE_USER', 'ROLE_ADMIN'])
class MembershipController {

    SpringSecurityService springSecurityService
    MembershipService membershipService

    static allowedMethods = [save: 'POST', cancel: 'POST']

    def index() {
        User user = springSecurityService.currentUser as User
        membershipService.syncMembershipStatuses(isAdmin(user) ? null : user)
        List<Membership> list = isAdmin(user) ? Membership.list(sort: 'startDate', order: 'desc') :
            Membership.findAllByUser(user, [sort: 'startDate', order: 'desc'])
        respond list, model: [isAdmin: isAdmin(user)]
    }

    def show(Long id) {
        User user = springSecurityService.currentUser as User
        membershipService.syncMembershipStatuses(isAdmin(user) ? null : user)
        Membership membership = membershipService.get(id)
        if (!membership) { notFound(); return }
        if (!isAdmin(user) && membership.user?.id != user.id) { render status: 403; return }
        Payment payment = Payment.findByPurposeAndTargetIdAndStatus('MEMBERSHIP', membership.id, 'COMPLETED')
        respond membership, model: [isAdmin: isAdmin(user), payment: payment]
    }

    @Secured(['ROLE_USER'])
    def create() {
        User user = springSecurityService.currentUser as User
        respond new Membership(user: user), model: membershipPricingModel()
    }

    @Secured(['ROLE_USER'])
    def save() {
        User user = springSecurityService.currentUser as User
        Date startDate = params.date('startDate', 'yyyy-MM-dd')
        Date endDate = params.date('endDate', 'yyyy-MM-dd')
        try {
            Membership membership = membershipService.createMembershipRequest(user, startDate, endDate)
            redirect controller: 'payment', action: 'checkout', params: [purpose: 'MEMBERSHIP', targetId: membership.id]
        } catch (Exception e) {
            flash.message = e.message
            render view: 'create', model: [membership: new Membership(user: user, startDate: startDate, endDate: endDate)] + membershipPricingModel()
        }
    }

    def cancel(Long id) {
        Membership membership = membershipService.get(id)
        if (!membership) { notFound(); return }
        User user = springSecurityService.currentUser as User
        boolean admin = isAdmin(user)
        if (!admin && membership.user?.id != user.id) { render status: 403; return }

        Payment completedPayment = Payment.findByPurposeAndTargetIdAndStatus(
            'MEMBERSHIP', membership.id, 'COMPLETED')
        if (!admin && completedPayment && membership.status in ['ACTIVE', 'SCHEDULED']) {
            flash.message = 'العضوية مدفوعة؛ تواصل مع الإدارة إذا احتجت إلغاءها أو معالجة الاسترداد.'
            redirect action: 'show', id: id
            return
        }

        membershipService.cancelMembership(id)
        flash.message = 'تم إلغاء العضوية.'
        redirect action: 'index'
    }

    private Map membershipPricingModel() {
        [
            pricePerDay  : membershipService.pricePerDay,
            discountTiers: membershipService.discountTiers
        ]
    }

    private boolean isAdmin(User user) { user?.authorities*.authority?.contains('ROLE_ADMIN') }
    protected void notFound() { render status: 404 }
}
