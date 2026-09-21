import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../models/api_models.dart';
import 'api_client.dart';
import 'api_config.dart';

class AuthService {
  static final instance = AuthService(ApiClient());

  final ApiClient client;
  final FlutterSecureStorage storage;
  final ValueNotifier<ApiUser?> user = ValueNotifier(null);

  AuthService(this.client, {this.storage = const FlutterSecureStorage()}) {
    client.onUnauthorized = clearLocalSession;
  }

  String get _key => 'manara.accessToken.${ApiConfig.baseUrl}';

  Future<void> login(LoginRequest request) async {
    final response = LoginResponse.fromJson(
      await client.request(
        '/api/login',
        method: 'POST',
        data: request.toJson(),
        authenticated: false,
      ),
    );
    await _acceptSession(response);
  }

  Future<void> register({
    required String username,
    required String fullName,
    required String password,
  }) async {
    final response = LoginResponse.fromJson(
      await client.request(
        '/api/register',
        method: 'POST',
        data: {
          'username': username.trim().toLowerCase(),
          'fullName': fullName.trim(),
          'password': password,
        },
        authenticated: false,
      ),
    );
    await _acceptSession(response);
  }

  Future<void> _acceptSession(LoginResponse response) async {
    client.token = response.accessToken;
    try {
      final account =
          response.user ?? ApiUser.fromJson(await client.request('/api/me'));
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
    }
  }

  Future<void> logout() async {
    if (client.token != null) {
      try {
        await client.request('/api/logout', method: 'POST');
      } catch (_) {
        // Local logout must still succeed if the server cannot be reached.
      }
    }
    await clearLocalSession();
  }

  Future<void> clearLocalSession() async {
    await storage.delete(key: _key);
    client.token = null;
    user.value = null;
  }
}
