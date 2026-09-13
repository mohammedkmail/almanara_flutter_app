import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../models/api_models.dart';
import 'api_client.dart';

class AuthService {
  static final instance = AuthService(ApiClient());
  final ApiClient client;
  final FlutterSecureStorage storage;
  final ValueNotifier<ApiUser?> user = ValueNotifier(null);
  AuthService(this.client, {this.storage = const FlutterSecureStorage()}) {
    client.onUnauthorized = logout;
  }
  String get _key => 'manara.accessToken.${client.dio.options.baseUrl}';

  Future<void> login(LoginRequest request) async {
    try {
      final response = LoginResponse.fromJson(
        await client.request(
          '/api/login',
          method: 'POST',
          data: request.toJson(),
          authenticated: false,
        ),
      );
      client.token = response.accessToken;
      final account = ApiUser.fromJson(await client.request('/api/me'));
      await storage.write(key: _key, value: response.accessToken);
      user.value = account;
    } catch (_) {
      client.token = null;
      rethrow;
    }
  }

  Future<void> restore() async {
    client.token = await storage.read(key: _key);
    if (client.token == null) return;
    try {
      user.value = ApiUser.fromJson(await client.request('/api/me'));
    } on ApiException catch (error) {
      if (error.statusCode != 401) rethrow;
      // Unauthorized callback already removed the expired token.
    }
  }

  // JWT logout clears this device's token. Server-issued tokens expire after one hour.
  Future<void> logout() async {
    await storage.delete(key: _key);
    client.token = null;
    user.value = null;
  }
}
