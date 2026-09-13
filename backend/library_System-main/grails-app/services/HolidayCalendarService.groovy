package librarysystem

import grails.gorm.transactions.Transactional
import groovy.json.JsonSlurper

import java.time.LocalDate
import java.time.ZoneId
import java.util.concurrent.ConcurrentHashMap

@Transactional
class HolidayCalendarService {

    private static final ZoneId ZONE =
        ZoneId.of('Asia/Hebron')

    private static final String COUNTRY_CODE =
        'PS'

    private static final String PROVIDER =
        'Tallyfy'

    private static final String EXTERNAL_ID_PREFIX =
        'TALLYFY-'

    /*
     * نعيد مزامنة السنة تلقائياً كل 12 ساعة.
     */
    private static final long AUTO_SYNC_INTERVAL_MS =
        12L * 60L * 60L * 1000L

    /*
     * إذا فشل المصدر الخارجي، لا نحاول مع كل request.
     * ننتظر 30 دقيقة قبل محاولة تلقائية جديدة.
     */
    private static final long RETRY_INTERVAL_MS =
        30L * 60L * 1000L

    private static final Map<Integer, Long> LAST_SYNC_ATTEMPT =
        new ConcurrentHashMap<Integer, Long>()


    /*
     * =============================================================
     * FIND HOLIDAY
     * =============================================================
     */

    Holiday holidayFor(Date date) {

        if (!date) {
            return null
        }

        LocalDate localDate =
            toLocalDate(date)

        ensureYearLoaded(
            localDate.year
        )

        Holiday holiday =
            Holiday.findByHolidayDate(
                atStartOfDay(localDate)
            )

        /*
         * تجاهل أي fallback قديم بقي في قاعدة البيانات
         * إلا إذا قام الأدمن بتعديله يدوياً.
         */
        if (
            holiday?.source == 'FALLBACK' &&
            !holiday?.adminOverride
        ) {
            return null
        }

        holiday
    }


    /*
     * =============================================================
     * CLOSED?
     * =============================================================
     */

    boolean isClosed(Date date) {

        Holiday holiday =
            holidayFor(date)

        holiday?.closed == true
    }


    /*
     * =============================================================
     * FIRST CLOSED DAY BETWEEN TWO DATES
     * =============================================================
     */

    Holiday firstClosedHolidayBetween(
        Date startTime,
        Date endTime
    ) {

        if (
            !startTime ||
            !endTime ||
            endTime <= startTime
        ) {
            return null
        }

        LocalDate current =
            toLocalDate(startTime)

        /*
         * إذا انتهى الحجز بالضبط 00:00،
         * اليوم التالي غير محسوب ضمن الحجز.
         */
        LocalDate end =
            toLocalDate(
                new Date(
                    endTime.time - 1L
                )
            )

        /*
         * تأكد أن كل السنوات المطلوبة
         * موجودة من الـ API.
         */
        (current.year..end.year).each { int year ->

            ensureYearLoaded(year)

        }

        while (!current.isAfter(end)) {

            Holiday holiday =
                Holiday.findByHolidayDate(
                    atStartOfDay(current)
                )

            if (
                holiday?.source == 'FALLBACK' &&
                !holiday?.adminOverride
            ) {
                holiday = null
            }

            if (holiday?.closed) {
                return holiday
            }

            current =
                current.plusDays(1)
        }

        null
    }


    /*
     * =============================================================
     * UPCOMING HOLIDAYS
     * =============================================================
     */

    List<Holiday> upcomingHolidays(
        int max = 6
    ) {

        LocalDate now =
            LocalDate.now(ZONE)

        /*
         * نحمّل السنة الحالية والقادمة
         * حتى نهاية السنة ما يصير عندنا نقص.
         */
        ensureYearLoaded(
            now.year
        )

        ensureYearLoaded(
            now.year + 1
        )

        Date today =
            atStartOfDay(now)

        List<Holiday> holidays =
            Holiday.findAllByHolidayDateGreaterThanEqualsAndClosed(
                today,
                true,
                [
                    sort : 'holidayDate',
                    order: 'asc',
                    max  : Math.max(
                        max * 3,
                        12
                    )
                ]
            )

        holidays
            .findAll { Holiday holiday ->

                holiday.source != 'FALLBACK' ||
                    holiday.adminOverride

            }
            .take(
                Math.max(
                    1,
                    max
                )
            )
    }


