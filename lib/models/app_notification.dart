class AppNotification {
  final int id;
  final String title;
  final String body;
  final String? type;
  final int? targetId;
  final bool isRead;
  final DateTime? readAt;
  final DateTime? dateCreated;

  const AppNotification({
    required this.id,
    required this.title,
    required this.body,
    this.type,
    this.targetId,
    required this.isRead,
    this.readAt,
    this.dateCreated,
  });

  factory AppNotification.fromJson(Map<String, dynamic> json) {
    return AppNotification(
      id: _toInt(json['id']) ?? 0,
      title: json['title']?.toString() ?? '',
      body: json['body']?.toString() ?? '',
      type: json['type']?.toString(),
      targetId: _toInt(json['targetId']),
      isRead: json['read'] == true,
      readAt: _toDateTime(json['readAt']),
      dateCreated: _toDateTime(json['dateCreated']),
    );
  }

  static int? _toInt(dynamic value) {
    if (value == null) {
      return null;
    }

    if (value is int) {
      return value;
    }

    if (value is num) {
      return value.toInt();
    }

    return int.tryParse(value.toString());
  }

  static DateTime? _toDateTime(dynamic value) {
    final milliseconds = _toInt(value);

    if (milliseconds == null) {
      return null;
    }

    return DateTime.fromMillisecondsSinceEpoch(milliseconds);
  }
}

class NotificationInbox {
  final int unreadCount;
  final List<AppNotification> notifications;

  const NotificationInbox({
    required this.unreadCount,
    required this.notifications,
  });

  factory NotificationInbox.fromJson(Map<String, dynamic> json) {
    final rawData = json['data'];

    final notifications = rawData is List
        ? rawData
              .whereType<Map>()
              .map(
                (item) =>
                    AppNotification.fromJson(Map<String, dynamic>.from(item)),
              )
              .toList()
        : <AppNotification>[];

    return NotificationInbox(
      unreadCount: AppNotification._toInt(json['unreadCount']) ?? 0,
      notifications: notifications,
    );
  }
}
