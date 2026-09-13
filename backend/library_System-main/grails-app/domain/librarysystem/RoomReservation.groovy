package librarysystem

class RoomReservation {

    Date startTime
    Date endTime

    BigDecimal basePrice = 0.0
    BigDecimal discountPercentage = 0.0
    BigDecimal discountAmount = 0.0
    BigDecimal totalPrice

    String status = 'CONFIRMED'

    User user
    StudyRoom studyRoom

    Date dateCreated
    Date lastUpdated

    static constraints = {
        startTime nullable: false
        endTime nullable: false
        basePrice nullable: false, min: 0.0
        discountPercentage nullable: false, min: 0.0, max: 100.0
        discountAmount nullable: false, min: 0.0
        totalPrice nullable: false, min: 0.0
        status nullable: false, blank: false, inList: [
            'CONFIRMED',
            'COMPLETED',
            'CANCELLED'
        ]
        user nullable: false
        studyRoom nullable: false
    }

    String toString() {
        "${studyRoom?.displayName() ?: 'غرفة'} — ${startTime?.format('dd/MM/yyyy HH:mm')}"
    }
}
