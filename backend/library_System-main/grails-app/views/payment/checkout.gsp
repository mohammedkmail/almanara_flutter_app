<!doctype html>
<html>

<head>

    <meta name="layout" content="main"/>

    <title>الدفع الآمن | المنارة</title>


    <%-- =========================================================
         BRAINTREE JAVASCRIPT SDK
         ========================================================= --%>

    <g:if test="${gatewayConfigured}">

        <script src="https://js.braintreegateway.com/web/3.145.0/js/client.min.js"></script>

        <script src="https://js.braintreegateway.com/web/3.145.0/js/hosted-fields.min.js"></script>

    </g:if>


    <%-- =========================================================
         CHECKOUT FIELD STYLES
         ========================================================= --%>

    <style>

        /*
         * Normal cardholder name input
         */
        .mn-cardholder-input {
            width: 100%;
            height: 54px;
            padding: 0 16px;

            border: 1px solid #d7dfdc;
            border-radius: 12px;

            background: #ffffff;
            color: #17212b;

            font-size: 16px;

            outline: none;

            direction: ltr;

            transition:
                border-color .2s ease,
                box-shadow .2s ease;
        }


        .mn-cardholder-input:focus {
            border-color: #17796a;
            box-shadow: 0 0 0 3px rgba(23, 121, 106, .10);
        }


        /*
         * Braintree puts an iframe inside each of these containers.
         */
        .mn-hosted-field {
            width: 100%;

            height: 54px !important;
            min-height: 54px !important;

            border: 1px solid #d7dfdc;
            border-radius: 12px;

            background: #ffffff;

            overflow: hidden;

            position: relative;

            cursor: text;

            pointer-events: auto !important;

            transition:
                border-color .2s ease,
                box-shadow .2s ease;
        }


        /*
         * Braintree iframe
         */
        .mn-hosted-field iframe {
            width: 100% !important;
            height: 100% !important;

            display: block !important;

            border: 0 !important;

            pointer-events: auto !important;
        }


        /*
         * Braintree automatically adds these classes.
         */
        .mn-hosted-field.braintree-hosted-fields-focused {
            border-color: #17796a;

            box-shadow:
                0 0 0 3px rgba(23, 121, 106, .10);
        }


        .mn-hosted-field.braintree-hosted-fields-valid {
            border-color: #198754;
        }


        .mn-hosted-field.braintree-hosted-fields-invalid {
            border-color: #dc3545;
        }


        #payButton:disabled {
            opacity: .65;
            cursor: not-allowed;
        }


        #paymentStatus {
            font-size: .82rem;
        }

    </style>

</head>


<body>


