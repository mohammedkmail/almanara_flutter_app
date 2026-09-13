package librarysystem

import grails.gorm.transactions.Transactional
import groovy.json.JsonOutput
import groovy.json.JsonSlurper
import java.math.RoundingMode

@Transactional
class CheckoutIntentService {

    CheckoutIntent createIntent(User user, String purpose, BigDecimal amount, String title,
                                String description, Map payload, int ttlMinutes = 20) {
        if (!user) throw new IllegalArgumentException('يجب تسجيل الدخول لإتمام العملية.')
        if (!(purpose in ['ROOM_RESERVATION', 'DIGITAL_RENTAL', 'MEMBERSHIP'])) {
            throw new IllegalArgumentException('نوع عملية الدفع غير صالح.')
        }
        if (amount == null || amount < BigDecimal.ZERO) {
            throw new IllegalArgumentException('قيمة العملية غير صالحة.')
        }

        new CheckoutIntent(
            token: UUID.randomUUID().toString(),
            purpose: purpose,
            amount: amount.setScale(2, RoundingMode.HALF_UP),
            payloadJson: JsonOutput.toJson(payload ?: [:]),
            title: title,
            description: description,
            expiresAt: new Date(System.currentTimeMillis() + (ttlMinutes * 60_000L)),
            status: 'OPEN',
            user: user
        ).save(flush: true, failOnError: true)
    }

    CheckoutIntent findOpen(String token, User user) {
        if (!token || !user) return null
        CheckoutIntent intent = CheckoutIntent.findByToken(token)
        if (!intent || intent.user?.id != user.id) return null

        if (intent.status == 'OPEN' && intent.expiresAt.before(new Date())) {
            intent.status = 'EXPIRED'
            intent.save(flush: true, failOnError: true)
        }

        intent.status == 'OPEN' ? intent : null
    }

    Map payload(CheckoutIntent intent) {
        if (!intent?.payloadJson) return [:]
        (new JsonSlurper().parseText(intent.payloadJson) ?: [:]) as Map
    }

    void complete(CheckoutIntent intent) {
        intent.status = 'COMPLETED'
        intent.save(flush: true, failOnError: true)
    }

    void cancel(CheckoutIntent intent) {
        if (intent?.status == 'OPEN') {
            intent.status = 'CANCELLED'
            intent.save(flush: true, failOnError: true)
        }
    }
}
