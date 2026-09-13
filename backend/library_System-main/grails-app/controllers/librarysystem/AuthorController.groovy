package librarysystem

import grails.plugin.springsecurity.SpringSecurityService
import grails.plugin.springsecurity.annotation.Secured
import grails.validation.ValidationException
import org.springframework.web.multipart.MultipartFile

import static org.springframework.http.HttpStatus.NOT_FOUND

class AuthorController {

    AuthorService authorService
    SpringSecurityService springSecurityService

    static allowedMethods = [save: 'POST', update: 'PUT', delete: 'DELETE']

    @Secured(['permitAll'])
    def index(Integer max) {
        int pageSize = Math.min(Math.max(max ?: 12, 1), 100)
        int offset = Math.max(params.int('offset') ?: 0, 0)
        boolean admin = isAdmin(springSecurityService.currentUser as User)
        respond Author.list(max: pageSize, offset: offset, sort: 'name', order: 'asc'),
            model: [authorCount: Author.count(), isAdmin: admin]
    }

    @Secured(['permitAll'])
    def show(Long id) {
        Author author = authorService.get(id)
        if (!author) { notFound(); return }
        boolean admin = isAdmin(springSecurityService.currentUser as User)
        List<Book> books = admin ?
            Book.findAllByAuthor(author, [sort: 'title', order: 'asc']) :
            Book.findAllByAuthorAndActive(author, true, [sort: 'title', order: 'asc'])
        respond author, model: [bookList: books, isAdmin: admin]
    }

    @Secured(['ROLE_ADMIN'])
    def create() { respond new Author(params) }

    @Secured(['ROLE_ADMIN'])
    def save(Author author) {
        if (!author) { notFound(); return }
        try {
            applyImage(author)
            authorService.save(author)
        } catch (ValidationException | IllegalArgumentException e) {
            flash.message = e.message ?: 'تعذر إضافة المؤلف. راجع الحقول المطلوبة.'
            render view: 'create', model: [author: author]
            return
        }
        flash.message = 'تمت إضافة المؤلف بنجاح.'
        redirect action: 'show', id: author.id
    }

    @Secured(['ROLE_ADMIN'])
    def edit(Long id) {
        Author author = authorService.get(id)
        if (!author) { notFound(); return }
        respond author
    }

    @Secured(['ROLE_ADMIN'])
    def update(Author author) {
        if (!author) { notFound(); return }
        try {
            applyImage(author)
            if (params.boolean('removeImage')) { author.imageData = null; author.imageContentType = null }
            authorService.save(author)
        } catch (ValidationException | IllegalArgumentException e) {
            flash.message = e.message ?: 'تعذر تحديث بيانات المؤلف.'
            render view: 'edit', model: [author: author]
            return
        }
        flash.message = 'تم تحديث بيانات المؤلف.'
        redirect action: 'show', id: author.id
    }

    @Secured(['ROLE_ADMIN'])
    def delete(Long id) {
        Author author = authorService.get(id)
        if (!author) { notFound(); return }
        if (Book.countByAuthor(author) > 0) {
            flash.message = 'لا يمكن حذف المؤلف لوجود كتب مرتبطة به.'
            redirect action: 'show', id: id; return
        }
        authorService.delete(id)
        flash.message = 'تم حذف المؤلف.'
        redirect action: 'index'
    }

    @Secured(['permitAll'])
    def photo(Long id) {
        Author author = authorService.get(id)
        if (!author?.imageData) { render status: NOT_FOUND; return }
        response.contentType = author.imageContentType ?: 'image/jpeg'
        response.contentLength = author.imageData.length
        response.outputStream.write(author.imageData)
        response.outputStream.flush()
    }

    private void applyImage(Author author) {
        MultipartFile file = request.getFile('imageFile')
        if (file && !file.empty) {
            if (!file.contentType?.startsWith('image/')) throw new IllegalArgumentException('الملف يجب أن يكون صورة.')
            if (file.size > 5 * 1024 * 1024) throw new IllegalArgumentException('حجم الصورة يجب ألا يتجاوز 5MB.')
            author.imageData = file.bytes
            author.imageContentType = file.contentType
        }
    }

    private boolean isAdmin(User user) { user?.authorities?.any { it.authority == 'ROLE_ADMIN' } ?: false }
    protected void notFound() { flash.message = 'المؤلف غير موجود.'; redirect action: 'index' }
}
