# ابدأ من هنا — Flutter

هذه النسخة مصممة للعمل مع Grails الموجود في الحزمة الثانية.

## أول تشغيل

```bash
flutter clean
flutter pub get
flutter run -d chrome
```

على Chrome سيستخدم تلقائيًا:

```text
http://localhost:8080/LibrarySystem
```

على Android Emulator سيستخدم:

```text
http://10.0.2.2:8080/LibrarySystem
```

وللهاتف الحقيقي استخدم:

```bash
flutter run --dart-define=API_BASE_URL=http://YOUR_PC_IP:8080/LibrarySystem
```

## Firebase — اجعله آخر خطوة

1. أنشئ/اختر Firebase Project.
2. أضف Android app بالـpackage `com.almanara.library`.
3. نزّل `google-services.json`.
4. ضعه في `android/app/google-services.json`.
5. نفّذ `flutter clean` ثم `flutter pub get` وشغّل التطبيق.

الكود يعمل بدون Firebase أثناء فحص بقية النظام؛ FCM يتفعل بعد إضافة الملف.

راجع `README.md` للقائمة الكاملة لاختبارات التسليم وبناء APK.
