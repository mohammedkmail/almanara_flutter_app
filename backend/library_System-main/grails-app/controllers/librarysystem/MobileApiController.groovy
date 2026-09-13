package librarysystem

import grails.converters.JSON
import grails.plugin.springsecurity.SpringSecurityService
import grails.plugin.springsecurity.annotation.Secured
import grails.validation.ValidationException

@Secured(['ROLE_USER', 'ROLE_ADMIN'])
class MobileApiController {
    SpringSecurityService springSecurityService
    ReservationService reservationService
    static allowedMethods = [me: 'GET', reservations: 'GET', reserve: 'POST']

    def me() {
        User user = springSecurityService.currentUser as User
        render([id: user.id, username: user.username, fullName: user.displayName,
                roles: user.authorities*.authority] as JSON)
    }

    @Secured(['ROLE_USER'])
    def reservations() {
        reservationService.expireReadyReservations()
        User user = springSecurityService.currentUser as User
        render([data: Reservation.findAllByUser(user, [sort: 'reservationDate', order: 'desc'])
            .collect { toMap(it) }] as JSON)
    }

    @Secured(['ROLE_USER'])
    def reserve() {
        def body
        try {
            body = request.JSON
        } catch (Exception ignored) {
            respondError(400, 'صيغة JSON غير صحيحة.'); return
        }
        String rawId = body instanceof Map ? body.bookId?.toString() : null
        if (!rawId?.isLong() || rawId.toLong() <= 0) {
            respondError(400, 'معرّف الكتاب مطلوب.'); return
        }
        Book book = Book.get(rawId.toLong())
        if (!book || !book.active) {
            respondError(404, 'الكتاب غير موجود.'); return
        }
        try {
            // Identity comes only from the authenticated principal, never the JSON body.
            Reservation result = reservationService.createReservation(
                springSecurityService.currentUser as User, book)
            render(status: 201, contentType: 'application/json', text: toMap(result) as JSON)
        } catch (ValidationException ignored) {
            respondError(422, 'تعذر التحقق من بيانات الحجز.')
        } catch (IllegalArgumentException e) {
            respondError(400, e.message)
        } catch (IllegalStateException e) {
            respondError(409, e.message)
        }
    }

    private Map toMap(Reservation item) {
        [id: item.id, bookId: item.book.id, bookTitle: item.book.title,
         status: item.status, fulfillmentStatus: item.fulfillmentStatus,
         feeAmount: item.feeAmount, reservationDate: item.reservationDate,
         readyUntil: item.readyUntil]
    }

    private void respondError(int code, String message) {
        render(status: code, contentType: 'application/json', text: [message: message] as JSON)
    }
}
