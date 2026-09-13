# إعداد التكاملات الخارجية — المنارة

هذا الملف هو الخطوات التي تحتاج تنفيذها **مرة واحدة عندك** بعد فك المشروع. الكود نفسه موجود داخل المشروع؛ المطلوب منك فقط مفاتيح الـ Sandbox/API.

## 1) Braintree Sandbox — الدفع التجريبي الرسمي

المشروع يستخدم:

- Braintree Java SDK على الخادم.
- Braintree JavaScript v3 Hosted Fields في صفحة الدفع.
- بيئة `SANDBOX` فقط.
- السيرفر لا يستقبل رقم البطاقة الكامل أو CVV أو تاريخ الانتهاء؛ يستقبل `paymentMethodNonce` مؤقتًا فقط.

### المطلوب منك

1. أنشئ حساب Braintree Sandbox من بوابة Braintree/PayPal Developer.
2. من لوحة الـ Sandbox افتح إعدادات API واحصل على:
   - Merchant ID
   - Public Key
   - Private Key
3. من جذر المشروع نفّذ:

```bash
cp config/integrations.example.sh config/integrations.local.sh
nano config/integrations.local.sh
```

4. ضع القيم الحقيقية الخاصة بالـ Sandbox، ثم:

```bash
source config/integrations.local.sh
```

5. شغّل المشروع من **نفس التيرمنال** الذي نفذت فيه `source`.

### بطاقة اختبار

استخدم بطاقة Sandbox فقط، ولا تستخدم بطاقة حقيقية:

```text
4111 1111 1111 1111
```

تاريخ انتهاء مستقبلي، مثل:

```text
12/30
```

CVV تجريبي، مثل:

```text
123
```

### ماذا يحدث داخل النظام؟

- Hosted Fields يرسل بيانات البطاقة مباشرة إلى Braintree.
- الواجهة تحصل على nonce مؤقت.
- `PaymentService` يطلب عملية Sale من Braintree Sandbox.
- بعد نجاح الدفع فقط يتم تنفيذ الـ business operation المطلوبة.
- نخزن: مرجع العملية، transaction id، نوع البطاقة وآخر 4 أرقام فقط.

## 2) Holiday API — تقويم فلسطين

المشروع يستخدم الدولة:

```text
PS
```

والتقويم يعمل بطبقتين:

1. بيانات محلية احتياطية داخل قاعدة البيانات.
2. مزامنة خارجية من Holiday API عند توفر `HOLIDAY_API_KEY`.

### المطلوب منك

أنشئ API key في Holiday API، ثم أضفه في:

```bash
nano config/integrations.local.sh
```

بالشكل:

```bash
export HOLIDAY_API_KEY='YOUR_KEY'
```

ثم:

```bash
source config/integrations.local.sh
```

من لوحة الأدمن:

```text
الإدارة → غرف الدراسة → تقويم العطل
```

اضغط **تحديث من المصدر الخارجي**.

إذا فشل الإنترنت أو الـ API، النظام لا يتوقف؛ يستخدم آخر بيانات محلية محفوظة + fallback.

### اختبار واضح للعطل

لـ 2026 يمكن تجربة:

```text
15/11/2026 — ذكرى إعلان الاستقلال
```

يجب رفض حجز غرفة يشمل هذا اليوم قبل الذهاب للدفع.

## 3) Google Books + Open Library

لا تحتاج إعدادًا يدويًا في النسخة الحالية.

من:

```text
الإدارة → الكتب → إضافة كتاب
```

اكتب ISBN ثم اضغط **جلب البيانات من ISBN**.

الترتيب:

```text
Google Books
    ↓ إذا لم توجد نتيجة
Open Library
    ↓
تعبئة البيانات المقترحة
```

البيانات النهائية لا تحفظ إلا عندما يضغط الأدمن حفظ؛ ويمكنه تعديل أي حقل قبل الحفظ.

## 4) تشغيل المشروع بعد الإعداد

```bash
source config/integrations.local.sh
grails compile
grails run-app
```

ولفحص المشروع كاملًا:

```bash
./scripts/verify-project.sh
```

## 5) مهم قبل GitHub

لا تعمل:

```bash
git add config/integrations.local.sh
```

الملف موجود أصلًا في `.gitignore` لأن فيه مفاتيح سرية.

الملف الذي يمكن رفعه بأمان هو:

```text
config/integrations.example.sh
```
