package librarysystem

import grails.gorm.services.Service

@Service(StudyRoom)
interface StudyRoomService {

    /** Retrieves a study room by ID. */
    StudyRoom get(Serializable id)

    /** Returns a list of study rooms based on the provided options. */
    List<StudyRoom> list(Map args)

    /** Returns the total number of study rooms. */
    Long count()

    /** Deletes a study room by ID. */
    void delete(Serializable id)

    /** Saves or updates a study room. */
    StudyRoom save(StudyRoom studyRoom)
}