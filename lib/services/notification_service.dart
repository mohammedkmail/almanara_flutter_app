import 'dart:convert';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../firebase_options.dart';
import 'auth_service.dart';
import 'library_service.dart';

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
}

class NotificationService {
  static final instance = NotificationService._();

  NotificationService._();

  final FlutterLocalNotificationsPlugin _local =
      FlutterLocalNotificationsPlugin();

  final ValueNotifier<Map<String, dynamic>?> openedPayload = ValueNotifier(
    null,
  );

  String? _token;
  bool _initialized = false;

  bool get initialized => _initialized;

  Future<void> initialize() async {
    if (_initialized || kIsWeb) return;

    try {
      FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

      await _local.initialize(
        settings: const InitializationSettings(
          android: AndroidInitializationSettings('@mipmap/ic_launcher'),
        ),
        onDidReceiveNotificationResponse: (response) {
          final payload = response.payload;

          if (payload == null || payload.isEmpty) {
            return;
          }

          try {
            openedPayload.value = Map<String, dynamic>.from(
              jsonDecode(payload) as Map,
            );
          } catch (error) {
            debugPrint('Could not parse notification payload: $error');
          }
        },
      );

      final settings = await FirebaseMessaging.instance.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );

      debugPrint('Notification permission: ${settings.authorizationStatus}');

      _token = await FirebaseMessaging.instance.getToken();

      debugPrint('FCM TOKEN: $_token');

      FirebaseMessaging.instance.onTokenRefresh.listen((token) async {
        _token = token;

        debugPrint('FCM TOKEN REFRESHED: $token');

        await syncDeviceToken();
      });

      FirebaseMessaging.onMessage.listen(_showForegroundMessage);

      FirebaseMessaging.onMessageOpenedApp.listen(_handleRemoteOpen);

      final initialMessage = await FirebaseMessaging.instance
          .getInitialMessage();

      if (initialMessage != null) {
        _handleRemoteOpen(initialMessage);
      }

      _initialized = true;
    } catch (error) {
      debugPrint('Could not initialize Firebase notifications: $error');
    }
  }

  Future<void> syncDeviceToken() async {
    if (!_initialized ||
        _token == null ||
        AuthService.instance.user.value == null) {
      return;
    }

    try {
      final platform = switch (defaultTargetPlatform) {
        TargetPlatform.iOS => 'IOS',
        TargetPlatform.android => 'ANDROID',
        _ => 'UNKNOWN',
      };

      await LibraryService.instance.registerDevice(_token!, platform: platform);

      debugPrint('FCM token registered with backend successfully.');
    } catch (error) {
      debugPrint('Could not register FCM token with backend: $error');
    }
  }

  Future<void> unregisterDevice() async {
    if (_token == null || AuthService.instance.user.value == null) {
      return;
    }

    try {
      await LibraryService.instance.unregisterDevice(_token!);
    } catch (error) {
      debugPrint('Could not unregister FCM token: $error');
    }
  }

  Future<void> _showForegroundMessage(RemoteMessage message) async {
    final notification = message.notification;

    await _local.show(
      id: message.hashCode,
      title: notification?.title ?? 'المنارة',
      body: notification?.body ?? 'لديك تحديث جديد في حسابك',
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          'manara_updates',
          'تحديثات المنارة',
          channelDescription: 'إشعارات الحجوزات والعضوية وخدمات المكتبة',
          importance: Importance.high,
          priority: Priority.high,
        ),
      ),
      payload: jsonEncode(message.data),
    );
  }

  void _handleRemoteOpen(RemoteMessage message) {
    openedPayload.value = Map<String, dynamic>.from(message.data);
  }
}
