import 'package:flutter_test/flutter_test.dart';
import 'dart:io';
import 'package:dio/io.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:al_manara_system/models/api_models.dart';
import 'package:al_manara_system/services/api_client.dart';
import 'package:al_manara_system/services/auth_service.dart';
import 'package:al_manara_system/services/library_service.dart';

// Run only against the disposable H2 backend started by scripts/start-api-test.ps1.
// This deliberately creates a reservation in that test database.
void main() {
  final nativeClient = HttpClient();
  TestWidgetsFlutterBinding.ensureInitialized();
  const url = String.fromEnvironment('API_TEST_URL');
  test(
    'Flutter services communicate with real Grails over HTTP',
    () async {
      FlutterSecureStorage.setMockInitialValues({});
    final client = ApiClient();
    client.dio.httpClientAdapter = IOHttpClientAdapter(createHttpClient: () => nativeClient);
      client.dio.options.baseUrl = url;
      final auth = AuthService(client);
      final library = LibraryService(client);
      await expectLater(
        client.request('/api/books'),
        throwsA(
          isA<ApiException>().having(
            (e) => e.statusCode,
            'unauthenticated',
            401,
          ),
        ),
      );
      await expectLater(
        auth.login(const LoginRequest('ahmad@library.com', 'wrong')),
        throwsA(
          isA<ApiException>().having((e) => e.statusCode, 'bad password', 401),
        ),
      );
      await auth.login(const LoginRequest('ahmad@library.com', '123456'));
      expect(auth.user.value!.username, 'ahmad@library.com');
      final books = await library.books();
      expect(books, isNotEmpty);
      final existing = await library.reservations();
      BookReservation? created;
      for (final book in books) {
        try {
          created = await library.reserve(ReservationRequest(book.id!));
          break;
        } on ApiException catch (error) {
          if (error.statusCode != 409) rethrow;
        }
      }
      expect(
        created,
        isNotNull,
        reason: 'Restart the disposable backend to reset test data.',
      );
      expect((await library.reservations()).length, existing.length + 1);
      final book = books.firstWhere((b) => b.title == created!.bookTitle);
      await expectLater(
        library.reserve(ReservationRequest(book.id!)),
        throwsA(
          isA<ApiException>().having((e) => e.statusCode, 'duplicate', 409),
        ),
      );
      final restored = AuthService(client);
      await restored.restore();
      expect(restored.user.value!.username, 'ahmad@library.com');
      await restored.logout();
      await expectLater(
        client.request('/api/books'),
        throwsA(
          isA<ApiException>().having((e) => e.statusCode, 'logged out', 401),
        ),
      );
      client.dio.close();
    },
    skip: url.isEmpty
        ? 'Set API_TEST_URL for an isolated live backend.'
        : false,
  );
}
