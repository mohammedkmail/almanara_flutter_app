import 'app_user_role.dart';
import 'library_book.dart';

class LoginRequest {
  final String username;
  final String password;
  const LoginRequest(this.username, this.password);
  Map<String, dynamic> toJson() => {'username': username, 'password': password};
}

class LoginResponse {
  final String accessToken;
  const LoginResponse(this.accessToken);
  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    final token = json['access_token'];
    if (token is! String || token.isEmpty) {
      throw const FormatException('Missing access token');
    }
    return LoginResponse(token);
  }
}

class ApiUser {
  final String username;
  final String fullName;
  final AppUserRole role;
  const ApiUser(this.username, this.fullName, this.role);
  factory ApiUser.fromJson(Map<String, dynamic> json) => ApiUser(
    json['username'] as String,
    (json['fullName'] ?? json['username']) as String,
    (json['roles'] as List).contains('ROLE_ADMIN')
        ? AppUserRole.admin
        : AppUserRole.customer,
  );
}

class BookPage {
  final List<LibraryBook> books;
  final int total;
  const BookPage(this.books, this.total);
  factory BookPage.fromJson(Map<String, dynamic> json) => BookPage(
    (json['data'] as List)
        .map((e) => LibraryBook.fromJson(e as Map<String, dynamic>))
        .toList(),
    (json['total'] as num).toInt(),
  );
}

class ReservationRequest {
  final int bookId;
  const ReservationRequest(this.bookId);
  Map<String, dynamic> toJson() => {'bookId': bookId};
}

class BookReservation {
  final int id;
  final String bookTitle;
  final String status;
  final double feeAmount;
  const BookReservation(this.id, this.bookTitle, this.status, this.feeAmount);
  factory BookReservation.fromJson(Map<String, dynamic> json) =>
      BookReservation(
        (json['id'] as num).toInt(),
        json['bookTitle'] as String,
        json['status'] as String,
        (json['feeAmount'] as num).toDouble(),
      );
  String get statusLabel => switch (status) {
    'WAITING' => 'في قائمة الانتظار',
    'READY' => 'تم تخصيص نسخة — بانتظار الدفع أو التأكيد',
    'PAID' => 'مدفوع',
    'CONFIRMED' => 'مؤكد',
    'FULFILLED' => 'تم التسليم',
    'EXPIRED' => 'منتهي',
    'CANCELLED' => 'ملغي',
    _ => status,
  };
}
