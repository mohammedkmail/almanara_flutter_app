<!doctype html>
<html>
<head>
    <meta name="layout" content="main"/>
    <title>تسجيل الدخول | المنارة</title>
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
                        <span class="mn-auth-eyebrow"><i class="bi bi-stars"></i> أهلاً بعودتك</span>
                        <h1>كل خدمات مكتبتك <span>في مكان واحد.</span></h1>
                        <p>
                            سجّل دخولك لإدارة الاستعارات والحجوزات، الوصول إلى مكتبتك الرقمية
                            وحجز غرف الدراسة بسهولة.
                        </p>
                    </div>

                    <div class="mn-auth-benefits">
                        <div>
                            <span><i class="bi bi-bookmark-check"></i></span>
                            <strong>حجز واستعارة</strong>
                            <small>تابع كتبك وحجوزاتك الحالية.</small>
                        </div>
                        <div>
                            <span><i class="bi bi-tablet"></i></span>
                            <strong>قراءة رقمية</strong>
                            <small>وصول واضح للمحتوى الذي تملكه.</small>
                        </div>
                        <div>
                            <span><i class="bi bi-door-open"></i></span>
                            <strong>غرف الدراسة</strong>
                            <small>احجز وقتك ومساحتك من حسابك.</small>
                        </div>
                    </div>
                </div>
            </div>

            <div class="mn-auth-form-side">
                <div class="mn-auth-form-wrap">
                    <div class="mn-auth-form-heading">
                        <span>تسجيل الدخول</span>
                        <h2>مرحباً بك في المنارة</h2>
                        <p>أدخل بيانات حسابك للمتابعة.</p>
                    </div>

                    <g:if test="${flash.message}">
                        <div class="mn-auth-alert">
                            <i class="bi bi-exclamation-circle"></i>
                            <span>${flash.message}</span>
                        </div>
                    </g:if>

                    <form action="${postUrl ?: createLink(uri: '/login/authenticate')}"
                          method="POST"
                          id="loginForm"
                          autocomplete="off"
                          class="mn-auth-form">

                        <div class="mn-auth-field">
                            <label for="username">اسم المستخدم</label>
                            <div class="mn-auth-input-wrap">
                                <span class="mn-auth-input-icon"><i class="bi bi-person"></i></span>
                                <input type="text"
                                       name="${usernameParameter ?: 'username'}"
                                       id="username"
                                       class="form-control mn-auth-input"
                                       placeholder="أدخل اسم المستخدم"
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
                                       name="${passwordParameter ?: 'password'}"
                                       id="password"
                                       class="form-control mn-auth-input mn-auth-password-input"
                                       placeholder="أدخل كلمة المرور"
                                       autocomplete="current-password"
                                       required/>
                                <button type="button"
                                        class="mn-auth-password-toggle"
                                        id="togglePassword"
                                        aria-label="إظهار كلمة المرور">
                                    <i class="bi bi-eye"></i>
                                </button>
                            </div>
                        </div>

                        <div class="mn-auth-options">
                            <label class="mn-auth-remember">
                                <input type="checkbox"
                                       name="${rememberMeParameter ?: 'remember-me'}"
                                       id="remember_me"/>
                                <span>تذكرني</span>
                            </label>
                        </div>

                        <button type="submit" class="btn mn-auth-submit">
                            <span>دخول إلى الحساب</span>
                            <i class="bi bi-arrow-left"></i>
                        </button>
                    </form>

                    <div class="mn-auth-separator"><span></span><small>أو</small><span></span></div>

                    <div class="mn-auth-switch">
                        <span>ليس لديك حساب؟</span>
                        <g:link controller="register" action="create">إنشاء حساب جديد</g:link>
                    </div>

                    <div class="mn-auth-security">
                        <i class="bi bi-shield-check"></i>
                        <span>دخول آمن ومحمي بواسطة Spring Security</span>
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
    const passwordInput = document.getElementById('password');
    const toggleButton = document.getElementById('togglePassword');

    if (passwordInput && toggleButton) {
        toggleButton.addEventListener('click', function () {
            const hidden = passwordInput.type === 'password';
            passwordInput.type = hidden ? 'text' : 'password';
            toggleButton.innerHTML = hidden
                ? '<i class="bi bi-eye-slash"></i>'
                : '<i class="bi bi-eye"></i>';
            toggleButton.setAttribute(
                'aria-label',
                hidden ? 'إخفاء كلمة المرور' : 'إظهار كلمة المرور'
            );
        });
    }
});
</script>

</body>
</html>
