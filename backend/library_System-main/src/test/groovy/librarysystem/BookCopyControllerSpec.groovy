package librarysystem

import grails.testing.web.controllers.ControllerUnitTest
import spock.lang.Specification

class BookCopyControllerSpec extends Specification implements ControllerUnitTest<BookCopyController> {
    void 'controller loads correctly'() {
        expect:
        controller != null
    }
}
