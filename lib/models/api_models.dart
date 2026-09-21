import '../services/api_config.dart';
import 'app_user_role.dart';
import 'library_book.dart';

class LoginRequest {
  final String username;
  final String password;
  const LoginRequest(this.username, this.password);
  Map<String, dynamic> toJson() => {
    'username': username.trim().toLowerCase(),
    'password': password,
  };
}

class LoginResponse {
  final String accessToken;
  final ApiUser? user;
  const LoginResponse(this.accessToken, {this.user});

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    final token = json['access_token'];
    if (token is! String || token.isEmpty) {
      throw const FormatException('Missing access token');
    }
    final rawUser = json['user'];
    return LoginResponse(
      token,
      user: rawUser is Map
          ? ApiUser.fromJson(Map<String, dynamic>.from(rawUser))
          : null,
    );
  }
}

class ApiUser {
  final int? id;
  final String username;
  final String fullName;
  final AppUserRole role;

  const ApiUser({
    this.id,
    required this.username,
    required this.fullName,
    required this.role,
  });

  factory ApiUser.fromJson(Map<String, dynamic> json) {
    final roles = (json['roles'] as List? ?? const [])
        .map((e) => e.toString())
        .toList();
    return ApiUser(
      id: asInt(json['id']),
      username: (json['username'] ?? '').toString(),
      fullName: (json['fullName'] ?? json['username'] ?? '').toString(),
      role: roles.contains('ROLE_ADMIN')
          ? AppUserRole.admin
          : AppUserRole.customer,
    );
  }
}

class BookPage {
  final List<LibraryBook> books;
  final int total;
  const BookPage(this.books, this.total);

  factory BookPage.fromJson(Map<String, dynamic> json) => BookPage(
    mapList(json['data']).map(LibraryBook.fromJson).toList(),
    asInt(json['total']) ?? 0,
  );
}

class ReservationRequest {
  final int bookId;
  const ReservationRequest(this.bookId);
  Map<String, dynamic> toJson() => {'bookId': bookId};
}

class BookReservation {
  final int id;
  final int? bookId;
  final String bookTitle;
  final String bookAuthor;
  final String? bookCoverUrl;
  final String status;
  final String fulfillmentStatus;
  final String fulfillmentMethod;
  final String? deliveryAddress;
  final double feeAmount;
  final DateTime? reservationDate;
  final DateTime? readyUntil;
  final int? assignedCopyId;
  final String? assignedCopyCode;
  final int? userId;
  final String? userName;

  const BookReservation({
    required this.id,
    this.bookId,
    required this.bookTitle,
    this.bookAuthor = '',
    this.bookCoverUrl,
    required this.status,
    required this.fulfillmentStatus,
    required this.fulfillmentMethod,
    this.deliveryAddress,
    required this.feeAmount,
    this.reservationDate,
    this.readyUntil,
    this.assignedCopyId,
    this.assignedCopyCode,
    this.userId,
    this.userName,
  });

  factory BookReservation.fromJson(Map<String, dynamic> json) =>
      BookReservation(
        id: asInt(json['id']) ?? 0,
        bookId: asInt(json['bookId']),
        bookTitle: (json['bookTitle'] ?? '').toString(),
        bookAuthor: (json['bookAuthor'] ?? '').toString(),
        bookCoverUrl: ApiConfig.resourceUrl(json['bookCoverUrl']?.toString()),
        status: (json['status'] ?? '').toString(),
        fulfillmentStatus: (json['fulfillmentStatus'] ?? '').toString(),
        fulfillmentMethod: (json['fulfillmentMethod'] ?? 'PICKUP').toString(),
        deliveryAddress: json['deliveryAddress']?.toString(),
        feeAmount: asDouble(json['feeAmount']) ?? 0,
        reservationDate: asDate(json['reservationDate']),
        readyUntil: asDate(json['readyUntil']),
        assignedCopyId: asInt(json['assignedCopyId']),
        assignedCopyCode: json['assignedCopyCode']?.toString(),
        userId: asInt(json['userId']),
        userName: json['userName']?.toString(),
      );

