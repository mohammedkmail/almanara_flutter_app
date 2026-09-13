package librarysystem

class DigitalAccess {

    String accessType
    Date startDate = new Date()
    Date endDate
    String status = 'ACTIVE'
    BigDecimal paidAmount = 0.0

    User user
    Book book

    static constraints = {
        accessType nullable: false, blank: false, inList: ['RENTAL', 'PURCHASE']
        startDate nullable: false
        endDate nullable: true
        status nullable: false, blank: false, inList: ['ACTIVE', 'EXPIRED', 'REVOKED']
        paidAmount nullable: false, min: 0.0
        user nullable: false
        book nullable: false
    }

    String toString() {
        "${book?.title ?: 'كتاب'} — ${accessType == 'PURCHASE' ? 'شراء رقمي' : 'استئجار رقمي'}"
    }
}
