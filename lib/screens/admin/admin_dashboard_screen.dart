import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        body: SafeArea(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 30),
            children: [
              Text(
                'لوحة الإدارة',
                style: TextStyle(
                  color: colors.onSurface,
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'ملخص سريع لحالة المكتبة اليوم.',
                style: TextStyle(color: colors.onSurfaceVariant, fontSize: 13),
              ),
              const SizedBox(height: 22),
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: 1.7,
                children: const [
                  _AdminStat(title: 'إجمالي الكتب', value: '124', icon: Icons.menu_book_outlined),
                  _AdminStat(title: 'استعارات نشطة', value: '38', icon: Icons.swap_horiz_rounded),
                  _AdminStat(title: 'متأخرة', value: '4', icon: Icons.warning_amber_rounded, warning: true),
                  _AdminStat(title: 'حجوزات غرف', value: '9', icon: Icons.meeting_room_outlined),
                ],
              ),
              const SizedBox(height: 28),
              Text(
                'يحتاج متابعة',
                style: TextStyle(
                  color: colors.onSurface,
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 10),
              const _AdminTask(
                title: '4 استعارات متأخرة',
                subtitle: 'راجع المستخدمين ومواعيد الإرجاع.',
                icon: Icons.warning_amber_rounded,
              ),
              const _AdminTask(
                title: '3 حجوزات كتب بانتظار التوفر',
                subtitle: 'تحقق من النسخ المعادة حديثاً.',
                icon: Icons.bookmark_outline,
              ),
              const _AdminTask(
                title: 'حجوزات الغرف لليوم',
                subtitle: '9 حجوزات مؤكدة خلال اليوم.',
                icon: Icons.calendar_month_outlined,
              ),
              const SizedBox(height: 22),
              Text(
                'هذه الأرقام تجريبية حالياً. لاحقاً ستأتي مباشرة من Dashboard API في مشروع الويب.',
                style: TextStyle(
                  color: colors.onSurfaceVariant,
                  fontSize: 11,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AdminStat extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final bool warning;

  const _AdminStat({
    required this.title,
    required this.value,
    required this.icon,
    this.warning = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(13),
        border: Border.all(color: theme.dividerColor),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: warning ? Colors.redAccent : AppTheme.turquoise,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
                Text(
                  title,
                  style: TextStyle(
                    color: theme.colorScheme.onSurfaceVariant,
                    fontSize: 11,
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

class _AdminTask extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;

  const _AdminTask({
    required this.title,
    required this.subtitle,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 13),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: theme.dividerColor)),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppTheme.turquoise),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
                const SizedBox(height: 3),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: theme.colorScheme.onSurfaceVariant,
                    fontSize: 11,
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
