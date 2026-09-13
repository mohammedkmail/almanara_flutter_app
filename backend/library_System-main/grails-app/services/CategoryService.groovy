package librarysystem

import grails.gorm.services.Service

@Service(Category)
interface CategoryService {

    /** Retrieves a category by ID. */
    Category get(Serializable id)

    /** Returns a list of categories based on the provided options. */
    List<Category> list(Map args)

    /** Returns the total number of categories. */
    Long count()

    /** Deletes a category by ID. */
    void delete(Serializable id)

    /** Saves or updates a category. */
    Category save(Category category)
}