    /*
     * =============================================================
     * HOLIDAYS FOR MONTH
     * =============================================================
     */

    List<Holiday> holidaysForMonth(
        int year,
        int month
    ) {

        ensureYearLoaded(year)

        LocalDate first =
            LocalDate.of(
                year,
                month,
                1
            )

        LocalDate next =
            first.plusMonths(1)

        List<Holiday> holidays =
            Holiday.findAllByHolidayDateGreaterThanEqualsAndHolidayDateLessThan(
                atStartOfDay(first),
                atStartOfDay(next),
                [
                    sort : 'holidayDate',
                    order: 'asc'
                ]
            )

        holidays.findAll { Holiday holiday ->

            holiday.source != 'FALLBACK' ||
                holiday.adminOverride

        }
    }


    /*
     * =============================================================
     * SYNC YEAR FROM EXTERNAL API
     * =============================================================
     */

    Map syncYear(int year) {

        int imported = 0
        int updated = 0
        int skipped = 0
        int removedFallback = 0

        try {

            String endpoint =
                "https://tallyfy.com/national-holidays/api/${COUNTRY_CODE}/${year}.json"

            String body =
                downloadJson(endpoint)

            def json =
                new JsonSlurper()
                    .parseText(body)

            List holidays =
                (json?.holidays ?: []) as List

            if (!holidays) {
                throw new IllegalStateException(
                    "لم يرجع المصدر الخارجي أي عطلات لسنة ${year}."
                )
            }

            /*
             * أكثر من مناسبة يمكن أن تكون بنفس اليوم.
             * لذلك نجمعها في سجل Holiday واحد.
             */
            Map<LocalDate, List> byDate =
                holidays
                    .findAll { item ->
                        item?.observed_date || item?.date
                    }
                    .groupBy { item ->

                        String dateText =
                            item?.observed_date
                                ?.toString()
                                ?.trim()

                        if (!dateText) {
                            dateText =
                                item?.date
                                    ?.toString()
                                    ?.trim()
                        }

                        LocalDate.parse(
                            dateText.substring(0, 10)
                        )
                    }

            Date syncTime =
                new Date()

            byDate
                .keySet()
                .sort()
                .each { LocalDate localDate ->

                    if (localDate.year != year) {
                        return
                    }

                    List sameDay =
                        byDate[localDate]

                    List<String> names =
                        sameDay
                            .collect { item ->

                                String localName =
                                    item?.local_name
                                        ?.toString()
                                        ?.trim()

                                if (localName) {
                                    return localName
                                }

                                arabicName(
                                    item?.name
                                        ?.toString()
                                )
                            }
                            .findAll { it }
                            .unique()

                    String holidayName =
                        names
                            ? names.join(' / ')
                            : 'عطلة رسمية'

                    Date day =
                        atStartOfDay(localDate)

                    String externalId =
                        "${EXTERNAL_ID_PREFIX}${COUNTRY_CODE}-${localDate}"

                    Holiday existing =
                        Holiday.findByHolidayDate(day)

                    if (existing?.adminOverride) {

                        existing.lastSyncedAt =
                            syncTime

                        existing.save(
                            flush: true,
                            failOnError: true
                        )

                        skipped++

                    } else if (existing) {

                        existing.name =
                            holidayName

                        existing.source =
                            'API'

                        existing.externalId =
                            externalId

                        existing.closed =
                            true

                        existing.lastSyncedAt =
                            syncTime

                        existing.save(
                            flush: true,
                            failOnError: true
                        )

                        updated++

                    } else {

                        new Holiday(
                            holidayDate: day,
                            name: holidayName,
                            source: 'API',
                            externalId: externalId,
                            closed: true,
                            adminOverride: false,
                            lastSyncedAt: syncTime
                        ).save(
                            flush: true,
                            failOnError: true
                        )

                        imported++
                    }
                }

            /*
             * بعد نجاح المصدر الخارجي،
             * امسح فقط fallback اليدوي القديم.
             */
            removedFallback =
                removeOldFallbackRows(year)

            LAST_SYNC_ATTEMPT[year] =
                System.currentTimeMillis()

            return [
                success        : true,
                provider       : PROVIDER,
                imported       : imported,
                updated        : updated,
                skipped        : skipped,
                removedFallback: removedFallback,
                message:
                    "تم تحديث تقويم ${year} من ${PROVIDER}: " +
                    "${imported} جديد، " +
                    "${updated} محدّث، " +
                    "${skipped} محفوظ كتعديل إداري، " +
                    "${removedFallback} سجل احتياطي قديم تم حذفه."
            ]

        } catch (Exception e) {

            LAST_SYNC_ATTEMPT[year] =
                System.currentTimeMillis()

            log.warn(
                "Holiday sync failed for ${year}: ${e.message}",
                e
            )

            return [
                success : false,
                provider: PROVIDER,
                imported: imported,
                updated : updated,
                skipped : skipped,
                message:
                    "تعذر تحديث العطل من ${PROVIDER}: " +
                    "${e.message}. " +
                    "سيتم الاحتفاظ بآخر بيانات API مخزنة في النظام."
            ]
        }
    }


