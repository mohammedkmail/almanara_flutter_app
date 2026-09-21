import 'package:dio/dio.dart';
import 'package:image_picker/image_picker.dart';

import '../models/api_models.dart';
import '../models/library_book.dart';
import '../models/study_room.dart';
import 'api_client.dart';
import 'api_config.dart';
import 'auth_service.dart';

class LibraryService {
  static final instance = LibraryService(AuthService.instance.client);
  final ApiClient client;
  LibraryService(this.client);

  Future<List<LibraryBook>> books({
    String search = '',
    int? categoryId,
    int? authorId,
    bool? availableOnly,
    bool? digitalOnly,
  }) async {
    final result = <LibraryBook>[];
    while (true) {
      final page = BookPage.fromJson(
        await client.request(
          '/api/books',
          query: {
            'max': 100,
            'offset': result.length,
            if (search.trim().isNotEmpty) 'search': search.trim(),
            if (categoryId != null) 'categoryId': categoryId,
            if (authorId != null) 'authorId': authorId,
            if (availableOnly != null) 'availableOnly': availableOnly,
            if (digitalOnly != null) 'digitalOnly': digitalOnly,
          },
        ),
      );
      result.addAll(page.books);
      if (page.books.isEmpty || result.length >= page.total) return result;
    }
  }

  Future<LibraryBook> book(int id) async =>
      LibraryBook.fromJson(await client.request('/api/books/$id'));

  Future<LibraryBook> saveBook(Map<String, dynamic> data) async =>
      LibraryBook.fromJson(
        await client.request('/api/books', method: 'POST', data: data),
      );

  Future<LibraryBook> updateBook(int id, Map<String, dynamic> data) async =>
      LibraryBook.fromJson(
        await client.request('/api/books/$id', method: 'PUT', data: data),
      );

  Future<void> deleteBook(int id) async {
    await client.request('/api/books/$id', method: 'DELETE');
  }

  Future<IsbnMetadata> isbnLookup(String isbn) async => IsbnMetadata(
    await client.request(
      '/api/books/isbn-lookup',
      method: 'POST',
      data: {'isbn': isbn.trim()},
    ),
  );

  Future<DashboardSummary> dashboard() async =>
      DashboardSummary(await client.request('/api/dashboard'));

  Future<List<CategoryItem>> categories() async => mapList(
    (await client.request('/api/categories'))['data'],
  ).map(CategoryItem.fromJson).toList();

  Future<CategoryItem> category(int id) async =>
      CategoryItem.fromJson(await client.request('/api/categories/$id'));

  Future<List<AuthorItem>> authors() async => mapList(
    (await client.request('/api/authors'))['data'],
  ).map(AuthorItem.fromJson).toList();

  Future<AuthorItem> author(int id) async =>
      AuthorItem.fromJson(await client.request('/api/authors/$id'));

  Future<BookReservation> reserve(ReservationRequest request) async =>
      BookReservation.fromJson(
        await client.request(
          '/api/reservations',
          method: 'POST',
          data: request.toJson(),
        ),
      );

  Future<List<BookReservation>> reservations() async => mapList(
    (await client.request('/api/reservations'))['data'],
  ).map(BookReservation.fromJson).toList();

  Future<void> cancelReservation(int id) async {
    await client.request('/api/reservations/$id', method: 'DELETE');
  }

  Future<Map<String, dynamic>> reservationCheckout(
    int id, {
    String fulfillmentMethod = 'PICKUP',
    String? deliveryAddress,
  }) async {
    final result = await client.request(
      '/api/reservations/$id/checkout',
      method: 'POST',
      data: {
        'fulfillmentMethod': fulfillmentMethod,
        if (deliveryAddress?.trim().isNotEmpty == true)
          'deliveryAddress': deliveryAddress!.trim(),
      },
    );
    final paymentUrl = result['paymentUrl']?.toString();
    if (paymentUrl != null && paymentUrl.isNotEmpty) {
      result['paymentUrl'] = ApiConfig.resourceUrl(paymentUrl);
    }
    return result;
  }

  Future<List<BorrowingItem>> borrowings() async => mapList(
    (await client.request('/api/borrowings'))['data'],
  ).map(BorrowingItem.fromJson).toList();

  Future<List<StudyRoom>> rooms() async => mapList(
    (await client.request('/api/rooms'))['data'],
  ).map(StudyRoom.fromJson).toList();

  Future<StudyRoom> room(int id) async =>
      StudyRoom.fromJson(await client.request('/api/rooms/$id'));

  Future<StudyRoom> saveRoom(Map<String, dynamic> data) async =>
      StudyRoom.fromJson(
        await client.request('/api/rooms', method: 'POST', data: data),
      );

