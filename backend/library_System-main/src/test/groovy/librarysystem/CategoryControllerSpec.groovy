package librarysystem

import grails.testing.web.controllers.ControllerUnitTest
import spock.lang.Specification

class CategoryControllerSpec extends Specification implements ControllerUnitTest<CategoryController> {
    void 'controller loads correctly'() {
        expect:
        controller != null
    }
}
