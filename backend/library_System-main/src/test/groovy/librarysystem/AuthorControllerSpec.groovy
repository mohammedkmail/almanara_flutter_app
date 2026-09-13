package librarysystem

import grails.testing.web.controllers.ControllerUnitTest
import spock.lang.Specification

class AuthorControllerSpec extends Specification implements ControllerUnitTest<AuthorController> {
    void 'controller loads correctly'() {
        expect:
        controller != null
    }
}
