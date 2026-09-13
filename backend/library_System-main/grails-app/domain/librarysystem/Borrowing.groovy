package librarysystem

class Borrowing {

    Date borrowDate = new Date()
    Date dueDate
    Date returnDate

    String status = 'ACTIVE'
    BigDecimal lateFee = 0.0
    String origin = 'COUNTER'
    String fulfillmentMethod = 'PICKUP'

    User user
    BookCopy bookCopy

    static constraints = {
        borrowDate nullable: false
        dueDate nullable: false
        returnDate nullable: true
        status nullable: false, blank: false, inList: [
            'ACTIVE',
            'RETURNED',
            'OVERDUE',
            'CANCELLED'
        ]
        lateFee nullable: false, min: 0.0
        origin nullable: false, blank: false, inList: ['COUNTER', 'RESERVATION']
        fulfillmentMethod nullable: false, blank: false, inList: ['PICKUP', 'DELIVERY']
        user nullable: false
        bookCopy nullable: false
    }

    String toString() {
        "${bookCopy?.book?.title ?: 'كتاب'} — ${user?.toString() ?: 'عضو'}"
    }
}
