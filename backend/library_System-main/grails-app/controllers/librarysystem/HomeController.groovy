package librarysystem

import grails.plugin.springsecurity.SpringSecurityService
import grails.plugin.springsecurity.annotation.Secured

@Secured(['permitAll'])
class HomeController {

    SpringSecurityService springSecurityService
    MembershipService membershipService
    HolidayCalendarService holidayCalendarService

    static allowedMethods = [
        index: 'GET'
    ]

    def index() {

        Date now = new Date()

        User currentUser =
            springSecurityService.currentUser as User

        boolean loggedIn =
            currentUser != null

        boolean isAdmin =
            hasRole(currentUser, 'ROLE_ADMIN')

        boolean isLibraryUser =
            hasRole(currentUser, 'ROLE_USER')


        /* =========================================================
           PUBLIC COLLECTION DATA
           ========================================================= */

        List<Book> featuredBooks =
            Book.findAllByActive(
                true,
                [
                    max  : 12,
                    sort : 'dateCreated',
                    order: 'desc'
                ]
            )

        Long totalBooks =
            Book.countByActive(true)

        Long totalAuthors =
            Author.count()

        Long totalCategories =
            Category.countByActive(true)

        Long totalDigitalBooks =
            Book.countByActiveAndDigitalAvailable(
                true,
                true
            )

        Long totalCopies =
            BookCopy.count()

        Long availableCopies =
            BookCopy.countByStatus('AVAILABLE')


        Role memberRole =
            Role.findByAuthority('ROLE_USER')

        Long totalMembers =
            memberRole ?
                UserRole.countByRole(memberRole) :
                0L


        /* =========================================================
           MOST BORROWED BOOKS
           ========================================================= */

        Map<Long, Integer> borrowCountByBookId =
            [:].withDefault { 0 }

        Borrowing.list().each { Borrowing borrowing ->

            Book borrowedBook =
                borrowing.bookCopy?.book

            if (borrowedBook?.active) {
                borrowCountByBookId[borrowedBook.id] =
                    borrowCountByBookId[borrowedBook.id] + 1
            }
        }

        List<Book> popularBooks =
            borrowCountByBookId
                .entrySet()
                .sort { Map.Entry<Long, Integer> first, Map.Entry<Long, Integer> second ->
                    second.value <=> first.value
                }
                .collect { Map.Entry<Long, Integer> entry ->
                    Book.get(entry.key)
                }
                .findAll { Book book ->
                    book?.active
                }
                .take(12)

        if (popularBooks.size() < 12) {

            featuredBooks.each { Book book ->

                if (
                    popularBooks.size() < 12 &&
                    !popularBooks*.id.contains(book.id)
                ) {
                    popularBooks << book
                }
            }
        }


        /* =========================================================
           USER DASHBOARD DATA
           ========================================================= */

        List<Borrowing> userBorrowings = []
        List<Reservation> userReservations = []
        List<RoomReservation> userRoomReservations = []

        Membership currentMembership = null
        boolean hasActiveMembership = false


        if (loggedIn && isLibraryUser && !isAdmin) {

            userBorrowings =
                Borrowing.findAllByUser(
                    currentUser,
                    [
                        sort : 'dueDate',
                        order: 'asc'
                    ]
                ).findAll { Borrowing borrowing ->

                    borrowing.status in [
                        'ACTIVE',
                        'OVERDUE'
                    ]

                }.take(4)


            userReservations =
                Reservation.findAllByUser(
                    currentUser,
                    [
                        sort : 'reservationDate',
                        order: 'desc'
                    ]
                ).findAll { Reservation reservation ->

                    reservation.status in [
                        'WAITING',
                        'READY',
                        'PAID',
                        'CONFIRMED'
                    ]

                }.take(4)


            userRoomReservations =
                RoomReservation.findAllByUser(
                    currentUser,
                    [
                        sort : 'startTime',
                        order: 'asc'
                    ]
                ).findAll { RoomReservation reservation ->

                    reservation.status == 'CONFIRMED' &&
                    reservation.endTime &&
                    reservation.endTime.after(now)

                }.take(3)


            currentMembership =
                membershipService
                    .currentActiveMembership(currentUser)

            hasActiveMembership =
                currentMembership != null
        }


        /* =========================================================
           ADMIN DASHBOARD DATA
           ========================================================= */

        Long activeBorrowingCount = 0L
        Long overdueBorrowingCount = 0L
        Long waitingReservationCount = 0L
        Long confirmedReservationCount = 0L
        Long confirmedRoomReservationCount = 0L

        List<Borrowing> urgentBorrowings = []


        if (loggedIn && isAdmin) {

            List<Borrowing> openBorrowings =
                Borrowing.list(
                    sort: 'dueDate',
                    order: 'asc'
                ).findAll { Borrowing borrowing ->

                    borrowing.status in [
                        'ACTIVE',
                        'OVERDUE'
                    ]
                }


            overdueBorrowingCount =
                openBorrowings.count { Borrowing borrowing ->

                    borrowing.status == 'OVERDUE' ||
                    (
                        borrowing.status == 'ACTIVE' &&
                        borrowing.dueDate &&
                        borrowing.dueDate.before(now)
                    )
                } as Long


            activeBorrowingCount =
                (openBorrowings.size() as Long) -
                overdueBorrowingCount


            waitingReservationCount =
                Reservation.countByStatus('WAITING')


            confirmedReservationCount =
                Reservation.countByStatusInList(['PAID', 'CONFIRMED'])


            confirmedRoomReservationCount =
                RoomReservation.findAllByStatus('CONFIRMED')
                    .count { RoomReservation reservation ->
                        reservation.endTime && reservation.endTime.after(now)
                    } as Long


            urgentBorrowings =
                openBorrowings.findAll { Borrowing borrowing ->

                    borrowing.status == 'OVERDUE' ||
                    (
                        borrowing.status == 'ACTIVE' &&
                        borrowing.dueDate &&
                        borrowing.dueDate.before(now)
                    )

                }.take(4)
        }


        /* =========================================================
           VIEW MODEL
           ========================================================= */

        [
            currentUser                 : currentUser,
            loggedIn                   : loggedIn,
            isAdmin                    : isAdmin,
            isLibraryUser              : isLibraryUser,

            featuredBooks              : featuredBooks,
            popularBooks               : popularBooks,
            borrowCountByBookId         : borrowCountByBookId,

            totalBooks                 : totalBooks,
            totalAuthors               : totalAuthors,
            totalCategories            : totalCategories,
            totalDigitalBooks          : totalDigitalBooks,
            totalCopies                : totalCopies,
            availableCopies            : availableCopies,
            totalMembers               : totalMembers,

            userBorrowings             : userBorrowings,
            userReservations           : userReservations,
            userRoomReservations       : userRoomReservations,
            currentMembership          : currentMembership,
            hasActiveMembership        : hasActiveMembership,

            activeBorrowingCount       : activeBorrowingCount,
            overdueBorrowingCount      : overdueBorrowingCount,
            waitingReservationCount    : waitingReservationCount,
            confirmedReservationCount  : confirmedReservationCount,
            confirmedRoomReservationCount: confirmedRoomReservationCount,
            urgentBorrowings           : urgentBorrowings,

            membershipPricePerDay      :
                membershipService.getPricePerDay(),
            membershipDiscountTiers    : membershipService.getDiscountTiers(),
            upcomingHolidays            : holidayCalendarService.upcomingHolidays(3)
        ]
    }


    private boolean hasRole(
        User user,
        String authority
    ) {

        if (!user) {
            return false
        }

        user.authorities.any { Role role ->
            role.authority == authority
        }
    }
}
