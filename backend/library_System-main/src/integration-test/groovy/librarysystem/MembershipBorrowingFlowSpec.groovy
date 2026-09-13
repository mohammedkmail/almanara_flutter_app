package librarysystem

import grails.gorm.transactions.Rollback
import grails.testing.mixin.integration.Integration
import spock.lang.Specification

@Integration
@Rollback
class MembershipBorrowingFlowSpec extends Specification {

    MembershipService membershipService
    ReservationService reservationService
    BorrowingService borrowingService
    DigitalAccessService digitalAccessService
    BookService bookService

    void 'active membership removes physical borrowing fee while non member keeps book fee'() {
        given:
        Author author = new Author(name: 'Flow Author').save(flush: true, failOnError: true)
        Category category = new Category(name: 'Flow Category', active: true).save(flush: true, failOnError: true)
        Book book = new Book(
            title: 'Flow Book',
            isbn: 'FLOW-ISBN-001',
            borrowingFee: new BigDecimal('3.00'),
            physicalSaleStock: 0,
            digitalAvailable: false,
            membershipIncluded: false,
            active: true,
            author: author,
            category: category
        ).save(flush: true, failOnError: true)

        BookCopy memberCopy = new BookCopy(copyCode: 'FLOW-COPY-MEMBER', status: 'AVAILABLE', book: book)
            .save(flush: true, failOnError: true)
        BookCopy regularCopy = new BookCopy(copyCode: 'FLOW-COPY-REGULAR', status: 'AVAILABLE', book: book)
            .save(flush: true, failOnError: true)

        User member = new User(username: 'member-flow@library.test', password: 'secret', enabled: true)
            .save(flush: true, failOnError: true)
        User regular = new User(username: 'regular-flow@library.test', password: 'secret', enabled: true)
            .save(flush: true, failOnError: true)

        Date today = new Date()
        Calendar endCalendar = Calendar.getInstance()
        endCalendar.time = today
        endCalendar.add(Calendar.DAY_OF_MONTH, 60)
        new Membership(
            user: member,
            startDate: today,
            endDate: endCalendar.time,
            status: 'ACTIVE',
            price: new BigDecimal('57.00')
        ).save(flush: true, failOnError: true)

        expect:
        membershipService.borrowingFeeFor(member, book) == BigDecimal.ZERO
        membershipService.borrowingFeeFor(regular, book) == new BigDecimal('3.00')

        when:
        Reservation memberReservation = reservationService.createReservation(member, book)

        then:
        memberReservation.status == 'READY'
        memberReservation.assignedCopy.id == memberCopy.id
        memberReservation.feeAmount == BigDecimal.ZERO
        memberReservation.fulfillmentStatus == 'AWAITING_CONFIRM'

        when:
        reservationService.updateFulfillmentPreference(memberReservation.id, 'PICKUP', null)
        reservationService.confirmIncludedBorrowing(memberReservation.id)
        Borrowing borrowing = borrowingService.borrowReservation(memberReservation.id)
        memberReservation.refresh()
        memberCopy.refresh()

        then:
        borrowing.status == 'ACTIVE'
        memberReservation.status == 'FULFILLED'
        memberCopy.status == 'BORROWED'

        when:
        Reservation regularReservation = reservationService.createReservation(regular, book)

        then:
        regularReservation.status == 'READY'
        regularReservation.assignedCopy.id == regularCopy.id
        regularReservation.feeAmount == new BigDecimal('3.00')
        regularReservation.fulfillmentStatus == 'AWAITING_PAYMENT'
    }

    void 'future paid membership is scheduled and does not grant benefits early'() {
        given:
        User user = new User(username: 'future-member@library.test', password: 'secret', enabled: true)
            .save(flush: true, failOnError: true)

        Calendar start = Calendar.getInstance()
        start.add(Calendar.DAY_OF_MONTH, 10)
        Calendar end = Calendar.getInstance()
        end.add(Calendar.DAY_OF_MONTH, 40)

        Membership request = membershipService.createMembershipRequest(user, start.time, end.time)

        when:
        Membership activated = membershipService.activateMembership(request.id)

        then:
        activated.status == 'SCHEDULED'
        !membershipService.hasActiveMembership(user)
    }

    void 'digital rental uses calendar date arithmetic compatible with current Groovy runtime'() {
        given:
        Author author = new Author(name: 'Digital Flow Author').save(flush: true, failOnError: true)
        Category category = new Category(name: 'Digital Flow Category', active: true).save(flush: true, failOnError: true)
        Book book = new Book(
            title: 'Digital Flow Book',
            isbn: 'FLOW-ISBN-DIGITAL',
            borrowingFee: new BigDecimal('3.00'),
            physicalSaleStock: 0,
            digitalAvailable: true,
            digitalRentalPrice: new BigDecimal('2.00'),
            membershipIncluded: false,
            active: true,
            author: author,
            category: category
        ).save(flush: true, failOnError: true)
        User user = new User(username: 'digital-flow@library.test', password: 'secret', enabled: true)
            .save(flush: true, failOnError: true)

        when:
        DigitalAccess access = digitalAccessService.grantPaidRentalAccess(
            user, book, 2, new BigDecimal('4.00'))

        then:
        access.status == 'ACTIVE'
        access.endDate.after(access.startDate)
    }