  bool get canCancel =>
      !const ['FULFILLED', 'EXPIRED', 'CANCELLED'].contains(status);
  bool get readyForCustomer => status == 'READY';

  String get statusLabel => switch (status) {
    'WAITING' => 'في قائمة الانتظار',
    'READY' => 'جاهز للتأكيد',
    'PAID' => 'تم الدفع',
    'CONFIRMED' => 'مؤكد',
    'FULFILLED' => 'تم التسليم',
    'EXPIRED' => 'انتهت المهلة',
    'CANCELLED' => 'ملغي',
    _ => status,
  };
}

class BorrowingItem {
  final int id;
  final int? bookId;
  final String bookTitle;
  final String bookAuthor;
  final String? bookCoverUrl;
  final int? copyId;
  final String copyCode;
  final int? userId;
  final String userName;
  final DateTime? borrowDate;
  final DateTime? dueDate;
  final DateTime? returnDate;
  final String status;
  final double lateFee;
  final String origin;
  final String fulfillmentMethod;

  const BorrowingItem({
    required this.id,
    this.bookId,
    required this.bookTitle,
    this.bookAuthor = '',
    this.bookCoverUrl,
    this.copyId,
    this.copyCode = '',
    this.userId,
    this.userName = '',
    this.borrowDate,
    this.dueDate,
    this.returnDate,
    required this.status,
    this.lateFee = 0,
    this.origin = '',
    this.fulfillmentMethod = 'PICKUP',
  });

  factory BorrowingItem.fromJson(Map<String, dynamic> json) => BorrowingItem(
    id: asInt(json['id']) ?? 0,
    bookId: asInt(json['bookId']),
    bookTitle: (json['bookTitle'] ?? '').toString(),
    bookAuthor: (json['bookAuthor'] ?? '').toString(),
    bookCoverUrl: ApiConfig.resourceUrl(json['bookCoverUrl']?.toString()),
    copyId: asInt(json['copyId']),
    copyCode: (json['copyCode'] ?? '').toString(),
    userId: asInt(json['userId']),
    userName: (json['userName'] ?? '').toString(),
    borrowDate: asDate(json['borrowDate']),
    dueDate: asDate(json['dueDate']),
    returnDate: asDate(json['returnDate']),
    status: (json['status'] ?? '').toString(),
    lateFee: asDouble(json['lateFee']) ?? 0,
    origin: (json['origin'] ?? '').toString(),
    fulfillmentMethod: (json['fulfillmentMethod'] ?? 'PICKUP').toString(),
  );

  bool get open => status == 'ACTIVE' || status == 'OVERDUE';

  String get statusLabel => switch (status) {
    'ACTIVE' => 'قيد الاستعارة',
    'OVERDUE' => 'متأخر',
    'RETURNED' => 'تمت الإعادة',
    'CANCELLED' => 'ملغي',
    _ => status,
  };
}

class RoomReservationItem {
  final int id;
  final int? roomId;
  final String roomName;
  final String? roomImageUrl;
  final DateTime? startTime;
  final DateTime? endTime;
  final double basePrice;
  final double discountPercentage;
  final double discountAmount;
  final double totalPrice;
  final String status;
  final int? userId;
  final String? userName;

  const RoomReservationItem({
    required this.id,
    this.roomId,
    required this.roomName,
    this.roomImageUrl,
    this.startTime,
    this.endTime,
    this.basePrice = 0,
    this.discountPercentage = 0,
    this.discountAmount = 0,
    required this.totalPrice,
    required this.status,
    this.userId,
    this.userName,
  });

