package librarysystem

class CheckoutIntent {

    String token
    String purpose
    BigDecimal amount
    String payloadJson
    String title
    String description
    Date expiresAt
    String status = 'OPEN'

    User user

    Date dateCreated
    Date lastUpdated

    static constraints = {
        token nullable: false, blank: false, unique: true, maxSize: 80
        purpose nullable: false, blank: false, inList: [
            'ROOM_RESERVATION',
            'DIGITAL_RENTAL',
            'MEMBERSHIP'
        ]
        amount nullable: false, min: 0.0
        payloadJson nullable: false, blank: false, maxSize: 8000
        title nullable: false, blank: false, maxSize: 180
        description nullable: true, blank: true, maxSize: 500
        expiresAt nullable: false
        status nullable: false, blank: false, inList: ['OPEN', 'COMPLETED', 'CANCELLED', 'EXPIRED']
        user nullable: false
    }

    static mapping = {
        payloadJson type: 'text'
    }

    String toString() {
        title ?: purpose
    }
}
