package librarysystem

class DiscountRule {

    String name
    Integer minHours
    Integer maxHours
    BigDecimal percentage
    Integer priority = 100
    Boolean active = true

    Date dateCreated
    Date lastUpdated

    static constraints = {
        name nullable: false, blank: false, maxSize: 120
        minHours nullable: false, min: 0
        maxHours nullable: true, min: 1, validator: { Integer value, DiscountRule obj ->
            if (value != null && obj.minHours != null && value < obj.minHours) {
                return 'discountRule.maxHours.invalidRange'
            }
        }
        percentage nullable: false, min: 0.0, max: 100.0
        priority nullable: false, min: 0
        active nullable: false
    }

    String toString() {
        "${name} (${percentage}%)"
    }
}
