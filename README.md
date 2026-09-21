# المنارة — Flutter Mobile Client

تطبيق Flutter لنظام مكتبة **المنارة**. هذه النسخة متصلة مباشرةً بمشروع Grails الموجود في الحزمة الثانية، وليست مشروع UI تجريبي منفصل.

## ما الذي يعمل في التطبيق؟

- Splash + استعادة الجلسة.
- تسجيل الدخول وإنشاء الحساب وتسجيل الخروج.
- Bearer access token محفوظ في `flutter_secure_storage`.
- Dashboard واحد للمستخدم يعرض بيانات حقيقية من السيرفر.
- فهرس الكتب، البحث، التفاصيل، صور الأغلفة ومشاركة الكتاب عبر Android Share Sheet.
- حجز كتاب وإلغاء الحجز والدفع عند الحاجة.
- شراء ورقي/رقمي واستئجار رقمي حسب إعداد الكتاب في Grails.
- غرف الدراسة: عرض الغرف، احتساب السعر، الحجز، الإلغاء والدفع.
- العضوية: الحالة الحالية، التسعير والدفع.
- شاشة **مكتبتي** تجمع حجوزات الكتب والغرف والمشتريات والوصول الرقمي.
- التقويم/العطل من نفس Backend.
- Admin: Dashboard حقيقي، إدارة الكتب، ISBN lookup، إدارة الغرف، ومتابعة العمليات.
- Firebase Cloud Messaging مهيأ للكود: token registration، foreground/background notifications وفتح الإشعار.
- Loading / empty / validation / API / network error states.

## المعمارية

```text
Flutter UI
   ↓
Models + Services
   ↓  HTTP/JSON + Bearer token
Grails REST API
   ↓
Existing Grails Services / Business Rules
   ↓
MySQL

Grails → Braintree (payments)
Grails → Google Books / Open Library (ISBN metadata)
Grails → Holiday provider (calendar)
Grails → Firebase Admin → FCM → Android app
```

الويب والموبايل يستخدمان نفس قاعدة البيانات ونفس طبقة الـServices في Grails، لذلك لا توجد قواعد حجز أو دفع مكررة داخل Flutter.

## المتطلبات

- يفضّل Flutter 3.47.2 (وهو الإصدار الذي أُنشئت به هذه النسخة)؛ الحد البرمجي في `pubspec.yaml` هو Dart 3.10+
- Android SDK
- مشروع Grails الثاني شغال على Tomcat أو `bootRun`
- MySQL الخاص بالمكتبة

بعد فك الضغط:

```bash
flutter pub get
```

> `pubspec.lock` يتم إنشاؤه بواسطة `flutter pub get` بعد تثبيت الحزم على جهازك.

## عنوان الـAPI

التطبيق يختار العنوان المناسب تلقائيًا في التطوير:

### Chrome على نفس الكمبيوتر

```text
http://localhost:8080/LibrarySystem
```

```bash
flutter run -d chrome
```

### Android Emulator

```text
http://10.0.2.2:8080/LibrarySystem
```

```bash
flutter run
```

### هاتف Android حقيقي

الهاتف لا يستطيع استخدام `localhost` للوصول للكمبيوتر. استعمل IP الكمبيوتر على نفس شبكة Wi‑Fi:

```bash
flutter run --dart-define=API_BASE_URL=http://YOUR_PC_IP:8080/LibrarySystem
```

مثال فقط:

```bash
flutter run --dart-define=API_BASE_URL=http://192.168.1.20:8080/LibrarySystem
```

لا تغيّر الكود من أجل الـIP؛ استخدم `--dart-define`.

## Firebase — آخر خطوة يدوية

الكود مهيأ بحيث غياب Firebase لا يمنع بقية التطبيق من العمل. لتفعيل FCM على Android:

1. أنشئ Firebase Project.
2. أضف Android app بالـpackage التالي حرفيًا:

```text
com.almanara.library
```

3. نزّل `google-services.json` وضعه هنا:

```text
android/app/google-services.json
```

4. لا ترفعه إلى Git؛ الملف موجود في `.gitignore`.
5. نفّذ:

```bash
flutter clean
flutter pub get
flutter run
```

الـGradle يطبق Google Services فقط عندما يكون `google-services.json` موجودًا، لذلك المشروع يظل قابلًا للتشغيل قبل هذه الخطوة.

### Backend Firebase

إرسال FCM من السيرفر يحتاج أيضًا Firebase Admin service account داخل مشروع Grails. التعليمات موجودة في README الخاص بالـGrails و`INTEGRATIONS_SETUP_AR.md`.

## الدفع

لا توجد مفاتيح Braintree داخل Flutter. التطبيق يطلب Checkout من Grails ثم يفتح صفحة دفع قصيرة العمر يقدمها الـBackend. بعد نجاح الدفع، Grails هو المسؤول عن تحديث الحجز/الشراء/العضوية.

هذا يمنع كشف مفاتيح الدفع داخل APK.

## ISBN

إضافة كتاب من واجهة Admin تدعم البحث بالـISBN عبر Grails. الـBackend يجرب Google Books ثم Open Library، لذلك Flutter لا يحمل مفاتيح خارجية ولا يكرر منطق جلب البيانات.

## بناء APK

بعد نجاح التجربة على Android:

```bash
flutter build apk --release
```

الملف المتوقع:

```text
build/app/outputs/flutter-apk/app-release.apk
```

إعداد release الحالي مناسب لعمل APK للديمو المحلي. للنشر على Google Play أنشئ keystore إنتاجي واتبع إعداد signing الرسمي بدل debug signing.

## فحص التسليم المقترح

نفّذ هذه السيناريوهات قبل العرض النهائي:

1. Login صحيح وخاطئ.
2. إنشاء حساب جديد.
3. عرض الكتب والبحث وفتح التفاصيل.
4. حجز كتاب ثم ظهوره في **مكتبتي**.
5. إلغاء حجز مسموح.
6. ISBN lookup من Admin.
7. عرض الغرف + quote + حجز غرفة.
8. عرض العضوية والدفع في Braintree Sandbox.
9. شراء/استئجار رقمي حسب كتاب يدعم ذلك.
10. سحب الشاشة للتحديث بعد الدفع والعودة للتطبيق.
11. قطع الإنترنت والتأكد من ظهور رسالة واضحة.
12. استقبال FCM في foreground/background بعد إضافة Firebase.
13. الضغط على الإشعار وفتح القسم المناسب.
14. Share من تفاصيل الكتاب وظهور Android Share Sheet.

## ملاحظة مهمة قبل أول تشغيل مع النسخة الجديدة من Grails

إذا قاعدة MySQL موجودة من المشروع القديم وGrails production يعمل بـ`dbCreate: none`، شغّل ملف migration الموجود في مشروع Grails **مرة واحدة** قبل تجربة Login من Flutter. الملف يضيف جداول mobile tokens وFCM وروابط الدفع وغيرها بدون حذف بيانات المكتبة الحالية.