<section class="mn-page">


    <div class="container">


        <div class="mn-checkout-shell">


            <%-- =====================================================
                 PAYMENT SUMMARY
                 ===================================================== --%>

            <aside class="mn-checkout-summary">


                <span class="mn-kicker">
                    Braintree Sandbox
                </span>


                <h1>
                    إتمام الدفع
                </h1>


                <p>
                    بوابة دفع تجريبية رسمية.
                    بيانات البطاقة تُكتب داخل حقول مستضافة من Braintree
                    ولا تمر عبر خادم المنارة.
                </p>


                <div class="mn-checkout-item">


                    <div class="d-flex gap-3 align-items-start">


                        <span class="brand-icon">

                            <i class="bi ${targetIcon ?: 'bi-credit-card'}"></i>

                        </span>


                        <div>

                            <small class="opacity-75">

                                ${targetDescription}

                            </small>


                            <strong dir="auto">

                                ${targetTitle}

                            </strong>

                        </div>


                    </div>


                    <g:each
                            in="${summaryLines ?: []}"
                            var="line">


                        <div class="mn-price-line">


                            <span>

                                ${line.label}

                            </span>


                            <strong dir="auto">

                                ${line.value ?: '—'}

                            </strong>


                        </div>


                    </g:each>


                    <div class="mn-price-line total">


                        <span>
                            الإجمالي
                        </span>


                        <span class="mn-checkout-total">

                            <ui:money value="${amount}"/>

                        </span>


                    </div>


                </div>


            </aside>


            <%-- =====================================================
                 PAYMENT CARD
                 ===================================================== --%>

            <div class="mn-hosted-card">


                <div class="mb-4">


                    <span class="mn-kicker">
                        دفع اختباري فقط
                    </span>


                    <h2 class="h4 mt-2 mb-2">
                        بيانات البطاقة
                    </h2>


                    <p class="mn-muted mb-0">

                        لا تستخدم بطاقة حقيقية.
                        استخدم بيانات Braintree Sandbox المخصصة للاختبار.

                    </p>


                </div>


                <%-- =================================================
                     GATEWAY NOT CONFIGURED
                     ================================================= --%>

                <g:if test="${!gatewayConfigured}">


                    <div class="alert alert-warning border-0 rounded-4">


                        <strong class="d-block mb-2">

                            Braintree Sandbox غير موصول بعد

                        </strong>


                        أضف متغيرات البيئة


                        <code>
                            BRAINTREE_MERCHANT_ID
                        </code>


                        و


                        <code>
                            BRAINTREE_PUBLIC_KEY
                        </code>


                        و


                        <code>
                            BRAINTREE_PRIVATE_KEY
                        </code>


                        ثم أعد تشغيل المشروع.


                        <g:if test="${gatewayError}">


                            <div class="small mt-2">

                                ${gatewayError}

                            </div>


                        </g:if>


                    </div>


                </g:if>


                <%-- =================================================
                     BRAINTREE READY
                     ================================================= --%>

                <g:else>


                    <%-- Security information --%>

                    <div class="mn-secure-note mb-4">


                        <i class="bi bi-shield-lock-fill fs-5"></i>


                        <span>

                            رقم البطاقة وCVV وتاريخ الانتهاء
                            تُرسل مباشرة إلى Braintree.

                            المنارة تستقبل رمزًا مؤقتًا
                            (nonce) فقط،

                            وتحفظ بعد نجاح العملية
                            نوع البطاقة وآخر 4 أرقام
                            ومرجع العملية.

                        </span>


                    </div>


                    <%-- Sandbox card information --%>

                    <div class="alert alert-info border-0 rounded-4 small">


                        بطاقة Sandbox للتجربة:


                        <strong dir="ltr">

                            4111 1111 1111 1111

                        </strong>


                        — تاريخ مستقبلي مثل


                        <strong dir="ltr">

                            12/30

                        </strong>


                        — CVV مثل


                        <strong dir="ltr">

                            123

                        </strong>


                    </div>


                    <%-- =================================================
                         PAYMENT FORM
                         ================================================= --%>

                    <g:form
                            controller="payment"
                            action="process"
                            method="POST"
                            id="braintreeCheckoutForm"
                            data-no-global-submit-lock="true">


                        <%-- Required server values --%>

                        <g:hiddenField
                                name="purpose"
                                value="${purpose}"/>


                        <g:hiddenField
                                name="targetId"
                                value="${targetId}"/>


                        <g:hiddenField
                                name="checkoutToken"
                                value="${checkoutToken}"/>


                        <%-- Braintree nonce --%>

                        <g:hiddenField
                                name="paymentMethodNonce"
                                id="paymentMethodNonce"/>


                        <%-- =================================================
                             CARDHOLDER NAME
                             Normal HTML input.
                             It is sent to Braintree during tokenize().
                             ================================================= --%>

                        <div class="mn-field">


                            <label for="cardholderName">

                                اسم حامل البطاقة

                            </label>


                            <input
                                    type="text"
                                    id="cardholderName"
                                    class="mn-cardholder-input"
                                    placeholder="HADI HUSSM"
                                    autocomplete="cc-name"
                                    maxlength="100"
                                    dir="ltr"
                                    required/>


                        </div>


                        <%-- =================================================
                             CARD NUMBER
                             BRAINTREE HOSTED FIELD
                             ================================================= --%>

                        <div class="mn-field">


                            <label for="card-number">

                                رقم البطاقة

                            </label>


                            <div
                                    id="card-number"
                                    class="mn-hosted-field"
                                    dir="ltr">
                            </div>


                        </div>


                        <%-- =================================================
                             EXPIRATION + CVV
                             ================================================= --%>

                        <div class="row g-3">


                            <div class="col-md-6 mn-field">


                                <label for="expiration-date">

                                    تاريخ الانتهاء

                                </label>


                                <div
                                        id="expiration-date"
                                        class="mn-hosted-field"
                                        dir="ltr">
                                </div>


                            </div>


                            <div class="col-md-6 mn-field">


                                <label for="cvv">

                                    CVV

                                </label>


                                <div
                                        id="cvv"
                                        class="mn-hosted-field"
                                        dir="ltr">
                                </div>


                            </div>


                        </div>


                        <%-- =================================================
                             ERROR
                             ================================================= --%>

                        <div
                                id="paymentError"
                                class="alert alert-danger d-none mt-3"
                                role="alert">
                        </div>


                        <%-- =================================================
                             STATUS
                             ================================================= --%>

                        <div
                                id="paymentStatus"
                                class="alert alert-secondary d-none mt-3"
                                role="status">
                        </div>


                        <%-- =================================================
                             PAY
                             ================================================= --%>

                        <button
                                type="submit"
                                class="mn-btn mn-btn-primary w-100 mt-3"
                                id="payButton"
                                disabled>


                            <i class="bi bi-lock-fill"></i>


                            دفع


                            <ui:money value="${amount}"/>


                            عبر Sandbox


                        </button>


                    </g:form>


                </g:else>


                <%-- =================================================
                     CANCEL
                     ================================================= --%>

                <g:form
                        controller="payment"
                        action="cancel"
                        method="POST"
                        class="mt-3">


                    <g:hiddenField
                            name="purpose"
                            value="${purpose}"/>


                    <g:hiddenField
                            name="targetId"
                            value="${targetId}"/>


                    <g:hiddenField
                            name="checkoutToken"
                            value="${checkoutToken}"/>


                    <button
                            type="submit"
                            class="mn-btn mn-btn-light w-100">


                        إلغاء والعودة للوحة التحكم


                    </button>


                </g:form>


            </div>


        </div>


    </div>


