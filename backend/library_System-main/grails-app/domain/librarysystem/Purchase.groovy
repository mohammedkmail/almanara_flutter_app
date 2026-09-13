package librarysystem

class Purchase {

    String purchaseType
    Integer quantity = 1

    BigDecimal unitPrice
    BigDecimal totalAmount

    Date purchaseDate = new Date()
    String status = 'PENDING'

    String fulfillmentMethod = 'PICKUP'
    String fulfillmentStatus = 'AWAITING_PAYMENT'
    String deliveryAddress
    String adminNotes

    User user
    Book book

    static constraints = {
        purchaseType nullable: false, blank: false, inList: ['PHYSICAL', 'DIGITAL']
        quantity nullable: false, min: 1
        unitPrice nullable: false, min: 0.0
        totalAmount nullable: false, min: 0.0
        purchaseDate nullable: false
        status nullable: false, blank: false, inList: ['PENDING', 'COMPLETED', 'FAILED', 'CANCELLED']
        fulfillmentMethod nullable: false, blank: false, inList: ['PICKUP', 'DELIVERY', 'DIGITAL']
        fulfillmentStatus nullable: false, blank: false, inList: [
            'AWAITING_PAYMENT',
            'PREPARING',
            'READY_FOR_PICKUP',
            'OUT_FOR_DELIVERY',
            'FULFILLED',
            'DIGITAL_GRANTED',
            'CANCELLED'
        ]
        deliveryAddress nullable: true, blank: true, maxSize: 1000
        adminNotes nullable: true, blank: true, maxSize: 1500
        user nullable: false
        book nullable: false
    }

    String toString() {
        "${book?.title ?: 'كتاب'} — ${user?.toString() ?: 'عضو'}"
    }
}
