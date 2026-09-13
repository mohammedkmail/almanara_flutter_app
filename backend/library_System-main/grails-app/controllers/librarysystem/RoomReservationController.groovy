package librarysystem

import grails.converters.JSON
import grails.plugin.springsecurity.SpringSecurityService
import grails.plugin.springsecurity.annotation.Secured

@Secured(['ROLE_USER', 'ROLE_ADMIN'])
class RoomReservationController {

    SpringSecurityService springSecurityService
    RoomReservationService roomReservationService
    HolidayCalendarService holidayCalendarService
    CheckoutIntentService checkoutIntentService

    static allowedMethods = [save: 'POST', quote: 'POST', cancel: 'POST']

    def index() {
        roomReservationService.updateCompletedReservations()
        User currentUser = springSecurityService.currentUser as User
        List<RoomReservation> reservations = isAdmin(currentUser) ?
            RoomReservation.list(sort: 'startTime', order: 'desc') :
            RoomReservation.findAllByUser(currentUser, [sort: 'startTime', order: 'desc'])
        respond reservations, model: [isAdmin: isAdmin(currentUser)]
    }

    def show(Long id) {
        RoomReservation reservation = roomReservationService.get(id)
        if (!reservation) { notFound(); return }
        User currentUser = springSecurityService.currentUser as User
        if (!isAdmin(currentUser) && reservation.user?.id != currentUser.id) { render status: 403; return }
        Payment payment = Payment.findByPurposeAndTargetIdAndStatus('ROOM_RESERVATION', reservation.id, 'COMPLETED')
        respond reservation, model: [isAdmin: isAdmin(currentUser), payment: payment]
    }

    @Secured(['ROLE_USER'])
    def create() {
        holidayCalendarService.ensureYearLoaded(Calendar.getInstance().get(Calendar.YEAR))
        respond new RoomReservation(), model: [
            activeRooms: StudyRoom.findAllByActive(true, [sort: 'roomNumber', order: 'asc']),
            upcomingHolidays: holidayCalendarService.upcomingHolidays(8)
        ]
    }

    @Secured(['ROLE_USER'])
    def quote() {
        User user = springSecurityService.currentUser as User
        try {
            StudyRoom room = StudyRoom.get(params.long('studyRoomId'))
            Date start = params.date('startTime', "yyyy-MM-dd'T'HH:mm")
            Date end = params.date('endTime', "yyyy-MM-dd'T'HH:mm")
            Map pricing = roomReservationService.quote(user, room, start, end)
            render([ok: true, basePrice: pricing.basePrice, discountPercentage: pricing.percentage,
                    discountAmount: pricing.discountAmount, totalPrice: pricing.totalPrice,
                    durationHours: pricing.durationHours, ruleName: pricing.rule?.name] as JSON)
        } catch (Exception e) {
            render([ok: false, message: e.message] as JSON)
        }
    }

    @Secured(['ROLE_USER'])
    def save() {
        User user = springSecurityService.currentUser as User
        StudyRoom room = StudyRoom.get(params.long('studyRoom.id'))
        Date start = params.date('startTime', "yyyy-MM-dd'T'HH:mm")
        Date end = params.date('endTime', "yyyy-MM-dd'T'HH:mm")
        try {
            Map pricing = roomReservationService.quote(user, room, start, end)
            CheckoutIntent intent = checkoutIntentService.createIntent(
                user, 'ROOM_RESERVATION', pricing.totalPrice,
                room?.displayName() ?: 'حجز غرفة دراسة',
                'لا يُنشأ الحجز النهائي إلا بعد نجاح الدفع.',
                [studyRoomId: room.id, startTime: start.time, endTime: end.time,
                 basePrice: pricing.basePrice, discountPercentage: pricing.percentage,
                 discountAmount: pricing.discountAmount]
            )
            redirect controller: 'payment', action: 'checkout', params: [purpose: 'ROOM_RESERVATION', checkoutToken: intent.token]
        } catch (IllegalArgumentException | IllegalStateException e) {
            flash.message = e.message
            render view: 'create', model: [roomReservation: new RoomReservation(user: user, studyRoom: room, startTime: start, endTime: end),
                activeRooms: StudyRoom.findAllByActive(true, [sort: 'roomNumber', order: 'asc']),
                upcomingHolidays: holidayCalendarService.upcomingHolidays(8)]
        }
    }

    def cancel(Long id) {
        RoomReservation reservation = roomReservationService.get(id)
        if (!reservation) { notFound(); return }
        User currentUser = springSecurityService.currentUser as User
        if (!isAdmin(currentUser) && reservation.user?.id != currentUser.id) { render status: 403; return }
        try {
            roomReservationService.cancelReservation(id)
            flash.message = 'تم إلغاء حجز الغرفة.'
            redirect action: 'index'
        } catch (Exception e) {
            flash.message = e.message
            redirect action: 'show', id: id
        }
    }

    private boolean isAdmin(User user) { user?.authorities*.authority?.contains('ROLE_ADMIN') }
    protected void notFound() { render status: 404 }
}