  factory RoomReservationItem.fromJson(Map<String, dynamic> json) =>
      RoomReservationItem(
        id: asInt(json['id']) ?? 0,
        roomId: asInt(json['roomId']),
        roomName: (json['roomName'] ?? '').toString(),
        roomImageUrl: ApiConfig.resourceUrl(json['roomImageUrl']?.toString()),
        startTime: asDate(json['startTime']),
        endTime: asDate(json['endTime']),
        basePrice: asDouble(json['basePrice']) ?? 0,
        discountPercentage: asDouble(json['discountPercentage']) ?? 0,
        discountAmount: asDouble(json['discountAmount']) ?? 0,
        totalPrice: asDouble(json['totalPrice']) ?? 0,
        status: (json['status'] ?? '').toString(),
        userId: asInt(json['userId']),
        userName: json['userName']?.toString(),
      );
}

class PurchaseItem {
  final int id;
  final int? bookId;
  final String bookTitle;
  final String bookAuthor;
  final String? bookCoverUrl;
  final String purchaseType;
  final int quantity;
  final double unitPrice;
  final double totalAmount;
  final String status;
  final String fulfillmentMethod;
  final String fulfillmentStatus;
  final String? deliveryAddress;
  final DateTime? purchaseDate;
  final int? userId;
  final String? userName;

  const PurchaseItem({
    required this.id,
    this.bookId,
    required this.bookTitle,
    this.bookAuthor = '',
    this.bookCoverUrl,
    required this.purchaseType,
    required this.quantity,
    required this.unitPrice,
    required this.totalAmount,
    required this.status,
    required this.fulfillmentMethod,
    required this.fulfillmentStatus,
    this.deliveryAddress,
    this.purchaseDate,
    this.userId,
    this.userName,
  });

  factory PurchaseItem.fromJson(Map<String, dynamic> json) => PurchaseItem(
    id: asInt(json['id']) ?? 0,
    bookId: asInt(json['bookId']),
    bookTitle: (json['bookTitle'] ?? '').toString(),
    bookAuthor: (json['bookAuthor'] ?? '').toString(),
    bookCoverUrl: ApiConfig.resourceUrl(json['bookCoverUrl']?.toString()),
    purchaseType: (json['purchaseType'] ?? '').toString(),
    quantity: asInt(json['quantity']) ?? 1,
    unitPrice: asDouble(json['unitPrice']) ?? 0,
    totalAmount: asDouble(json['totalAmount']) ?? 0,
    status: (json['status'] ?? '').toString(),
    fulfillmentMethod: (json['fulfillmentMethod'] ?? '').toString(),
    fulfillmentStatus: (json['fulfillmentStatus'] ?? '').toString(),
    deliveryAddress: json['deliveryAddress']?.toString(),
    purchaseDate: asDate(json['purchaseDate']),
    userId: asInt(json['userId']),
    userName: json['userName']?.toString(),
  );
}

class PaymentItem {
  final int id;
  final String referenceCode;
  final String purpose;
  final double amount;
  final String status;
  final String paymentMethod;
  final String channel;
  final DateTime? paidAt;
  final String userName;

  const PaymentItem({
    required this.id,
    required this.referenceCode,
    required this.purpose,
    required this.amount,
    required this.status,
    required this.paymentMethod,
    required this.channel,
    this.paidAt,
    this.userName = '',
  });

  factory PaymentItem.fromJson(Map<String, dynamic> json) => PaymentItem(
    id: asInt(json['id']) ?? 0,
    referenceCode: (json['referenceCode'] ?? '').toString(),
    purpose: (json['purpose'] ?? '').toString(),
    amount: asDouble(json['amount']) ?? 0,
    status: (json['status'] ?? '').toString(),
    paymentMethod: (json['paymentMethod'] ?? '').toString(),
    channel: (json['channel'] ?? '').toString(),
    paidAt: asDate(json['paidAt']),
    userName: (json['userName'] ?? '').toString(),
  );
}

class DigitalAccessItem {
  final int? id;
  final int bookId;
  final String bookTitle;
  final String bookAuthor;
  final String? bookCoverUrl;
  final String source;
  final DateTime? endDate;

