<!doctype html>
<html>
<head>
    <meta name="layout" content="main"/>
    <title>حجز ${reservation?.book?.title} | المنارة</title>
</head>
<body>
<section class="mn-page">
    <div class="container">
        <div class="mn-page-head">
            <div>
                <span class="mn-kicker">حجز كتاب #${reservation?.id}</span>
                <h1 dir="auto">${reservation?.book?.title}</h1>
                <p dir="auto">${reservation?.book?.author?.name}</p>
            </div>
            <g:link action="index" class="mn-btn mn-btn-light">حجوزات الكتب</g:link>
        </div>

        <div class="mn-detail-hero">
            <div class="mn-detail-media">
                <g:if test="${reservation.book?.coverData || reservation.book?.externalCoverUrl}">
                    <img src="${createLink(controller:'book', action:'cover', id:reservation.book.id)}"/>
                </g:if>
                <g:else><i class="bi bi-book fs-1"></i></g:else>
            </div>
            <div class="mn-detail-copy">
                <span class="mn-kicker">حالة الطلب</span>
                <div class="my-3"><ui:status value="${reservation.status}"/></div>

                <g:if test="${reservation.status == 'WAITING'}">
                    <p>تم حفظ دورك مجانًا. عند توفر نسخة سيخصصها النظام لك ويحدد خطوة التأكيد حسب حالة عضويتك.</p>
                </g:if>
                <g:elseif test="${reservation.status == 'READY'}">
                    <g:if test="${(reservation.feeAmount ?: 0) > 0}">
                        <p>تم تخصيص نسخة لك مؤقتًا. أكمل رسوم الاستعارة قبل انتهاء المهلة لتثبيت الحجز.</p>
                    </g:if>
                    <g:else>
                        <p>تم تخصيص نسخة لك مؤقتًا، والاستعارة مشمولة بدون رسوم. أكمل التأكيد قبل انتهاء المهلة.</p>
                    </g:else>
                </g:elseif>
                <g:elseif test="${reservation.status == 'PAID'}">
                    <p>اكتمل دفع رسوم الاستعارة والنسخة محفوظة باسمك. مدة الـ14 يوم تبدأ عند التسليم الفعلي.</p>
                </g:elseif>
                <g:elseif test="${reservation.status == 'CONFIRMED'}">
                    <p>تم تأكيد الاستعارة بدون رسوم ضمن الميزة المتاحة لك، والنسخة محفوظة حتى التسليم.</p>
                </g:elseif>
                <g:elseif test="${reservation.status == 'FULFILLED'}">
                    <p>تم تسليم النسخة وبدأت الاستعارة الفعلية.</p>
                </g:elseif>
                <g:else>
                    <p>هذا الحجز مغلق ولا يحتاج إجراء إضافيًا.</p>
                </g:else>

                <div class="mn-meta-row">
                    <span class="mn-meta-chip">النسخة: ${reservation.assignedCopy?.copyCode ?: 'لم تخصص بعد'}</span>
                    <span class="mn-meta-chip"><ui:label value="${reservation.fulfillmentMethod}"/></span>
                    <span class="mn-meta-chip"><ui:label value="${reservation.fulfillmentStatus}"/></span>
                </div>
            </div>
        </div>

        <div class="mn-form-shell mt-4">
            <div>
                <div class="mn-panel">
                    <div class="mn-panel-body">
                        <div class="row g-4">
                            <div class="col-md-6">
                                <small class="mn-muted">صاحب الحجز</small>
                                <strong class="d-block" dir="auto">${reservation.user?.fullName ?: reservation.user?.username}</strong>
                            </div>
                            <div class="col-md-6">
                                <small class="mn-muted">تاريخ الطلب</small>
                                <strong class="d-block">${reservation.reservationDate ? g.formatDate(date: reservation.reservationDate, format: 'dd/MM/yyyy HH:mm') : ''}</strong>
                            </div>
                            <div class="col-md-6">
                                <small class="mn-muted">رسوم الاستعارة</small>
                                <strong class="d-block">
                                    <g:if test="${(reservation.feeAmount ?: 0) <= 0}">بدون رسوم</g:if>
                                    <g:else><ui:money value="${reservation.feeAmount}"/></g:else>
                                </strong>
                                <g:if test="${hasActiveMembership}">
                                    <small class="text-success">ميزة العضوية الفعالة</small>
                                </g:if>
                            </div>
                            <g:if test="${reservation.readyUntil}">
                                <div class="col-md-6">
                                    <small class="mn-muted">المهلة</small>
                                    <strong class="d-block">${g.formatDate(date: reservation.readyUntil, format: 'dd/MM/yyyy HH:mm')}</strong>
                                </div>
                            </g:if>
                            <g:if test="${reservation.deliveryAddress}">
                                <div class="col-12">
                                    <small class="mn-muted">عنوان التوصيل</small>
                                    <p dir="auto">${reservation.deliveryAddress}</p>
                                </div>
                            </g:if>
                            <g:if test="${payment}">
                                <div class="col-12">
                                    <small class="mn-muted">مرجع الدفع</small>
                                    <g:link controller="payment" action="show" id="${payment.id}" class="d-block" dir="ltr">${payment.referenceCode}</g:link>
                                </div>
                            </g:if>
                        </div>
                    </div>
                </div>

                <g:if test="${!isAdmin && reservation.status == 'READY'}">
                    <div class="mn-form-section mt-3">
                        <g:if test="${(reservation.feeAmount ?: 0) > 0}">
                            <h2>ثبت الاستعارة</h2>
                            <p>اختر طريقة الاستلام، ثم انتقل إلى الدفع. السعر يُراجع مرة أخرى على الخادم قبل تنفيذ العملية.</p>
                        </g:if>
                        <g:else>
                            <h2>أكد استعارتك بدون رسوم</h2>
                            <p>عضويتك الفعالة تشمل الاستعارة الورقية. اختر طريقة الاستلام ثم أكد الحجز مباشرة بدون Braintree.</p>
                        </g:else>

                        <g:form action="checkout" id="${reservation.id}" method="POST">
                            <div class="mn-field">
                                <label>طريقة الاستلام</label>
                                <select name="fulfillmentMethod" id="reservationFulfillment" class="form-select">
                                    <option value="PICKUP">استلام من المكتبة</option>
                                    <option value="DELIVERY">توصيل</option>
                                </select>
                            </div>
                            <div class="mn-field" id="reservationAddress">
                                <label>عنوان التوصيل</label>
                                <textarea name="deliveryAddress" class="form-control" rows="3" dir="auto"></textarea>
                            </div>
                            <button class="mn-btn mn-btn-primary">
                                <g:if test="${(reservation.feeAmount ?: 0) > 0}">
                                    متابعة إلى الدفع — <ui:money value="${reservation.feeAmount}"/>
                                </g:if>
                                <g:else>تأكيد الاستعارة بدون رسوم</g:else>
                            </button>
                        </g:form>
                    </div>
                </g:if>
            </div>

            <aside class="mn-form-aside">
                <g:if test="${isAdmin && reservation.status == 'WAITING'}">
                    <div class="mn-panel"><div class="mn-panel-body">
                        <strong>تجهيز نسخة</strong>
                        <p class="mn-muted mt-2">اختر نسخة متاحة؛ بعدها يحدد النظام تلقائيًا هل الاستعارة تحتاج رسومًا أو مشمولة بالعضوية.</p>
                        <g:if test="${availableCopyList}">
                            <g:form action="assignCopy" id="${reservation.id}" method="POST">
                                <div class="mn-field"><label>النسخة</label><g:select name="bookCopyId" from="${availableCopyList}" optionKey="id" optionValue="copyCode" class="form-select"/></div>
                                <button class="mn-btn mn-btn-primary w-100">تخصيص النسخة</button>
                            </g:form>
                        </g:if>
                        <g:else><p class="small text-danger mb-0">لا توجد نسخة متاحة الآن.</p></g:else>
                    </div></div>
                </g:if>

                <g:elseif test="${isAdmin && reservation.status in ['READY','PAID','CONFIRMED']}">
                    <div class="mn-panel"><div class="mn-panel-body">
                        <strong>
                            <g:if test="${reservation.status == 'PAID'}">تسليم نسخة مدفوعة</g:if>
                            <g:elseif test="${reservation.status == 'CONFIRMED'}">تسليم استعارة مشمولة</g:elseif>
                            <g:elseif test="${(reservation.feeAmount ?: 0) > 0}">دفع وتسليم من الكاونتر</g:elseif>
                            <g:else>تأكيد وتسليم بدون رسوم</g:else>
                        </strong>
                        <p class="mn-muted mt-2">عند التسليم الفعلي تبدأ مدة الاستعارة البالغة 14 يومًا.</p>

                        <g:form action="handover" id="${reservation.id}" method="POST">
                            <g:if test="${reservation.status == 'READY' && (reservation.feeAmount ?: 0) > 0}">
                                <div class="mn-field"><label>طريقة الدفع</label><select name="paymentMethod" class="form-select"><option value="CASH">نقدي</option><option value="CARD">بطاقة كاونتر</option></select></div>
                                <div class="mn-field"><label>ملاحظات</label><textarea name="notes" class="form-control" rows="2"></textarea></div>
                            </g:if>
                            <button class="mn-btn mn-btn-primary w-100">تأكيد التسليم وبدء الاستعارة</button>
                        </g:form>

                        <g:if test="${reservation.status in ['PAID','CONFIRMED'] && reservation.fulfillmentMethod == 'DELIVERY' && reservation.fulfillmentStatus != 'OUT_FOR_DELIVERY'}">
                            <g:form action="outForDelivery" id="${reservation.id}" method="POST" class="mt-2">
                                <button class="mn-btn mn-btn-light w-100">خرج للتوصيل</button>
                            </g:form>
                        </g:if>
                    </div></div>
                </g:elseif>

                <g:else>
                    <div class="mn-panel"><div class="mn-panel-body">
                        <strong>منطق الحجز</strong>
                        <p class="mn-muted mt-2 mb-0">بانتظار نسخة: يحفظ الدور. جاهز: نسخة مخصصة مؤقتًا. مدفوع أو مؤكد: النسخة محفوظة حتى التسليم. مكتمل: بدأت الاستعارة الفعلية.</p>
                    </div></div>
                </g:else>
            </aside>
        </div>

        <g:if test="${reservation.status in ['WAITING','READY','CONFIRMED'] || (isAdmin && reservation.status == 'PAID')}">
            <g:form action="cancel" id="${reservation.id}" method="POST" class="mt-4">
                <button class="mn-btn mn-btn-danger" data-confirm="إلغاء هذا الحجز؟">إلغاء الحجز</button>
            </g:form>
        </g:if>
    </div>
</section>
<script>
(function(){
    const select = document.getElementById('reservationFulfillment');
    const address = document.getElementById('reservationAddress');
    if (!select || !address) return;
    function update(){ address.style.display = select.value === 'DELIVERY' ? 'block' : 'none'; }
    select.addEventListener('change', update);
    update();
})();
</script>
</body>
</html>
