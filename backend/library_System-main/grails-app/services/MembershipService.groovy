package librarysystem

import grails.gorm.transactions.Transactional

import java.time.LocalDate
import java.time.ZoneId
import java.time.temporal.ChronoUnit
import java.math.RoundingMode

@Transactional
class MembershipService {

    private static final BigDecimal PRICE_PER_DAY = new BigDecimal('1.00')

    private static final List<Map<String, Object>> DISCOUNT_TIERS = [
        [minDays: 365, percentage: new BigDecimal('20'), label: 'سنة أو أكثر'],
        [minDays: 180, percentage: new BigDecimal('15'), label: '6 أشهر أو أكثر'],
        [minDays: 90,  percentage: new BigDecimal('10'), label: '3 أشهر أو أكثر'],
        [minDays: 30,  percentage: new BigDecimal('5'),  label: 'شهر أو أكثر']
    ].asImmutable()

    Membership get(Serializable id) { Membership.get(id) }
    List<Membership> list(Map params = [:]) { Membership.list(params) }
    Long count() { Membership.count() }

    void syncMembershipStatuses(User user = null) {
        LocalDate today = LocalDate.now()
        List<Membership> memberships = user ?
            Membership.findAllByUserAndStatusInList(user, ['ACTIVE', 'SCHEDULED']) :
            Membership.findAllByStatusInList(['ACTIVE', 'SCHEDULED'])

        memberships.each { Membership membership ->
            LocalDate start = toLocalDate(membership.startDate)
            LocalDate end = toLocalDate(membership.endDate)
            String nextStatus = membership.status

            if (end.isBefore(today)) {
                nextStatus = 'EXPIRED'
            } else if (today.isBefore(start)) {
                nextStatus = 'SCHEDULED'
            } else {
                nextStatus = 'ACTIVE'
            }

            if (membership.status != nextStatus) {
                membership.status = nextStatus
                membership.save(flush: true, failOnError: true)
            }
        }
    }

    Membership currentActiveMembership(User user) {
        if (!user) return null
        syncMembershipStatuses(user)
        LocalDate today = LocalDate.now()

        Membership.findAllByUserAndStatus(user, 'ACTIVE', [sort: 'endDate', order: 'desc'])
            .find { Membership membership ->
                LocalDate start = toLocalDate(membership.startDate)
                LocalDate end = toLocalDate(membership.endDate)
                !today.isBefore(start) && !today.isAfter(end)
            }
    }

    boolean hasActiveMembership(User user) {
        currentActiveMembership(user) != null
    }

    BigDecimal borrowingFeeFor(User user, Book book) {
        if (!book) return BigDecimal.ZERO
        hasActiveMembership(user) ? BigDecimal.ZERO : (book.borrowingFee ?: BigDecimal.ZERO)
    }

    Membership createMembershipRequest(User user, Date startDate, Date endDate) {
        validateDates(user, startDate, endDate)
        syncMembershipStatuses(user)

        Membership pending = Membership.findByUserAndStatus(user, 'PENDING')
        LocalDate requestedStart = toLocalDate(startDate)
        LocalDate requestedEnd = toLocalDate(endDate)
        ensureNoMembershipOverlap(user, requestedStart, requestedEnd, pending?.id)

        Map pricing = calculatePricing(startDate, endDate)
        BigDecimal price = pricing.totalPrice as BigDecimal

        if (pending) {
            pending.startDate = startDate
            pending.endDate = endDate
            pending.price = price
            pending.save(flush: true, failOnError: true)
            return pending
        }

        new Membership(
            user: user,
            startDate: startDate,
            endDate: endDate,
            price: price,
            status: 'PENDING'
        ).save(flush: true, failOnError: true)
    }

    Membership activateMembership(Long id) {
        Membership membership = Membership.lock(id)
        if (!membership) throw new IllegalArgumentException('طلب العضوية غير موجود.')
        if (membership.status in ['ACTIVE', 'SCHEDULED']) return membership

        validatePendingMembershipForPayment(membership)
        LocalDate requestedStart = toLocalDate(membership.startDate)

        membership.status = requestedStart.isAfter(LocalDate.now()) ? 'SCHEDULED' : 'ACTIVE'
        membership.save(flush: true, failOnError: true)
        membership
    }

    Map validatePendingMembershipForPayment(Membership membership) {
        if (!membership) throw new IllegalArgumentException('طلب العضوية غير موجود.')
        if (membership.status != 'PENDING') {
            throw new IllegalStateException('طلب العضوية لم يعد بانتظار الدفع.')
        }

        syncMembershipStatuses(membership.user)
        LocalDate today = LocalDate.now()
        LocalDate requestedStart = toLocalDate(membership.startDate)
        LocalDate requestedEnd = toLocalDate(membership.endDate)

        if (requestedStart.isBefore(today) || requestedEnd.isBefore(today)) {
            throw new IllegalStateException('فترة العضوية لم تعد صالحة للدفع. حدّث الطلب واختر تاريخ بداية من اليوم أو بعده.')
        }

        ensureNoMembershipOverlap(
            membership.user,
            requestedStart,
            requestedEnd,
            membership.id
        )

        calculatePricing(membership.startDate, membership.endDate)
    }

