import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

class MyLibraryScreen extends StatelessWidget {
  const MyLibraryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: DefaultTabController(
        length: 3,
        child: Scaffold(
          appBar: AppBar(
            title: const Text('مكتبتي'),
            bottom: const TabBar(
              tabs: [
                Tab(text: 'استعاراتي'),
                Tab(text: 'حجوزاتي'),
                Tab(text: 'رقمياتي'),
              ],
            ),
          ),
          body: TabBarView(
            children: [
              ListView(
                padding: const EdgeInsets.all(20),
                children: const [
                  _LibraryItem(
                    icon: Icons.menu_book_outlined,
                    title: 'Clean Code',
                    subtitle: 'موعد الإرجاع: 18 سبتمبر 2026',
                    status: 'نشط',
                  ),
                  _LibraryItem(
                    icon: Icons.menu_book_outlined,
                    title: 'Atomic Habits',
                    subtitle: 'موعد الإرجاع: 22 سبتمبر 2026',
                    status: 'نشط',
                  ),
                ],
              ),
              ListView(
                padding: const EdgeInsets.all(20),
                children: const [
                  _LibraryItem(
                    icon: Icons.bookmark_outline,
                    title: 'Design Patterns',
                    subtitle: 'الحجز بانتظار توفر نسخة',
                    status: 'WAITING',
                  ),
                  _LibraryItem(
                    icon: Icons.meeting_room_outlined,
                    title: 'غرفة الدراسة 3',
                    subtitle: 'اليوم • 2:00 م - 4:00 م',
                    status: 'CONFIRMED',
                  ),
                ],
              ),
              ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  const _LibraryItem(
                    icon: Icons.tablet_android_outlined,
                    title: 'The Pragmatic Programmer',
                    subtitle: 'متاح ضمن عضويتك',
                    status: 'ACTIVE',
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'لاحقاً ستأتي الاستعارات والحجوزات والكتب الرقمية من حساب المستخدم عبر الـ API.',
                    style: TextStyle(
                      color: colors.onSurfaceVariant,
                      fontSize: 12,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LibraryItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String status;

  const _LibraryItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: theme.dividerColor),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppTheme.turquoise.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: AppTheme.turquoise),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: colors.onSurface,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: colors.onSurfaceVariant,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            status,
            style: const TextStyle(
              color: AppTheme.turquoise,
              fontSize: 10,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
