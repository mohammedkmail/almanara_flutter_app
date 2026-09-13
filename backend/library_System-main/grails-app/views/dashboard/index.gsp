<!DOCTYPE html>
<html>
<head>
    <meta name="layout" content="main"/>
    <title>لوحة التحكم | المنارة</title>
</head>
<body>

<section class="mn-system-page mn-dashboard-page">
    <div class="container">
        <div class="mn-page-heading">
            <div>
                <span class="mn-page-kicker"><i class="bi bi-grid"></i> ${isAdmin ? 'إدارة المنارة' : 'مساحتي الشخصية'}</span>
                <h1>${isAdmin ? 'لوحة تحكم الإدارة' : 'لوحة تحكمي'}</h1>
                <p>${isAdmin ? 'مؤشرات تشغيلية تساعدك على متابعة حركة المكتبة واتخاذ الإجراء المناسب.' : 'ملخص مختصر لما يخص حسابك فقط: استعاراتك، حجوزاتك، مشترياتك ووصولك الرقمي.'}</p>
            </div>

            <div class="mn-page-actions">
                <g:link controller="book" action="index" class="btn btn-outline-primary">
                    <i class="bi bi-book"></i> تصفح الكتب
                </g:link>
                <g:if test="${isAdmin}">
                    <g:link controller="book" action="create" class="btn btn-primary">
                        <i class="bi bi-plus-circle"></i> إضافة كتاب
                    </g:link>
                </g:if>
            </div>
        </div>

        <g:if test="${isAdmin}">
            <div class="mn-dashboard-grid">
                <g:link controller="book" action="index" class="mn-dashboard-card">
                    <span class="mn-dashboard-card-icon"><i class="bi bi-bookshelf"></i></span>
                    <div><small>إجمالي الكتب</small><strong>${totalBooks ?: 0}</strong><p>كتاب مسجل في النظام</p></div>
                    <i class="bi bi-arrow-left mn-dashboard-card-arrow"></i>
                </g:link>

                <g:link controller="borrowing" action="index" class="mn-dashboard-card">
                    <span class="mn-dashboard-card-icon"><i class="bi bi-arrow-left-right"></i></span>
                    <div><small>الاستعارات الفعالة</small><strong>${activeBorrowings ?: 0}</strong><p>كتب ما زالت قيد الاستعارة</p></div>
                    <i class="bi bi-arrow-left mn-dashboard-card-arrow"></i>
                </g:link>

                <g:link controller="borrowing" action="index" class="mn-dashboard-card warning">
                    <span class="mn-dashboard-card-icon"><i class="bi bi-exclamation-triangle"></i></span>
                    <div><small>استعارات متأخرة</small><strong>${overdueBorrowings ?: 0}</strong><p>تحتاج متابعة من الإدارة</p></div>
                    <i class="bi bi-arrow-left mn-dashboard-card-arrow"></i>
                </g:link>

                <g:link controller="reservation" action="index" class="mn-dashboard-card">
                    <span class="mn-dashboard-card-icon"><i class="bi bi-bookmark"></i></span>
                    <div><small>الحجوزات المنتظرة</small><strong>${waitingReservations ?: 0}</strong><p>طلبات بانتظار توفر نسخة</p></div>
                    <i class="bi bi-arrow-left mn-dashboard-card-arrow"></i>
                </g:link>

                <g:link controller="purchase" action="index" class="mn-dashboard-card highlight">
                    <span class="mn-dashboard-card-icon"><i class="bi bi-cash-stack"></i></span>
                    <div><small>إجمالي المبيعات</small><strong>$${totalSales ?: 0}</strong><p>${completedPurchases ?: 0} عملية شراء مكتملة</p></div>
                    <i class="bi bi-arrow-left mn-dashboard-card-arrow"></i>
                </g:link>

                <g:link controller="roomReservation" action="index" class="mn-dashboard-card">
                    <span class="mn-dashboard-card-icon"><i class="bi bi-door-open"></i></span>
                    <div><small>حجوزات الغرف</small><strong>${confirmedRoomReservations ?: 0}</strong><p>حجوزات مؤكدة قادمة</p></div>
                    <i class="bi bi-arrow-left mn-dashboard-card-arrow"></i>
                </g:link>
            </div>

            <div class="mn-dashboard-shortcuts">
                <div class="mn-dashboard-shortcuts-copy">
                    <span>إجراءات الإدارة</span>
                    <h2>انتقل مباشرة إلى ما يحتاج متابعة</h2>
                </div>
                <div class="mn-dashboard-shortcuts-grid">
                    <g:link controller="borrowing" action="index"><i class="bi bi-arrow-left-right"></i><span>الاستعارات</span></g:link>
                    <g:link controller="reservation" action="index"><i class="bi bi-bookmark-check"></i><span>حجوزات الكتب</span></g:link>
                    <g:link controller="bookCopy" action="index"><i class="bi bi-collection"></i><span>نسخ الكتب</span></g:link>
                    <g:link controller="payment" action="index"><i class="bi bi-credit-card"></i><span>المدفوعات</span></g:link>
                    <g:link controller="studyRoom" action="index"><i class="bi bi-door-closed"></i><span>إدارة الغرف</span></g:link>
                    <g:link controller="discountRule" action="index"><i class="bi bi-percent"></i><span>قواعد الخصم</span></g:link>
                </div>
            </div>
        </g:if>

        <g:else>
            <div class="mn-dashboard-grid mn-user-dashboard-grid">
                <g:link controller="borrowing" action="index" class="mn-dashboard-card">
                    <span class="mn-dashboard-card-icon"><i class="bi bi-arrow-left-right"></i></span>
                    <div><small>استعاراتي الحالية</small><strong>${activeBorrowings ?: 0}</strong><p>${overdueBorrowings ? overdueBorrowings + ' منها متأخرة' : 'تابع مواعيد الإرجاع من هنا'}</p></div>
                    <i class="bi bi-arrow-left mn-dashboard-card-arrow"></i>
                </g:link>

                <g:link controller="reservation" action="index" class="mn-dashboard-card">
                    <span class="mn-dashboard-card-icon"><i class="bi bi-bookmark-check"></i></span>
                    <div><small>حجوزات الكتب</small><strong>${activeReservations ?: 0}</strong><p>حجوزات بانتظار نسخة أو استلام</p></div>
                    <i class="bi bi-arrow-left mn-dashboard-card-arrow"></i>
                </g:link>

                <g:link controller="roomReservation" action="index" class="mn-dashboard-card">
                    <span class="mn-dashboard-card-icon"><i class="bi bi-calendar-check"></i></span>
                    <div><small>حجوزات الغرف القادمة</small><strong>${confirmedRoomReservations ?: 0}</strong><p>مواعيدك المؤكدة فقط</p></div>
                    <i class="bi bi-arrow-left mn-dashboard-card-arrow"></i>
                </g:link>

                <g:link controller="purchase" action="index" class="mn-dashboard-card">
                    <span class="mn-dashboard-card-icon"><i class="bi bi-bag-check"></i></span>
                    <div><small>مشترياتي</small><strong>${completedPurchases ?: 0}</strong><p>عمليات الشراء المكتملة بحسابك</p></div>
                    <i class="bi bi-arrow-left mn-dashboard-card-arrow"></i>
                </g:link>

                <g:link controller="digitalAccess" action="index" class="mn-dashboard-card highlight">
                    <span class="mn-dashboard-card-icon"><i class="bi bi-tablet"></i></span>
                    <div><small>مكتبتي الرقمية</small><strong>${digitalAccessCount ?: 0}</strong><p>كتب رقمية متاحة لك حاليًا</p></div>
                    <i class="bi bi-arrow-left mn-dashboard-card-arrow"></i>
                </g:link>

                <g:link controller="membership" action="index" class="mn-dashboard-card ${activeMembership ? 'membership-active' : ''}">
                    <span class="mn-dashboard-card-icon"><i class="bi bi-person-badge"></i></span>
                    <div>
                        <small>العضوية</small>
                        <strong class="dashboard-text-value">${activeMembership ? 'فعّالة' : 'غير فعّالة'}</strong>
                        <p><g:if test="${activeMembership}">استعارة بدون رسوم حتى <g:formatDate date="${activeMembership.endDate}" format="dd/MM/yyyy"/></g:if><g:else>فعّلها لاستعارة بدون رسوم ومزايا رقمية</g:else></p>
                    </div>
                    <i class="bi bi-arrow-left mn-dashboard-card-arrow"></i>
                </g:link>
            </div>

            <div class="mn-dashboard-shortcuts">
                <div class="mn-dashboard-shortcuts-copy">
                    <span>وصول سريع</span>
                    <h2>كل ما يخص حسابك بدون ازدحام إداري</h2>
                </div>
                <div class="mn-dashboard-shortcuts-grid">
                    <g:link controller="book" action="index"><i class="bi bi-search"></i><span>ابحث عن كتاب</span></g:link>
                    <g:link controller="borrowing" action="index"><i class="bi bi-arrow-left-right"></i><span>استعاراتي</span></g:link>
                    <g:link controller="reservation" action="index"><i class="bi bi-bookmark-check"></i><span>حجوزاتي</span></g:link>
                    <g:link controller="digitalAccess" action="index"><i class="bi bi-tablet"></i><span>مكتبتي الرقمية</span></g:link>
                    <g:link controller="roomReservation" action="create"><i class="bi bi-calendar-plus"></i><span>احجز غرفة</span></g:link>
                    <g:link controller="membership" action="create"><i class="bi bi-person-badge"></i><span>العضوية</span></g:link>
                </div>
            </div>
        </g:else>
    </div>
</section>

</body>
</html>
