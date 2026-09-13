package librarysystem

import grails.gorm.services.Service

@Service(BookCopy)
interface BookCopyService {

    /** Retrieves a book copy by ID. */
    BookCopy get(Serializable id)

    /** Returns a list of book copies based on the provided options. */
    List<BookCopy> list(Map args)

    /** Returns the total number of book copies. */
    Long count()

    /** Deletes a book copy by ID. */
    void delete(Serializable id)

    /** Saves or updates a book copy. */
    BookCopy save(BookCopy bookCopy)
}