  const DigitalAccessItem({
    this.id,
    required this.bookId,
    required this.bookTitle,
    this.bookAuthor = '',
    this.bookCoverUrl,
    required this.source,
    this.endDate,
  });

  factory DigitalAccessItem.fromJson(Map<String, dynamic> json) =>
      DigitalAccessItem(
        id: asInt(json['id']),
        bookId: asInt(json['bookId']) ?? 0,
        bookTitle: (json['bookTitle'] ?? '').toString(),
        bookAuthor: (json['bookAuthor'] ?? '').toString(),
        bookCoverUrl: ApiConfig.resourceUrl(json['bookCoverUrl']?.toString()),
        source: (json['source'] ?? '').toString(),
        endDate: asDate(json['endDate']),
      );
}

class CategoryItem {
  final int id;
  final String name;
  final String description;
  final bool active;
  final int bookCount;
  final List<LibraryBook> books;

  const CategoryItem({
    required this.id,
    required this.name,
    this.description = '',
    this.active = true,
    this.bookCount = 0,
    this.books = const [],
  });

  factory CategoryItem.fromJson(Map<String, dynamic> json) => CategoryItem(
    id: asInt(json['id']) ?? 0,
    name: (json['name'] ?? '').toString(),
    description: (json['description'] ?? '').toString(),
    active: json['active'] != false,
    bookCount: asInt(json['bookCount']) ?? 0,
    books: mapList(json['books']).map(LibraryBook.fromJson).toList(),
  );
}

class AuthorItem {
  final int id;
  final String name;
  final String biography;
  final String nationality;
  final int bookCount;
  final String? imageUrl;
  final List<LibraryBook> books;

  const AuthorItem({
    required this.id,
    required this.name,
    this.biography = '',
    this.nationality = '',
    this.bookCount = 0,
    this.imageUrl,
    this.books = const [],
  });

  factory AuthorItem.fromJson(Map<String, dynamic> json) => AuthorItem(
    id: asInt(json['id']) ?? 0,
    name: (json['name'] ?? '').toString(),
    biography: (json['biography'] ?? '').toString(),
    nationality: (json['nationality'] ?? '').toString(),
    bookCount: asInt(json['bookCount']) ?? 0,
    imageUrl: ApiConfig.resourceUrl(json['imageUrl']?.toString()),
    books: mapList(json['books']).map(LibraryBook.fromJson).toList(),
  );
}

class BookCopyItem {
  final int id;
  final String copyCode;
  final String status;
  final int? bookId;
  final String bookTitle;
  final String? bookCoverUrl;
  final bool hasHistory;
  final bool operationallyLocked;

  const BookCopyItem({
    required this.id,
    required this.copyCode,
    required this.status,
    this.bookId,
    this.bookTitle = '',
    this.bookCoverUrl,
    this.hasHistory = false,
    this.operationallyLocked = false,
  });

  factory BookCopyItem.fromJson(Map<String, dynamic> json) => BookCopyItem(
    id: asInt(json['id']) ?? 0,
    copyCode: (json['copyCode'] ?? '').toString(),
    status: (json['status'] ?? '').toString(),
    bookId: asInt(json['bookId']),
    bookTitle: (json['bookTitle'] ?? '').toString(),
    bookCoverUrl: ApiConfig.resourceUrl(json['bookCoverUrl']?.toString()),
    hasHistory: json['hasHistory'] == true,
    operationallyLocked: json['operationallyLocked'] == true,
  );
}

class AdminUserItem {
  final int id;
  final String username;
  final String fullName;
  final bool enabled;
  final bool accountLocked;
  final MembershipInfo? membership;

  const AdminUserItem({
    required this.id,
    required this.username,
    required this.fullName,
    required this.enabled,
    required this.accountLocked,
    this.membership,
  });

  factory AdminUserItem.fromJson(Map<String, dynamic> json) {
    final m = json['membership'];
    return AdminUserItem(
      id: asInt(json['id']) ?? 0,
      username: (json['username'] ?? '').toString(),
      fullName: (json['fullName'] ?? '').toString(),
      enabled: json['enabled'] != false,
      accountLocked: json['accountLocked'] == true,
      membership: m is Map
          ? MembershipInfo.fromJson(Map<String, dynamic>.from(m))
          : null,
    );
  }
}

