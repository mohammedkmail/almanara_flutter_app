package librarysystem

import grails.gorm.transactions.Transactional

import java.math.RoundingMode

@Transactional
class DiscountRuleService {

    Map calculate(BigDecimal pricePerHour, Date startTime, Date endTime) {
        if (pricePerHour == null || !startTime || !endTime || endTime <= startTime) {
            return [durationMinutes: 0L, durationHours: BigDecimal.ZERO, basePrice: BigDecimal.ZERO,
                    percentage: BigDecimal.ZERO, discountAmount: BigDecimal.ZERO, totalPrice: BigDecimal.ZERO, rule: null]
        }

        long durationMinutes = Math.ceil((endTime.time - startTime.time) / (1000.0d * 60.0d)) as long
        BigDecimal durationHours = BigDecimal.valueOf(durationMinutes)
            .divide(BigDecimal.valueOf(60), 4, RoundingMode.HALF_UP)

        BigDecimal basePrice = pricePerHour.multiply(durationHours).setScale(2, RoundingMode.HALF_UP)
        int qualifyingHours = Math.ceil(durationMinutes / 60.0d) as int

        DiscountRule rule = DiscountRule.findAllByActive(true, [sort: 'priority', order: 'asc'])
            .find { DiscountRule candidate ->
                candidate.minHours <= qualifyingHours &&
                    (candidate.maxHours == null || candidate.maxHours >= qualifyingHours)
            }

        BigDecimal percentage = rule?.percentage ?: BigDecimal.ZERO
        BigDecimal discountAmount = basePrice
            .multiply(percentage)
            .divide(BigDecimal.valueOf(100), 2, RoundingMode.HALF_UP)
        BigDecimal totalPrice = basePrice.subtract(discountAmount).setScale(2, RoundingMode.HALF_UP)

        [
            durationMinutes : durationMinutes,
            durationHours   : durationHours,
            basePrice       : basePrice,
            percentage      : percentage,
            discountAmount  : discountAmount,
            totalPrice      : totalPrice,
            rule            : rule
        ]
    }
}
