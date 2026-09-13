<!doctype html><html><head><meta name="layout" content="main"/><title>إضافة كتاب | المنارة</title></head><body><section class="mn-page"><div class="container"><div class="mn-page-head"><div><span class="mn-kicker">إدارة الفهرس</span><h1>إضافة كتاب</h1><p>أضف البيانات يدويًا أو استخدم ISBN لتسريع الفهرسة، ثم راجع كل شيء قبل الحفظ.</p></div><g:link action="index" class="mn-btn mn-btn-light">العودة للكتب</g:link></div><g:hasErrors bean="${book}">
    <div class="alert alert-danger">
        <strong>تعذر حفظ الكتاب:</strong>
        <ul class="mb-0 mt-2">
            <g:eachError bean="${book}" var="error">
                <li><g:message error="${error}"/></li>
            </g:eachError>
        </ul>
    </div>
</g:hasErrors><g:render template="form" model="[book:book, authorList:authorList, categoryList:categoryList, formAction:'save']"/></div></section></body></html>
