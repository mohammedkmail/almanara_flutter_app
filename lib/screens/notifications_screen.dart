import 'package:flutter/material.dart';

import '../models/app_notification.dart';
import '../services/notification_inbox_service.dart';
import '../theme/app_theme.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  late Future<NotificationInbox> _future;

  bool _markingAll = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() {
    _future = NotificationInboxService.instance.getNotifications();
  }

  Future<void> _refresh() async {
    setState(() {
      _load();
    });

    await _future;
  }

  Future<void> _markAsRead(AppNotification notification) async {
    if (notification.isRead) {
      return;
    }

    try {
      await NotificationInboxService.instance.markAsRead(notification.id);

      if (!mounted) {
        return;
      }

      setState(() {
        _load();
      });
    } catch (error) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('تعذر تحديث الإشعار: $error')));
    }
  }

  Future<void> _markAllAsRead() async {
    if (_markingAll) {
      return;
    }

    setState(() {
      _markingAll = true;
    });

    try {
      await NotificationInboxService.instance.markAllAsRead();

      if (!mounted) {
        return;
      }

      setState(() {
        _load();
      });
    } catch (error) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('تعذر تحديث الإشعارات: $error')));
    } finally {
      if (mounted) {
        setState(() {
          _markingAll = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(title: const Text('الإشعارات')),
        body: FutureBuilder<NotificationInbox>(
          future: _future,
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return _ErrorView(
                error: snapshot.error.toString(),
                onRetry: () {
                  setState(() {
                    _load();
                  });
                },
              );
            }

            final inbox =
                snapshot.data ??
                const NotificationInbox(unreadCount: 0, notifications: []);

            if (inbox.notifications.isEmpty) {
              return RefreshIndicator(
                onRefresh: _refresh,
                child: ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  children: const [
                    SizedBox(height: 170),
                    Icon(
                      Icons.notifications_none_rounded,
                      size: 62,
                      color: AppTheme.turquoise,
                    ),
                    SizedBox(height: 16),
                    Text(
                      'لا توجد إشعارات حتى الآن',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    SizedBox(height: 6),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 30),
                      child: Text(
                        'ستظهر هنا تحديثات الحجوزات والاستعارات والطلبات.',
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              );
            }

            return Column(
              children: [
                if (inbox.unreadCount > 0)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            '${inbox.unreadCount} إشعار غير مقروء',
                            style: const TextStyle(fontWeight: FontWeight.w800),
                          ),
                        ),
                        TextButton.icon(
                          onPressed: _markingAll ? null : _markAllAsRead,
                          icon: _markingAll
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Icon(Icons.done_all_rounded),
                          label: const Text('قراءة الكل'),
                        ),
                      ],
                    ),
                  ),

                Expanded(
                  child: RefreshIndicator(
                    onRefresh: _refresh,
                    child: ListView.separated(
                      padding: const EdgeInsets.fromLTRB(14, 8, 14, 24),
                      itemCount: inbox.notifications.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 8),
                      itemBuilder: (context, index) {
                        final notification = inbox.notifications[index];

                        return _NotificationTile(
                          notification: notification,
                          onTap: () {
                            _markAsRead(notification);
                          },
                        );
                      },
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _NotificationTile extends StatelessWidget {
  final AppNotification notification;
  final VoidCallback onTap;

  const _NotificationTile({required this.notification, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final unread = !notification.isRead;

    return Material(
      color: unread
          ? AppTheme.turquoise.withValues(alpha: 0.06)
          : Colors.transparent,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: unread
                  ? AppTheme.turquoise.withValues(alpha: 0.30)
                  : theme.dividerColor,
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppTheme.turquoise.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  _iconForType(notification.type),
                  color: AppTheme.turquoise,
                ),
              ),

              const SizedBox(width: 12),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            notification.title,
                            style: TextStyle(
                              fontWeight: unread
                                  ? FontWeight.w900
                                  : FontWeight.w700,
                            ),
                          ),
                        ),

                        if (unread)
                          Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: AppTheme.turquoise,
                              shape: BoxShape.circle,
                            ),
                          ),
                      ],
                    ),

                    const SizedBox(height: 5),

                    Text(
                      notification.body,
                      style: TextStyle(
                        color: theme.colorScheme.onSurfaceVariant,
                        fontSize: 12.5,
                        height: 1.4,
                      ),
                    ),

                    if (notification.dateCreated != null) ...[
                      const SizedBox(height: 8),
                      Text(
                        _formatDate(notification.dateCreated!),
                        style: TextStyle(
                          color: theme.colorScheme.onSurfaceVariant,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static IconData _iconForType(String? type) {
    final value = type?.toUpperCase() ?? '';

    if (value.contains('ROOM')) {
      return Icons.meeting_room_outlined;
    }

    if (value.contains('PURCHASE')) {
      return Icons.shopping_bag_outlined;
    }

    if (value.contains('MEMBERSHIP')) {
      return Icons.card_membership_outlined;
    }

    if (value.contains('BORROW') || value.contains('RESERVATION')) {
      return Icons.menu_book_outlined;
    }

    return Icons.notifications_none_rounded;
  }

  static String _formatDate(DateTime date) {
    final local = date.toLocal();

    final day = local.day.toString().padLeft(2, '0');

    final month = local.month.toString().padLeft(2, '0');

    final hour = local.hour.toString().padLeft(2, '0');

    final minute = local.minute.toString().padLeft(2, '0');

    return '$day/$month/${local.year} - $hour:$minute';
  }
}

class _ErrorView extends StatelessWidget {
  final String error;
  final VoidCallback onRetry;

  const _ErrorView({required this.error, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.error_outline_rounded,
              size: 52,
              color: AppTheme.turquoise,
            ),
            const SizedBox(height: 14),
            const Text(
              'تعذر تحميل الإشعارات',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 8),
            Text(error, textAlign: TextAlign.center),
            const SizedBox(height: 18),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('إعادة المحاولة'),
            ),
          ],
        ),
      ),
    );
  }
}
