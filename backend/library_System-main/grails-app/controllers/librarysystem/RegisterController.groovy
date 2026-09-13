package librarysystem

import grails.plugin.springsecurity.annotation.Secured

@Secured(['permitAll'])
class RegisterController {

    RegisterService registerService

    static allowedMethods = [
        save: 'POST'
    ]

    def create() {

        respond new User()
    }

    def save() {

        String username =
            params.username?.trim()

        String fullName =
            params.fullName?.trim()

        String password =
            params.password

        String confirmPassword =
            params.confirmPassword


        if (!username) {

            flash.message =
                'اسم المستخدم مطلوب.'

            respond new User(
                username: username,
                fullName: fullName
            ),
            view: 'create'

            return
        }


        if (!password) {

            flash.message =
                'كلمة المرور مطلوبة.'

            respond new User(
                username: username,
                fullName: fullName
            ),
            view: 'create'

            return
        }


        if (password != confirmPassword) {

            flash.message =
                'كلمتا المرور غير متطابقتين.'

            respond new User(
                username: username,
                fullName: fullName
            ),
            view: 'create'

            return
        }


        if (User.findByUsername(username)) {

            flash.message =
                'اسم المستخدم مسجل مسبقًا.'

            respond new User(
                username: username,
                fullName: fullName
            ),
            view: 'create'

            return
        }


        try {

            registerService.registerUser(
                username,
                fullName,
                password
            )

            flash.message =
                'تم إنشاء الحساب بنجاح. يمكنك تسجيل الدخول الآن.'

            redirect controller: 'login',
                     action: 'auth'

        } catch (
            IllegalArgumentException |
            IllegalStateException e
        ) {

            flash.message = e.message

            respond new User(
                username: username,
                fullName: fullName
            ),
            view: 'create'
        }
    }
}