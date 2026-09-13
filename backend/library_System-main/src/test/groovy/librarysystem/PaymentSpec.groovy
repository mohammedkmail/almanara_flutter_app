package librarysystem

import grails.testing.gorm.DomainUnitTest
import spock.lang.Specification

class PaymentSpec extends Specification implements DomainUnitTest<Payment> {

    void 'payment defaults reflect the online sandbox flow'() {
        given:
        Payment payment = new Payment(
            referenceCode: 'MN-TEST-1',
            purpose: 'PURCHASE',
            amount: new BigDecimal('10.00'),
            user: new User(username: 'demo@library.com', password: 'secret')
        )

        expect:
        payment.provider == 'BRAINTREE'
        payment.paymentMethod == 'CARD'
        payment.channel == 'ONLINE'
        payment.status == 'COMPLETED'
        payment.toString() == 'MN-TEST-1'
    }
}
