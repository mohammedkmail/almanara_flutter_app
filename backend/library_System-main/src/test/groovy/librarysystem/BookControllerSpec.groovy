package librarysystem

import grails.testing.web.controllers.ControllerUnitTest
import spock.lang.Specification

class BookControllerSpec extends Specification implements ControllerUnitTest<BookController> {
    void 'controller loads correctly'() {
        expect:
        controller != null
    }
}
