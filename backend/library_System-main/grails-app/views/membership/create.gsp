<!doctype html>
<html>
<head>
    <meta name="layout" content="main"/>
    <title>تفعيل عضوية | المنارة</title>
</head>
<body>
<section class="mn-page mn-membership-create-page">
    <div class="container">
        <div class="mn-page-head">
            <div>
                <span class="mn-kicker">عضوية المنارة</span>
                <h1>اختر فترة العضوية</h1>
                <p>فعّل عضويتك لتستعير الكتب الورقية بدون رسوم، وتفتح محتوى رقميًا مختارًا، وتوفّر أكثر مع المدد الأطول.</p>
            </div>
            <g:link action="index" class="mn-btn mn-btn-light">عضوياتي</g:link>
        </div>

        <div class="mn-membership-benefits-grid">
            <div class="mn-membership-benefit-card primary">
                <span class="mn-membership-benefit-icon"><i class="bi bi-book-half"></i></span>
                <div>
                    <small>خلّي كتبك أقرب</small>
                    <strong>استعارة ورقية بلا رسوم</strong>
                    <p>طوال فترة عضويتك الفعالة، أي كتاب ورقي متاح للاستعارة يمكنك أخذه بدون رسوم إعارة إضافية.</p>
                </div>
            </div>
            <div class="mn-membership-benefit-card">
                <span class="mn-membership-benefit-icon"><i class="bi bi-tablet"></i></span>
                <div>
                    <small>مكتبتك تروح معك</small>
                    <strong>رف رقمي يرافقك</strong>
                    <p>افتح مجموعة مختارة من الكتب الرقمية مباشرة من حسابك طوال فترة الاشتراك.</p>
                </div>
            </div>
            <div class="mn-membership-benefit-card">
                <span class="mn-membership-benefit-icon"><i class="bi bi-graph-down-arrow"></i></span>
                <div>
                    <small>وفّر كلما كملت</small>
                    <strong>خصومات تصاعدية حتى 20%</strong>
                    <p>اختر اشتراكًا أطول وخذ سعرًا أفضل تلقائيًا، مع حساب واضح قبل الانتقال للدفع.</p>
                </div>
            </div>
        </div>
        <p class="mn-membership-fine-print"><i class="bi bi-info-circle"></i> الاستعارة المجانية تشمل رسوم الإعارة الأساسية فقط؛ رسوم التأخير عند تجاوز موعد الإرجاع تبقى منفصلة.</p>

        <g:form action="save" method="POST">
            <div class="mn-form-shell mn-membership-pricing-shell">
                <div class="mn-form-section">
                    <div class="row g-3">
                        <div class="col-md-6 mn-field">
                            <label>تاريخ البداية</label>
                            <input type="date" name="startDate" id="membershipStart" class="form-control"
                                   value="${membership?.startDate ? g.formatDate(date: membership?.startDate, format: 'yyyy-MM-dd') : ''}" required/>
                        </div>
                        <div class="col-md-6 mn-field">
                            <label>تاريخ النهاية</label>
                            <input type="date" name="endDate" id="membershipEnd" class="form-control"
                                   value="${membership?.endDate ? g.formatDate(date: membership?.endDate, format: 'yyyy-MM-dd') : ''}" required/>
                        </div>
                    </div>

                    <div id="membershipError" class="alert alert-danger d-none"></div>

                    <div class="mn-membership-tier-grid">
                        <g:each in="${discountTiers?.reverse()}" var="tier">
                            <div class="mn-membership-tier" data-min-days="${tier.minDays}">
                                <span>${tier.label}</span>
                                <strong>${tier.percentage}%</strong>
                                <small>خصم مدة</small>
                            </div>
                        </g:each>
                    </div>

                    <button class="mn-btn mn-btn-primary mt-3">متابعة إلى الدفع</button>
                </div>

                <aside class="mn-form-aside">
                    <div class="mn-price-box mn-membership-price-box">
                        <span class="mn-kicker">ملخص السعر</span>
                        <div class="mn-price-line"><span>عدد الأيام</span><strong id="membershipDays">—</strong></div>
                        <div class="mn-price-line"><span>السعر لليوم</span><strong><ui:money value="${pricePerDay}"/></strong></div>
                        <div class="mn-price-line"><span>السعر الأساسي</span><strong id="membershipBase">—</strong></div>
                        <div class="mn-price-line discount"><span id="membershipDiscountLabel">خصم المدة</span><strong id="membershipDiscount">—</strong></div>
                        <div class="mn-price-line total"><span>الإجمالي بعد الخصم</span><strong id="membershipTotal">—</strong></div>
                    </div>
                </aside>
            </div>
        </g:form>
    </div>
</section>

<script>
(function () {
    const startInput = document.getElementById('membershipStart');
    const endInput = document.getElementById('membershipEnd');
    const daysOutput = document.getElementById('membershipDays');
    const baseOutput = document.getElementById('membershipBase');
    const discountOutput = document.getElementById('membershipDiscount');
    const discountLabel = document.getElementById('membershipDiscountLabel');
    const totalOutput = document.getElementById('membershipTotal');
    const errorBox = document.getElementById('membershipError');
    const rate = Number('${pricePerDay ?: 0}');

    // Mirrors MembershipService only for instant preview; server-side pricing stays authoritative.
    const tiers = [
        { minDays: 365, percentage: 20, label: 'خصم سنة أو أكثر' },
        { minDays: 180, percentage: 15, label: 'خصم 6 أشهر أو أكثر' },
        { minDays: 90, percentage: 10, label: 'خصم 3 أشهر أو أكثر' },
        { minDays: 30, percentage: 5, label: 'خصم شهر أو أكثر' }
    ];

    function money(value) {
        return '$' + Number(value || 0).toFixed(2);
    }

    function update() {
        errorBox.classList.add('d-none');
        document.querySelectorAll('.mn-membership-tier').forEach(function (card) {
            card.classList.remove('active');
        });

        if (!startInput.value || !endInput.value) {
            daysOutput.textContent = '—';
            baseOutput.textContent = '—';
            discountOutput.textContent = '—';
            discountLabel.textContent = 'خصم المدة';
            totalOutput.textContent = '—';
            return;
        }

        const start = Date.parse(startInput.value + 'T00:00:00Z');
        const end = Date.parse(endInput.value + 'T00:00:00Z');
        const days = Math.floor((end - start) / 86400000) + 1;

        if (days < 1) {
            errorBox.textContent = 'تاريخ النهاية يجب ألا يسبق تاريخ البداية.';
            errorBox.classList.remove('d-none');
            daysOutput.textContent = '—';
            baseOutput.textContent = '—';
            discountOutput.textContent = '—';
            totalOutput.textContent = '—';
            return;
        }

        const tier = tiers.find(function (item) { return days >= item.minDays; });
        const percentage = tier ? tier.percentage : 0;
        const base = days * rate;
        const discount = base * percentage / 100;
        const total = base - discount;

        daysOutput.textContent = days + ' يوم';
        baseOutput.textContent = money(base);
        discountOutput.textContent = percentage ? '-' + money(discount) + ' (' + percentage + '%)' : money(0);
        discountLabel.textContent = tier ? tier.label : 'بدون خصم مدة';
        totalOutput.textContent = money(total);

        if (tier) {
            const activeCard = document.querySelector('.mn-membership-tier[data-min-days="' + tier.minDays + '"]');
            if (activeCard) activeCard.classList.add('active');
        }
    }

    startInput.addEventListener('change', update);
    endInput.addEventListener('change', update);
    update();
})();
</script>
</body>
</html>
