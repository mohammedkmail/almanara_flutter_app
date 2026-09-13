package librarysystem

import groovy.transform.EqualsAndHashCode
import grails.compiler.GrailsCompileStatic

@GrailsCompileStatic
@EqualsAndHashCode(includes='username')
class User implements Serializable {

    private static final long serialVersionUID = 1

    String username
    String fullName
    String password
    boolean enabled = true
    boolean accountExpired
    boolean accountLocked
    boolean passwordExpired

    Set<Role> getAuthorities() {
        (UserRole.findAllByUser(this) as List<UserRole>)*.role as Set<Role>
    }

    static constraints = {
        password nullable: false, blank: false, password: true
        username nullable: false, blank: false, unique: true
        fullName nullable: true, blank: true, maxSize: 120
    }

    static mapping = {
        table name: '`user`'
        password column: '`password`'
    }

    String getDisplayName() {
        fullName?.trim() ?: username ?: 'مستخدم'
    }

    String toString() {
        displayName
    }

    static hasMany = [
    borrowings      : Borrowing,
    reservations    : Reservation,
    memberships     : Membership,
    purchases       : Purchase,
    digitalAccesses : DigitalAccess,
    roomReservations: RoomReservation,
    payments        : Payment,
    checkoutIntents : CheckoutIntent
]
}
