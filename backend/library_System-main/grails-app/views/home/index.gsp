<!doctype html>
<html>
<head>
    <meta name="layout" content="main"/>
    <title>المنارة | مكتبتك للمعرفة</title>
</head>
<body>

<div class="mn-home">

    <!-- =========================================================
         HERO
    ========================================================== -->
    <section class="mn-hero mn-hero-cinematic">

        <div class="mn-hero-photo" aria-hidden="true">
            <asset:image src="project_image/main_image.png" alt=""/>
        </div>

        <div class="mn-hero-overlay" aria-hidden="true"></div>

        <div class="container mn-hero-cinematic-container">
            <div class="mn-hero-cinematic-copy">

                <span class="mn-hero-cinematic-kicker">
                    <i class="bi bi-stars"></i>
                    المعرفة تبدأ من كتاب
                </span>

                <h1>
                    اكتشف عالماً
                    <span>من المعرفة</span>
                </h1>

                <p>
                    كتب ورقية ورقمية، حجوزات واستعارات وغرف دراسة؛
                    كل خدمات مكتبة المنارة بين يديك في مكان واحد.
                </p>

                <g:form controller="book"
                        action="index"
                        method="GET"
                        class="mn-cinematic-search">

                    <i class="bi bi-search"></i>

                    <input type="search"
                           name="search"
                           placeholder="ابحث عن كتاب أو مؤلف..."
                           autocomplete="off"
                           aria-label="ابحث عن كتاب أو مؤلف"/>

                    <button type="submit">
                        بحث
                    </button>
                </g:form>

                <div class="mn-cinematic-stats">

                    <g:link controller="book" action="index" class="mn-cinematic-stat">
                        <span class="mn-cinematic-stat-icon">
                            <i class="bi bi-book"></i>
                        </span>
                        <strong>${totalBooks ?: 0}</strong>
                        <small>كتاب متاح</small>
                    </g:link>

                    <sec:ifLoggedIn>
                        <g:link controller="dashboard" action="index" class="mn-cinematic-stat">
                            <span class="mn-cinematic-stat-icon">
                                <i class="bi bi-people"></i>
                            </span>
                            <strong>${totalMembers ?: 0}</strong>
                            <small>عضو مسجّل</small>
                        </g:link>
                    </sec:ifLoggedIn>

                    <sec:ifNotLoggedIn>
                        <g:link controller="register" action="create" class="mn-cinematic-stat">
                            <span class="mn-cinematic-stat-icon">
                                <i class="bi bi-people"></i>
                            </span>
                            <strong>${totalMembers ?: 0}</strong>
                            <small>عضو مسجّل</small>
                        </g:link>
                    </sec:ifNotLoggedIn>

                    <g:link controller="book" action="index" class="mn-cinematic-stat">
                        <span class="mn-cinematic-stat-icon">
                            <i class="bi bi-journal-check"></i>
                        </span>
                        <strong>${availableCopies ?: 0}</strong>
                        <small>نسخة جاهزة</small>
                    </g:link>

                    <sec:ifLoggedIn>
                        <g:link controller="digitalAccess" action="index" class="mn-cinematic-stat">
                            <span class="mn-cinematic-stat-icon">
                                <i class="bi bi-tablet"></i>
                            </span>
                            <strong>${totalDigitalBooks ?: 0}</strong>
                            <small>كتاب رقمي</small>
                        </g:link>
                    </sec:ifLoggedIn>

                    <sec:ifNotLoggedIn>
                        <g:link controller="book" action="index" class="mn-cinematic-stat">
                            <span class="mn-cinematic-stat-icon">
                                <i class="bi bi-tablet"></i>
                            </span>
                            <strong>${totalDigitalBooks ?: 0}</strong>
                            <small>كتاب رقمي</small>
                        </g:link>
                    </sec:ifNotLoggedIn>

                </div>

                <div class="mn-cinematic-actions">
                    <g:link controller="book" action="index" class="mn-cinematic-link">
                        تصفح المجموعة
                        <i class="bi bi-arrow-left"></i>
                    </g:link>

                    <sec:ifAnyGranted roles="ROLE_USER">
                        <g:link controller="roomReservation" action="create" class="mn-cinematic-link secondary">
                            حجز غرفة دراسة
                            <i class="bi bi-door-open"></i>
                        </g:link>
                    </sec:ifAnyGranted>

                    <sec:ifAnyGranted roles="ROLE_ADMIN">
                        <g:link controller="dashboard" action="index" class="mn-cinematic-link secondary">
                            لوحة الإدارة
                            <i class="bi bi-speedometer2"></i>
                        </g:link>
                    </sec:ifAnyGranted>
                </div>

            </div>
        </div>

        <a href="#homeContentStart"
           class="mn-hero-scroll-cue"
           aria-label="انتقل إلى محتوى الصفحة">
            <i class="bi bi-chevron-up"></i>
        </a>

    </section>

    <span id="homeContentStart" class="mn-scroll-anchor"></span>


    <!-- =========================================================
         DASHBOARD STRIP - LOGGED IN
    ========================================================== -->
    <sec:ifLoggedIn>
        <section class="mn-dashboard-section">
            <div class="container">

                <div class="mn-section-heading compact">
                    <div>
                        <span class="mn-section-kicker">
                            ${isAdmin ? 'لوحة الإدارة' : 'مساحتي في المنارة'}
                        </span>
                        <h2>
                            ${isAdmin ? 'أهم ما يحتاج متابعتك الآن' : 'ملخص نشاطك الحالي'}
                        </h2>
                    </div>

                    <g:link controller="dashboard" action="index" class="mn-section-link">
                        فتح لوحة التحكم
                        <i class="bi bi-arrow-left"></i>
                    </g:link>
                </div>

                <g:if test="${isAdmin}">
                    <div class="mn-dashboard-metrics">
                        <g:link controller="borrowing" action="index" class="mn-dashboard-metric danger">
                            <span class="mn-dashboard-icon"><i class="bi bi-exclamation-triangle"></i></span>
                            <strong>${overdueBorrowingCount ?: 0}</strong>
                            <small>استعارات متأخرة</small>
                        </g:link>

                        <g:link controller="reservation" action="index" class="mn-dashboard-metric amber">
                            <span class="mn-dashboard-icon"><i class="bi bi-hourglass-split"></i></span>
                            <strong>${waitingReservationCount ?: 0}</strong>
                            <small>حجوزات بانتظار التجهيز</small>
                        </g:link>

                        <g:link controller="reservation" action="index" class="mn-dashboard-metric teal">
                            <span class="mn-dashboard-icon"><i class="bi bi-bag-check"></i></span>
                            <strong>${confirmedReservationCount ?: 0}</strong>
                            <small>مؤكدة وجاهزة للتسليم</small>
                        </g:link>

                        <g:link controller="roomReservation" action="index" class="mn-dashboard-metric blue">
                            <span class="mn-dashboard-icon"><i class="bi bi-door-open"></i></span>
                            <strong>${confirmedRoomReservationCount ?: 0}</strong>
                            <small>حجوزات غرف مؤكدة قادمة</small>
                        </g:link>
                    </div>

                    <div class="mn-dashboard-panels">
                        <div class="mn-activity-panel">
                            <div class="mn-panel-heading">
                                <div>
                                    <span>تحتاج انتباهاً</span>
                                    <h3>الاستعارات المتأخرة</h3>
                                </div>

                                <g:link controller="borrowing" action="index">عرض الكل</g:link>
                            </div>

                            <g:if test="${urgentBorrowings}">
                                <div class="mn-activity-list">
                                    <g:each in="${urgentBorrowings}" var="borrowing">
                                        <div class="mn-activity-item">
                                            <span class="mn-activity-symbol danger"><i class="bi bi-book"></i></span>
                                            <div class="mn-activity-copy">
                                                <strong dir="auto">${borrowing.bookCopy?.book?.title}</strong>
                                                <small>
                                                    ${borrowing.user?.username}
                                                    <span>•</span>
                                                    استحقاق
                                                    <g:formatDate date="${borrowing.dueDate}" format="dd/MM/yyyy"/>
                                                </small>
                                            </div>
                                            <g:link controller="borrowing" action="show" id="${borrowing.id}" class="mn-mini-link">
                                                التفاصيل
                                            </g:link>
                                        </div>
                                    </g:each>
                                </div>
                            </g:if>
                            <g:else>
                                <div class="mn-empty-state small">
                                    <i class="bi bi-check2-circle"></i>
                                    <strong>لا توجد استعارات متأخرة حالياً</strong>
                                </div>
                            </g:else>
                        </div>

                        <div class="mn-quick-panel">
                            <div class="mn-panel-heading">
                                <div>
                                    <span>وصول سريع</span>
                                    <h3>إجراءات الإدارة</h3>
                                </div>
                            </div>

                            <div class="mn-quick-grid">
                                <g:link controller="book" action="create">
                                    <i class="bi bi-plus-square"></i>
                                    <strong>إضافة كتاب</strong>
                                </g:link>

                                <g:link controller="bookCopy" action="index">
                                    <i class="bi bi-collection"></i>
                                    <strong>نسخ الكتب</strong>
                                </g:link>

                                <g:link controller="reservation" action="index">
                                    <i class="bi bi-bookmark-check"></i>
                                    <strong>الحجوزات</strong>
                                </g:link>

                                <g:link controller="studyRoom" action="index">
                                    <i class="bi bi-door-open"></i>
                                    <strong>غرف الدراسة</strong>
                                </g:link>
                            </div>
                        </div>
                    </div>
                </g:if>

                <g:else>
                    <div class="mn-dashboard-metrics">
                        <g:link controller="borrowing" action="index" class="mn-dashboard-metric teal">
                            <span class="mn-dashboard-icon"><i class="bi bi-book-half"></i></span>
                            <strong>${userBorrowings?.size() ?: 0}</strong>
                            <small>كتب معك الآن</small>
                        </g:link>

                        <g:link controller="reservation" action="index" class="mn-dashboard-metric amber">
                            <span class="mn-dashboard-icon"><i class="bi bi-bookmark"></i></span>
                            <strong>${userReservations?.size() ?: 0}</strong>
                            <small>حجوزات كتب فعالة</small>
                        </g:link>

                        <g:link controller="roomReservation" action="index" class="mn-dashboard-metric blue">
                            <span class="mn-dashboard-icon"><i class="bi bi-door-open"></i></span>
                            <strong>${userRoomReservations?.size() ?: 0}</strong>
                            <small>حجوزات غرف قادمة</small>
                        </g:link>

                        <g:link controller="membership" action="index" class="mn-dashboard-metric ${hasActiveMembership ? 'green' : 'danger'}">
                            <span class="mn-dashboard-icon"><i class="bi bi-person-badge"></i></span>
                            <strong class="textual">${hasActiveMembership ? 'فعالة' : 'غير فعالة'}</strong>
                            <small>العضوية</small>
                        </g:link>
                    </div>

                    <div class="mn-dashboard-panels">
                        <div class="mn-activity-panel">
                            <div class="mn-panel-heading">
                                <div>
                                    <span>نشاطك</span>
                                    <h3>الكتب والحجوزات الحالية</h3>
                                </div>

                                <g:link controller="dashboard" action="index">التفاصيل</g:link>
                            </div>

                            <g:if test="${userBorrowings || userReservations}">
                                <div class="mn-activity-list">
                                    <g:each in="${userBorrowings.take(Math.min(2, userBorrowings.size()))}" var="borrowing">
                                        <div class="mn-activity-item">
                                            <span class="mn-activity-symbol ${borrowing.status == 'OVERDUE' || (borrowing.dueDate && borrowing.dueDate.before(new Date())) ? 'danger' : 'teal'}">
                                                <i class="bi bi-book"></i>
                                            </span>
                                            <div class="mn-activity-copy">
                                                <strong dir="auto">${borrowing.bookCopy?.book?.title}</strong>
                                                <small>
                                                    موعد الإرجاع
                                                    <g:formatDate date="${borrowing.dueDate}" format="dd/MM/yyyy"/>
                                                </small>
                                            </div>
                                            <g:link controller="borrowing" action="show" id="${borrowing.id}" class="mn-mini-link">عرض</g:link>
                                        </div>
                                    </g:each>

                                    <g:each in="${userReservations.take(Math.min(2, userReservations.size()))}" var="reservation">
                                        <div class="mn-activity-item">
                                            <span class="mn-activity-symbol ${reservation.status in ['PAID','CONFIRMED'] ? 'green' : 'amber'}">
                                                <i class="bi bi-bookmark"></i>
                                            </span>
                                            <div class="mn-activity-copy">
                                                <strong dir="auto">${reservation.book?.title}</strong>
                                                <small>
                                                    <ui:label value="${reservation.status}"/>
                                                    <g:if test="${reservation.status in ['READY','PAID','CONFIRMED'] && reservation.readyUntil}">
                                                        <span>•</span>
                                                        حتى <g:formatDate date="${reservation.readyUntil}" format="dd/MM HH:mm"/>
                                                    </g:if>
                                                </small>
                                            </div>
                                            <g:link controller="reservation" action="show" id="${reservation.id}" class="mn-mini-link">عرض</g:link>
                                        </div>
                                    </g:each>
                                </div>
                            </g:if>
                            <g:else>
                                <div class="mn-empty-state small">
                                    <i class="bi bi-book"></i>
                                    <strong>لا يوجد نشاط حالي</strong>
                                    <span>ابدأ باستكشاف الكتب أو حجز غرفة دراسة.</span>
                                </div>
                            </g:else>
                        </div>

                        <div class="mn-quick-panel">
                            <div class="mn-panel-heading">
                                <div>
                                    <span>وصول سريع</span>
                                    <h3>ماذا تريد أن تفعل؟</h3>
                                </div>
                            </div>

                            <div class="mn-quick-grid">
                                <g:link controller="book" action="index">
                                    <i class="bi bi-search"></i>
                                    <strong>ابحث عن كتاب</strong>
                                </g:link>

                                <g:link controller="roomReservation" action="create">
                                    <i class="bi bi-calendar-plus"></i>
                                    <strong>احجز غرفة</strong>
                                </g:link>

                                <g:link controller="digitalAccess" action="index">
                                    <i class="bi bi-tablet"></i>
                                    <strong>المكتبة الرقمية</strong>
                                </g:link>

                                <g:link controller="membership" action="index">
                                    <i class="bi bi-person-badge"></i>
                                    <strong>العضوية</strong>
                                </g:link>
                            </div>
                        </div>
                    </div>
                </g:else>
            </div>
        </section>
    </sec:ifLoggedIn>


    <!-- =========================================================
         POPULAR BOOKS
    ========================================================== -->
    <section class="mn-home-section mn-books-section">
        <div class="container">
            <div class="mn-section-heading">
                <div>
                    <span class="mn-section-kicker">اختيارات القرّاء</span>
                    <h2>الأكثر استعارة</h2>
                    <p>العناوين الأكثر حضوراً في حركة الاستعارة داخل المنارة.</p>
                </div>

                <g:link controller="book" action="index" class="mn-section-link">
                    عرض جميع الكتب
                    <i class="bi bi-arrow-left"></i>
                </g:link>
            </div>

            <div class="mn-horizontal-wrap books">
                <g:if test="${popularBooks?.size() > 6}">
                    <button type="button"
                            class="mn-scroll-control prev"
                            data-scroll-target="#popularBooks"
                            data-scroll-direction="-1"
                            aria-label="السابق">
                        <i class="bi bi-chevron-right"></i>
                    </button>
                </g:if>

                <div class="mn-book-grid" id="popularBooks">
                    <g:if test="${popularBooks}">
                        <g:each in="${popularBooks}" var="book">
                            <article class="mn-book-card">
                                <g:link controller="book" action="show" id="${book.id}" class="mn-book-cover-link">
                                    <div class="mn-book-cover">
                                        <g:if test="${book.coverData || book.externalCoverUrl}">
                                            <img src="${createLink(controller: 'book', action: 'cover', id: book.id)}"
                                                 alt="${book.title}"/>
                                        </g:if>
                                        <g:else>
                                            <div class="mn-book-cover-placeholder">
                                                <i class="bi bi-book"></i>
                                                <strong dir="auto">${book.title}</strong>
                                            </div>
                                        </g:else>

                                        <g:if test="${book.digitalAvailable}">
                                            <span class="mn-book-badge">رقمي</span>
                                        </g:if>
                                    </div>
                                </g:link>

                                <div class="mn-book-card-body">
                                    <span class="mn-book-category" dir="auto">${book.category?.name}</span>

                                    <h3 dir="auto">
                                        <g:link controller="book" action="show" id="${book.id}">
                                            ${book.title}
                                        </g:link>
                                    </h3>

                                    <p dir="auto">${book.author?.name}</p>

                                    <div class="mn-book-meta">
                                        <span>
                                            <i class="bi bi-arrow-left-right"></i>
                                            ${borrowCountByBookId[book.id] ?: 0} استعارة
                                        </span>

                                        <g:if test="${book.publishYear}">
                                            <span>${book.publishYear}</span>
                                        </g:if>
                                    </div>

                                    <g:link controller="book" action="show" id="${book.id}" class="mn-book-action">
                                        عرض الكتاب
                                    </g:link>
                                </div>
                            </article>
                        </g:each>
                    </g:if>
                    <g:else>
                        <div class="mn-empty-state wide">
                            <i class="bi bi-bookshelf"></i>
                            <strong>لا توجد كتب لعرضها بعد</strong>
                        </div>
                    </g:else>
                </div>

                <g:if test="${popularBooks?.size() > 6}">
                    <button type="button"
                            class="mn-scroll-control next"
                            data-scroll-target="#popularBooks"
                            data-scroll-direction="1"
                            aria-label="التالي">
                        <i class="bi bi-chevron-left"></i>
                    </button>
                </g:if>
            </div>
        </div>
    </section>


    <!-- =========================================================
         VALUE / MEMBERSHIP
    ========================================================== -->
    <section class="mn-home-section mn-value-section">
        <div class="container">
            <div class="mn-value-grid">

                <div class="mn-membership-banner">
                    <div class="mn-membership-copy">
                        <span>عضوية المنارة</span>
                        <h2>عضوية واحدة تفتح لك استعارة ورقية بدون رسوم ومكتبة رقمية أوسع.</h2>
                        <p>
                            تبدأ العضوية من <strong>$${membershipPricePerDay} يومياً</strong>،
                            وكلما طالت مدة الاشتراك زاد التوفير.
                        </p>

                        <div class="mn-home-membership-benefits">
                            <span><i class="bi bi-bookmark-check"></i> استعارة ورقية بدون رسوم</span>
                            <span><i class="bi bi-tablet"></i> كتب رقمية مختارة ضمن العضوية</span>
                            <span><i class="bi bi-stars"></i> خصم يصل إلى 20% على مدة الاشتراك</span>
                        </div>

                        <div class="mn-home-membership-tiers">
                            <g:each in="${membershipDiscountTiers?.reverse()}" var="tier">
                                <span><b>${tier.percentage}%</b> ${tier.label}</span>
                            </g:each>
                        </div>

                        <sec:ifAnyGranted roles="ROLE_USER">
                            <g:if test="${hasActiveMembership}">
                                <g:link controller="digitalAccess" action="index" class="mn-banner-action">
                                    افتح مكتبتي الرقمية
                                </g:link>
                            </g:if>
                            <g:else>
                                <g:link controller="membership" action="create" class="mn-banner-action">
                                    ابدأ عضويتك
                                </g:link>
                            </g:else>
                        </sec:ifAnyGranted>

                        <sec:ifAnyGranted roles="ROLE_ADMIN">
                            <g:link controller="membership" action="index" class="mn-banner-action">
                                إدارة العضويات
                            </g:link>
                        </sec:ifAnyGranted>

                        <sec:ifNotLoggedIn>
                            <g:link controller="register" action="create" class="mn-banner-action">
                                أنشئ حساباً الآن
                            </g:link>
                        </sec:ifNotLoggedIn>
                    </div>

                    <div class="mn-membership-illustration" aria-hidden="true">
                        <span class="book-a"></span>
                        <span class="book-b"></span>
                        <span class="book-c"></span>
                        <span class="cup"><i class="bi bi-cup-hot"></i></span>
                    </div>
                </div>

                <div class="mn-why-panel">
                    <div class="mn-why-heading">
                        <span>لماذا المنارة؟</span>
                        <h2>كل ما تحتاجه من مكتبتك</h2>
                    </div>

                    <div class="mn-why-grid">
                        <div>
                            <i class="bi bi-book-half"></i>
                            <strong>استعارة منظمة</strong>
                            <small>حجوزات واستلام وإرجاع واضح.</small>
                        </div>

                        <div>
                            <i class="bi bi-tablet"></i>
                            <strong>قراءة رقمية</strong>
                            <small>وصول للكتب الرقمية حسب صلاحيتك.</small>
                        </div>

                        <div>
                            <i class="bi bi-door-open"></i>
                            <strong>غرف دراسة</strong>
                            <small>احجز مساحة هادئة بوقت مناسب.</small>
                        </div>

                        <div>
                            <i class="bi bi-person-badge"></i>
                            <strong>عضوية تستاهل</strong>
                            <small>استعارة ورقية بلا رسوم، كتب رقمية مختارة، وتوفير أكبر للمدد الأطول.</small>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </section>


    <!-- =========================================================
         VISIT GUIDE
    ========================================================== -->
    <section class="mn-home-section mn-visit-section">
        <div class="container">
            <div class="mn-section-heading">
                <div>
                    <span class="mn-section-kicker">قبل ما تبدأ</span>
                    <h2>استخدم المكتبة بطريقتك</h2>
                    <p>ثلاث خطوات واضحة بدون قوائم طويلة أو إجراءات مخفية.</p>
                </div>
            </div>

            <div class="mn-visit-grid">
                <g:link controller="book" action="index" class="mn-visit-card">
                    <span class="mn-visit-number">01</span>
                    <i class="bi bi-search"></i>
                    <strong>دوّر على كتابك</strong>
                    <small>ابحث بالعنوان أو المؤلف أو القسم، وشوف النسخ والخدمات المتاحة مباشرة.</small>
                </g:link>

                <sec:ifLoggedIn>
                    <g:link controller="roomReservation" action="create" class="mn-visit-card">
                        <span class="mn-visit-number">02</span>
                        <i class="bi bi-door-open"></i>
                        <strong>احجز غرفة وادفع</strong>
                        <small>اختَر الوقت والغرفة، ثم أكمل الدفع التجريبي لتأكيد الموعد.</small>
                    </g:link>
                </sec:ifLoggedIn>
                <sec:ifNotLoggedIn>
                    <g:link controller="register" action="create" class="mn-visit-card">
                        <span class="mn-visit-number">02</span>
                        <i class="bi bi-person-plus"></i>
                        <strong>افتح حسابك</strong>
                        <small>الحساب يفتح لك الحجز والشراء، والعضوية تجعل الاستعارة الورقية بدون رسوم وتضيف وصولًا رقميًا أوسع.</small>
                    </g:link>
                </sec:ifNotLoggedIn>

                <div class="mn-visit-card static">
                    <span class="mn-visit-number">03</span>
                    <i class="bi bi-calendar2-check"></i>
                    <strong>مفتوح طوال الأسبوع</strong>
                    <small>لا يوجد إغلاق أسبوعي ثابت؛ الحجز يتوقف تلقائياً فقط في العطل المسجلة.</small>
                    <g:if test="${upcomingHolidays}">
                        <span class="mn-next-holiday">
                            أقرب عطلة: ${upcomingHolidays[0].name} —
                            <g:formatDate date="${upcomingHolidays[0].holidayDate}" format="dd/MM/yyyy"/>
                        </span>
                    </g:if>
                </div>
            </div>
        </div>
    </section>


    <!-- =========================================================
         FINAL CTA
    ========================================================== -->
    <section class="mn-home-section mn-final-cta-section">
        <div class="container">
            <div class="mn-final-cta">
                <span class="mn-final-icon"><i class="bi bi-envelope-paper"></i></span>

                <div>
                    <span>ابدأ رحلتك اليوم</span>
                    <h2>كتابك القادم أقرب مما تتوقع.</h2>
                    <p>ابحث في المجموعة أو افتح حسابك وابدأ باستخدام خدمات المنارة.</p>
                </div>

                <div class="mn-final-actions">
                    <g:link controller="book" action="index" class="mn-final-primary">
                        استكشف الكتب
                    </g:link>

                    <sec:ifNotLoggedIn>
                        <g:link controller="register" action="create" class="mn-final-secondary">
                            إنشاء حساب
                        </g:link>
                    </sec:ifNotLoggedIn>

                    <sec:ifLoggedIn>
                        <g:link controller="dashboard" action="index" class="mn-final-secondary">
                            لوحة التحكم
                        </g:link>
                    </sec:ifLoggedIn>
                </div>
            </div>
        </div>
    </section>

</div>
</body>
</html>