    void 'catalog search accepts numeric text and searches title isbn author and category'() {
        given:
        Author author = new Author(name: 'Search Author 9').save(flush: true, failOnError: true)
        Category category = new Category(name: 'Search Category').save(flush: true, failOnError: true)
        new Book(
            title: 'Searchable Book',
            isbn: 'SEARCH-9001',
            borrowingFee: new BigDecimal('3.00'),
            physicalSaleStock: 0,
            digitalAvailable: false,
            membershipIncluded: false,
            active: true,
            author: author,
            category: category
        ).save(flush: true, failOnError: true)

        when:
        Map result = bookService.searchCatalog('9', false, 12, 0)

        then:
        result.total >= 1
        (result.books as List<Book>)*.isbn.contains('SEARCH-9001')
    }

    void 'available copies respect the oldest waiting reservation first'() {
        given:
        Author author = new Author(name: 'Queue Author').save(flush: true, failOnError: true)
        Category category = new Category(name: 'Queue Category').save(flush: true, failOnError: true)
        Book book = new Book(
            title: 'Queue Book',
            isbn: 'QUEUE-ISBN-001',
            borrowingFee: new BigDecimal('3.00'),
            physicalSaleStock: 0,
            digitalAvailable: false,
            membershipIncluded: false,
            active: true,
            author: author,
            category: category
        ).save(flush: true, failOnError: true)
        User first = new User(username: 'queue-first@library.test', password: 'secret', enabled: true)
            .save(flush: true, failOnError: true)
        User second = new User(username: 'queue-second@library.test', password: 'secret', enabled: true)
            .save(flush: true, failOnError: true)

        Reservation firstReservation = reservationService.createReservation(first, book)
        assert firstReservation.status == 'WAITING'

        BookCopy copy = new BookCopy(copyCode: 'QUEUE-COPY-001', status: 'AVAILABLE', book: book)
            .save(flush: true, failOnError: true)

        when:
        Reservation secondReservation = reservationService.createReservation(second, book)
        firstReservation.refresh()
        secondReservation.refresh()
        copy.refresh()

        then:
        firstReservation.status == 'READY'
        firstReservation.assignedCopy.id == copy.id
        secondReservation.status == 'WAITING'
        secondReservation.assignedCopy == null
        copy.status == 'RESERVED'
    }

    void 'stale pending membership cannot be paid after its requested start date passes'() {
        given:
        User user = new User(username: 'stale-member@library.test', password: 'secret', enabled: true)
            .save(flush: true, failOnError: true)
        Calendar start = Calendar.getInstance()
        start.add(Calendar.DAY_OF_MONTH, -1)
        Calendar end = Calendar.getInstance()
        end.add(Calendar.DAY_OF_MONTH, 30)
        Membership membership = new Membership(
            user: user,
            startDate: start.time,
            endDate: end.time,
            status: 'PENDING',
            price: new BigDecimal('30.00')
        ).save(flush: true, failOnError: true)

        when:
        membershipService.validatePendingMembershipForPayment(membership)

        then:
        thrown(IllegalStateException)
    }

    void 'membership included digital access is not granted for an archived book'() {
        given:
        Author author = new Author(name: 'Archived Digital Author').save(flush: true, failOnError: true)
        Category category = new Category(name: 'Archived Digital Category', active: true).save(flush: true, failOnError: true)
        Book book = new Book(
            title: 'Archived Digital Book',
            isbn: 'ARCHIVED-DIGITAL-001',
            borrowingFee: new BigDecimal('3.00'),
            physicalSaleStock: 0,
            digitalAvailable: true,
            digitalRentalPrice: new BigDecimal('1.00'),
            membershipIncluded: true,
            active: false,
            author: author,
            category: category
        ).save(flush: true, failOnError: true)
        User user = new User(username: 'archived-digital-member@library.test', password: 'secret', enabled: true)
            .save(flush: true, failOnError: true)
        Date today = new Date()
        Calendar end = Calendar.getInstance()
        end.add(Calendar.DAY_OF_MONTH, 30)
        new Membership(user: user, startDate: today, endDate: end.time, status: 'ACTIVE', price: new BigDecimal('30.00'))
            .save(flush: true, failOnError: true)

        expect:
        !digitalAccessService.canAccessBook(user, book)
    }

}
