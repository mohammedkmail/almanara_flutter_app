package librarysystem

class Membership {

    Date startDate
    Date endDate
    String status = 'PENDING'
    BigDecimal price

    User user

    static constraints = {
        startDate nullable: false
        endDate nullable: false
        status nullable: false, blank: false, inList: ['PENDING', 'SCHEDULED', 'ACTIVE', 'EXPIRED', 'CANCELLED']
        price nullable: false, min: 0.0
        user nullable: false
    }

    String toString() {
        "عضوية ${user?.toString() ?: ''}"
    }
}
