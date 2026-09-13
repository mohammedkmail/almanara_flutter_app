package librarysystem

import grails.testing.web.controllers.ControllerUnitTest
import spock.lang.Specification

class PaymentControllerSpec extends Specification implements ControllerUnitTest<PaymentController> {
    void 'controller loads correctly'() {
        expect:
        controller != null
    }
}