class DashboardSummary {
  final Map<String, dynamic> raw;
  const DashboardSummary(this.raw);
  int count(String key) => asInt(raw[key]) ?? 0;
  double amount(String key) => asDouble(raw[key]) ?? 0;
  bool flag(String key) => raw[key] == true;
  String text(String key) => (raw[key] ?? '').toString();
  Map<String, dynamic>? map(String key) =>
      raw[key] is Map ? Map<String, dynamic>.from(raw[key] as Map) : null;
}

class MembershipInfo {
  final int id;
  final DateTime? startDate;
  final DateTime? endDate;
  final String status;
  final double price;
  final bool paid;
  final bool canCancel;
  final int? userId;
  final String userName;

  const MembershipInfo({
    required this.id,
    this.startDate,
    this.endDate,
    required this.status,
    required this.price,
    this.paid = false,
    this.canCancel = false,
    this.userId,
    this.userName = '',
  });

  factory MembershipInfo.fromJson(Map<String, dynamic> json) => MembershipInfo(
    id: asInt(json['id']) ?? 0,
    startDate: asDate(json['startDate']),
    endDate: asDate(json['endDate']),
    status: (json['status'] ?? '').toString(),
    price: asDouble(json['price']) ?? 0,
    paid: json['paid'] == true,
    canCancel: json['canCancel'] == true,
    userId: asInt(json['userId']),
    userName: (json['userName'] ?? '').toString(),
  );

  String get statusLabel => switch (status) {
    'ACTIVE' => 'فعالة',
    'SCHEDULED' => 'مجدولة',
    'PENDING' => 'بانتظار الدفع',
    'EXPIRED' => 'منتهية',
    'CANCELLED' => 'ملغاة',
    _ => status,
  };
}

class MembershipOverview {
  final MembershipInfo? current;
  final List<MembershipInfo> history;
  final double pricePerDay;
  final List<Map<String, dynamic>> discountTiers;

  const MembershipOverview({
    this.current,
    this.history = const [],
    required this.pricePerDay,
    required this.discountTiers,
  });

  factory MembershipOverview.fromJson(Map<String, dynamic> json) {
    final rawCurrent = json['current'];
    return MembershipOverview(
      current: rawCurrent is Map
          ? MembershipInfo.fromJson(Map<String, dynamic>.from(rawCurrent))
          : null,
      history: mapList(json['history']).map(MembershipInfo.fromJson).toList(),
      pricePerDay: asDouble(json['pricePerDay']) ?? 0,
      discountTiers: mapList(json['discountTiers']),
    );
  }
}

class PaymentLaunch {
  final String paymentUrl;
  final double amount;
  const PaymentLaunch(this.paymentUrl, this.amount);

  factory PaymentLaunch.fromJson(Map<String, dynamic> json) => PaymentLaunch(
    ApiConfig.resourceUrl(json['paymentUrl']?.toString()) ?? '',
    asDouble(json['amount']) ?? 0,
  );
}

class IsbnMetadata {
  final Map<String, dynamic> raw;
  const IsbnMetadata(this.raw);
  String get title => (raw['title'] ?? '').toString();
  List<String> get authors =>
      (raw['authors'] as List? ?? const []).map((e) => e.toString()).toList();
  List<String> get categories => (raw['categories'] as List? ?? const [])
      .map((e) => e.toString())
      .toList();
  String get description => (raw['description'] ?? '').toString();
  int? get publishYear => asInt(raw['publishYear']);
  String? get publisher => raw['publisher']?.toString();
  int? get pageCount => asInt(raw['pageCount']);
  String? get language => raw['language']?.toString();
  String? get externalCoverUrl => raw['externalCoverUrl']?.toString();
  String? get source => raw['source']?.toString();
}

