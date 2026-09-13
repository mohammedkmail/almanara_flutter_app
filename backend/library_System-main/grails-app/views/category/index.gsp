<!doctype html>
<html>
<head>
    <meta name="layout" content="main"/>
    <title>الأقسام | المنارة</title>
</head>
<body>
<section class="mn-catalog-page mn-categories-catalog">
    <div class="container">
        <header class="mn-editorial-header">
            <div>
                <span class="mn-editorial-kicker">اختر رفّك</span>
                <h1>أقسام المكتبة</h1>
                <p>بدل القوائم التقليدية، كل قسم هنا يعمل كرف مستقل: فكرة واضحة، وصف قصير، وعدد الكتب التي ستجدها داخله.</p>
            </div>
            <div class="mn-editorial-side">
                <span class="mn-count-stamp"><b>${categoryCount ?: 0}</b> قسم</span>
                <sec:ifAnyGranted roles="ROLE_ADMIN"><g:link action="create" class="mn-solid-action"><i class="bi bi-plus-lg"></i> إضافة قسم</g:link></sec:ifAnyGranted>
            </div>
        </header>

        <g:if test="${categoryList}">
            <div class="mn-category-ledger">
                <g:each in="${categoryList}" var="category" status="i">
                    <article class="mn-category-ledger-row">
                        <div class="mn-category-number">${String.format('%02d', i + 1 + (params.int('offset') ?: 0))}</div>
                        <div class="mn-category-spine"><span></span><span></span><span></span></div>
                        <div class="mn-category-copy">
                            <span class="mn-note-label">${categoryBookCounts?.get(category.id) ?: 0} كتاب</span>
                            <h2><g:link action="show" id="${category.id}">${category.name}</g:link></h2>
                            <p>${category.description ?: 'لم يُضف وصف لهذا القسم بعد.'}</p>
                        </div>
                        <div class="mn-category-row-actions">
                            <g:if test="${isAdmin && !category.active}"><span class="mn-mini-badge">غير مفعّل</span></g:if>
                            <g:link action="show" id="${category.id}" class="mn-round-arrow" aria-label="فتح القسم"><i class="bi bi-arrow-left"></i></g:link>
                            <sec:ifAnyGranted roles="ROLE_ADMIN"><g:link action="edit" id="${category.id}" class="mn-icon-action" title="تعديل"><i class="bi bi-pencil"></i></g:link></sec:ifAnyGranted>
                        </div>
                    </article>
                </g:each>
            </div>
            <div class="mn-pagination-wrap"><g:paginate total="${categoryCount ?: 0}" max="${params.int('max') ?: 12}"/></div>
        </g:if>
        <g:else><div class="mn-catalog-empty"><i class="bi bi-grid"></i><h2>لا توجد أقسام متاحة الآن</h2><p>ستظهر الأقسام هنا بمجرد إضافتها وتفعيلها.</p></div></g:else>
    </div>
</section>
</body>
</html>
