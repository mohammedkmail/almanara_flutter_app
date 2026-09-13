<!doctype html>
<html>
<head>
    <meta name="layout" content="main"/>
    <title>تقويم العطل | المنارة</title>
</head>

<body>

<section class="mn-page">
    <div class="container">

        <div class="mn-page-head">

            <div>
                <span class="mn-kicker">إدارة التشغيل</span>

                <h1>تقويم العطل والإغلاق</h1>

                <p>
                    المكتبة تعمل طوال الأسبوع. هذه الأيام فقط تمنع إنشاء
                    حجوزات غرف جديدة، ويمكن تعديلها يدويًا حتى لو جاءت
                    من مصدر خارجي.
                </p>
            </div>

            <div class="mn-toolbar">

                <g:link action="create"
                        class="mn-btn mn-btn-primary">
                    <i class="bi bi-plus-lg"></i>
                    إضافة يوم
                </g:link>

                <g:form action="sync"
                        method="POST"
                        class="d-inline">

                    <g:hiddenField name="year"
                                   value="${year}"/>

                    <button class="mn-btn mn-btn-light">
                        <i class="bi bi-arrow-repeat"></i>
                        مزامنة ${year}
                    </button>

                </g:form>

            </div>

        </div>


        <!-- Navigation -->
        <div class="mn-panel mb-3">

            <div class="mn-panel-body
                        d-flex
                        justify-content-between
                        align-items-center
                        flex-wrap
                        gap-2">

                <g:link action="index"
                        params="${[
                            year : month == 1 ? year - 1 : year,
                            month: month == 1 ? 12 : month - 1
                        ]}"
                        class="mn-btn mn-btn-light mn-btn-sm">

                    <i class="bi bi-chevron-right"></i>
                    الشهر السابق

                </g:link>


                <strong class="h5 mb-0">
                    ${year} /
                    ${String.format('%02d', month)}
                </strong>


                <g:link action="index"
                        params="${[
                            year : month == 12 ? year + 1 : year,
                            month: month == 12 ? 1 : month + 1
                        ]}"
                        class="mn-btn mn-btn-light mn-btn-sm">

                    الشهر التالي
                    <i class="bi bi-chevron-left"></i>

                </g:link>

            </div>

        </div>


        <!-- Calendar -->
        <div class="mn-calendar">

            <div class="mn-calendar-grid">

                <g:each in="${[
                    'الأحد',
                    'الاثنين',
                    'الثلاثاء',
                    'الأربعاء',
                    'الخميس',
                    'الجمعة',
                    'السبت'
                ]}"
                        var="dayName">

                    <div class="mn-calendar-dayname">
                        ${dayName}
                    </div>

                </g:each>


                <g:each in="${cells}" var="cell">

                    <g:if test="${cell['empty']}">

                        <div class="mn-calendar-cell empty"></div>

                    </g:if>

                    <g:else>

                        <div class="mn-calendar-cell">

                            <g:set var="dayDate"
                                   value="${cell['date']}"/>


                            <div class="d-flex justify-content-between">

                                <span class="mn-calendar-date">
                                    ${dayDate?.dayOfMonth}
                                </span>

                                <g:link action="create"
                                        params="${[
                                            date: dayDate?.toString()
                                        ]}"
                                        class="small"
                                        title="إضافة">

                                    <i class="bi bi-plus-circle"></i>

                                </g:link>

                            </div>


                            <g:if test="${cell['holidayId']}">

                                <g:link action="edit"
                                        id="${cell['holidayId']}"
                                        class="${cell['holidayClosed'] ?
                                            'mn-calendar-event closed' :
                                            'mn-calendar-event'}">

                                    ${cell['holidayName']}

                                    <br/>

                                    <small>

                                        <ui:label value="${cell['holidaySource']}"/>

                                        •

                                        ${cell['holidayClosed'] ?
                                            'مغلق' :
                                            'مفتوح باستثناء إداري'}

                                    </small>

                                </g:link>

                            </g:if>

                        </div>

                    </g:else>

                </g:each>

            </div>

        </div>


        <!-- Holidays List -->
        <div class="mn-panel mt-4">

            <div class="mn-panel-head">

                <h2>أيام هذا الشهر</h2>

                <span class="mn-status ${
                    apiConfigured ?
                    'mn-status-success' :
                    'mn-status-warning'
                }">

                    ${apiConfigured ?
                        'API مهيأ' :
                        'Fallback محلي فعال'}

                </span>

            </div>


            <div class="table-responsive">

                <table class="mn-data-table">

                    <thead>
                    <tr>
                        <th>التاريخ</th>
                        <th>الاسم</th>
                        <th>المصدر</th>
                        <th>الحالة</th>
                        <th></th>
                    </tr>
                    </thead>


                    <tbody>

                    <g:each in="${holidays}" var="holidayRow">

                        <tr>

                            <td>
                                <g:formatDate
                                        date="${holidayRow.holidayDate}"
                                        format="dd/MM/yyyy"/>
                            </td>

                            <td>
                                <strong>${holidayRow.name}</strong>
                            </td>

                            <td>
                                <ui:label value="${holidayRow.source}"/>
                            </td>

                            <td>
                                ${holidayRow.closed ?
                                    'المكتبة مغلقة' :
                                    'المكتبة مفتوحة'}
                            </td>

                            <td>

                                <g:link action="edit"
                                        id="${holidayRow.id}"
                                        class="mn-btn mn-btn-light mn-btn-sm">

                                    تعديل

                                </g:link>

                            </td>

                        </tr>

                    </g:each>


                    <g:if test="${!holidays}">

                        <tr>
                            <td colspan="5"
                                class="mn-empty">

                                لا توجد أيام إغلاق في هذا الشهر.

                            </td>
                        </tr>

                    </g:if>

                    </tbody>

                </table>

            </div>

        </div>

    </div>
</section>

</body>
</html>
