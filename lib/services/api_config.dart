import 'package:flutter/foundation.dart';

class ApiConfig {
  ApiConfig._();

  static const String _override = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: '',
  );

  static String get baseUrl {
    if (_override.trim().isNotEmpty) {
      return _normalize(_override);
    }

    if (kIsWeb) {
      return 'http://localhost:8080/LibrarySystem';
    }

    if (defaultTargetPlatform == TargetPlatform.android) {
      return 'http://localhost:8080/LibrarySystem';
    }

    return 'http://localhost:8080/LibrarySystem';
  }

  static String url(String path) {
    final clean = path.startsWith('/') ? path : '/$path';
    return '$baseUrl$clean';
  }

  static String? resourceUrl(String? value) {
    if (value == null || value.trim().isEmpty) return null;

    final trimmed = value.trim();

    if (trimmed.startsWith('http://') || trimmed.startsWith('https://')) {
      return trimmed;
    }

    final base = Uri.parse(baseUrl);

    if (trimmed.startsWith('/')) {
      final contextPath = base.path.replaceAll(RegExp(r'/+$'), '');

      if (contextPath.isNotEmpty &&
          (trimmed == contextPath || trimmed.startsWith('$contextPath/'))) {
        return base
            .replace(path: trimmed, query: null, fragment: null)
            .toString();
      }
    }

    return url(trimmed);
  }

  static String _normalize(String value) {
    return value.trim().replaceAll(RegExp(r'/+$'), '');
  }
}
