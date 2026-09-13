class ApiConfig {
  ApiConfig._();

  // Android Emulator يصل إلى localhost في الكمبيوتر عبر 10.0.2.2.
  // غيّر هذا العنوان لاحقاً إذا شغلت التطبيق على جهاز حقيقي أو سيرفر خارجي.
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://10.0.2.2:8081',
  );

  // هذا الـ endpoint موجود حالياً في مشروع الويب.
  static const String books = '/api/books';

  static String bookById(int id) => '$books/$id';
}