  Future<StudyRoom> updateRoom(int id, Map<String, dynamic> data) async =>
      StudyRoom.fromJson(
        await client.request('/api/rooms/$id', method: 'PUT', data: data),
      );

  Future<StudyRoom> uploadRoomPhoto(int id, XFile image) async {
    final bytes = await image.readAsBytes();
    final mimeType = _roomImageMimeType(image);

    final formData = FormData.fromMap({
      'imageFile': MultipartFile.fromBytes(
        bytes,
        filename: image.name.isNotEmpty ? image.name : 'room-image.jpg',
        contentType: DioMediaType.parse(mimeType),
      ),
    });

    return StudyRoom.fromJson(
      await client.request(
        '/api/rooms/$id/photo',
        method: 'POST',
        data: formData,
      ),
    );
  }

  Future<StudyRoom> removeRoomPhoto(int id) async {
    return StudyRoom.fromJson(
      await client.request('/api/rooms/$id/photo', method: 'DELETE'),
    );
  }

  Future<StudyRoom> saveRoomWithImage(
    Map<String, dynamic> data, {
    XFile? image,
  }) async {
    StudyRoom room = await saveRoom(data);

    if (image != null) {
      final roomId = room.id;
      if (roomId == null) {
        throw const ApiException(
          'تم إنشاء الغرفة لكن السيرفر لم يُرجع رقم الغرفة.',
        );
      }
      room = await uploadRoomPhoto(roomId, image);
    }

    return room;
  }

  Future<StudyRoom> updateRoomWithImage(
    int id,
    Map<String, dynamic> data, {
    XFile? image,
    bool removeImage = false,
  }) async {
    StudyRoom room = await updateRoom(id, data);

    if (removeImage) {
      room = await removeRoomPhoto(id);
    }

    if (image != null) {
      room = await uploadRoomPhoto(id, image);
    }

    return room;
  }

  String _roomImageMimeType(XFile image) {
    final reported = image.mimeType?.trim().toLowerCase();
    if (reported != null && reported.startsWith('image/')) {
      return reported;
    }

    final name = image.name.toLowerCase();

    if (name.endsWith('.png')) {
      return 'image/png';
    }
    if (name.endsWith('.webp')) {
      return 'image/webp';
    }
    if (name.endsWith('.gif')) {
      return 'image/gif';
    }
    if (name.endsWith('.heic') || name.endsWith('.heif')) {
      return 'image/heic';
    }

    return 'image/jpeg';
  }

  Future<void> deleteRoom(int id) async {
    await client.request('/api/rooms/$id', method: 'DELETE');
  }

  Future<Map<String, dynamic>> roomQuote({
    required int roomId,
    required DateTime start,
    required DateTime end,
  }) => client.request(
    '/api/room-quote',
    method: 'POST',
    data: {
      'studyRoomId': roomId,
      'startTime': start.toUtc().toIso8601String(),
      'endTime': end.toUtc().toIso8601String(),
    },
  );

  Future<PaymentLaunch> roomCheckout({
    required int roomId,
    required DateTime start,
    required DateTime end,
  }) async => PaymentLaunch.fromJson(
    await client.request(
      '/api/room-checkout',
      method: 'POST',
      data: {
        'studyRoomId': roomId,
        'startTime': start.toUtc().toIso8601String(),
        'endTime': end.toUtc().toIso8601String(),
      },
    ),
  );

  Future<List<RoomReservationItem>> roomReservations() async => mapList(
    (await client.request('/api/room-reservations'))['data'],
  ).map(RoomReservationItem.fromJson).toList();

  Future<void> cancelRoomReservation(int id) async {
    await client.request('/api/room-reservations/$id', method: 'DELETE');
  }

  Future<MembershipOverview> membership() async =>
      MembershipOverview.fromJson(await client.request('/api/membership'));

  Future<Map<String, dynamic>> membershipQuote(DateTime start, DateTime end) =>
      client.request(
        '/api/membership/quote',
        method: 'POST',
        data: {
          'startDate': start.toUtc().toIso8601String(),
          'endDate': end.toUtc().toIso8601String(),
        },
      );

  Future<PaymentLaunch> membershipCheckout(
    DateTime start,
    DateTime end,
  ) async => PaymentLaunch.fromJson(
    await client.request(
      '/api/membership/checkout',
      method: 'POST',
      data: {
        'startDate': start.toUtc().toIso8601String(),
        'endDate': end.toUtc().toIso8601String(),
      },
    ),
  );

