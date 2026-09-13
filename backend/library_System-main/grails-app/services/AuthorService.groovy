package librarysystem

import grails.gorm.services.Service

@Service(Author)
interface AuthorService {

    /** Retrieves an author by ID. */
    Author get(Serializable id)

    /** Returns a list of authors based on the provided options. */
    List<Author> list(Map args)

    /** Returns the total number of authors. */
    Long count()

    /** Deletes an author by ID. */
    void delete(Serializable id)

    /** Saves or updates an author. */
    Author save(Author author)
}