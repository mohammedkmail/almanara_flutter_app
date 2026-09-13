import 'package:dio/dio.dart';

import 'api_config.dart';

class ApiException implements Exception {
  final String message;
  final int? statusCode;
  const ApiException(this.message, [this.statusCode]);
  @override
  String toString() => message;
}

class ApiClient {
  final Dio dio;
  String? token;
  Future<void> Function()? onUnauthorized;
  ApiClient({Dio? dio})
    : dio =
          dio ??
          Dio(
            BaseOptions(
              baseUrl: ApiConfig.baseUrl.replaceAll(RegExp(r'/+$'), ''),
              connectTimeout: const Duration(seconds: 15),
              receiveTimeout: const Duration(seconds: 20),
              sendTimeout: const Duration(seconds: 20),
              followRedirects: false,
              headers: {'Accept': 'application/json'},
              contentType: Headers.jsonContentType,
            ),
          );

  Future<Map<String, dynamic>> request(
    String path, {
    String method = 'GET',
    Map<String, dynamic>? data,
    Map<String, dynamic>? query,
    bool authenticated = true,
  }) async {
    final sentToken = authenticated ? token : null;
    try {
      final response = await dio.request<dynamic>(
        path,
        data: data,
        queryParameters: query,
        options: Options(
          method: method,
          headers: {
            if (sentToken != null) 'Authorization': 'Bearer $sentToken',
          },
        ),
      );
      if (response.data is! Map<String, dynamic>) {
        throw const ApiException(
          'استجابة غير متوقعة من السيرفر. تحقق من عنوان API.',
        );
      }
      return response.data as Map<String, dynamic>;
    } on DioException catch (error) {
      final status = error.response?.statusCode;
      if (status == 401 && authenticated && token == sentToken) {
        await onUnauthorized?.call();
      }
      String message = switch (status) {
        401 =>
          authenticated
              ? 'انتهت الجلسة. سجّل الدخول مجدداً.'
              : 'اسم المستخدم أو كلمة المرور غير صحيحة.',
        403 => 'ليس لديك صلاحية لهذه العملية.',
        404 => 'العنصر أو مسار API غير موجود.',
        409 => 'يتعارض الطلب مع الحالة الحالية.',
        400 || 422 => 'تحقق من البيانات المدخلة.',
        _ =>
          status != null && status >= 500
              ? 'حدث خطأ في السيرفر. حاول لاحقاً.'
              : 'تعذر الاتصال بالسيرفر. تحقق من الاتصال وعنوان API.',
      };
      final body = error.response?.data;
      if (status != null &&
          status < 500 &&
          body is Map &&
          body['message'] is String) {
        message = body['message'] as String;
      }
      if (error.type == DioExceptionType.connectionTimeout ||
          error.type == DioExceptionType.receiveTimeout ||
          error.type == DioExceptionType.sendTimeout) {
        message = 'انتهت مهلة الطلب. حدّث القائمة للتحقق قبل إعادة الإرسال.';
      }
      throw ApiException(message, status);
    }
  }
}
