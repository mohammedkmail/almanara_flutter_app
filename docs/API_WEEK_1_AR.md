# ربط المنارة — Week 1

## الهدف النهائي

تطبيق Flutter وموقع المكتبة لا يملكان قاعدتي بيانات منفصلتين. كلاهما يتعامل مع **نفس Grails LibrarySystem ونفس MySQL**:

```text
                 ┌── Website / GSP
                 │
MySQL ← Grails LibrarySystem
                 │
                 └── REST API ← Flutter
```

المسارات الجديدة للـ mobile API مضافة إلى نفس مشروع الويب، لذلك قواعد العمل الموجودة في Services تبقى هي المرجع الوحيد.

## ما تم تنفيذه

- `Dio` لإرسال HTTP/JSON.
- GET الكتب من قاعدة MySQL الحقيقية.
- POST حجز كتاب.
- Models للـ request/response و JSON serialization/deserialization.
- فصل الـ UI عن منطق API في `services/`.
- Loading / error / empty states.
- Login API عبر Spring Security REST وJWT.
- حفظ التوكن بواسطة `flutter_secure_storage`.
- `/api/me` لاستعادة الجلسة والتأكد من صلاحية التوكن.
- Role-based navigation للمستخدم والإدارة.
- Logout يحذف التوكن من الجهاز.

## التشغيل الحقيقي — MySQL

من جذر Flutter:

```powershell
./scripts/start-backend-mysql.ps1
```

السكريبت يشغّل Grails في:

```text
grails.env=development
port=8080
```

وفي `grails-app/conf/application.yml` بيئة development تستخدم قاعدة:

```text
ubs_training
```

لذلك أي كتاب/حجز يظهر في الموقع أو يُضاف من نفس النظام يكون في نفس قاعدة البيانات التي يقرأ منها Flutter.

ثم شغّل Flutter:

```powershell
flutter pub get
flutter run -d emulator-5554
```

العنوان الافتراضي في Flutter:

```text
http://10.0.2.2:8080
```

`10.0.2.2` هو localhost للكمبيوتر من داخل Android Emulator.

## استخدام Tomcat بدلاً من bootRun

إذا كان الموقع منشوراً على Tomcat تحت:

```text
http://localhost:8080/LibrarySystem
```

ابنِ WAR من **هذه النسخة المدمجة** لأنها تحتوي API/JWT:

```powershell
./scripts/build-backend-war.ps1
```

بعد نشره، شغّل Flutter:

```powershell
flutter run -d emulator-5554 --dart-define=API_BASE_URL=http://10.0.2.2:8080/LibrarySystem
```

## لماذا كانت البيانات سابقاً مختلفة؟

السكريبت القديم:

```powershell
./scripts/start-api-test.ps1
```

يشغّل:

```text
grails.env=test
port=8081
```

وبيئة `test` تستخدم H2 مؤقتة وBootStrap، لذلك ظهرت بيانات تدريب مختلفة عن موقع المكتبة. هذا السكريبت بقي للاختبارات فقط.

## API Contracts

| Method | Path | Request / Response |
|---|---|---|
| POST | `/api/login` | `{username,password}` → JWT response |
| GET | `/api/me` | `{id,username,fullName,roles}` |
| GET | `/api/books?max=100&offset=0` | `{total,max,offset,data:[...]}` |
| GET | `/api/books/{id}` | book object |
| POST | `/api/reservations` | `{bookId}` → reservation, `201` |
| GET | `/api/reservations` | current user's reservations |

الطلبات المحمية ترسل:

```text
Authorization: Bearer <token>
Accept: application/json
```

والـ POST يرسل:

```text
Content-Type: application/json
```

## أهم Status Codes

- `200` نجاح.
- `201` تم إنشاء مورد جديد.
- `400` بيانات الطلب غير صحيحة.
- `401` Login/Token مطلوب أو غير صالح.
- `403` المستخدم معروف لكن لا يملك الصلاحية.
- `404` العنصر غير موجود.
- `409` تعارض في business state مثل وجود حجز فعال.
- `422` فشل validation.
- `5xx` خطأ في السيرفر.

## JWT

`grails-app/conf/application.groovy` يفعّل Spring Security REST JWT. في development يتم إنشاء secret مؤقت عند تشغيل السيرفر، لذلك Restart للسيرفر يلغي التوكنات السابقة. في production يجب تحديد `JWT_SECRET` ثابت وآمن.

## اختبار H2 المعزول

للاختبارات فقط:

```powershell
./scripts/start-api-test.ps1
```

ثم يمكن تمرير:

```text
API_BASE_URL=http://10.0.2.2:8081
```

لا تعتمد على بيانات H2 عند مقارنة Flutter بالموقع.

## ما لم يتم ربطه بعد

نطاق Week 1 الرئيسي مرتبط: Login + Books + Book Reservation + Session. الشاشات الأخرى مثل الغرف والعضويات والمبيعات والإشعارات والقراءة الرقمية يمكن ربطها في المراحل التالية بنفس نمط `Model → Service → API → UI`.