  Future<MembershipInfo> cancelMembership(int id) async =>
      MembershipInfo.fromJson(
        await client.request('/api/membership/$id/cancel', method: 'POST'),
      );

  Future<List<PurchaseItem>> purchases() async => mapList(
    (await client.request('/api/purchases'))['data'],
  ).map(PurchaseItem.fromJson).toList();

  Future<List<PaymentItem>> payments() async => mapList(
    (await client.request('/api/payments'))['data'],
  ).map(PaymentItem.fromJson).toList();

  Future<PaymentLaunch> purchaseCheckout({
    required int bookId,
    required String purchaseType,
    int quantity = 1,
    String fulfillmentMethod = 'PICKUP',
    String? deliveryAddress,
  }) async => PaymentLaunch.fromJson(
    await client.request(
      '/api/purchases/checkout',
      method: 'POST',
      data: {
        'bookId': bookId,
        'purchaseType': purchaseType,
        'quantity': quantity,
        'fulfillmentMethod': fulfillmentMethod,
        if (deliveryAddress?.trim().isNotEmpty == true)
          'deliveryAddress': deliveryAddress!.trim(),
      },
    ),
  );

  Future<List<DigitalAccessItem>> digitalAccess() async => mapList(
    (await client.request('/api/digital-access'))['data'],
  ).map(DigitalAccessItem.fromJson).toList();

  Future<Map<String, dynamic>> digitalRead(int bookId) =>
      client.request('/api/digital-read/$bookId');

  Future<PaymentLaunch> digitalRent({
    required int bookId,
    required int days,
  }) async => PaymentLaunch.fromJson(
    await client.request(
      '/api/digital-rent',
      method: 'POST',
      data: {'bookId': bookId, 'rentalDays': days},
    ),
  );

  Future<List<Map<String, dynamic>>> holidays({int limit = 8}) async => mapList(
    (await client.request('/api/holidays', query: {'limit': limit}))['data'],
  );

  Future<Map<String, dynamic>> syncHolidays([int? year]) => client.request(
    '/api/holidays/sync',
    method: 'POST',
    query: {if (year != null) 'year': year},
  );

  Future<AdminOperations> adminOperations() async =>
      AdminOperations.fromJson(await client.request('/api/admin/operations'));

  Future<Map<String, dynamic>> adminReference() =>
      client.request('/api/admin/reference');

  Future<List<AdminUserItem>> adminUsers() async => mapList(
    (await client.request('/api/admin/users'))['data'],
  ).map(AdminUserItem.fromJson).toList();

  Future<List<BookCopyItem>> adminBookCopies({int? bookId}) async => mapList(
    (await client.request(
      '/api/admin/book-copies',
      query: {if (bookId != null) 'bookId': bookId},
    ))['data'],
  ).map(BookCopyItem.fromJson).toList();

  Future<BookCopyItem> adminSaveBookCopy({
    required int bookId,
    required String copyCode,
  }) async => BookCopyItem.fromJson(
    await client.request(
      '/api/admin/book-copies',
      method: 'POST',
      data: {'bookId': bookId, 'copyCode': copyCode},
    ),
  );

  Future<BookCopyItem> adminUpdateBookCopy(
    int id,
    Map<String, dynamic> data,
  ) async => BookCopyItem.fromJson(
    await client.request(
      '/api/admin/book-copies/$id',
      method: 'PUT',
      data: data,
    ),
  );

  Future<void> adminDeleteBookCopy(int id) async {
    await client.request('/api/admin/book-copies/$id', method: 'DELETE');
  }

  Future<CategoryItem> adminSaveCategory(Map<String, dynamic> data) async =>
      CategoryItem.fromJson(
        await client.request(
          '/api/admin/categories',
          method: 'POST',
          data: data,
        ),
      );

  Future<CategoryItem> adminUpdateCategory(
    int id,
    Map<String, dynamic> data,
  ) async => CategoryItem.fromJson(
    await client.request(
      '/api/admin/categories/$id',
      method: 'PUT',
      data: data,
    ),
  );

  Future<void> adminDeleteCategory(int id) async {
    await client.request('/api/admin/categories/$id', method: 'DELETE');
  }

  Future<AuthorItem> adminSaveAuthor(Map<String, dynamic> data) async =>
      AuthorItem.fromJson(
        await client.request('/api/admin/authors', method: 'POST', data: data),
      );

  Future<AuthorItem> adminUpdateAuthor(
    int id,
    Map<String, dynamic> data,
  ) async => AuthorItem.fromJson(
    await client.request('/api/admin/authors/$id', method: 'PUT', data: data),
  );