    Membership cancelMembership(Long id) {
        Membership membership = Membership.get(id)
        if (!membership) return null
        if (membership.status in ['EXPIRED', 'CANCELLED']) {
            throw new IllegalStateException('هذه العضوية مغلقة بالفعل.')
        }
        membership.status = 'CANCELLED'
        membership.save(flush: true, failOnError: true)
        membership
    }

    Map calculatePricing(Date startDate, Date endDate) {
        if (!startDate || !endDate) return emptyPricing()

        LocalDate start = toLocalDate(startDate)
        LocalDate end = toLocalDate(endDate)
        if (end.isBefore(start)) return emptyPricing()

        long days = ChronoUnit.DAYS.between(start, end) + 1
        BigDecimal basePrice = PRICE_PER_DAY
            .multiply(BigDecimal.valueOf(days))
            .setScale(2, RoundingMode.HALF_UP)

        Map<String, Object> tier = DISCOUNT_TIERS.find { Map<String, Object> candidate ->
            days >= (candidate.minDays as Integer)
        }

        BigDecimal percentage = tier ? (tier.percentage as BigDecimal) : BigDecimal.ZERO
        BigDecimal discountAmount = basePrice
            .multiply(percentage)
            .divide(BigDecimal.valueOf(100), 2, RoundingMode.HALF_UP)
        BigDecimal totalPrice = basePrice
            .subtract(discountAmount)
            .setScale(2, RoundingMode.HALF_UP)

        [
            days              : days,
            basePrice         : basePrice,
            discountPercentage: percentage,
            discountAmount    : discountAmount,
            totalPrice        : totalPrice,
            tierLabel         : tier?.label
        ]
    }

    BigDecimal calculatePrice(Date startDate, Date endDate) {
        calculatePricing(startDate, endDate).totalPrice as BigDecimal
    }

    BigDecimal getPricePerDay() { PRICE_PER_DAY }

    List<Map<String, Object>> getDiscountTiers() {
        DISCOUNT_TIERS.collect { Map<String, Object> tier ->
            new LinkedHashMap<String, Object>(tier)
        }
    }

    private Map emptyPricing() {
        [
            days              : 0L,
            basePrice         : BigDecimal.ZERO.setScale(2),
            discountPercentage: BigDecimal.ZERO,
            discountAmount    : BigDecimal.ZERO.setScale(2),
            totalPrice        : BigDecimal.ZERO.setScale(2),
            tierLabel         : null
        ]
    }

    private void validateDates(User user, Date startDate, Date endDate) {
        if (!user) throw new IllegalArgumentException('يجب تسجيل الدخول لطلب عضوية.')
        if (!startDate || !endDate) throw new IllegalArgumentException('حدد تاريخ بداية ونهاية العضوية.')

        LocalDate start = toLocalDate(startDate)
        LocalDate end = toLocalDate(endDate)
        if (end.isBefore(start)) {
            throw new IllegalArgumentException('تاريخ نهاية العضوية لا يمكن أن يسبق تاريخ البداية.')
        }
        if (start.isBefore(LocalDate.now())) {
            throw new IllegalArgumentException('لا يمكن بدء عضوية جديدة بتاريخ سابق.')
        }
    }

    private void ensureNoMembershipOverlap(
        User user,
        LocalDate requestedStart,
        LocalDate requestedEnd,
        Long excludedMembershipId = null
    ) {
        Membership overlap = Membership.findAllByUserAndStatusInList(
            user,
            ['ACTIVE', 'SCHEDULED']
        ).find { Membership current ->
            current.id != excludedMembershipId &&
                dateRangesOverlap(
                    requestedStart,
                    requestedEnd,
                    toLocalDate(current.startDate),
                    toLocalDate(current.endDate)
                )
        }

        if (overlap) {
            throw new IllegalStateException(
                'لديك عضوية فعالة أو مجدولة تغطي جزءًا من الفترة المختارة. اختر فترة تبدأ بعد انتهائها.'
            )
        }
    }

    private boolean dateRangesOverlap(LocalDate startA, LocalDate endA, LocalDate startB, LocalDate endB) {
        !endA.isBefore(startB) && !endB.isBefore(startA)
    }

    private LocalDate toLocalDate(Date date) {
        java.time.Instant.ofEpochMilli(date.time)
            .atZone(ZoneId.systemDefault())
            .toLocalDate()
    }
}
