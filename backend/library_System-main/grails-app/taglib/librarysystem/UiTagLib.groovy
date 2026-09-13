package librarysystem

class UiTagLib {

    static namespace = 'ui'

    private static final Map<String, String> STATUS_LABELS = [
        'PENDING':'بانتظار الدفع', 'COMPLETED':'مكتمل', 'CANCELLED':'ملغي', 'FAILED':'فشل',
        'WAITING':'بانتظار نسخة', 'READY':'جاهز للتأكيد', 'PAID':'مدفوع', 'CONFIRMED':'مؤكد', 'FULFILLED':'تم التسليم', 'EXPIRED':'منتهي',
        'WAITING_FOR_COPY':'بانتظار توفر نسخة', 'AWAITING_PAYMENT':'بانتظار الدفع', 'AWAITING_CONFIRM':'بانتظار التأكيد', 'READY_FOR_PICKUP':'جاهز للاستلام',
        'PREPARING_DELIVERY':'قيد تجهيز التوصيل', 'OUT_FOR_DELIVERY':'خرج للتوصيل', 'HANDED_OVER':'تم التسليم',
        'PREPARING':'قيد التجهيز', 'DIGITAL_GRANTED':'تم منح الوصول الرقمي',
        'SCHEDULED':'مجدولة', 'ACTIVE':'نشط', 'RETURNED':'مُعاد', 'OVERDUE':'متأخر', 'AVAILABLE':'متاح', 'BORROWED':'مُعار',
        'RESERVED':'محجوز', 'LOST':'مفقود', 'DAMAGED':'تالف', 'REFUNDED':'مسترد', 'VOIDED':'ملغى ماليًا',
        'OPEN':'مفتوح', 'REVOKED':'مسحوب', 'PICKUP':'استلام من المكتبة', 'DELIVERY':'توصيل', 'DIGITAL':'رقمي',
        'PHYSICAL':'ورقي', 'PURCHASE':'شراء', 'RENTAL':'استئجار', 'ONLINE':'أونلاين', 'COUNTER':'كاونتر',
        'CARD':'بطاقة', 'CASH':'نقدي', 'BRAINTREE':'Braintree Sandbox', 'MANUAL':'يدوي', 'API':'مزامن خارجيًا',
        'FALLBACK':'احتياطي محلي', 'ROOM_RESERVATION':'حجز غرفة', 'BOOK_RESERVATION':'حجز كتاب',
        'BORROWING':'استعارة', 'DIGITAL_RENTAL':'استئجار رقمي', 'MEMBERSHIP':'عضوية'
    ]

    def label = { attrs ->
        String value = attrs.value?.toString()
        out << (value ? (STATUS_LABELS[value] ?: value) : '—')
    }

    def status = { attrs ->
        String value = attrs.value?.toString()
        String label = value ? (STATUS_LABELS[value] ?: value) : '—'
        String css = 'mn-status-neutral'
        if (value in ['COMPLETED','PAID','CONFIRMED','FULFILLED','ACTIVE','AVAILABLE','DIGITAL_GRANTED','HANDED_OVER']) css = 'mn-status-success'
        else if (value in ['WAITING','READY','PENDING','SCHEDULED','AWAITING_PAYMENT','AWAITING_CONFIRM','WAITING_FOR_COPY','PREPARING','READY_FOR_PICKUP','PREPARING_DELIVERY','OUT_FOR_DELIVERY','RESERVED','OPEN']) css = 'mn-status-warning'
        else if (value in ['FAILED','CANCELLED','EXPIRED','OVERDUE','LOST','DAMAGED','REVOKED','VOIDED']) css = 'mn-status-danger'
        out << "<span class=\"mn-status ${css}\">${label}</span>"
    }

    def money = { attrs ->
        BigDecimal value = attrs.value == null ? BigDecimal.ZERO : new BigDecimal(attrs.value.toString())
        out << '$' + String.format(Locale.US, '%.2f', value)
    }
}
