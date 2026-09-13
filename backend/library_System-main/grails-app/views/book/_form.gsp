<g:uploadForm action="${formAction}" id="${book?.id}" method="${formAction == 'update' ? 'PUT' : 'POST'}">

    <g:if test="${book?.id}">
        <g:hiddenField name="version" value="${book?.version}"/>
    </g:if>

    <div class="mn-form-shell">

        <div>

            <!-- ========================================================= -->
            <!-- بيانات الفهرسة -->
            <!-- ========================================================= -->

            <div class="mn-form-section">

                <div class="d-flex justify-content-between align-items-start gap-3 flex-wrap mb-3">

                    <div>
                        <h2>بيانات الفهرسة</h2>
                        <p class="mb-0">
                            أسماء الكتب والمؤلفين تقبل العربية والإنجليزية كما هي.
                        </p>
                    </div>

                    <button
                        type="button"
                        class="mn-btn mn-btn-light mn-btn-sm"
                        id="metadataLookup">

                        <i class="bi bi-stars"></i>
                        جلب البيانات من ISBN

                    </button>

                </div>


                <div
                    id="metadataMessage"
                    class="alert d-none">
                </div>


                <div class="row g-3">

                    <!-- اسم الكتاب -->

                    <div class="col-md-8 mn-field">

                        <label>اسم الكتاب</label>

                        <input
                            class="form-control"
                            name="title"
                            id="title"
                            value="${book?.title ?: ''}"
                            required
                            dir="auto"/>

                        <g:fieldError
                            bean="${book}"
                            field="title"/>

                    </div>


                    <!-- ISBN -->

                    <div class="col-md-4 mn-field">

                        <label>ISBN</label>

                        <input
                            class="form-control"
                            name="isbn"
                            id="isbn"
                            value="${book?.isbn ?: ''}"
                            required
                            dir="ltr"/>

                    </div>


                    <!-- الوصف -->

                    <div class="col-12 mn-field">

                        <label>الوصف</label>

                        <textarea
                            class="form-control"
                            name="description"
                            id="description"
                            rows="5"
                            dir="auto">${book?.description ?: ''}</textarea>

                    </div>


                    <!-- المؤلف الموجود -->

                    <div class="col-md-6 mn-field">

                        <label>المؤلف الموجود</label>

                        <g:select
                            name="author.id"
                            id="authorSelect"
                            from="${authorList}"
                            optionKey="id"
                            optionValue="name"
                            value="${book?.author?.id}"
                            noSelection="${['': 'اختر المؤلف']}"
                            class="form-select"/>

                        <div class="mn-help">
                            اختر مؤلفًا موجودًا، أو أضف مؤلفًا جديدًا من الحقل المجاور.
                        </div>

                    </div>


                    <!-- إضافة مؤلف جديد -->

                    <div class="col-md-6 mn-field">

                        <label>إضافة مؤلف جديد</label>

                        <input
                            type="text"
                            class="form-control"
                            name="newAuthorName"
                            id="newAuthorName"
                            value="${params.newAuthorName ?: ''}"
                            maxlength="180"
                            placeholder="مثال: نجيب محفوظ"
                            dir="auto"/>

                        <div
                            class="mn-help"
                            id="newAuthorHelp">

                            إذا كان الاسم موجودًا مسبقًا،
                            سيتم استخدام المؤلف الموجود بدل إنشاء نسخة مكررة.

                        </div>

                    </div>


                    <!-- القسم -->

                    <div class="col-md-4 mn-field">

                        <label>القسم</label>

                        <g:select
                            name="category.id"
                            id="categorySelect"
                            from="${categoryList}"
                            optionKey="id"
                            optionValue="name"
                            value="${book?.category?.id}"
                            noSelection="${['': 'اختر القسم']}"
                            class="form-select"
                            required="required"/>

                    </div>


                    <!-- سنة النشر -->

                    <div class="col-md-4 mn-field">

                        <label>سنة النشر</label>

                        <input
                            type="number"
                            min="0"
                            class="form-control"
                            name="publishYear"
                            id="publishYear"
                            value="${book?.publishYear ?: ''}"/>

                    </div>


                    <!-- اللغة -->

                    <div class="col-md-4 mn-field">

                        <label>اللغة</label>

                        <input
                            class="form-control"
                            name="language"
                            id="language"
                            value="${book?.language ?: ''}"
                            placeholder="ar / en"
                            dir="auto"/>

                    </div>


                    <!-- الناشر -->

                    <div class="col-md-8 mn-field">

                        <label>الناشر</label>

                        <input
                            class="form-control"
                            name="publisher"
                            id="publisher"
                            value="${book?.publisher ?: ''}"
                            dir="auto"/>

                    </div>


                    <!-- عدد الصفحات -->

                    <div class="col-md-4 mn-field">

                        <label>عدد الصفحات</label>

                        <input
                            type="number"
                            min="1"
                            class="form-control"
                            name="pageCount"
                            id="pageCount"
                            value="${book?.pageCount ?: ''}"/>

                    </div>

                </div>

            </div>


            <!-- ========================================================= -->
            <!-- الغلاف -->
            <!-- ========================================================= -->

            <div class="mn-form-section">

                <h2>الغلاف</h2>

                <p>
                    ارفع صورة من جهازك،
                    أو استخدم الغلاف المقترح من مصدر خارجي.
                    الصورة المرفوعة لها الأولوية.
                </p>


                <div class="mn-field">

                    <label>رفع غلاف</label>

                    <input
                        type="file"
                        name="coverFile"
                        accept="image/*"
                        class="form-control"/>

                    <div class="mn-help">
                        يفضل JPG/PNG/WebP وبحجم لا يتجاوز 5MB.
                    </div>

                </div>


                <div class="mn-field">

                    <label>رابط غلاف خارجي</label>

                    <input
                        type="url"
                        name="externalCoverUrl"
                        id="externalCoverUrl"
                        value="${book?.externalCoverUrl ?: ''}"
                        class="form-control"
                        dir="ltr"/>

                </div>


                <g:if test="${book?.coverData || book?.externalCoverUrl}">

                    <div class="mt-3">

                        <img
                            src="${createLink(controller: 'book', action: 'cover', id: book.id)}"
                            style="width:110px;height:150px;object-fit:cover;border-radius:12px"
                            alt="غلاف حالي"/>

                    </div>

                </g:if>

            </div>


            <!-- ========================================================= -->
            <!-- البيع الورقي والاستعارة -->
            <!-- ========================================================= -->

            <div class="mn-form-section">

                <h2>البيع الورقي والاستعارة</h2>

                <p>
                    مخزون البيع منفصل عن النسخ الفعلية
                    المخصصة للإعارة في قسم “نسخ الكتب”.
                </p>


                <div class="row g-3">

                    <!-- المخزون -->

                    <div class="col-md-4 mn-field">

                        <label>مخزون البيع الورقي</label>

                        <input
                            type="number"
                            min="0"
                            name="physicalSaleStock"
                            value="${book?.physicalSaleStock ?: 0}"
                            class="form-control"
                            required/>

                    </div>


                    <!-- السعر الورقي -->

                    <div class="col-md-4 mn-field">

                        <label>سعر النسخة الورقية</label>

                        <input
                            type="text"
                            inputmode="decimal"
                            name="physicalSalePriceInput"
                            value="${book?.physicalSalePrice ?: ''}"
                            class="form-control"/>

                    </div>


                    <!-- رسوم الاستعارة -->

                    <div class="col-md-4 mn-field">

                        <label>رسوم الاستعارة لغير الأعضاء</label>

                        <input
                            type="text"
                            inputmode="decimal"
                            name="borrowingFeeInput"
                            value="${book?.borrowingFee ?: 3.00}"
                            class="form-control"
                            required/>

                        <div class="mn-help">
                            تُدفع لغير المشترك بعد توفر نسخة وقبل الاستلام؛
                            العضوية الفعالة تجعل الاستعارة الورقية بدون رسوم.
                        </div>

                    </div>

                </div>

            </div>


            <!-- ========================================================= -->
            <!-- النسخة الرقمية -->
            <!-- ========================================================= -->

            <div class="mn-form-section">

                <h2>النسخة الرقمية</h2>

                <p>
                    الشراء والاستئجار الرقمي يمران عبر نفس سجل الدفع،
                    بينما الكتب المشمولة بالعضوية تُفتح للمشترك الفعال.
                </p>


                <div class="row g-3">

                    <!-- سعر الشراء الرقمي -->

                    <div class="col-md-4 mn-field">

                        <label>سعر الشراء الرقمي</label>

                        <input
                            type="text"
                            inputmode="decimal"
                            name="digitalPurchasePriceInput"
                            value="${book?.digitalPurchasePrice ?: ''}"
                            class="form-control"/>

                    </div>


                    <!-- سعر الاستئجار -->

                    <div class="col-md-4 mn-field">

                        <label>سعر الاستئجار الرقمي الأساسي</label>

                        <input
                            type="text"
                            inputmode="decimal"
                            name="digitalRentalPriceInput"
                            value="${book?.digitalRentalPrice ?: ''}"
                            class="form-control"/>

                    </div>


                    <!-- المحتوى الرقمي -->

                    <div class="col-12 mn-field">

                        <label>محتوى النسخة الرقمية / النص التدريبي</label>

                        <textarea
                            name="digitalContent"
                            class="form-control"
                            rows="7"
                            dir="auto">${book?.digitalContent ?: ''}</textarea>

                    </div>

                </div>


                <div class="d-flex flex-wrap gap-4">

                    <!-- النسخة الرقمية متاحة -->

                    <div class="form-check">

                        <input
                            class="form-check-input"
                            type="checkbox"
                            name="digitalAvailable"
                            value="true"
                            id="digitalAvailable"
                            ${book?.digitalAvailable ? 'checked' : ''}/>

                        <label
                            class="form-check-label"
                            for="digitalAvailable">

                            النسخة الرقمية متاحة

                        </label>

                    </div>


                    <!-- مشمولة بالعضوية -->

                    <div class="form-check">

                        <input
                            class="form-check-input"
                            type="checkbox"
                            name="membershipIncluded"
                            value="true"
                            id="membershipIncluded"
                            ${book?.membershipIncluded ? 'checked' : ''}/>

                        <label
                            class="form-check-label"
                            for="membershipIncluded">

                            مشمولة بالعضوية

                        </label>

                    </div>


                    <!-- فعال -->

                    <div class="form-check">

                        <input
                            class="form-check-input"
                            type="checkbox"
                            name="active"
                            value="true"
                            id="active"
                            ${book?.active != false ? 'checked' : ''}/>

                        <label
                            class="form-check-label"
                            for="active">

                            الكتاب ظاهر وفعال

                        </label>

                    </div>

                </div>

            </div>


            <!-- ========================================================= -->
            <!-- الأزرار -->
            <!-- ========================================================= -->

            <div class="mn-form-actions">

                <button
                    type="submit"
                    class="mn-btn mn-btn-primary">

                    <i class="bi bi-check2"></i>
                    حفظ الكتاب

                </button>


                <g:link
                    action="${book?.id ? 'show' : 'index'}"
                    id="${book?.id}"
                    class="mn-btn mn-btn-light">

                    إلغاء

                </g:link>

            </div>

        </div>


        <!-- ============================================================= -->
        <!-- المساعد الجانبي -->
        <!-- ============================================================= -->

        <aside class="mn-form-aside">

            <div class="mn-panel">

                <div class="mn-panel-body">

                    <span class="mn-kicker">
                        مساعد الفهرسة
                    </span>


                    <h3 class="h6 mt-3">
                        الـ API يقترح، أنت تقرر
                    </h3>


                    <p class="mn-muted mb-0">

                        Google Books ثم Open Library
                        يمكنهم تعبئة بيانات عامة وغلاف.

                        إذا كان المؤلف موجودًا سيتم اختياره تلقائيًا،
                        وإذا لم يكن موجودًا سيُقترح اسمه لإضافته بعد مراجعتك.

                    </p>


                    <div
                        id="metadataSuggestions"
                        class="small mt-3">
                    </div>

                </div>

            </div>

        </aside>

    </div>

