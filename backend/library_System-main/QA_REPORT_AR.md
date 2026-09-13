# تقرير فحص النسخة — المنارة

تم تنفيذ فحوصات ثابتة على النسخة النهائية قبل التغليف:

- لا توجد ملفات اختبار scaffold تحتوي `assert false` أو `true == false` أو `fix me`.
- لا توجد أسماء Class مختلفة عن أسماء ملفات Grails المصدرية.
- تمت إزالة مجلد `bin/` القديم الذي كان يحتوي نسخًا مكررة من سورس المشروع.
- تم فحص 231 مرجع Controller/Action صريح في GSP، وكلها تشير إلى Actions موجودة.
- توازن وسوم GSP صحيح.
- توازن أقواس CSS صحيح.
- `application.js` يمر عبر `node --check`.
- تم فحص JavaScript المضمن في 9 صفحات GSP ولم تظهر أخطاء syntax بعد تحييد تعبيرات GSP.
- لا يوجد `cardNumber` أو `CVV` أو expiry خام في Controllers/Services؛ الدفع الأونلاين يعتمد nonce من Hosted Fields.
- لا يوجد RoomReservation بحالة `PENDING` في مسار الغرف؛ الحالات النهائية هي `CONFIRMED / COMPLETED / CANCELLED`.
- ملف `application.yml` صالح كـ multi-document YAML.
- تمت مراجعة النصوص المرئية ولم تبقَ scaffold labels إنجليزية؛ الاستثناءات مصطلحات تقنية مقصودة مثل ISBN وCVV وBraintree.

## لماذا لا يوجد Build Success من بيئة التجهيز؟

تمت محاولة تشغيل Gradle Wrapper، لكن بيئة التجهيز لم تستطع الوصول إلى `services.gradle.org` لتنزيل Gradle 8.14.3 (`UnknownHostException`) ولم يتوفر Gradle distribution محلي. لذلك يجب تنفيذ `grails compile` و`./gradlew test` عندك بعد فك المشروع؛ بيئتك السابقة كانت قادرة على تشغيل Grails/Gradle.

هذا القيد متعلق بالشبكة في بيئة التجهيز، وليس نتيجة Compiler error من سورس المشروع.
