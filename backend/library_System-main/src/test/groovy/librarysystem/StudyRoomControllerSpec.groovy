package librarysystem

import grails.testing.gorm.DomainUnitTest
import grails.testing.web.controllers.ControllerUnitTest
import spock.lang.Specification

class StudyRoomControllerSpec extends Specification
        implements ControllerUnitTest<StudyRoomController>,
                   DomainUnitTest<StudyRoom> {

    void "controller loads correctly"() {

        expect:

        controller != null
    }
}
