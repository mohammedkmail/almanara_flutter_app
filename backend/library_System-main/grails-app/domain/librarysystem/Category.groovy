package librarysystem

class Category {

    String name
    String description
    Boolean active = true

    static hasMany = [books: Book]

    static constraints = {
        name nullable: false, blank: false, unique: true, maxSize: 160
        description nullable: true, blank: true, maxSize: 3000
        active nullable: false
    }

    static mapping = {
        description type: 'text'
    }

    String toString() {
        name ?: 'قسم'
    }
}
