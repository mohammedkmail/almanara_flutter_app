import '../models/app_notification.dart';
import 'api_client.dart';
import 'auth_service.dart';

class NotificationInboxService {
  NotificationInboxService._(this.client);

  static final NotificationInboxService instance = NotificationInboxService._(
    AuthService.instance.client,
  );

  final ApiClient client;

  Future<NotificationInbox> getNotifications({int max = 50}) async {
    final json = await client.request(
      '/api/notifications',
      query: {'max': max},
    );

    return NotificationInbox.fromJson(json);
  }

  Future<int> markAsRead(int id) async {
    final json = await client.request(
      '/api/notifications/$id/read',
      method: 'POST',
    );

    return _toInt(json['unreadCount']) ?? 0;
  }

  Future<int> markAllAsRead() async {
    final json = await client.request(
      '/api/notifications/read-all',
      method: 'POST',
    );

    return _toInt(json['unreadCount']) ?? 0;
  }

  int? _toInt(dynamic value) {
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
}
