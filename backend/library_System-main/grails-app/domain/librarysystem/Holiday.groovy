package librarysystem

class Holiday {

    Date holidayDate
    String name
    String source = 'MANUAL'
    String externalId
    Boolean closed = true
    Boolean adminOverride = false
    String notes
    Date lastSyncedAt

    Date dateCreated
    Date lastUpdated

    static constraints = {
        holidayDate nullable: false, unique: true
        name nullable: false, blank: false, maxSize: 180
        source nullable: false, blank: false, inList: ['API', 'MANUAL', 'FALLBACK']
        externalId nullable: true, blank: true, maxSize: 180
        closed nullable: false
        adminOverride nullable: false
        notes nullable: true, blank: true, maxSize: 1000
        lastSyncedAt nullable: true
    }

    String toString() {
        name ?: 'عطلة'
    }
}
