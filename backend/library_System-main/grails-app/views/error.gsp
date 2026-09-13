<!doctype html>
<html>
<head>
    <meta name="layout" content="main"/>
    <title>حدث خطأ | المنارة</title>
</head>
<body>
<section class="mn-error-page">
    <div class="container">
        <div class="mn-error-card">
            <span class="mn-error-code">500</span>
            <span class="mn-error-icon danger"><i class="bi bi-exclamation-triangle"></i></span>
            <h1>حدث خطأ غير متوقع</h1>
            <p>تعذر إكمال الطلب حالياً. جرّب العودة للرئيسية ثم أعد المحاولة.</p>
            <g:if test="${exception}">
                <details class="mn-error-details">
                    <summary>تفاصيل تقنية</summary>
                    <div><strong>الرسالة:</strong> ${exception.message}</div>
                </details>
            </g:if>
            <div class="mn-error-actions">
                <a href="${createLink(uri: '/')}" class="btn btn-primary"><i class="bi bi-house"></i> العودة للرئيسية</a>
            </div>
        </div>
    </div>
</section>
</body>
</html>
