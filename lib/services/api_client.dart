import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

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
              connectTimeout: const Duration(seconds: 15),
              receiveTimeout: const Duration(seconds: 25),
              sendTimeout: const Duration(seconds: 25),
              followRedirects: false,
              headers: const {'Accept': 'application/json'},
            ),
          );

  Future<Map<String, dynamic>> request(
    String path, {
    String method = 'GET',
    Object? data,
    Map<String, dynamic>? query,
    bool authenticated = true,
  }) async {
    final sentToken = authenticated ? token : null;
    final requestUrl = ApiConfig.url(path);

    debugPrint('API REQUEST: $method $requestUrl');

    try {
      final response = await dio.request<dynamic>(
        requestUrl,
        data: data,
        queryParameters: query,
        options: Options(
          method: method,
          contentType: data is FormData
              ? Headers.multipartFormDataContentType
              : Headers.jsonContentType,
          headers: {
            if (sentToken != null) 'Authorization': 'Bearer $sentToken',
          },
        ),
      );

      debugPrint('API STATUS: ${response.statusCode}');
      debugPrint('API URL: ${response.realUri}');

      if (response.data is! Map) {
        throw const ApiException('استجابة غير متوقعة من السيرفر.');
      }

      return Map<String, dynamic>.from(response.data as Map);
    } on DioException catch (error) {
      final status = error.response?.statusCode;

      debugPrint('DIO TYPE: ${error.type}');
      debugPrint('DIO STATUS: $status');
      debugPrint('DIO URL: ${error.requestOptions.uri}');
      debugPrint('DIO MESSAGE: ${error.message}');
      debugPrint('DIO RESPONSE: ${error.response?.data}');

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
        409 => 'لا يمكن تنفيذ العملية في الحالة الحالية.',
        400 || 422 => 'تحقق من البيانات المدخلة.',
        _ =>
          status != null && status >= 500
              ? 'حدث خطأ في السيرفر. حاول لاحقاً.'
              : 'تعذر الاتصال بالسيرفر. تحقق أن Tomcat يعمل وأن عنوان API صحيح.',
      };

      final body = error.response?.data;

      if (body is Map && body['message'] is String) {
        message = body['message'] as String;
      }

      if (error.type == DioExceptionType.connectionTimeout ||
          error.type == DioExceptionType.receiveTimeout ||
          error.type == DioExceptionType.sendTimeout) {
        message =
            'انتهت مهلة الطلب. تحقق أن Grails/Tomcat يعمل ثم حاول مجدداً.';
      }

      throw ApiException(message, status);
    }
  }
}
