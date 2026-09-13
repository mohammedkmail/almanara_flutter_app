package librarysystem

class Reservation {

    Date reservationDate = new Date()
    String status = 'WAITING'
    Date readyUntil
    Date paidAt

    String fulfillmentMethod = 'PICKUP'
    String fulfillmentStatus = 'WAITING_FOR_COPY'
    String deliveryAddress

    BigDecimal feeAmount = 0.0

    User user
    Book book
    BookCopy assignedCopy

    static constraints = {
        reservationDate nullable: false
        status nullable: false, blank: false, inList: [
            'WAITING',
            'READY',
            'PAID',
            'CONFIRMED',
            'FULFILLED',
            'EXPIRED',
            'CANCELLED'
        ]
        readyUntil nullable: true
        paidAt nullable: true
        fulfillmentMethod nullable: false, blank: false, inList: ['PICKUP', 'DELIVERY']
        fulfillmentStatus nullable: false, blank: false, inList: [
            'WAITING_FOR_COPY',
            'AWAITING_PAYMENT',
            'AWAITING_CONFIRM',
            'READY_FOR_PICKUP',
            'PREPARING_DELIVERY',
            'OUT_FOR_DELIVERY',
            'HANDED_OVER',
            'CANCELLED'
        ]
        deliveryAddress nullable: true, blank: true, maxSize: 1000
        feeAmount nullable: false, min: 0.0
        user nullable: false
        book nullable: false
        assignedCopy nullable: true
    }

    String toString() {
        "${book?.title ?: 'كتاب'} — ${user?.toString() ?: 'عضو'}"
    }
}
