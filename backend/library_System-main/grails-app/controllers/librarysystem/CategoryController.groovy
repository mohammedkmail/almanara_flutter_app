package librarysystem

import grails.plugin.springsecurity.SpringSecurityService
import grails.plugin.springsecurity.annotation.Secured
import grails.validation.ValidationException

class CategoryController {

    CategoryService categoryService
    SpringSecurityService springSecurityService

    static allowedMethods = [
        save  : 'POST',
        update: 'PUT',
        delete: 'DELETE'
    ]

    @Secured(['permitAll'])
    def index(Integer max) {

        int pageSize = Math.min(Math.max(max ?: 12, 1), 100)
        int offset = Math.max(params.int('offset') ?: 0, 0)

        User currentUser =
            springSecurityService.currentUser as User

        boolean admin =
            isAdmin(currentUser)

        List<Category> categoryList
        Long categoryCount

        if (admin) {

            categoryList =
                Category.list(
                    max: pageSize,
                    offset: offset,
                    sort: 'name',
                    order: 'asc'
                )

            categoryCount =
                Category.count()

        } else {

            categoryList =
                Category.findAllByActive(
                    true,
                    [
                        max   : pageSize,
                        offset: offset,
                        sort  : 'name',
                        order : 'asc'
                    ]
                )

            categoryCount =
                Category.countByActive(true)
        }

        respond categoryList,
            model: [
                categoryCount: categoryCount,
                isAdmin      : admin
            ]
    }

    @Secured(['permitAll'])
    def show(Long id) {

        Category category =
            categoryService.get(id)

        if (!category) {
            notFound()
            return
        }

        User currentUser =
            springSecurityService.currentUser as User

        boolean admin =
            isAdmin(currentUser)

        if (
            category.active != true &&
            !admin
        ) {
            notFound()
            return
        }

        List<Book> bookList

        if (admin) {

            bookList =
                Book.findAllByCategory(
                    category,
                    [
                        sort : 'title',
                        order: 'asc'
                    ]
                )

        } else {

            bookList =
                Book.findAllByCategoryAndActive(
                    category,
                    true,
                    [
                        sort : 'title',
                        order: 'asc'
                    ]
                )
        }

        respond category,
            model: [
                bookList: bookList,
                isAdmin : admin
            ]
    }

    @Secured(['ROLE_ADMIN'])
    def create() {

        respond new Category(params)
    }

    @Secured(['ROLE_ADMIN'])
    def save(Category category) {

        if (!category) {
            notFound()
            return
        }

        try {

            categoryService.save(category)

        } catch (ValidationException e) {

            flash.message =
                'تعذر إضافة القسم. راجع الحقول المطلوبة.'

            respond category.errors,
                view: 'create'

            return
        }

        flash.message =
            'تمت إضافة القسم بنجاح.'

        redirect action: 'show',
                 id: category.id
    }

    @Secured(['ROLE_ADMIN'])
    def edit(Long id) {

        Category category =
            categoryService.get(id)

        if (!category) {
            notFound()
            return
        }

        respond category
    }

    @Secured(['ROLE_ADMIN'])
    def update(Category category) {

        if (!category) {
            notFound()
            return
        }

        try {

            categoryService.save(category)

        } catch (ValidationException e) {

            flash.message =
                'تعذر تحديث القسم. راجع الحقول المطلوبة.'

            respond category.errors,
                view: 'edit'

            return
        }

        flash.message =
            'تم تحديث القسم بنجاح.'

        redirect action: 'show',
                 id: category.id
    }

    @Secured(['ROLE_ADMIN'])
    def delete(Long id) {

        if (!id) {
            notFound()
            return
        }

        Category category =
            categoryService.get(id)

        if (!category) {
            notFound()
            return
        }

        Long bookCount =
            Book.countByCategory(category)

        if (bookCount > 0) {

            category.active = false

            categoryService.save(category)

            flash.message =
                'القسم مرتبط بكتب موجودة، لذلك تم تعطيله بدل حذفه.'

            redirect action: 'index'
            return
        }

        categoryService.delete(id)

        flash.message =
            'تم حذف القسم بنجاح.'

        redirect action: 'index'
    }

    private boolean isAdmin(User user) {

        if (!user) {
            return false
        }

        return user.authorities?.any {
            it.authority == 'ROLE_ADMIN'
        } ?: false
    }

    protected void notFound() {

        flash.message =
            'القسم غير موجود.'

        redirect action: 'index'
    }
}
