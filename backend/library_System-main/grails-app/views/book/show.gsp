<!doctype html>
<html>
<head>
    <meta name="layout" content="main"/>
    <title>${book?.title} | المنارة</title>
</head>

<body>

<section class="mn-catalog-page mn-book-detail-new">

    <div class="container">

        <g:link action="index" class="mn-back-link">
            <i class="bi bi-arrow-right"></i>
            العودة إلى الكتب
        </g:link>


        <div class="mn-book-detail-layout">

            <aside class="mn-book-detail-aside">

                <div class="mn-detail-cover">

                    <g:if test="${book?.coverData || book?.externalCoverUrl}">
                        <img
                            src="${createLink(controller:'book', action:'cover', id:book.id)}"
                            alt="${book.title}"/>
                    </g:if>

                    <g:else>
                        <div class="mn-library-cover-placeholder">
                            <i class="bi bi-book"></i>
                            <span dir="auto">${book?.title}</span>
                        </div>
                    </g:else>

                </div>


                <div class="mn-detail-stock">

                    <div>
                        <span>نسخ الإعارة</span>
                        <b>${physicalCopyCount ?: 0}</b>
                    </div>

                    <div>
                        <span>المتاح الآن</span>
                        <b>${availableCopies?.size() ?: 0}</b>
                    </div>

                    <div>
                        <span>مخزون البيع</span>
                        <b>${book?.physicalSaleStock ?: 0}</b>
                    </div>

                </div>

            </aside>



            <div class="mn-book-detail-main">

                <div class="mn-book-detail-heading">

                    <div>

                        <span class="mn-editorial-kicker">
                            ${book?.category?.name}
                        </span>

                        <h1 dir="auto">
                            ${book?.title}
                        </h1>

                        <p>
                            للكاتب
                            <g:link
                                controller="author"
                                action="show"
                                id="${book?.author?.id}"
                                dir="auto">

                                ${book?.author?.name}

                            </g:link>
                        </p>

                    </div>


                    <div class="mn-detail-badges">

                        <g:if test="${book?.digitalAvailable}">
                            <span>نسخة رقمية</span>
                        </g:if>

                        <g:if test="${book?.membershipIncluded}">
                            <span>ضمن العضوية</span>
                        </g:if>

                        <g:if test="${availableCopies}">
                            <span class="active">متاح للإعارة</span>
                        </g:if>

                        <g:if test="${isAdmin && !book?.active}">
                            <span class="inactive">غير ظاهر للزوار</span>
                        </g:if>

                    </div>

                </div>



                <div class="mn-book-story">

                    <span>عن الكتاب</span>

                    <p>
                        ${book?.description ?: 'لم يُضف وصف مختصر لهذا الكتاب بعد.'}
                    </p>

                </div>



                <div class="mn-book-data-strip">

                    <div>
                        <small>ISBN</small>
                        <b dir="ltr">${book?.isbn ?: '—'}</b>
                    </div>

                    <div>
                        <small>سنة النشر</small>
                        <b>${book?.publishYear ?: '—'}</b>
                    </div>

                    <div>
                        <small>القسم</small>
                        <b>${book?.category?.name ?: '—'}</b>
                    </div>

                </div>



                <g:if test="${physicalCopyCount > 0 ||
                              book?.physicalSalePrice != null ||
                              book?.digitalPurchasePrice != null ||
                              book?.digitalRentalPrice != null}">

                    <div class="mn-price-board">


                        <g:if test="${physicalCopyCount > 0}">

                            <div>

                                <span>
                                    استعارة ورقية
                                </span>

                                <b dir="ltr">

                                    <g:if test="${hasActiveMembership}">
                                        بدون رسوم مع العضوية
                                    </g:if>

                                    <g:else>
                                        $${String.format(
                                            java.util.Locale.US,
                                            '%.2f',
                                            book.borrowingFee ?: 0G
                                        )}
                                        <span dir="rtl">لغير الأعضاء</span>
                                    </g:else>

                                </b>

                            </div>

                        </g:if>



                        <g:if test="${book?.physicalSalePrice != null}">

                            <div>

                                <span>
                                    شراء نسخة ورقية
                                </span>

                                <b dir="ltr">
                                    $${String.format(
                                        java.util.Locale.US,
                                        '%.2f',
                                        book.physicalSalePrice
                                    )}
                                </b>

                            </div>

                        </g:if>



                        <g:if test="${book?.digitalAvailable &&
                                    book?.digitalPurchasePrice != null}">

                            <div>

                                <span>
                                    شراء رقمي دائم
                                </span>

                                <b dir="ltr">
                                    $${String.format(
                                        java.util.Locale.US,
                                        '%.2f',
                                        book.digitalPurchasePrice
                                    )}
                                </b>

                            </div>

                        </g:if>



                        <g:if test="${book?.digitalAvailable &&
                                    book?.digitalRentalPrice != null}">

                            <div>

                                <span>
                                    استئجار رقمي / يوم
                                </span>

                                <b dir="ltr">
                                    $${String.format(
                                        java.util.Locale.US,
                                        '%.2f',
                                        book.digitalRentalPrice
                                    )}
                                </b>

                            </div>

                        </g:if>

                    </div>

                </g:if>



                <g:if test="${libraryUser}">

                    <section class="mn-book-actions-panel">

                        <div class="mn-actions-panel-heading">

                            <span>
                                ماذا تريد أن تفعل؟
                            </span>

                            <h2>
                                خيارات هذا الكتاب
                            </h2>

                        </div>



                        <g:if test="${canReadDigital}">

                            <div class="mn-action-row highlight">

                                <div>

                                    <i class="bi bi-tablet"></i>

                                    <span>

                                        <b>
                                            وصولك الرقمي مفعّل
                                        </b>

                                        <small>
                                            يمكنك فتح الكتاب الآن.
                                        </small>

                                    </span>

                                </div>


                                <g:link
                                    controller="digitalAccess"
                                    action="read"
                                    params="[bookId: book.id]"
                                    class="mn-solid-action">

                                    قراءة الكتاب

                                </g:link>

                            </div>

                        </g:if>



                        <div class="mn-purchase-actions">

                            <g:if test="${book?.physicalSalePrice != null &&
                                        (book?.physicalSaleStock ?: 0) > 0}">

                                <g:form
                                    controller="purchase"
                                    action="buy"
                                    method="POST"
                                    class="mn-purchase-form mn-physical-buy-form">

                                    <g:hiddenField
                                        name="bookId"
                                        value="${book.id}"/>

                                    <g:hiddenField
                                        name="purchaseType"
                                        value="PHYSICAL"/>


                                    <label>
                                        الكمية

                                        <input
                                            type="number"
                                            name="quantity"
                                            min="1"
                                            max="${book.physicalSaleStock}"
                                            value="1"/>
                                    </label>


                                    <label>

                                        طريقة الاستلام

                                        <select
                                            name="fulfillmentMethod"
                                            class="form-select mn-fulfillment-select">

                                            <option value="PICKUP">
                                                استلام من المكتبة
                                            </option>

                                            <option value="DELIVERY">
                                                توصيل
                                            </option>

                                        </select>

                                    </label>


                                    <label class="mn-delivery-address d-none">

                                        عنوان التوصيل

                                        <textarea
                                            name="deliveryAddress"
                                            rows="2"
                                            class="form-control"
                                            placeholder="المدينة، الحي، الشارع، وأي تفاصيل تساعد في التوصيل"
                                            dir="auto"></textarea>

                                    </label>


                                    <button
                                        type="submit"
                                        class="mn-outline-action">

                                        <i class="bi bi-credit-card"></i>
                                        متابعة للدفع

                                    </button>

                                </g:form>

                            </g:if>



                            <g:if test="${book?.digitalAvailable &&
                                        book?.digitalPurchasePrice != null &&
                                        !ownsDigital}">

                                <g:form
                                    controller="purchase"
                                    action="buy"
                                    method="POST">

                                    <g:hiddenField
                                        name="bookId"
                                        value="${book.id}"/>

                                    <g:hiddenField
                                        name="purchaseType"
                                        value="DIGITAL"/>

                                    <g:hiddenField
                                        name="quantity"
                                        value="1"/>


                                    <button
                                        type="submit"
                                        class="mn-outline-action">

                                        <i class="bi bi-credit-card"></i>
                                        شراء رقمي

                                    </button>

                                </g:form>

                            </g:if>



                            <g:if test="${book?.digitalAvailable &&
                                        book?.digitalRentalPrice != null &&
                                        !canReadDigital}">

                                <g:form
                                    controller="digitalAccess"
                                    action="rent"
                                    method="POST"
                                    class="mn-digital-rental-form">

                                    <g:hiddenField
                                        name="bookId"
                                        value="${book.id}"/>


                                    <label>

                                        مدة الاستئجار

                                        <span class="mn-inline-number-field">

                                            <input
                                                type="number"
                                                name="rentalDays"
                                                min="1"
                                                max="30"
                                                value="7"
                                                required/>

                                            يوم

                                        </span>

                                    </label>


                                    <small>
                                        السعر يُحسب حسب عدد الأيام ويظهر لك كاملًا قبل الدفع.
                                    </small>


                                    <button
                                        type="submit"
                                        class="mn-outline-action">

                                        <i class="bi bi-clock-history"></i>
                                        متابعة لاستئجار رقمي

                                    </button>

                                </g:form>

                            </g:if>

                        </div>



                        <div class="mn-lending-box">

                            <div>

                                <span>
                                    الإعارة الورقية
                                </span>

                                <h3>
                                    احجز نسخة للاستعارة
                                </h3>

                            </div>


                            <g:if test="${currentReservation}">

                                <div class="mn-current-reservation">

                                    <b>
                                        <ui:label value="${currentReservation.status}"/>
                                    </b>


                                    <g:if test="${currentReservation.readyUntil}">

                                        <small>
                                            محجوز لك حتى
                                            <g:formatDate
                                                date="${currentReservation.readyUntil}"
                                                format="dd/MM/yyyy HH:mm"/>
                                        </small>

                                    </g:if>


                                    <g:link
                                        controller="reservation"
                                        action="show"
                                        id="${currentReservation.id}">

                                        تفاصيل الحجز

                                    </g:link>

                                </div>

                            </g:if>



                            <g:elseif test="${physicalCopyCount > 0}">

                                <g:if test="${hasActiveMembership}">

                                    <p>
                                        <strong>
                                            ميزة عضويتك فعّالة:
                                        </strong>

                                        احجز النسخة، وعند تخصيصها لك يتم تأكيد
                                        الاستعارة بدون رسوم.
                                    </p>

                                </g:if>


                                <g:else>

                                    <p>
                                        الحجز يحفظ دورك، وعند تخصيص نسخة تُدفع رسوم
                                        الاستعارة لهذا الكتاب. يمكنك تفعيل العضوية
                                        لتصبح الاستعارة الورقية بدون رسوم.
                                    </p>

                                </g:else>


                                <g:form
                                    controller="reservation"
                                    action="reserve"
                                    method="POST">

                                    <g:hiddenField
                                        name="bookId"
                                        value="${book.id}"/>


                                    <button
                                        type="submit"
                                        class="mn-solid-action">

                                        <i class="bi bi-bookmark-plus"></i>
                                        حجز نسخة

                                    </button>

                                </g:form>

                            </g:elseif>



                            <g:else>

                                <p>
                                    لا توجد نسخ مخصصة للإعارة لهذا العنوان حاليًا.
                                </p>

                            </g:else>

                        </div>



                        <g:if test="${book?.membershipIncluded}">

                            <p class="mn-membership-note">

                                <i class="bi bi-person-badge"></i>

                                النسخة الرقمية من هذا الكتاب متاحة ضمن العضوية النشطة.

                            </p>

                        </g:if>

                    </section>

                </g:if>



                <sec:ifNotLoggedIn>

                    <div class="mn-signin-prompt">

                        <div>

                            <span>
                                تريد حجزه أو شراءه؟
                            </span>

                            <h2>
                                سجّل الدخول لاستخدام خدمات الكتاب
                            </h2>

                            <p>
                                بعد الدخول يمكنك الحجز، الشراء، الاستئجار
                                وفتح مكتبتك الرقمية.
                            </p>

                        </div>


                        <g:link
                            controller="login"
                            action="auth"
                            class="mn-solid-action">

                            تسجيل الدخول

                        </g:link>

                    </div>

                </sec:ifNotLoggedIn>



                <sec:ifAnyGranted roles="ROLE_ADMIN">

                    <div class="mn-admin-inline-panel">

                        <div>

                            <span>
                                إدارة الكتاب
                            </span>

                            <small>
                                هذه الأدوات تظهر للمشرف فقط.
                            </small>

                        </div>


                        <div>

                            <g:link
                                action="edit"
                                id="${book.id}"
                                class="mn-outline-action">

                                <i class="bi bi-pencil"></i>
                                تعديل الكتاب

                            </g:link>


                            <g:form
                                action="delete"
                                id="${book.id}"
                                method="DELETE">

                                <button
                                    type="submit"
                                    class="mn-danger-link"
                                    data-confirm="هل تريد حذف هذا الكتاب؟ إذا كان له سجل في النظام سيتم تعطيله بدل الحذف.">

                                    <i class="bi bi-trash3"></i>
                                    حذف / تعطيل

                                </button>

                            </g:form>

                        </div>

                    </div>

                </sec:ifAnyGranted>

            </div>

        </div>

    </div>

</section>


<script>

document
    .querySelectorAll('.mn-physical-buy-form')
    .forEach(function (form) {

        const select =
            form.querySelector('.mn-fulfillment-select');

        const address =
            form.querySelector('.mn-delivery-address');

        const textarea =
            address?.querySelector('textarea');


        const toggleDeliveryAddress = function () {

            const delivery =
                select?.value === 'DELIVERY';

            address?.classList.toggle(
                'd-none',
                !delivery
            );

            if (textarea) {
                textarea.required = delivery;
            }
        };


        select?.addEventListener(
            'change',
            toggleDeliveryAddress
        );

        toggleDeliveryAddress();
    });

</script>

</body>
</html>