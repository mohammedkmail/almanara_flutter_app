<!doctype html>
<html lang="ar" dir="rtl">
<head>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>
    <meta http-equiv="X-UA-Compatible" content="IE=edge"/>
    <meta name="viewport" content="width=device-width, initial-scale=1"/>

    <title><g:layoutTitle default="المنارة"/></title>

    <asset:link rel="icon" href="favicon.ico" type="image/x-ico"/>
    <link rel="preconnect" href="https://fonts.googleapis.com"/>
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin="anonymous"/>
    <link href="https://fonts.googleapis.com/css2?family=Alexandria:wght@400;500;600;700;800&amp;family=IBM+Plex+Sans+Arabic:wght@400;500;600;700&amp;display=swap" rel="stylesheet"/>

    <asset:stylesheet src="application.css"/>

    <g:layoutHead/>
</head>

<body class="manara-site manara-controller-${controllerName ?: 'page'} ${controllerName == 'home' ? 'manara-home-page' : 'manara-inner-page'}">

<header class="manara-header">
    <nav class="navbar navbar-expand-xl manara-navbar">
        <div class="container">

            <a class="navbar-brand manara-brand" href="${createLink(uri: '/')}">
                <span class="manara-brand-mark" aria-hidden="true">
                    <span class="manara-brand-book"><i class="bi bi-book-half"></i></span>
                    <span class="manara-brand-ray"><i class="bi bi-stars"></i></span>
                </span>

                <span class="manara-brand-copy">
                    <strong>المنارة</strong>
                    <small>مكتبتك للمعرفة</small>
                </span>
            </a>

            <button class="navbar-toggler manara-navbar-toggler"
                    type="button"
                    data-bs-toggle="collapse"
                    data-bs-target="#manaraMainNavbar"
                    aria-controls="manaraMainNavbar"
                    aria-expanded="false"
                    aria-label="فتح القائمة">
                <i class="bi bi-list"></i>
            </button>

            <div class="collapse navbar-collapse" id="manaraMainNavbar">

                <ul class="navbar-nav manara-main-nav">
                    <li class="nav-item">
                        <a class="nav-link ${controllerName == 'home' ? 'active' : ''}"
                           href="${createLink(uri: '/')}">
                            الرئيسية
                        </a>
                    </li>

                    <li class="nav-item">
                        <g:link controller="book"
                                action="index"
                                class="nav-link ${controllerName == 'book' ? 'active' : ''}">
                            الكتب
                        </g:link>
                    </li>

                    <li class="nav-item">
                        <g:link controller="category"
                                action="index"
                                class="nav-link ${controllerName == 'category' ? 'active' : ''}">
                            الأقسام
                        </g:link>
                    </li>

                    <li class="nav-item">
                        <g:link controller="author"
                                action="index"
                                class="nav-link ${controllerName == 'author' ? 'active' : ''}">
                            المؤلفون
                        </g:link>
                    </li>

                    <sec:ifAnyGranted roles="ROLE_USER">
                        <li class="nav-item dropdown">
                            <a class="nav-link dropdown-toggle ${controllerName in ['dashboard','membership','borrowing','reservation','purchase','digitalAccess','roomReservation'] ? 'active' : ''}"
                               href="#"
                               id="myLibraryDropdown"
                               role="button"
                               data-bs-toggle="dropdown"
                               aria-expanded="false">
                                مكتبتي
                            </a>

                            <ul class="dropdown-menu dropdown-menu-end manara-dropdown manara-user-menu"
                                aria-labelledby="myLibraryDropdown">

                                <li class="manara-dropdown-profile">
                                    <span class="manara-dropdown-avatar"><i class="bi bi-person"></i></span>
                                    <span>
                                        <small>مرحباً بك</small>
                                        <strong><sec:loggedInUserInfo field="username"/></strong>
                                    </span>
                                </li>

                                <li><hr class="dropdown-divider"/></li>

                                <li>
                                    <g:link controller="dashboard" action="index" class="dropdown-item">
                                        <i class="bi bi-grid"></i>
                                        <span>لوحة التحكم</span>
                                    </g:link>
                                </li>

                                <li>
                                    <g:link controller="membership" action="index" class="dropdown-item">
                                        <i class="bi bi-person-badge"></i>
                                        <span>عضويتي</span>
                                    </g:link>
                                </li>

                                <li><hr class="dropdown-divider"/></li>

                                <li>
                                    <g:link controller="borrowing" action="index" class="dropdown-item">
                                        <i class="bi bi-arrow-left-right"></i>
                                        <span>استعاراتي</span>
                                    </g:link>
                                </li>

                                <li>
                                    <g:link controller="reservation" action="index" class="dropdown-item">
                                        <i class="bi bi-bookmark"></i>
                                        <span>حجوزات الكتب</span>
                                    </g:link>
                                </li>

                                <li>
                                    <g:link controller="purchase" action="index" class="dropdown-item">
                                        <i class="bi bi-bag"></i>
                                        <span>مشترياتي</span>
                                    </g:link>
                                </li>

                                <li>
                                    <g:link controller="payment" action="index" class="dropdown-item">
                                        <i class="bi bi-receipt"></i>
                                        <span>مدفوعاتي</span>
                                    </g:link>
                                </li>

                                <li>
                                    <g:link controller="digitalAccess" action="index" class="dropdown-item">
                                        <i class="bi bi-tablet"></i>
                                        <span>مكتبتي الرقمية</span>
                                    </g:link>
                                </li>

                                <li><hr class="dropdown-divider"/></li>

                                <li>
                                    <g:link controller="roomReservation" action="create" class="dropdown-item">
                                        <i class="bi bi-calendar-plus"></i>
                                        <span>حجز غرفة دراسة</span>
                                    </g:link>
                                </li>

                                <li>
                                    <g:link controller="roomReservation" action="index" class="dropdown-item">
                                        <i class="bi bi-door-open"></i>
                                        <span>حجوزات الغرف</span>
                                    </g:link>
                                </li>
                            </ul>
                        </li>
                    </sec:ifAnyGranted>

                    <sec:ifAnyGranted roles="ROLE_ADMIN">
                        <li class="nav-item dropdown">
                            <a class="nav-link dropdown-toggle ${controllerName in ['dashboard','bookCopy','borrowing','reservation','purchase','membership','studyRoom','roomReservation','payment','holiday','discountRule'] ? 'active' : ''}"
                               href="#"
                               id="adminDropdown"
                               role="button"
                               data-bs-toggle="dropdown"
                               aria-expanded="false">
                                الإدارة
                            </a>

                            <div class="dropdown-menu dropdown-menu-end manara-dropdown manara-admin-menu"
                                 aria-labelledby="adminDropdown">
                                <div class="manara-admin-menu-grid">

                                    <section>
                                        <h3><i class="bi bi-bookshelf"></i> المحتوى</h3>

                                        <g:link controller="book" action="index" class="dropdown-item">
                                            <i class="bi bi-book"></i><span>الكتب</span>
                                        </g:link>

                                        <g:link controller="book" action="create" class="dropdown-item">
                                            <i class="bi bi-plus-circle"></i><span>إضافة كتاب</span>
                                        </g:link>

                                        <g:link controller="author" action="index" class="dropdown-item">
                                            <i class="bi bi-pen"></i><span>المؤلفون</span>
                                        </g:link>

                                        <g:link controller="category" action="index" class="dropdown-item">
                                            <i class="bi bi-grid"></i><span>الأقسام</span>
                                        </g:link>

                                        <g:link controller="bookCopy" action="index" class="dropdown-item">
                                            <i class="bi bi-collection"></i><span>نسخ الكتب</span>
                                        </g:link>
                                    </section>

                                    <section>
                                        <h3><i class="bi bi-arrow-repeat"></i> الحركة</h3>

                                        <g:link controller="dashboard" action="index" class="dropdown-item">
                                            <i class="bi bi-speedometer2"></i><span>لوحة التحكم</span>
                                        </g:link>

                                        <g:link controller="borrowing" action="index" class="dropdown-item">
                                            <i class="bi bi-arrow-left-right"></i><span>الاستعارات</span>
                                        </g:link>

                                        <g:link controller="reservation" action="index" class="dropdown-item">
                                            <i class="bi bi-bookmark-check"></i><span>حجوزات الكتب</span>
                                        </g:link>

                                        <g:link controller="purchase" action="index" class="dropdown-item">
                                            <i class="bi bi-bag-check"></i><span>المشتريات</span>
                                        </g:link>

                                        <g:link controller="membership" action="index" class="dropdown-item">
                                            <i class="bi bi-people"></i><span>العضويات</span>
                                        </g:link>

                                        <g:link controller="purchase" action="counterSale" class="dropdown-item">
                                            <i class="bi bi-shop"></i><span>بيع مباشر من الكاونتر</span>
                                        </g:link>

                                        <g:link controller="payment" action="index" class="dropdown-item">
                                            <i class="bi bi-credit-card"></i><span>سجل المدفوعات</span>
                                        </g:link>
                                    </section>

                                    <section>
                                        <h3><i class="bi bi-door-open"></i> غرف الدراسة</h3>

                                        <g:link controller="studyRoom" action="index" class="dropdown-item">
                                            <i class="bi bi-door-closed"></i><span>إدارة الغرف</span>
                                        </g:link>

                                        <g:link controller="roomReservation" action="index" class="dropdown-item">
                                            <i class="bi bi-calendar-check"></i><span>حجوزات الغرف</span>
                                        </g:link>

                                        <g:link controller="discountRule" action="index" class="dropdown-item">
                                            <i class="bi bi-percent"></i><span>قواعد الخصم</span>
                                        </g:link>

                                        <g:link controller="holiday" action="index" class="dropdown-item">
                                            <i class="bi bi-calendar3"></i><span>تقويم العطل</span>
                                        </g:link>
                                    </section>
                                </div>
                            </div>
                        </li>
                    </sec:ifAnyGranted>
                </ul>

                <div class="manara-navbar-tools">
                    <g:form controller="book"
                            action="index"
                            method="GET"
                            class="manara-navbar-search"
                            id="globalLibrarySearch">

                        <i class="bi bi-search"></i>

                        <input type="search"
                               name="search"
                               value="${controllerName == 'book' ? search : ''}"
                               placeholder="ابحث عن كتاب أو مؤلف..."
                               autocomplete="off"
                               aria-label="البحث في المكتبة"/>

                        <kbd>Ctrl K</kbd>
                    </g:form>

                    <sec:ifLoggedIn>
                        <div class="dropdown">
                            <button class="manara-account-button dropdown-toggle"
                                    type="button"
                                    id="accountDropdown"
                                    data-bs-toggle="dropdown"
                                    aria-expanded="false">
                                <span class="manara-account-avatar"><i class="bi bi-person"></i></span>
                                <span class="manara-account-name"><sec:loggedInUserInfo field="username"/></span>
                            </button>

                            <ul class="dropdown-menu dropdown-menu-start manara-dropdown manara-account-menu"
                                aria-labelledby="accountDropdown">
                                <li>
                                    <g:link controller="dashboard" action="index" class="dropdown-item">
                                        <i class="bi bi-grid"></i><span>لوحة التحكم</span>
                                    </g:link>
                                </li>
                                <li><hr class="dropdown-divider"/></li>
                                <li>
                                    <form action="${createLink(controller: 'logout')}" method="POST" class="m-0">
                                        <button type="submit" class="dropdown-item manara-logout-item">
                                            <i class="bi bi-box-arrow-left"></i><span>تسجيل الخروج</span>
                                        </button>
                                    </form>
                                </li>
                            </ul>
                        </div>
                    </sec:ifLoggedIn>

                    <sec:ifNotLoggedIn>
                        <g:link controller="login" action="auth" class="manara-login-button">
                            <i class="bi bi-person"></i>
                            <span>تسجيل الدخول</span>
                        </g:link>
                    </sec:ifNotLoggedIn>
                </div>
            </div>
        </div>
    </nav>