class AdminDigitalAccessItem {
  final int id;
  final int? bookId;
  final String bookTitle;
  final String bookAuthor;
  final String? bookCoverUrl;
  final int? userId;
  final String userName;
  final String accessType;
  final String status;
  final DateTime? startDate;
  final DateTime? endDate;
  final double paidAmount;

  const AdminDigitalAccessItem({
    required this.id,
    this.bookId,
    required this.bookTitle,
    this.bookAuthor = '',
    this.bookCoverUrl,
    this.userId,
    this.userName = '',
    required this.accessType,
    required this.status,
    this.startDate,
    this.endDate,
    this.paidAmount = 0,
  });

  factory AdminDigitalAccessItem.fromJson(Map<String, dynamic> json) =>
      AdminDigitalAccessItem(
        id: asInt(json['id']) ?? 0,
        bookId: asInt(json['bookId']),
        bookTitle: (json['bookTitle'] ?? '').toString(),
        bookAuthor: (json['bookAuthor'] ?? '').toString(),
        bookCoverUrl: ApiConfig.resourceUrl(json['bookCoverUrl']?.toString()),
        userId: asInt(json['userId']),
        userName: (json['userName'] ?? '').toString(),
        accessType: (json['accessType'] ?? '').toString(),
        status: (json['status'] ?? '').toString(),
        startDate: asDate(json['startDate']),
        endDate: asDate(json['endDate']),
        paidAmount: asDouble(json['paidAmount']) ?? 0,
      );

  String get accessLabel => switch (accessType) {
    'PURCHASE' => 'شراء رقمي',
    'RENTAL' => 'استئجار رقمي',
    _ => accessType,
  };
}

class AdminOperations {
  final List<BorrowingItem> borrowings;
  final List<BookReservation> reservations;
  final List<RoomReservationItem> roomReservations;
  final List<PurchaseItem> purchases;
  final List<PaymentItem> payments;
  final List<MembershipInfo> memberships;
  final List<AdminDigitalAccessItem> digitalAccesses;

  const AdminOperations({
    required this.borrowings,
    required this.reservations,
    required this.roomReservations,
    required this.purchases,
    required this.payments,
    this.memberships = const [],
    this.digitalAccesses = const [],
  });

  factory AdminOperations.fromJson(Map<String, dynamic> json) =>
      AdminOperations(
        borrowings: mapList(
          json['borrowings'],
        ).map(BorrowingItem.fromJson).toList(),
        reservations: mapList(
          json['reservations'],
        ).map(BookReservation.fromJson).toList(),
        roomReservations: mapList(
          json['roomReservations'],
        ).map(RoomReservationItem.fromJson).toList(),
        purchases: mapList(
          json['purchases'],
        ).map(PurchaseItem.fromJson).toList(),
        payments: mapList(json['payments']).map(PaymentItem.fromJson).toList(),
        memberships: mapList(
          json['memberships'],
        ).map(MembershipInfo.fromJson).toList(),
        digitalAccesses: mapList(
          json['digitalAccesses'],
        ).map(AdminDigitalAccessItem.fromJson).toList(),
      );
}

List<Map<String, dynamic>> mapList(dynamic value) =>
    (value as List? ?? const [])
        .whereType<Map>()
        .map((e) => Map<String, dynamic>.from(e))
        .toList();

int? asInt(dynamic value) {
  if (value == null) return null;
  if (value is num) return value.toInt();
  return int.tryParse(value.toString());
}

double? asDouble(dynamic value) {
  if (value == null) return null;
  if (value is num) return value.toDouble();
  return double.tryParse(value.toString());
}

DateTime? asDate(dynamic value) {
  if (value == null) return null;
  if (value is num) return DateTime.fromMillisecondsSinceEpoch(value.toInt());
  final text = value.toString();
  final millis = int.tryParse(text);
  if (millis != null) return DateTime.fromMillisecondsSinceEpoch(millis);
  return DateTime.tryParse(text)?.toLocal();
}