    /*
     * =============================================================
     * AUTOMATIC YEAR LOADING
     * =============================================================
     */

    void ensureYearLoaded(
        int year
    ) {

        if (!needsSync(year)) {
            return
        }

        long now =
            System.currentTimeMillis()

        Long lastAttempt =
            LAST_SYNC_ATTEMPT[year]

        /*
         * لا نعمل request كل ثانية إذا المصدر وقع.
         */
        if (
            lastAttempt != null &&
            (now - lastAttempt) < RETRY_INTERVAL_MS
        ) {
            return
        }

        LAST_SYNC_ATTEMPT[
            year
        ] = now

        Map result =
            syncYear(year)

        if (!result.success) {

            log.warn(
                result.message?.toString()
            )
        }
    }


    /*
     * =============================================================
     * DOES THIS YEAR NEED SYNC?
     * =============================================================
     */

    private boolean needsSync(
        int year
    ) {

        LocalDate startDate =
            LocalDate.of(
                year,
                1,
                1
            )

        LocalDate endDate =
            startDate.plusYears(1)

        List<Holiday> providerRecords =
            Holiday.createCriteria().list(
                max: 1
            ) {

                ge(
                    'holidayDate',
                    atStartOfDay(startDate)
                )

                lt(
                    'holidayDate',
                    atStartOfDay(endDate)
                )

                like(
                    'externalId',
                    "${EXTERNAL_ID_PREFIX}%"
                )

                order(
                    'lastSyncedAt',
                    'desc'
                )
            }

        Holiday latest =
            providerRecords
                ? providerRecords[0]
                : null

        /*
         * ما في بيانات من Tallyfy لهذه السنة.
         */
        if (!latest) {
            return true
        }

        /*
         * بيانات قديمة بدون تاريخ مزامنة.
         */
        if (!latest.lastSyncedAt) {
            return true
        }

        long age =
            System.currentTimeMillis() -
            latest.lastSyncedAt.time

        age >= AUTO_SYNC_INTERVAL_MS
    }


    /*
     * =============================================================
     * DOWNLOAD ICS
     * =============================================================
     */

