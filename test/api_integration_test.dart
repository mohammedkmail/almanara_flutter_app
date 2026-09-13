import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:al_manara_system/models/api_models.dart';
import 'package:al_manara_system/models/app_user_role.dart';
import 'package:al_manara_system/services/api_client.dart';
import 'package:al_manara_system/services/auth_service.dart';
import 'package:al_manara_system/services/library_service.dart';

class FakeAdapter implements HttpClientAdapter {
  final ResponseBody Function(RequestOptions) handler;
  FakeAdapter(this.handler);
  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async => handler(options);
  @override
  void close({bool force = false}) {}
}

ResponseBody jsonResponse(Object data, [int code = 200]) =>
    ResponseBody.fromString(
      jsonEncode(data),
      code,
      headers: {
        Headers.contentTypeHeader: ['application/json'],
      },
    );

ApiClient clientWith(ResponseBody Function(RequestOptions) handler) {
  final client = ApiClient();
  client.dio.httpClientAdapter = FakeAdapter(handler);
  return client;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(() => FlutterSecureStorage.setMockInitialValues({}));

  test(
    'login uses JSON, secures token, validates identity and restores session',
    () async {
      final client = clientWith((options) {
        if (options.path == '/api/login') {
          expect(options.method, 'POST');
          expect(options.data, {'username': 'student', 'password': 'password'});
          expect(options.headers.containsKey('Authorization'), isFalse);
          return jsonResponse({'access_token': 'test-token'});
        }
        expect(options.path, '/api/me');
        expect(options.headers['Authorization'], 'Bearer test-token');
        return jsonResponse({
          'username': 'student',
          'fullName': 'طالب',
          'roles': ['ROLE_USER'],
        });
      });
      final auth = AuthService(client);
      await auth.login(const LoginRequest('student', 'password'));
      expect(auth.user.value!.role, AppUserRole.customer);
      final restored = AuthService(client);
      await restored.restore();
      expect(restored.user.value!.username, 'student');
      await restored.logout();
      expect(client.token, isNull);
      expect(await restored.storage.readAll(), isEmpty);
    },
  );

  test('bad login and 403 do not expire an unrelated session', () async {
    var expired = false;
    final client = clientWith((_) => jsonResponse({}, 401));
    client.onUnauthorized = () async {
      expired = true;
    };
    await expectLater(
      client.request('/api/login', authenticated: false),
      throwsA(isA<ApiException>().having((e) => e.statusCode, 'status', 401)),
    );
    expect(expired, isFalse);
    client.dio.httpClientAdapter = FakeAdapter((_) => jsonResponse({}, 403));
    await expectLater(
      client.request('/api/books'),
      throwsA(isA<ApiException>()),
    );
    expect(expired, isFalse);
  });

  test('authenticated 401 clears secure token and current identity', () async {
    final client = clientWith((_) => jsonResponse({}, 401));
    final auth = AuthService(client);
    client.token = 'expired';
    auth.user.value = const ApiUser('student', 'Student', AppUserRole.customer);
    await expectLater(
      client.request('/api/books'),
      throwsA(isA<ApiException>()),
    );
    expect(client.token, isNull);
    expect(auth.user.value, isNull);
  });

  test(
    'catalog follows pagination and parses nested names and numeric prices',
    () async {
      var calls = 0;
      final client = clientWith((options) {
        expect(options.queryParameters['offset'], calls);
        calls++;
        return jsonResponse({
          'total': 2,
          'data': [
            {
              'id': calls,
              'title': 'Book $calls',
              'author': {'name': 'Author'},
              'category': {'name': 'Category'},
              'available': true,
              'borrowingFee': 3,
            },
          ],
        });
      });
      final books = await LibraryService(client).books();
      expect(books.length, 2);
      expect(books.first.author, 'Author');
      expect(books.first.borrowingFee, 3.0);
      expect(books.first.available, isTrue);
    },
  );

  test('empty catalog terminates pagination', () async {
    final client = clientWith((_) => jsonResponse({'total': 0, 'data': []}));
    expect(await LibraryService(client).books(), isEmpty);
  });

  test(
    'reservation sends only book identity and renders actual 201 status',
    () async {
      final client = clientWith((options) {
        expect(options.method, 'POST');
        expect(options.data, {'bookId': 9});
        return jsonResponse({
          'id': 21,
          'bookTitle': 'Book',
          'status': 'WAITING',
          'feeAmount': 3,
        }, 201);
      });
      final reservation = await LibraryService(client)
          .reserve(const ReservationRequest(9));
      expect(reservation.id, 21);
      expect(reservation.statusLabel, 'في قائمة الانتظار');
    },
  );

  test('conflict preserves server message without retrying POST', () async {
    var calls = 0;
    final client = clientWith((_) {
      calls++;
      return jsonResponse({'message': 'لديك حجز فعال'}, 409);
    });
    await expectLater(
      LibraryService(client).reserve(const ReservationRequest(9)),
      throwsA(
        isA<ApiException>().having(
          (e) => e.message,
          'message',
          'لديك حجز فعال',
        ),
      ),
    );
    expect(calls, 1);
  });

  test(
    'HTML and missing login token fail instead of reporting success',
    () async {
      final client = clientWith(
        (_) => ResponseBody.fromString('<html>Login</html>', 200),
      );
      await expectLater(
        client.request('/api/books'),
        throwsA(isA<ApiException>()),
      );
      expect(() => LoginResponse.fromJson({}), throwsFormatException);
    },
  );
}
