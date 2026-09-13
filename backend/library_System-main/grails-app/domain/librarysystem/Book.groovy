package librarysystem

class Book {

    String title
    String isbn
    String description
    Integer publishYear

    String publisher
    Integer pageCount
    String language
    String externalCoverUrl
    String metadataSource

    byte[] coverData
    String coverContentType

    Integer physicalSaleStock = 0
    BigDecimal physicalSalePrice
    BigDecimal borrowingFee = 3.00

    Boolean digitalAvailable = false
    BigDecimal digitalPurchasePrice
    BigDecimal digitalRentalPrice
    Boolean membershipIncluded = false
    String digitalContent

    Boolean active = true

    Category category
    Author author

    Date dateCreated
    Date lastUpdated

    static hasMany = [
        copies         : BookCopy,
        reservations   : Reservation,
        purchases      : Purchase,
        digitalAccesses: DigitalAccess
    ]

    static constraints = {
        title nullable: false, blank: false, maxSize: 300
        isbn nullable: false, blank: false, unique: true, maxSize: 32
        description nullable: true, blank: true, maxSize: 8000
        publishYear nullable: true, min: 0

        publisher nullable: true, blank: true, maxSize: 220
        pageCount nullable: true, min: 1
        language nullable: true, blank: true, maxSize: 60
        externalCoverUrl nullable: true, blank: true, url: true, maxSize: 1000
        metadataSource nullable: true, blank: true, maxSize: 80

        coverData nullable: true
        coverContentType nullable: true, blank: true, maxSize: 120

        physicalSaleStock nullable: false, min: 0
        physicalSalePrice nullable: true, min: 0.0
        borrowingFee nullable: false, min: 0.01

        digitalAvailable nullable: false
        digitalPurchasePrice nullable: true, min: 0.0
        digitalRentalPrice nullable: true, min: 0.0
        membershipIncluded nullable: false
        digitalContent nullable: true

        active nullable: false
        category nullable: false
        author nullable: false
    }

    static mapping = {
        description type: 'text'
        digitalContent type: 'text'
        coverData sqlType: 'LONGBLOB'
    }

    String toString() {
        title ?: 'كتاب'
    }
}
