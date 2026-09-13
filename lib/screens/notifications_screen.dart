import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(title: const Text('الإشعارات')),
        body: ListView(
          padding: const EdgeInsets.all(20),
          children: const [
            _NotificationTile(
              icon: Icons.schedule_outlined,
              title: 'موعد إرجاع قريب',
              subtitle: 'تبقى 5 أيام على موعد إرجاع Clean Code.',
            ),
            _NotificationTile(
              icon: Icons.meeting_room_outlined,
              title: 'حجز غرفة اليوم',
              subtitle: 'لديك حجز في غرفة الدراسة 3 الساعة 2:00 م.',
            ),
            _NotificationTile(
              icon: Icons.bookmark_outline,
              title: 'تحديث حجز كتاب',
              subtitle: 'سيظهر هنا أي تغيير على حالة حجز الكتاب.',
            ),
          ],
        ),
      ),
    );
  }
}

class _NotificationTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _NotificationTile({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: theme.dividerColor)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppTheme.turquoise),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.w800)),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: theme.colorScheme.onSurfaceVariant,
                    fontSize: 12,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
