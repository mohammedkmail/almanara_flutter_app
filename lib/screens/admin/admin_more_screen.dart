import 'package:flutter/material.dart';

import '../../services/auth_service.dart';
import '../../widgets/api_error_view.dart';

import '../../theme/app_theme.dart';
import '../../theme/theme_controller.dart';

class AdminMoreScreen extends StatelessWidget {
  const AdminMoreScreen({super.key});

  void _openPlaceholder(BuildContext context, String title) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => _AdminManagementPlaceholder(title: title),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(title: const Text('المزيد')),
        body: ListView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 30),
          children: [
            Text(
              'إدارة النظام',
              style: TextStyle(
                color: colors.onSurface,
                fontSize: 18,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 8),
            _MoreItem(
              icon: Icons.category_outlined,
              title: 'التصنيفات',
              onTap: () => _openPlaceholder(context, 'إدارة التصنيفات'),
            ),
            _MoreItem(
              icon: Icons.person_2_outlined,
              title: 'المؤلفون',
              onTap: () => _openPlaceholder(context, 'إدارة المؤلفين'),
            ),
            _MoreItem(
              icon: Icons.card_membership_outlined,
              title: 'العضويات',
              onTap: () => _openPlaceholder(context, 'إدارة العضويات'),
            ),
            _MoreItem(
              icon: Icons.payments_outlined,
              title: 'المدفوعات',
              onTap: () => _openPlaceholder(context, 'إدارة المدفوعات'),
            ),
            _MoreItem(
              icon: Icons.percent_outlined,
              title: 'قواعد الخصم',
              onTap: () => _openPlaceholder(context, 'قواعد الخصم والعطل'),
            ),
            ValueListenableBuilder<ThemeMode>(
              valueListenable: ThemeController.themeMode,
              builder: (context, mode, child) {
                return _MoreItem(
                  icon: mode == ThemeMode.dark
                      ? Icons.light_mode_outlined
                      : Icons.dark_mode_outlined,
                  title: mode == ThemeMode.dark
                      ? 'الوضع النهاري'
                      : 'الوضع الداكن',
                  onTap: ThemeController.toggleTheme,
                );
              },
            ),
            const SizedBox(height: 18),
            OutlinedButton.icon(
              onPressed: () async {
                try {
                  await AuthService.instance.logout();
                } catch (error) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(apiErrorMessage(error))),
                    );
                  }
                }
              },
              icon: const Icon(Icons.logout_rounded),
              label: const Text('تسجيل الخروج'),
            ),
          ],
        ),
      ),
    );
  }
}

class _MoreItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const _MoreItem({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: theme.dividerColor)),
        ),
        child: Row(
          children: [
            Icon(icon, color: AppTheme.turquoise),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
            Icon(
              Icons.chevron_left_rounded,
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ],
        ),
      ),
    );
  }
}

class _AdminManagementPlaceholder extends StatelessWidget {
  final String title;

  const _AdminManagementPlaceholder({required this.title});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(title: Text(title)),
        body: Padding(
          padding: const EdgeInsets.all(20),
          child: Text(
            'واجهة $title جاهزة كمكان في التنقل. عند إنشاء REST API لهذا الجزء سنعرض البيانات ونضيف عمليات الإدارة هنا بدون تغيير هيكل التطبيق.',
            style: TextStyle(color: colors.onSurfaceVariant, height: 1.6),
          ),
        ),
      ),
    );
  }
}
