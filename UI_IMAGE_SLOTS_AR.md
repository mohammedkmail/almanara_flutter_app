# أماكن الصور في واجهة Flutter

## صور البيانات — تعمل تلقائيًا من Grails

لا تضف هذه الصور داخل `assets` يدويًا:

- أغلفة الكتب: `Book.coverUrl`
- صور غرف الدراسة: `StudyRoom.imageUrl`
- صور المؤلفين: `AuthorItem.imageUrl`

يتم عرض fallback مرتب إذا لم توجد صورة.

## الصور الزخرفية

الـHome Hero يستخدم الآن `ManaraDecorativeImageSlot` داخل:

```text
lib/screens/home_screen.dart
```

وعند اعتماد صورة نهائية يمكنك استبداله بـ:

```dart
Image.asset(
  'assets/images/home_hero_final.jpg',
  fit: BoxFit.cover,
)
```

ثم ضع الصورة في:

```text
assets/images/
```

المجلد معرف أصلًا في `pubspec.yaml`.

الفكرة المقصودة هي أن صور الكتب والغرف تكون حقيقية من النظام، بينما صور الـHero لا تكون صور AI عشوائية أو صور تجريبية مخلوطة ببيانات المشروع.
