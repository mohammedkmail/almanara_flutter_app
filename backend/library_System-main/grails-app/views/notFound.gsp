<!doctype html>
<html>
<head>
    <meta name="layout" content="main"/>
    <title>الصفحة غير موجودة | المنارة</title>
</head>
<body>
<section class="mn-error-page">
    <div class="container">
        <div class="mn-error-card">
            <span class="mn-error-code">404</span>
            <span class="mn-error-icon"><i class="bi bi-compass"></i></span>
            <h1>الصفحة غير موجودة</h1>
            <p>الرابط الذي فتحته غير موجود أو تم نقله. يمكنك العودة للرئيسية أو تصفح كتب المنارة.</p>
            <div class="mn-error-actions">
                <a href="${createLink(uri: '/')}" class="btn btn-primary"><i class="bi bi-house"></i> الرئيسية</a>
                <g:link controller="book" action="index" class="btn btn-outline-primary"><i class="bi bi-book"></i> تصفح الكتب</g:link>
            </div>
        </div>
    </div>
</section>
</body>
</html>
