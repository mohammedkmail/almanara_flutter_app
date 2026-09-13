package librarysystem

import grails.plugin.springsecurity.annotation.Secured

import java.time.LocalDate
import java.time.ZoneId

@Secured(['ROLE_ADMIN'])
class HolidayController {

    HolidayCalendarService holidayCalendarService

    static allowedMethods = [save: 'POST', update: 'PUT', delete: 'DELETE', sync: 'POST']

    def index(Integer year, Integer month) {
        LocalDate today = LocalDate.now(ZoneId.of('Asia/Hebron'))
        int y = year ?: today.year
        int m = month ?: today.monthValue
        if (m < 1) { m = 12; y-- }
        if (m > 12) { m = 1; y++ }

        holidayCalendarService.ensureYearLoaded(y)
        LocalDate first = LocalDate.of(y, m, 1)
        int leading = first.dayOfWeek.value % 7 // Sunday = 0
        List<Map> cells = []
        leading.times { cells << [empty: true] }
        (1..first.lengthOfMonth()).each { int day ->
            LocalDate date = LocalDate.of(y, m, day)
            Date dbDate = Date.from(date.atStartOfDay(ZoneId.of('Asia/Hebron')).toInstant())
            Holiday dayHoliday = Holiday.findByHolidayDate(dbDate)

            cells << [
                date         : date,
                holidayId    : dayHoliday?.id,
                holidayName  : dayHoliday?.name,
                holidayClosed: dayHoliday?.closed,
                holidaySource: dayHoliday?.source
            ]
        }
        while (cells.size() % 7 != 0) cells << [empty: true]

        List<Map> holidayRows = holidayCalendarService.holidaysForMonth(y, m).collect { Holiday h ->
            [
                id         : h.id,
                holidayDate: h.holidayDate,
                name       : h.name,
                source     : h.source,
                closed     : h.closed
            ]
        }

        render view: 'index', model: [
            year         : y,
            month        : m,
            cells        : cells,
            holidays     : holidayRows,
            apiConfigured: true
        ]
    }

    def create(String date) {
        Holiday holiday = new Holiday()
        if (date) {
            try {
                LocalDate ld = LocalDate.parse(date)
                holiday.holidayDate = Date.from(ld.atStartOfDay(ZoneId.of('Asia/Hebron')).toInstant())
            } catch (ignored) { }
        }
        respond holiday
    }

    def save() {
        try {
            Holiday holiday = bindHoliday(new Holiday())
            holiday.source = 'MANUAL'
            holiday.adminOverride = true
            holiday.save(flush: true, failOnError: true)
            flash.message = 'تمت إضافة يوم الإغلاق إلى التقويم.'
            redirect action: 'index', params: monthParams(holiday.holidayDate)
        } catch (Exception e) {
            flash.message = e.message
            redirect action: 'create', params: [date: params.holidayDate]
        }
    }

    def edit(Long id) {
        Holiday holiday = Holiday.get(id)
        if (!holiday) { notFound(); return }
        respond holiday
    }

    def update(Long id) {
        Holiday holiday = Holiday.get(id)
        if (!holiday) { notFound(); return }
        try {
            bindHoliday(holiday)
            holiday.source = 'MANUAL'
            holiday.adminOverride = true
            holiday.save(flush: true, failOnError: true)
            flash.message = 'تم تحديث يوم التقويم وحفظ التعديل الإداري.'
            redirect action: 'index', params: monthParams(holiday.holidayDate)
        } catch (Exception e) {
            flash.message = e.message
            redirect action: 'edit', id: id
        }
    }

    def delete(Long id) {
        Holiday holiday = Holiday.get(id)
        if (!holiday) { notFound(); return }
        Map back = monthParams(holiday.holidayDate)
        holiday.delete(flush: true)
        flash.message = 'تم حذف اليوم من التقويم.'
        redirect action: 'index', params: back
    }

    def sync(Integer year) {
        int y = year ?: Calendar.getInstance().get(Calendar.YEAR)
        Map result = holidayCalendarService.syncYear(y)
        flash.message = result.message
        redirect action: 'index', params: [year: y, month: Calendar.getInstance().get(Calendar.MONTH) + 1]
    }

    private Holiday bindHoliday(Holiday holiday) {
        LocalDate ld = LocalDate.parse(params.holidayDate)
        holiday.holidayDate = Date.from(ld.atStartOfDay(ZoneId.of('Asia/Hebron')).toInstant())
        holiday.name = params.name?.trim()
        holiday.closed = params.closed != null ? params.boolean('closed') : false
        holiday.notes = params.notes?.trim()
        holiday
    }

    private Map monthParams(Date date) {
        LocalDate ld = date.toInstant().atZone(ZoneId.of('Asia/Hebron')).toLocalDate()
        [year: ld.year, month: ld.monthValue]
    }

    protected void notFound() { flash.message = 'اليوم غير موجود في التقويم.'; redirect action: 'index' }
}
