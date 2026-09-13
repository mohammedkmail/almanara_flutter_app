package librarysystem

import grails.gorm.transactions.Transactional
import java.math.RoundingMode

@Transactional
class RoomReservationService {

    HolidayCalendarService holidayCalendarService
    DiscountRuleService discountRuleService

    RoomReservation get(Serializable id) { RoomReservation.get(id) }
    List<RoomReservation> list(Map params = [:]) { RoomReservation.list(params) }
    Long count() { RoomReservation.count() }

    Map quote(User user, StudyRoom studyRoom, Date startTime, Date endTime) {
        validateRequest(user, studyRoom, startTime, endTime)
        ensureAvailable(studyRoom, startTime, endTime)

        Holiday closedHoliday = holidayCalendarService.firstClosedHolidayBetween(startTime, endTime)
        if (closedHoliday) {
            throw new IllegalStateException("المكتبة مغلقة خلال هذا الحجز بسبب: ${closedHoliday.name} (${new java.text.SimpleDateFormat('dd/MM/yyyy').format(closedHoliday.holidayDate)}).")
        }

        discountRuleService.calculate(studyRoom.pricePerHour, startTime, endTime)
    }

    RoomReservation createConfirmedReservation(User user, Long studyRoomId, Date startTime, Date endTime,
                                               BigDecimal expectedTotal = null) {
        StudyRoom lockedRoom = StudyRoom.lock(studyRoomId)
        if (!lockedRoom) throw new IllegalArgumentException('غرفة الدراسة غير موجودة.')

        Map pricing = quote(user, lockedRoom, startTime, endTime)
        if (expectedTotal != null && pricing.totalPrice.setScale(2, RoundingMode.HALF_UP) != expectedTotal.setScale(2, RoundingMode.HALF_UP)) {
            throw new IllegalStateException('تغيّر سعر الحجز قبل إتمام الدفع. أعد فتح صفحة الحجز للتأكد من السعر الجديد.')
        }

        new RoomReservation(
            user: user,
            studyRoom: lockedRoom,
            startTime: startTime,
            endTime: endTime,
            basePrice: pricing.basePrice,
            discountPercentage: pricing.percentage,
            discountAmount: pricing.discountAmount,
            totalPrice: pricing.totalPrice,
            status: 'CONFIRMED'
        ).save(flush: true, failOnError: true)
    }

    RoomReservation cancelReservation(Long id) {
        RoomReservation reservation = RoomReservation.get(id)
        if (!reservation) return null
        if (reservation.status in ['COMPLETED', 'CANCELLED']) {
            throw new IllegalStateException('لا يمكن إلغاء هذا الحجز.')
        }
        if (reservation.startTime <= new Date()) {
            throw new IllegalStateException('لا يمكن إلغاء الحجز بعد بدء موعده.')
        }
        reservation.status = 'CANCELLED'
        reservation.save(flush: true, failOnError: true)
        reservation
    }

    void updateCompletedReservations() {
        Date now = new Date()
        RoomReservation.findAllByStatusAndEndTimeLessThan('CONFIRMED', now).each { RoomReservation reservation ->
            reservation.status = 'COMPLETED'
            reservation.save(flush: true, failOnError: true)
        }
    }

    Long countConfirmedReservations() {
        updateCompletedReservations()
        RoomReservation.countByStatus('CONFIRMED')
    }

    boolean isAvailable(StudyRoom room, Date startTime, Date endTime) {
        if (!room || !startTime || !endTime) return false
        !RoomReservation.findAllByStudyRoomAndStatusInList(room, ['CONFIRMED']).any { RoomReservation reservation ->
            startTime < reservation.endTime && endTime > reservation.startTime
        }
    }

    private void validateRequest(User user, StudyRoom studyRoom, Date startTime, Date endTime) {
        if (!user) throw new IllegalArgumentException('يجب تسجيل الدخول لحجز غرفة.')
        if (!studyRoom) throw new IllegalArgumentException('اختر غرفة دراسة.')
        if (studyRoom.active != true) throw new IllegalStateException('غرفة الدراسة غير متاحة حاليًا.')
        if (!startTime || !endTime) throw new IllegalArgumentException('حدد وقت البداية والنهاية.')
        if (startTime <= new Date()) throw new IllegalArgumentException('يجب أن يكون موعد البداية في المستقبل.')
        if (endTime <= startTime) throw new IllegalArgumentException('يجب أن يكون وقت النهاية بعد وقت البداية.')

        long minutes = Math.ceil((endTime.time - startTime.time) / (1000.0d * 60.0d)) as long
        if (minutes < 30) throw new IllegalArgumentException('الحد الأدنى للحجز 30 دقيقة.')
        if (minutes > 30L * 24L * 60L) throw new IllegalArgumentException('الحد الأقصى للحجز الواحد 30 يومًا.')
    }

    private void ensureAvailable(StudyRoom studyRoom, Date startTime, Date endTime) {
        if (!isAvailable(studyRoom, startTime, endTime)) {
            throw new IllegalStateException('الغرفة محجوزة خلال جزء من الفترة التي اخترتها. اختر وقتًا آخر.')
        }
    }
}