</g:uploadForm>


<!-- ================================================================= -->
<!-- ISBN Metadata JavaScript -->
<!-- ================================================================= -->

<script>
(function () {

    'use strict';


    const metadataButton =
        document.getElementById(
            'metadataLookup'
        );


    const metadataMessage =
        document.getElementById(
            'metadataMessage'
        );


    const authorSelect =
        document.getElementById(
            'authorSelect'
        );


    const newAuthorInput =
        document.getElementById(
            'newAuthorName'
        );


    const metadataSuggestions =
        document.getElementById(
            'metadataSuggestions'
        );


    if (!metadataButton) {
        return;
    }


    /**
     * تعبئة حقل إذا كانت القيمة موجودة.
     */
    const fillField = function (
        id,
        value
    ) {

        if (
            value === null ||
            value === undefined ||
            value === ''
        ) {
            return;
        }


        const element =
            document.getElementById(id);


        if (element) {
            element.value = value;
        }
    };


    /**
     * البحث عن Option بنفس النص.
     *
     * المقارنة غير حساسة لحالة الأحرف.
     */
    const selectByText = function (
        id,
        text
    ) {

        if (!text) {
            return false;
        }


        const select =
            document.getElementById(id);


        if (!select) {
            return false;
        }


        const wantedText =
            String(text)
                .trim()
                .toLowerCase();


        const options =
            Array.from(
                select.options
            );


        const matchedOption =
            options.find(
                function (option) {

                    return option.text
                        .trim()
                        .toLowerCase() ===
                        wantedText;
                }
            );


        if (!matchedOption) {
            return false;
        }


        select.value =
            matchedOption.value;


        return true;
    };


    /**
     * إذا اختار الأدمن مؤلفًا موجودًا،
     * نفرغ حقل المؤلف الجديد.
     */
    if (
        authorSelect &&
        newAuthorInput
    ) {

        authorSelect.addEventListener(
            'change',
            function () {

                if (
                    authorSelect.value
                ) {

                    newAuthorInput.value =
                        '';
                }
            }
        );


        /**
         * إذا كتب اسم مؤلف جديد،
         * نفرغ الاختيار من القائمة.
         */
        newAuthorInput.addEventListener(
            'input',
            function () {

                if (
                    newAuthorInput
                        .value
                        .trim()
                ) {

                    authorSelect.value =
                        '';
                }
            }
        );
    }


    /**
     * جلب بيانات الكتاب من ISBN.
     */
    metadataButton.addEventListener(
        'click',
        async function () {

            const isbnInput =
                document.getElementById(
                    'isbn'
                );


            const isbn =
                isbnInput
                    ? isbnInput.value.trim()
                    : '';


            metadataMessage.className =
                'alert d-none';


            if (!isbn) {

                metadataMessage.textContent =
                    'أدخل ISBN أولًا.';


                metadataMessage.className =
                    'alert alert-warning';


                return;
            }


            metadataButton.disabled =
                true;


            metadataButton.innerHTML =
                '<span class="spinner-border spinner-border-sm"></span> جاري البحث';


            try {

                /*
                 * الاتصال بالـController.
                 */
                const response =
                    await fetch(
                        '${createLink(controller: "book", action: "lookupMetadata")}?isbn=' +
                        encodeURIComponent(isbn)
                    );


                /*
                 * تحويل JSON.
                 */
                const data =
                    await response.json();


                /*
                 * إذا رجع السيرفر خطأ.
                 */
                if (!response.ok) {

                    throw new Error(
                        data.error ||
                        'لم يتم العثور على بيانات.'
                    );
                }


                /*
                 * =======================================================
                 * تعبئة بيانات الكتاب
                 * =======================================================
                 */

                fillField(
                    'title',
                    data.title
                );


                fillField(
                    'description',
                    data.description
                );


                fillField(
                    'publisher',
                    data.publisher
                );


                fillField(
                    'publishYear',
                    data.publishYear
                );


                fillField(
                    'pageCount',
                    data.pageCount
                );


                fillField(
                    'language',
                    data.language
                );


                fillField(
                    'externalCoverUrl',
                    data.externalCoverUrl
                );


                /*
                 * =======================================================
                 * المؤلف
                 * =======================================================
                 */

                const author =
                    data.authors &&
                    data.authors.length > 0
                        ? data.authors[0]
                        : null;


                const matchedAuthor =
                    selectByText(
                        'authorSelect',
                        author
                    );


                if (author) {

                    /*
                     * المؤلف موجود بالفعل.
                     */
                    if (matchedAuthor) {

                        if (
                            newAuthorInput
                        ) {

                            newAuthorInput.value =
                                '';
                        }

                    } else {

                        /*
                         * المؤلف غير موجود.
                         *
                         * لا نترك أي مؤلف قديم مختار.
                         */
                        if (
                            authorSelect
                        ) {

                            authorSelect.value =
                                '';
                        }


                        /*
                         * نضع الاسم الذي جاء من API
                         * في حقل إضافة مؤلف جديد.
                         */
                        if (
                            newAuthorInput
                        ) {

                            newAuthorInput.value =
                                author;
                        }
                    }
                }


                /*
                 * =======================================================
                 * التصنيف
                 * =======================================================
                 */

                const category =
                    data.categories &&
                    data.categories.length > 0
                        ? data.categories[0]
                        : null;


                const matchedCategory =
                    selectByText(
                        'categorySelect',
                        category
                    );


                /*
                 * =======================================================
                 * عرض معلومات المصدر والاقتراحات
                 * =======================================================
                 */

                if (
                    metadataSuggestions
                ) {

                    let authorStatus =
                        '';


                    if (author) {

                        authorStatus =
                            matchedAuthor
                                ? ' ✓ موجود وتم اختياره'
                                : ' — غير موجود، جاهز للإضافة';
                    }


                    let categoryStatus =
                        '';


                    if (category) {

                        categoryStatus =
                            matchedCategory
                                ? ' ✓'
                                : ' — اختر أقرب قسم';
                    }


                    metadataSuggestions.innerHTML =
                        '<strong>المصدر:</strong> ' +
                        (data.source || '—') +

                        '<br><strong>المؤلف المقترح:</strong> ' +
                        (author || '—') +
                        authorStatus +

                        '<br><strong>التصنيف المقترح:</strong> ' +
                        (category || '—') +
                        categoryStatus;
                }


                metadataMessage.textContent =
                    'تم جلب البيانات. راجعها قبل الحفظ.';


                metadataMessage.className =
                    'alert alert-success';


            } catch (error) {

                console.error(
                    'ISBN metadata error:',
                    error
                );


                metadataMessage.textContent =
                    error.message;


                metadataMessage.className =
                    'alert alert-warning';


            } finally {

                metadataButton.disabled =
                    false;


                metadataButton.innerHTML =
                    '<i class="bi bi-stars"></i> جلب البيانات من ISBN';
            }
        }
    );

})();
</script>