  Future<void> adminDeleteAuthor(int id) async {
    await client.request('/api/admin/authors/$id', method: 'DELETE');
  }

  Future<List<Map<String, dynamic>>> adminHolidays() async =>
      mapList((await client.request('/api/admin/holidays'))['data']);

  Future<Map<String, dynamic>> adminSaveHoliday(Map<String, dynamic> data) =>
      client.request('/api/admin/holidays', method: 'POST', data: data);

  Future<Map<String, dynamic>> adminUpdateHoliday(
    int id,
    Map<String, dynamic> data,
  ) => client.request('/api/admin/holidays/$id', method: 'PUT', data: data);

  Future<void> adminDeleteHoliday(int id) async {
    await client.request('/api/admin/holidays/$id', method: 'DELETE');
  }

  Future<List<Map<String, dynamic>>> adminDiscountRules() async =>
      mapList((await client.request('/api/admin/discount-rules'))['data']);

  Future<Map<String, dynamic>> adminSaveDiscountRule(
    Map<String, dynamic> data,
  ) => client.request('/api/admin/discount-rules', method: 'POST', data: data);

  Future<Map<String, dynamic>> adminUpdateDiscountRule(
    int id,
    Map<String, dynamic> data,
  ) => client.request(
    '/api/admin/discount-rules/$id',
    method: 'PUT',
    data: data,
  );

  Future<void> adminDeleteDiscountRule(int id) async {
    await client.request('/api/admin/discount-rules/$id', method: 'DELETE');
  }

  Future<BorrowingItem> adminReturnBorrowing(int id) async =>
      BorrowingItem.fromJson(
        await client.request(
          '/api/admin/borrowings/$id/return',
          method: 'POST',
        ),
      );

  Future<BookReservation> adminAssignReservationCopy(
    int reservationId,
    int bookCopyId,
  ) async => BookReservation.fromJson(
    await client.request(
      '/api/admin/reservations/$reservationId/assign-copy',
      method: 'POST',
      data: {'bookCopyId': bookCopyId},
    ),
  );

  Future<BookReservation> adminReservationOutForDelivery(int id) async =>
      BookReservation.fromJson(
        await client.request(
          '/api/admin/reservations/$id/out-for-delivery',
          method: 'POST',
        ),
      );

  Future<Map<String, dynamic>> adminReservationHandover(
    int id, {
    String paymentMethod = 'CASH',
    String? notes,
  }) => client.request(
    '/api/admin/reservations/$id/handover',
    method: 'POST',
    data: {
      'paymentMethod': paymentMethod,
      if (notes?.trim().isNotEmpty == true) 'notes': notes!.trim(),
    },
  );

  Future<PurchaseItem> adminUpdatePurchaseFulfillment(
    int id,
    String status,
  ) async => PurchaseItem.fromJson(
    await client.request(
      '/api/admin/purchases/$id/fulfillment',
      method: 'POST',
      data: {'fulfillmentStatus': status},
    ),
  );

  Future<Map<String, dynamic>> adminCounterBorrow({
    required int userId,
    required int bookCopyId,
    String paymentMethod = 'CASH',
    String? notes,
  }) => client.request(
    '/api/admin/counter/borrow',
    method: 'POST',
    data: {
      'userId': userId,
      'bookCopyId': bookCopyId,
      'paymentMethod': paymentMethod,
      if (notes?.trim().isNotEmpty == true) 'notes': notes!.trim(),
    },
  );

  Future<Map<String, dynamic>> adminCounterSale({
    required int userId,
    required int bookId,
    required String purchaseType,
    int quantity = 1,
    String fulfillmentMethod = 'PICKUP',
    String paymentMethod = 'CASH',
    String? deliveryAddress,
    String? notes,
  }) => client.request(
    '/api/admin/counter/sale',
    method: 'POST',
    data: {
      'userId': userId,
      'bookId': bookId,
      'purchaseType': purchaseType,
      'quantity': quantity,
      'fulfillmentMethod': fulfillmentMethod,
      'paymentMethod': paymentMethod,
      if (deliveryAddress?.trim().isNotEmpty == true)
        'deliveryAddress': deliveryAddress!.trim(),
      if (notes?.trim().isNotEmpty == true) 'notes': notes!.trim(),
    },
  );

  Future<void> registerDevice(
    String token, {
    String platform = 'ANDROID',
  }) async {
    await client.request(
      '/api/devices',
      method: 'POST',
      data: {'token': token, 'platform': platform},
    );
  }

  Future<void> unregisterDevice(String token) async {
    await client.request(
      '/api/devices',
      method: 'DELETE',
      data: {'token': token},
    );
  }
}
