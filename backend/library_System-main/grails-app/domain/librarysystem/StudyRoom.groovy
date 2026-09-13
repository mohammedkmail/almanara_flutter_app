package librarysystem

class StudyRoom {

    String roomNumber
    String name
    String description
    String location
    String features

    Integer capacity
    BigDecimal pricePerHour
    Boolean active = true

    byte[] imageData
    String imageContentType

    static hasMany = [
        reservations: RoomReservation
    ]

    static constraints = {
        roomNumber nullable: false, blank: false, unique: true, maxSize: 60
        name nullable: true, blank: true, maxSize: 160
        description nullable: true, blank: true, maxSize: 2500
        location nullable: true, blank: true, maxSize: 180
        features nullable: true, blank: true, maxSize: 2500
        capacity nullable: false, min: 1
        pricePerHour nullable: false, min: 0.0
        active nullable: false
        imageData nullable: true
        imageContentType nullable: true, blank: true, maxSize: 120
    }

    static mapping = {
        description type: 'text'
        features type: 'text'
        imageData sqlType: 'LONGBLOB'
    }

    String displayName() {
        name?.trim() ?: "غرفة ${roomNumber}"
    }

    String toString() {
        displayName()
    }
}