    private String downloadJson(
        String endpoint
    ) {

        def connection =
            new URL(endpoint)
                .openConnection()

        connection.setRequestProperty(
            'Accept',
            'application/json'
        )

        connection.setRequestProperty(
            'User-Agent',
            'Manara-Library/1.0'
        )

        connection.connectTimeout =
            6000

        connection.readTimeout =
            9000

        String body =
            connection
                .inputStream
                .getText('UTF-8')

        if (!body?.trim()) {
            throw new IllegalStateException(
                'المصدر الخارجي رجع استجابة فارغة.'
            )
        }

        body
    }


    /*
     * =============================================================
     * REMOVE OLD FALLBACK
     * =============================================================
     */

    private int removeOldFallbackRows(
        int year
    ) {

        LocalDate first =
            LocalDate.of(
                year,
                1,
                1
            )

        LocalDate next =
            first.plusYears(1)

        List<Holiday> holidays =
            Holiday.findAllByHolidayDateGreaterThanEqualsAndHolidayDateLessThan(
                atStartOfDay(first),
                atStartOfDay(next)
            )

        List<Holiday> fallbackRows =
            holidays.findAll { Holiday holiday ->

                holiday.source == 'FALLBACK' &&
                    !holiday.adminOverride
            }

        fallbackRows.each { Holiday holiday ->

            holiday.delete(
                flush: true
            )
        }

        fallbackRows.size()
    }


    /*
     * =============================================================
     * ARABIC NAMES
     * =============================================================
     */

    private String arabicName(
        String name
    ) {

        if (!name) {
            return 'عطلة رسمية'
        }

        String n =
            name.toLowerCase()

        if (
            n.contains('eid al-fitr') ||
            n.contains('fitr') ||
            n.contains('breaking the fast')
        ) {
            return 'عيد الفطر المبارك'
        }

        if (
            n.contains('eid al-adha') ||
            n.contains('adha') ||
            n.contains('feast of the sacrifice') ||
            n.contains('sacrifice')
        ) {
            return 'عيد الأضحى المبارك'
        }

        if (
            n.contains('islamic new year') ||
            n.contains('hijri new year') ||
            n.contains('muharram')
        ) {
            return 'رأس السنة الهجرية'
        }

        if (
            n.contains('prophet') ||
            n.contains('mawlid')
        ) {
            return 'المولد النبوي الشريف'
        }

        if (
            n.contains('isra') ||
            n.contains('miraj') ||
            n.contains("mi'raj") ||
            n.contains('ascension to heaven')
        ) {
            return 'الإسراء والمعراج'
        }

        if (
            n.contains('independence')
        ) {
            return 'ذكرى إعلان الاستقلال'
        }

        if (
            n.contains('labor') ||
            n.contains('labour')
        ) {
            return 'عيد العمال'
        }

        if (
            n.contains('orthodox christmas')
        ) {
            return 'عيد الميلاد المجيد - التقويم الشرقي'
        }

        if (
            n.contains('christmas')
        ) {
            return 'عيد الميلاد المجيد'
        }

        if (
            n.contains('new year') &&
            !n.contains('islamic') &&
            !n.contains('hijri')
        ) {
            return 'رأس السنة الميلادية'
        }

        if (
            n.contains('land day')
        ) {
            return 'يوم الأرض'
        }

        if (
            n.contains('nakba')
        ) {
            return 'ذكرى النكبة'
        }

        if (
            n.contains('good friday')
        ) {
            return 'الجمعة العظيمة'
        }

        if (
            n.contains('easter')
        ) {
            return 'عيد الفصح'
        }

        /*
         * إذا ظهر اسم جديد من الـ API
         * وما عندنا ترجمة له، نخزن الاسم القادم
         * من المصدر بدل ما نخترع اسم.
         */
        name
    }


    /*
     * =============================================================
     * DATE HELPERS
     * =============================================================
     */

    private LocalDate toLocalDate(
        Date date
    ) {

        date
            .toInstant()
            .atZone(ZONE)
            .toLocalDate()
    }


    private Date atStartOfDay(
        LocalDate date
    ) {

        Date.from(
            date
                .atStartOfDay(ZONE)
                .toInstant()
        )
    }
}