</header>

<main class="manara-main">
    <g:if test="${flash.message}">
        <div class="container manara-flash-container">
            <div class="alert manara-flash-message alert-dismissible fade show" role="alert">
                <i class="bi bi-check-circle"></i>
                <span>${flash.message}</span>
                <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="إغلاق"></button>
            </div>
        </div>
    </g:if>

    <g:layoutBody/>
</main>

<footer class="manara-footer">
    <div class="container">
        <div class="manara-footer-grid">

            <section class="manara-footer-brand">
                <a class="manara-footer-logo" href="${createLink(uri: '/')}">
                    <span class="manara-brand-mark" aria-hidden="true">
                        <span class="manara-brand-book"><i class="bi bi-book-half"></i></span>
                        <span class="manara-brand-ray"><i class="bi bi-stars"></i></span>
                    </span>
                    <strong>المنارة</strong>
                </a>

                <p>
                    مكتبة تجمع الكتب الورقية والقراءة الرقمية ومساحات الدراسة
                    في تجربة واضحة وسهلة.
                </p>
            </section>

            <section class="manara-footer-column">
                <h3>روابط سريعة</h3>
                <a href="${createLink(uri: '/')}">الرئيسية</a>
                <g:link controller="book" action="index">الكتب</g:link>
                <g:link controller="category" action="index">الأقسام</g:link>
                <g:link controller="author" action="index">المؤلفون</g:link>
            </section>

            <section class="manara-footer-column">
                <h3>خدمات المكتبة</h3>

                <sec:ifLoggedIn>
                    <g:link controller="borrowing" action="index">الاستعارات</g:link>
                    <g:link controller="reservation" action="index">حجوزات الكتب</g:link>
                    <g:link controller="digitalAccess" action="index">المكتبة الرقمية</g:link>
                </sec:ifLoggedIn>

                <sec:ifNotLoggedIn>
                    <g:link controller="book" action="index">استكشف الكتب</g:link>
                    <g:link controller="login" action="auth">تسجيل الدخول</g:link>
                    <g:link controller="register" action="create">إنشاء حساب</g:link>
                </sec:ifNotLoggedIn>
            </section>

            <section class="manara-footer-column">
                <h3>حسابك</h3>

                <sec:ifLoggedIn>
                    <g:link controller="dashboard" action="index">لوحة التحكم</g:link>

                    <sec:ifAnyGranted roles="ROLE_USER">
                        <g:link controller="membership" action="index">العضوية</g:link>
                        <g:link controller="purchase" action="index">المشتريات</g:link>
                        <g:link controller="roomReservation" action="index">حجوزات الغرف</g:link>
                    </sec:ifAnyGranted>
                </sec:ifLoggedIn>

                <sec:ifNotLoggedIn>
                    <g:link controller="login" action="auth">تسجيل الدخول</g:link>
                    <g:link controller="register" action="create">إنشاء حساب</g:link>
                </sec:ifNotLoggedIn>
            </section>
        </div>

        <div class="manara-footer-bottom">
            <span>
                جميع الحقوق محفوظة &copy;
                <g:formatDate date="${new Date()}" format="yyyy"/>
                المنارة
            </span>

            <span><i class="bi bi-book"></i> نظام إدارة المكتبة</span>
        </div>
    </div>
</footer>

<div id="spinner" class="manara-page-loader" aria-hidden="true">
    <div class="spinner-border" role="status">
        <span class="visually-hidden">جاري التحميل...</span>
    </div>
</div>

<asset:javascript src="application.js"/>
</body>
</html>
