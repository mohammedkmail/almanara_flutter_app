import '../models/api_models.dart';
import '../models/library_book.dart';
import 'api_client.dart';
import 'auth_service.dart';

class LibraryService {
  static final instance = LibraryService(AuthService.instance.client);
  final ApiClient client;
  LibraryService(this.client);

  Future<List<LibraryBook>> books() async {
    final result = <LibraryBook>[];
    while (true) {
      final page = BookPage.fromJson(
        await client.request(
          '/api/books',
          query: {'max': 100, 'offset': result.length},
        ),
      );
      result.addAll(page.books);
      if (page.books.isEmpty || result.length >= page.total) return result;
    }
  }

  Future<BookReservation> reserve(ReservationRequest request) async =>
      BookReservation.fromJson(
        await client.request(
          '/api/reservations',
          method: 'POST',
          data: request.toJson(),
        ),
      );

  Future<List<BookReservation>> reservations() async {
    final json = await client.request('/api/reservations');
    return (json['data'] as List)
        .map((e) => BookReservation.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
