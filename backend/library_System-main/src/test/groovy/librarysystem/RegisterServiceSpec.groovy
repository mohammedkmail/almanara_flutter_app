package librarysystem

import grails.testing.services.ServiceUnitTest
import spock.lang.Specification

class RegisterServiceSpec extends Specification
        implements ServiceUnitTest<RegisterService> {

    void "service should be created"() {
        expect:
        service != null
    }
}
