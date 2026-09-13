package librarysystem

class BookCopy {

    String copyCode
    String status = 'AVAILABLE'

    Book book

    static hasMany = [
        borrowings  : Borrowing,
        reservations: Reservation
    ]

    static constraints = {
        copyCode nullable: false, blank: false, unique: true, maxSize: 100
        status nullable: false, blank: false, inList: [
            'AVAILABLE',
            'BORROWED',
            'RESERVED',
            'LOST',
            'DAMAGED'
        ]
        book nullable: false
    }

    String toString() {
        "${book?.title ?: 'كتاب'} — ${copyCode}"
    }
}
