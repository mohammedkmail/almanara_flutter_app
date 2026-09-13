<!doctype html>
<html>
<head>
    <meta name="layout" content="main"/>
    <title>حجز غرفة دراسة | المنارة</title>
</head>
<body>
<section class="mn-page">
    <div class="container">
        <div class="mn-page-head">
            <div>
                <span class="mn-kicker">غرف الدراسة</span>
                <h1>اختر وقتك، شاهد السعر، ثم ادفع</h1>
                <p>لا يتم إنشاء الحجز النهائي إلا بعد نجاح الدفع. النظام يعيد فحص توفر الغرفة والعطل والسعر لحظة الدفع.</p>
            </div>
            <g:link action="index" class="mn-btn mn-btn-light"><i class="bi bi-clock-history"></i> حجوزاتي</g:link>
        </div>

        <g:if test="${upcomingHolidays}">
            <div class="mn-panel mb-4">
                <div class="mn-panel-body d-flex flex-wrap gap-3 align-items-center">
                    <strong><i class="bi bi-calendar-x ms-1"></i> أيام إغلاق قريبة:</strong>
                    <g:each in="${upcomingHolidays}" var="holiday">
                        <span class="mn-meta-chip">${holiday.holidayDate ? g.formatDate(date: holiday.holidayDate, format: 'dd/MM/yyyy') : ''} — ${holiday.name}</span>
                    </g:each>
                </div>
            </div>
        </g:if>

        <g:if test="${activeRooms}">
            <g:form action="save" method="POST" id="roomBookingForm">
                <div class="mn-form-shell">
                    <div>
                        <div class="mn-form-section">
                            <h2>1. اختر الغرفة</h2>
                            <p>يمكنك تعديل الاسم والصورة والموقع والتجهيزات من لوحة الإدارة.</p>
                            <div class="mn-room-grid">
                                <g:each in="${activeRooms}" var="room">
                                    <label class="mn-room-card position-relative" style="cursor:pointer">
                                        <input class="position-absolute opacity-0 room-radio" type="radio" name="studyRoom.id" value="${room.id}"
                                               data-price="${room.pricePerHour}" data-room-name="${room.displayName()}"
                                               ${roomReservation?.studyRoom?.id == room.id ? 'checked' : ''} required/>
                                        <div class="mn-room-image">
                                            <g:if test="${room.imageData}"><img src="${createLink(controller:'studyRoom', action:'photo', id:room.id)}" alt="${room.displayName()}"/></g:if>
                                            <g:else><i class="bi bi-door-open"></i></g:else>
                                        </div>
                                        <div class="mn-room-card-body">
                                            <div class="d-flex justify-content-between gap-2 align-items-start">
                                                <h3 dir="auto">${room.displayName()}</h3>
                                                <strong><ui:money value="${room.pricePerHour}"/><small class="mn-muted">/ساعة</small></strong>
                                            </div>
                                            <div class="mn-room-specs">
                                                <span><i class="bi bi-people"></i> ${room.capacity} أشخاص</span>
                                                <g:if test="${room.location}"><span><i class="bi bi-geo-alt"></i> ${room.location}</span></g:if>
                                            </div>
                                            <g:if test="${room.features}"><p class="small mn-muted mt-2 mb-0" dir="auto">${room.features}</p></g:if>
                                        </div>
                                    </label>
                                </g:each>
                            </div>
                        </div>

                        <div class="mn-form-section">
                            <h2>2. حدد الفترة</h2>
                            <p>الحد الأدنى 30 دقيقة والحد الأقصى 30 يومًا. المكتبة مفتوحة طوال الأسبوع ما عدا أيام الإغلاق في التقويم.</p>
                            <div class="row g-3">
                                <div class="col-md-6 mn-field">
                                    <label for="startTime">بداية الحجز</label>
                                    <input class="form-control" type="datetime-local" name="startTime" id="startTime"
                                           value="${roomReservation?.startTime ? g.formatDate(date:roomReservation.startTime, format:"yyyy-MM-dd'T'HH:mm") : ''}" required/>
                                </div>
                                <div class="col-md-6 mn-field">
                                    <label for="endTime">نهاية الحجز</label>
                                    <input class="form-control" type="datetime-local" name="endTime" id="endTime"
                                           value="${roomReservation?.endTime ? g.formatDate(date:roomReservation.endTime, format:"yyyy-MM-dd'T'HH:mm") : ''}" required/>
                                </div>
                            </div>
                            <div id="quoteMessage" class="alert d-none mt-3 mb-0"></div>
                        </div>
                    </div>

                    <aside class="mn-form-aside">
                        <div class="mn-price-box">
                            <span class="mn-kicker">ملخص الحجز</span>
                            <div class="mn-price-line"><span>الغرفة</span><strong id="quoteRoom">—</strong></div>
                            <div class="mn-price-line"><span>المدة</span><strong id="quoteDuration">—</strong></div>
                            <div class="mn-price-line"><span>السعر الأساسي</span><strong id="quoteBase">—</strong></div>
                            <div class="mn-price-line discount"><span id="discountLabel">خصم المدة</span><strong id="quoteDiscount">—</strong></div>
                            <div class="mn-price-line total"><span>المبلغ قبل الدفع</span><strong id="quoteTotal">—</strong></div>
                        </div>
                        <button type="submit" id="continueToPayment" class="mn-btn mn-btn-accent w-100 mt-3" disabled>
                            متابعة إلى الدفع <i class="bi bi-credit-card"></i>
                        </button>
                        <p class="mn-help mt-2 text-center">لن يظهر الحجز في سجلك إلا بعد نجاح Braintree Sandbox.</p>
                    </aside>
                </div>
            </g:form>
        </g:if>
        <g:else>
            <div class="mn-panel"><div class="mn-empty"><i class="bi bi-door-closed"></i><h3>لا توجد غرف فعالة حاليًا</h3><p>تواصل مع إدارة المكتبة أو حاول لاحقًا.</p></div></div>
        </g:else>
    </div>
