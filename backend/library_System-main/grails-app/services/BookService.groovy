package librarysystem

import grails.gorm.transactions.Transactional
import grails.validation.ValidationException

@Transactional
class BookService {

    /** Retrieves a book by ID. */
    Book get(Serializable id) {
        Book.get(id)
    }

    /** Returns a list of books based on the provided options. */
    List<Book> list(Map args) {
        Book.list(args)
    }

    /** Returns the total number of books. */
    Long count() {
        Book.count()
    }

    /** Finds books with titles matching the provided value. */
    List<Book> findAllByTitleIlike(String title, Map args) {
        Book.findAllByTitleIlike(title, args)
    }

    /** Counts books with titles matching the provided value. */
    Long countByTitleIlike(String title) {
        Book.countByTitleIlike(title)
    }

    /**
     * Searches the catalog by title, ISBN, author, or category.
     * The same query is reused by the browser catalog and REST API so
     * visibility and pagination rules stay consistent.
     */
    Map searchCatalog(String term, boolean includeInactive = false, int max = 12, int offset = 0) {
        String normalized = term?.trim()?.toLowerCase()
        int pageSize = Math.min(Math.max(max, 1), 100)
        int safeOffset = Math.max(offset, 0)

        if (!normalized) {
            List<Book> books = includeInactive ?
                Book.list(max: pageSize, offset: safeOffset, sort: 'title', order: 'asc') :
                Book.findAllByActive(true, [max: pageSize, offset: safeOffset, sort: 'title', order: 'asc'])
            Long total = includeInactive ? Book.count() : Book.countByActive(true)
            return [books: books, total: total, max: pageSize, offset: safeOffset]
        }

        String visibilityClause = includeInactive ? '' : 'b.active = true and '
        String fromWhere =
            'from Book b where ' +
            visibilityClause +
            '''(
                lower(b.title) like :search or
                lower(b.isbn) like :search or
                lower(b.author.name) like :search or
                lower(b.category.name) like :search
            )'''

        String pattern = "%${normalized}%"
        List<Book> books = Book.executeQuery(
            fromWhere + ' order by b.title asc',
            [search: pattern],
            [max: pageSize, offset: safeOffset]
        )
        Long total = Book.executeQuery(
            'select count(b.id) ' + fromWhere,
            [search: pattern]
        )[0] as Long

        [books: books, total: total, max: pageSize, offset: safeOffset]
    }

    /** Saves or updates a book after validating business rules. */
    Book save(Book book) {

        validateBusinessRules(book)

        if (book.hasErrors()) {
            throw new ValidationException(
                "تعذر حفظ الكتاب بسبب أخطاء في البيانات.",
                book.errors
            )
        }

        book.save(flush: true, failOnError: true)

        book
    }

    /**
     * Deletes a book only when it has no operational history.
     * Books referenced by copies/reservations/purchases/digital access are archived
     * by setting active=false so historical records remain valid.
     */
    Map deleteOrDeactivate(Serializable id) {
        Book book = Book.get(id)
        if (!book) return [found: false, deleted: false, book: null]

        boolean hasSystemHistory =
            BookCopy.countByBook(book) > 0 ||
            Reservation.countByBook(book) > 0 ||
            Purchase.countByBook(book) > 0 ||
            DigitalAccess.countByBook(book) > 0

        if (hasSystemHistory) {
            book.active = false
            book.save(flush: true, failOnError: true)
            return [found: true, deleted: false, book: book]
        }

        book.delete(flush: true)
        [found: true, deleted: true, book: book]
    }

    /** Kept for callers that only need the operation and not its result. */
    void delete(Serializable id) {
        deleteOrDeactivate(id)
    }

    /** Validates business rules related to digital book options. */
    private void validateBusinessRules(Book book) {

        if (!book.digitalAvailable) {

            if (book.digitalPurchasePrice != null) {
                book.errors.rejectValue(
                    'digitalPurchasePrice',
                    'book.digitalPurchasePrice.invalid',
                    'سعر الشراء الرقمي يتطلب تفعيل النسخة الرقمية.'
                )
            }

            if (book.digitalRentalPrice != null) {
                book.errors.rejectValue(
                    'digitalRentalPrice',
                    'book.digitalRentalPrice.invalid',
                    'سعر الاستئجار الرقمي يتطلب تفعيل النسخة الرقمية.'
                )
            }

            if (book.membershipIncluded) {
                book.errors.rejectValue(
                    'membershipIncluded',
                    'book.membershipIncluded.invalid',
                    'إتاحة الكتاب ضمن العضوية تتطلب تفعيل النسخة الرقمية.'
                )
            }

            if (book.digitalContent) {
                book.errors.rejectValue(
                    'digitalContent',
                    'book.digitalContent.invalid',
                    'المحتوى الرقمي يتطلب تفعيل النسخة الرقمية.'
                )
            }
        }
    }
}