</section>



<%-- =============================================================
     BRAINTREE JAVASCRIPT
     ============================================================= --%>

<g:if test="${gatewayConfigured}">


<script>

(function () {


    'use strict';



    /* =============================================================
       DOM ELEMENTS
       ============================================================= */

    const form =
        document.querySelector('input[name="paymentMethodNonce"]')
            ?.closest('form');


    const payButton =
        document.getElementById('payButton');


    const errorBox =
        document.getElementById('paymentError');


    const statusBox =
        document.getElementById('paymentStatus');


    const nonceInput =
        document.getElementById('paymentMethodNonce');


    const cardholderNameInput =
        document.getElementById('cardholderName');



    /*
     * Page cannot work without these elements.
     */
    if (
        !form ||
        !payButton ||
        !errorBox ||
        !nonceInput ||
        !cardholderNameInput
    ) {

        console.error(
            'Braintree checkout: required DOM elements are missing.'
        );

        return;
    }



    /* =============================================================
       UI HELPERS
       ============================================================= */

    function clearError() {

        errorBox.textContent = '';

        errorBox.classList.add('d-none');

    }



    function showError(message) {


        const finalMessage =
            message ||
            'تعذر تجهيز الدفع. راجع البيانات وحاول مرة أخرى.';


        console.error(
            '[Braintree Checkout]',
            finalMessage
        );


        errorBox.textContent =
            finalMessage;


        errorBox.classList.remove(
            'd-none'
        );


        if (statusBox) {

            statusBox.classList.add(
                'd-none'
            );

        }


        payButton.disabled =
            false;


        payButton.classList.remove(
            'is-submitting'
        );

    }



    function showStatus(message) {


        if (!statusBox) {

            return;

        }


        statusBox.textContent =
            message;


        statusBox.classList.remove(
            'd-none'
        );

    }



    function hideStatus() {


        if (!statusBox) {

            return;

        }


        statusBox.textContent =
            '';


        statusBox.classList.add(
            'd-none'
        );

    }



    /* =============================================================
       CHECK BRAINTREE SDK
       ============================================================= */

    if (
        typeof window.braintree === 'undefined' ||
        !window.braintree.client ||
        !window.braintree.hostedFields
    ) {


        showError(
            'لم يتم تحميل مكتبة Braintree. تحقق من اتصال الإنترنت ثم أعد تحميل الصفحة.'
        );


        return;

    }



    /* =============================================================
       CLIENT TOKEN
       ============================================================= */

    const clientToken =
        '${clientToken?.encodeAsJavaScript()}';



    if (
        !clientToken ||
        clientToken.trim() === ''
    ) {


        showError(
            'لم يتم إنشاء Client Token من Braintree Sandbox.'
        );


        return;

    }



    showStatus(
        'جاري الاتصال بـ Braintree Sandbox...'
    );



    /* =============================================================
       CREATE BRAINTREE CLIENT
       ============================================================= */

    braintree.client.create(


        {

            authorization:
                clientToken

        },


        function (
            clientError,
            clientInstance
        ) {


            if (clientError) {


                console.error(
                    'Braintree client.create error:',
                    clientError
                );


                showError(
                    'تعذر الاتصال ببيئة Braintree Sandbox: ' +
                    (clientError.message || '')
                );


                return;

            }



            showStatus(
                'تم الاتصال بـ Braintree. جاري تحميل حقول البطاقة الآمنة...'
            );



            /* =====================================================
               CREATE HOSTED FIELDS

               IMPORTANT:
               cardholderName is NOT defined here.

               Only:
               - number
               - expirationDate
               - cvv
               ===================================================== */

            braintree.hostedFields.create(


                {

                    client:
                        clientInstance,


                    styles: {


                        'input': {

                            'font-size':
                                '16px',

                            'font-family':
                                'Arial, sans-serif',

                            'font-weight':
                                '400',

                            'color':
                                '#17212b'

                        },


                        'input::placeholder': {

                            'color':
                                '#98a49f'

                        },


                        ':focus': {

                            'color':
                                '#081725'

                        },


                        '.invalid': {

                            'color':
                                '#a23b3b'

                        },


                        '.valid': {

                            'color':
                                '#16794e'

                        }


                    },


                    fields: {


                        /*
                         * CARD NUMBER
                         */
                        number: {

                            container:
                                '#card-number',

                            placeholder:
                                '4111 1111 1111 1111'

                        },


                        /*
                         * EXPIRATION
                         */
                        expirationDate: {

                            container:
                                '#expiration-date',

                            placeholder:
                                'MM/YY'

                        },


                        /*
                         * CVV
                         */
                        cvv: {

                            container:
                                '#cvv',

                            placeholder:
                                '123'

                        }


                    }


                },


                function (
                    hostedError,
                    hostedFieldsInstance
                ) {


                    if (hostedError) {


                        console.error(
                            'Braintree hostedFields.create error:',
                            hostedError
                        );


                        showError(
                            'تعذر تحميل حقول البطاقة الآمنة: ' +
                            (hostedError.message || '')
                        );


                        return;

                    }



                    /* =================================================
                       HOSTED FIELDS READY
                       ================================================= */

                    hideStatus();

                    clearError();


                    /*
                     * Enable Pay only after Braintree successfully
                     * creates the 3 secure fields.
                     */
                    payButton.disabled =
                        false;



                    console.log(
                        'Braintree Hosted Fields loaded successfully.'
                    );


                    console.log(
                        'Hosted iframe count:',
                        document.querySelectorAll(
                            '.mn-hosted-field iframe'
                        ).length
                    );



                    /* =================================================
                       SUBMIT

                       capture=true and stopImmediatePropagation()
                       prevent the global application.js form listener
                       from interfering before Braintree tokenization.
                       ================================================= */

                    form.addEventListener(


                        'submit',


                        function (event) {


                            event.preventDefault();


                            /*
                             * Prevent another form submit handler
                             * from disabling the button early.
                             */
                            event.stopImmediatePropagation();



                            clearError();

                            hideStatus();



                            /* =========================================
                               CARDHOLDER NAME
                               ========================================= */

                            const cardholderName =
                                cardholderNameInput
                                    .value
                                    .trim();



                            if (!cardholderName) {


                                showError(
                                    'أدخل اسم حامل البطاقة.'
                                );


                                cardholderNameInput.focus();


                                return;

                            }



                            /*
                             * Prevent double click.
                             */
                            payButton.disabled =
                                true;


                            payButton.classList.add(
                                'is-submitting'
                            );


                            showStatus(
                                'جاري التحقق من بيانات البطاقة...'
                            );



                            /* =========================================
                               TOKENIZE
                               ========================================= */

                            hostedFieldsInstance.tokenize(


                                {

                                    /*
                                     * Cardholder name is passed here,
                                     * rather than being a Hosted Field.
                                     */
                                    cardholderName:
                                        cardholderName

                                },


                                function (
                                    tokenError,
                                    payload
                                ) {


                                    if (tokenError) {


                                        console.error(
                                            'Braintree tokenize error:',
                                            tokenError
                                        );


                                        let message =
                                            'تحقق من بيانات البطاقة التجريبية ثم حاول مرة أخرى.';



                                        if (
                                            tokenError.code ===
                                            'HOSTED_FIELDS_FIELDS_EMPTY'
                                        ) {


                                            message =
                                                'أدخل جميع بيانات البطاقة أولاً.';

                                        }



                                        if (
                                            tokenError.code ===
                                            'HOSTED_FIELDS_FIELDS_INVALID'
                                        ) {


                                            message =
                                                'يوجد حقل غير صحيح. تحقق من رقم البطاقة وتاريخ الانتهاء وCVV.';

                                        }



                                        if (
                                            tokenError.code ===
                                            'HOSTED_FIELDS_FAILED_TOKENIZATION'
                                        ) {


                                            message =
                                                'رفض Braintree بيانات البطاقة. تحقق من بيانات Sandbox وحاول مرة أخرى.';

                                        }



                                        if (
                                            tokenError.code ===
                                            'HOSTED_FIELDS_TOKENIZATION_NETWORK_ERROR'
                                        ) {


                                            message =
                                                'تعذر الاتصال بـ Braintree أثناء التحقق من البطاقة.';

                                        }



                                        showError(
                                            message
                                        );


                                        return;

                                    }



                                    /* =================================
                                       CHECK NONCE
                                       ================================= */

                                    if (
                                        !payload ||
                                        !payload.nonce
                                    ) {


                                        showError(
                                            'لم يتم إنشاء رمز الدفع من Braintree.'
                                        );


                                        return;

                                    }



                                    /* =================================
                                       SAVE NONCE
                                       ================================= */

                                    nonceInput.value =
                                        payload.nonce;



                                    console.log(
                                        'Braintree nonce created successfully.'
                                    );



                                    showStatus(
                                        'تم التحقق من البطاقة. جاري تنفيذ عملية الدفع التجريبية...'
                                    );



                                    /* =================================
                                       SEND FORM TO GRAILS

                                       Native submit avoids firing our
                                       JavaScript submit listener again.
                                       ================================= */

                                    HTMLFormElement
                                        .prototype
                                        .submit
                                        .call(form);


                                }


                            );


                        },


                        /*
                         * Run before other submit listeners.
                         */
                        true


                    );


                }


            );


        }


    );


})();

</script>


</g:if>


</body>

</html>