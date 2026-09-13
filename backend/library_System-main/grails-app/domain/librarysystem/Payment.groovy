package librarysystem

class Payment {

    String referenceCode
    String provider = 'BRAINTREE'
    String providerTransactionId
    String purpose
    Long targetId

    BigDecimal amount
    String currency = 'USD'

    String paymentMethod = 'CARD'
    String cardBrand
    String cardLastFour
    String cardholderName
    String channel = 'ONLINE'

    String status = 'COMPLETED'
    String notes
    Date paidAt
    Date dateCreated

    User user

    static constraints = {
        referenceCode nullable: false, blank: false, unique: true, maxSize: 100
        provider nullable: false, blank: false, inList: ['BRAINTREE', 'COUNTER']
        providerTransactionId nullable: true, blank: true, maxSize: 180
        purpose nullable: false, blank: false, inList: [
            'PURCHASE',
            'ROOM_RESERVATION',
            'BOOK_RESERVATION',
            'BORROWING',
            'DIGITAL_RENTAL',
            'MEMBERSHIP'
        ]
        targetId nullable: true, min: 1L
        amount nullable: false, min: 0.0
        currency nullable: false, blank: false, inList: ['USD']
        paymentMethod nullable: false, blank: false, inList: ['CARD', 'CASH']
        cardBrand nullable: true, blank: true, maxSize: 80
        cardLastFour nullable: true, blank: true, matches: /\d{4}/
        cardholderName nullable: true, blank: true, maxSize: 120
        channel nullable: false, blank: false, inList: ['ONLINE', 'COUNTER']
        status nullable: false, blank: false, inList: ['COMPLETED', 'FAILED', 'VOIDED', 'REFUNDED']
        notes nullable: true, blank: true, maxSize: 1500
        paidAt nullable: true
        user nullable: false
    }

    String toString() {
        referenceCode ?: 'عملية دفع'
    }
}
