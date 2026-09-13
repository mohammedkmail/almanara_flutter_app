package librarysystem

import grails.gorm.transactions.Transactional

@Transactional
class RegisterService {

    User registerUser(
        String username,
        String fullName,
        String password
    ) {

        Role role =
            Role.findByAuthority('ROLE_USER')

        if (!role) {
            throw new IllegalStateException(
                'دور المستخدم غير مهيأ في النظام.'
            )
        }

        User user =
            new User(
                username: username,
                fullName: fullName?.trim(),
                password: password,
                enabled: true
            )

        if (!user.save(flush: true)) {
            throw new IllegalArgumentException(
                user.errors.allErrors
                    .collect { it.defaultMessage }
                    .join(', ')
            )
        }

        UserRole.create(
            user,
            role,
            true
        )

        user
    }
}