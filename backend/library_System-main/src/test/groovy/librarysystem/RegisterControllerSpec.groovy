package librarysystem

import grails.testing.web.controllers.ControllerUnitTest
import spock.lang.Specification

class RegisterControllerSpec extends Specification
        implements ControllerUnitTest<RegisterController> {

    void "controller should be created"() {
        expect:
        controller != null
    }
}
