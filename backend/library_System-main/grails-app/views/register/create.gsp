<!doctype html>
<html>
<head>
    <meta name="layout" content="main"/>
    <title>إنشاء حساب | المنارة</title>
</head>
<body>

<section class="mn-auth-page">
    <div class="container">
        <div class="mn-auth-shell">

            <div class="mn-auth-visual">
                <div class="mn-auth-photo" aria-hidden="true">
                    <asset:image src="project_image/main_image.png" alt=""/>
                </div>
                <div class="mn-auth-overlay" aria-hidden="true"></div>

                <div class="mn-auth-visual-content">
                    <a href="${createLink(uri: '/')}" class="mn-auth-brand">
                        <span class="mn-auth-brand-icon"><i class="bi bi-book-half"></i></span>
                        <span>
                            <strong>المنارة</strong>
                            <small>مكتبتك للمعرفة</small>
                        </span>
                    </a>

                    <div class="mn-auth-copy">
                        <span class="mn-auth-eyebrow"><i class="bi bi-stars"></i> ابدأ من هنا</span>
                        <h1>حساب واحد، <span>ومكتبة كاملة.</span></h1>
                        <p>
                            أنشئ حسابك لتتمكن من حجز الكتب، استخدام المكتبة الرقمية
                            وحجز غرف الدراسة من مكان واحد.
                        </p>
                    </div>

                    <div class="mn-auth-benefits">
                        <div>
                            <span><i class="bi bi-journal-bookmark"></i></span>
                            <strong>احجز كتبك</strong>
                            <small>تابع حالة كل حجز بسهولة.</small>
                        </div>
                        <div>
                            <span><i class="bi bi-tablet"></i></span>
                            <strong>مكتبة رقمية</strong>
                            <small>كل كتبك الرقمية ضمن حسابك.</small>
                        </div>
                        <div>
                            <span><i class="bi bi-door-open"></i></span>
                            <strong>مساحات دراسة</strong>
                            <small>اختر الغرفة والوقت المناسبين لك.</small>
                        </div>
                    </div>
                </div>
            </div>

            <div class="mn-auth-form-side">
                <div class="mn-auth-form-wrap">
                    <div class="mn-auth-form-heading">
                        <span>حساب جديد</span>
                        <h2>انضم إلى المنارة</h2>
                        <p>أدخل بياناتك لإنشاء حساب مستخدم جديد.</p>
                    </div>

                    <g:hasErrors bean="${user}">
                        <div class="mn-auth-alert">
                            <i class="bi bi-exclamation-circle"></i>
                            <div>
                                <g:eachError bean="${user}" var="error">
                                    <div><g:message error="${error}"/></div>
                                </g:eachError>
                            </div>
                        </div>
                    </g:hasErrors>

                    <g:form controller="register" action="save" method="POST" class="mn-auth-form">
                        <div class="mn-auth-field">
                            <label for="fullName">الاسم الكامل</label>
                            <div class="mn-auth-input-wrap">
                                <span class="mn-auth-input-icon"><i class="bi bi-person-vcard"></i></span>
                                <input type="text"
                                       name="fullName"
                                       id="fullName"
                                       class="form-control mn-auth-input"
                                       value="${user?.fullName ?: ''}"
                                       placeholder="الاسم الذي سيظهر في الحجوزات والاستعارات"
                                       autocomplete="name"
                                       dir="auto"/>
                            </div>
                        </div>

                        <div class="mn-auth-field">
                            <label for="username">اسم المستخدم / البريد الإلكتروني</label>
                            <div class="mn-auth-input-wrap">
                                <span class="mn-auth-input-icon"><i class="bi bi-person"></i></span>
                                <input type="text"
                                       name="username"
                                       id="username"
                                       class="form-control mn-auth-input"
                                       value="${user?.username ?: ''}"
                                       placeholder="مثال: hadi@example.com"
                                       autocomplete="username"
                                       required
                                       autofocus/>
                            </div>
                        </div>

                        <div class="mn-auth-field">
                            <label for="password">كلمة المرور</label>
                            <div class="mn-auth-input-wrap">
                                <span class="mn-auth-input-icon"><i class="bi bi-lock"></i></span>
                                <input type="password"
                                       name="password"
                                       id="password"
                                       class="form-control mn-auth-input mn-auth-password-input"
                                       placeholder="أنشئ كلمة مرور"
                                       autocomplete="new-password"
                                       required/>
                                <button type="button"
                                        class="mn-auth-password-toggle"
                                        data-password-target="password"
                                        aria-label="إظهار كلمة المرور">
                                    <i class="bi bi-eye"></i>
                                </button>
                            </div>
                        </div>

                        <div class="mn-auth-field">
                            <label for="confirmPassword">تأكيد كلمة المرور</label>
                            <div class="mn-auth-input-wrap">
                                <span class="mn-auth-input-icon"><i class="bi bi-shield-lock"></i></span>
                                <input type="password"
                                       name="confirmPassword"
                                       id="confirmPassword"
                                       class="form-control mn-auth-input mn-auth-password-input"
                                       placeholder="أعد كتابة كلمة المرور"
                                       autocomplete="new-password"
                                       required/>
                                <button type="button"
                                        class="mn-auth-password-toggle"
                                        data-password-target="confirmPassword"
                                        aria-label="إظهار كلمة المرور">
                                    <i class="bi bi-eye"></i>
                                </button>
                            </div>
                        </div>

                        <button type="submit" class="btn mn-auth-submit">
                            <span>إنشاء الحساب</span>
                            <i class="bi bi-arrow-left"></i>
                        </button>
                    </g:form>

                    <div class="mn-auth-separator"><span></span><small>أو</small><span></span></div>

                    <div class="mn-auth-switch">
                        <span>لديك حساب بالفعل؟</span>
                        <g:link controller="login" action="auth">تسجيل الدخول</g:link>
                    </div>

                    <a href="${createLink(uri: '/')}" class="mn-auth-home-link">
                        <i class="bi bi-arrow-right"></i>
                        العودة إلى الرئيسية
                    </a>
                </div>
            </div>

        </div>
    </div>
</section>

<script>
document.addEventListener('DOMContentLoaded', function () {
    document.querySelectorAll('.mn-auth-password-toggle').forEach(function (button) {
        button.addEventListener('click', function () {
            const targetId = button.getAttribute('data-password-target');
            const input = document.getElementById(targetId);
            if (!input) return;

            const hidden = input.type === 'password';
            input.type = hidden ? 'text' : 'password';
            button.innerHTML = hidden
                ? '<i class="bi bi-eye-slash"></i>'
                : '<i class="bi bi-eye"></i>';
        });
    });
});
</script>

</body>
</html>
