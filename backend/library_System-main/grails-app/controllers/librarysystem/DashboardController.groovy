package librarysystem

import grails.plugin.springsecurity.SpringSecurityService
import grails.plugin.springsecurity.annotation.Secured

@Secured(['ROLE_USER', 'ROLE_ADMIN'])
class DashboardController {

    SpringSecurityService springSecurityService
    BorrowingService borrowingService
    PurchaseService purchaseService
    ReservationService reservationService
    RoomReservationService roomReservationService
    MembershipService membershipService

    def index() {
        User currentUser = springSecurityService.currentUser as User
        boolean admin = currentUser?.authorities*.authority?.contains('ROLE_ADMIN')

        if (admin) {
            render view: 'index', model: [
                isAdmin                  : true,
                totalBooks               : Book.count(),
                activeBorrowings         : borrowingService.countActiveBorrowings(),
                overdueBorrowings        : borrowingService.countOverdueBorrowings(),
                waitingReservations      : reservationService.countWaitingReservations(),
                completedPurchases       : purchaseService.countCompletedPurchases(),
                totalSales               : purchaseService.totalSales(),
                confirmedRoomReservations: roomReservationService.countConfirmedReservations()
            ]
            return
        }

        Date now = new Date()
        List<Borrowing> borrowings = Borrowing.findAllByUser(currentUser)
        List<Reservation> reservations = Reservation.findAllByUser(currentUser)
        List<Purchase> purchases = Purchase.findAllByUser(currentUser)
        List<RoomReservation> roomReservations = RoomReservation.findAllByUser(currentUser)

        Membership activeMembership = membershipService.currentActiveMembership(currentUser)

        Set<Long> digitalBookIds = DigitalAccess.findAllByUser(currentUser)
            .findAll { DigitalAccess access ->
                access.status == 'ACTIVE' && (!access.endDate || access.endDate.after(now)) && access.book
            }
            .collect { DigitalAccess access -> access.book.id as Long }
            .toSet()

        if (activeMembership) {
            digitalBookIds.addAll(
                Book.findAllByMembershipIncludedAndDigitalAvailableAndActive(
                    true, true, true
                )*.id.collect { it as Long }
            )
        }

        render view: 'index', model: [
            isAdmin                  : false,
            currentUser              : currentUser,
            activeBorrowings         : borrowings.count { it.status in ['ACTIVE', 'OVERDUE'] } as Long,
            overdueBorrowings        : borrowings.count {
                it.status == 'OVERDUE' || (it.status == 'ACTIVE' && it.dueDate && it.dueDate.before(now))
            } as Long,
            activeReservations       : reservations.count { it.status in ['WAITING', 'READY', 'PAID', 'CONFIRMED'] } as Long,
            completedPurchases       : purchases.count { it.status == 'COMPLETED' } as Long,
            confirmedRoomReservations: roomReservations.count {
                it.status == 'CONFIRMED' && it.endTime && it.endTime.after(now)
            } as Long,
            digitalAccessCount       : digitalBookIds.size() as Long,
            activeMembership         : activeMembership
        ]
    }
}