</section>

<script>
(function(){
    const radios=[...document.querySelectorAll('.room-radio')];
    const start=document.getElementById('startTime');
    const end=document.getElementById('endTime');
    const button=document.getElementById('continueToPayment');
    const message=document.getElementById('quoteMessage');
    let timer;

    function money(v){ return '$'+Number(v||0).toFixed(2); }
    function selected(){ return radios.find(r=>r.checked); }
    function paint(){
        radios.forEach(r=>r.closest('.mn-room-card').style.outline=r.checked?'3px solid var(--sl-gold)':'none');
    }
    async function quote(){
        paint();
        const room=selected();
        button.disabled=true;
        if(!room || !start.value || !end.value) return;
        clearTimeout(timer);
        timer=setTimeout(async()=>{
            const body=new URLSearchParams({studyRoomId:room.value,startTime:start.value,endTime:end.value});
            try{
                const response=await fetch('${createLink(controller:"roomReservation",action:"quote")}',{
                    method:'POST', headers:{'Content-Type':'application/x-www-form-urlencoded;charset=UTF-8'}, body:body.toString()
                });
                const data=await response.json();
                message.classList.remove('d-none','alert-danger','alert-success');
                if(!data.ok){
                    message.classList.add('alert-danger'); message.textContent=data.message || 'الفترة غير متاحة.'; return;
                }
                message.classList.add('alert-success'); message.textContent='الفترة متاحة. سيعاد فحصها لحظة الدفع.';
                document.getElementById('quoteRoom').textContent=room.dataset.roomName;
                document.getElementById('quoteDuration').textContent=Number(data.durationHours).toFixed(1)+' ساعة';
                document.getElementById('quoteBase').textContent=money(data.basePrice);
                document.getElementById('quoteDiscount').textContent='-'+money(data.discountAmount)+' ('+Number(data.discountPercentage||0).toFixed(0)+'%)';
                document.getElementById('discountLabel').textContent=data.ruleName || 'خصم المدة';
                document.getElementById('quoteTotal').textContent=money(data.totalPrice);
                button.disabled=false;
            }catch(e){
                message.classList.remove('d-none','alert-success'); message.classList.add('alert-danger');
                message.textContent='تعذر حساب السعر الآن. حاول مرة أخرى.';
            }
        },350);
    }
    radios.forEach(r=>r.addEventListener('change',quote)); start?.addEventListener('change',quote); end?.addEventListener('change',quote); paint(); quote();
})();
</script>
</body>
</html>
