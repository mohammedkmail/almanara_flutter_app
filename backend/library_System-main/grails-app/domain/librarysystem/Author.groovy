package librarysystem

class Author {

    String name
    String biography
    String nationality

    byte[] imageData
    String imageContentType

    static hasMany = [books: Book]

    static constraints = {
        name nullable: false, blank: false, unique: true, maxSize: 180
        biography nullable: true, blank: true, maxSize: 6000
        nationality nullable: true, blank: true, maxSize: 120
        imageData nullable: true
        imageContentType nullable: true, blank: true, maxSize: 120
    }

    static mapping = {
        biography type: 'text'
        imageData sqlType: 'LONGBLOB'
    }

    String toString() {
        name ?: 'مؤلف'
    }
}