# Final UBS Review Notes — Current Logic Review

This review is based only on the latest project archive `library_System-main (4).zip`.

## Final business model

- Browsing the library/catalog is free.
- A registered enabled user can reserve/borrow a physical book.
- Non-member: pays the book's configured `borrowingFee`.
- Active member: physical borrowing fee is `0`.
- Late fees remain separate and still apply after the due date.
- Private study rooms remain a separate paid service.
- Membership also includes selected digital books and duration-based subscription discounts.

## Membership rules

- 30+ days: 5%
- 90+ days: 10%
- 180+ days: 15%
- 365+ days: 20%
- Starts today after payment -> `ACTIVE`.
- Starts in the future after payment -> `SCHEDULED`.
- Expired memberships -> `EXPIRED`.
- Scheduled memberships do not grant benefits before their start date.
- Overlapping active/scheduled membership periods are rejected before checkout and rechecked when payment finalizes.

## Physical reservation / borrowing flow

```text
WAITING -> READY -> PAID      -> FULFILLED   (non-member / borrowing fee paid)
                 -> CONFIRMED -> FULFILLED   (active member / no borrowing fee)
```

- `READY` fees are recalculated from current membership state before confirmation/payment.
- A zero-fee membership reservation does not create a fake Braintree transaction.
- Counter borrowing also creates no borrowing Payment when the active member's fee is zero.
- Book-copy assignment locks the copy before marking it `RESERVED` to reduce concurrent double-allocation risk.
- Available copies are allocated to the oldest `WAITING` reservation first, and direct counter borrowing cannot bypass an older waiting reservation.

## Search and API consistency

- Fixed `/book/index?search=...` Hibernate 500 caused by passing a GString-like HQL expression; the query is now built as a normal `String` with named parameters.
- Book catalog pagination clamps invalid max/offset values.
- REST book visibility follows browser rules: normal users cannot see inactive books, admins can.
- Book delete/archive business logic is centralized in `BookService`: books with operational history are deactivated rather than physically deleted, including through REST.

## Other logic fixes

- Replaced incompatible `Date + Integer` arithmetic in digital rental expiry with `Calendar`.
- Inactive/archived books cannot start new digital rentals or receive membership-included access; existing purchased/rental ownership remains readable.
- User dashboard digital count now includes membership-included digital books, not only explicit DigitalAccess rows.
- Payment-page membership cancellation cannot be abused to cancel an already-paid active/scheduled membership.
- Demo seed accounts are disabled in production.
- `/shutdown` is no longer public; it requires admin access.
- Removed stale `.save` generated backup test file from the final package.

## Stable integrations intentionally preserved

No functional rewrite was made to these working integrations:

- `grails-app/services/BraintreeGatewayService.groovy`
- `grails-app/services/BookMetadataService.groovy`
- `grails-app/services/HolidayCalendarService.groovy`
- `grails-app/services/RoomReservationService.groovy`
- `grails-app/controllers/librarysystem/RoomReservationController.groovy`
- `grails-app/views/payment/checkout.gsp`

The existing Braintree / Google Books + Open Library / holiday-calendar / study-room flow remains the base implementation.

## Verification

An integration spec `MembershipBorrowingFlowSpec` covers:

- active-member zero borrowing fee vs non-member fee;
- `READY -> CONFIRMED -> FULFILLED` member flow;
- future membership stays `SCHEDULED` and grants no early benefit;
- digital-rental expiry works without `Date.plus(Integer)`;
- numeric/text catalog search uses the corrected shared query;
- FIFO reservation allocation gives an available copy to the oldest waiting request.

Run on the project machine before the demo:

```bash
chmod +x gradlew
./gradlew clean test
./gradlew integrationTest
./gradlew bootRun
```
