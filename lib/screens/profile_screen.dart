import 'package:flutter/material.dart';

import '../models/app_user_role.dart';
import '../services/auth_service.dart';
import '../services/notification_service.dart';
import '../theme/app_theme.dart';
import '../theme/theme_controller.dart';
import '../widgets/manara_components.dart';
import 'authors_screen.dart';
import 'categories_screen.dart';
import 'membership_screen.dart';
import 'library_calendar_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  Future<void> _logout(BuildContext context) async {
    final ok =
        await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('تسجيل الخروج؟'),
            content: const Text('سيتم حذف رمز الجلسة المحفوظ على هذا الجهاز.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('رجوع'),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('تسجيل الخروج'),
              ),
            ],
          ),
        ) ??
        false;
    if (!ok) return;
    await NotificationService.instance.unregisterDevice();
    await AuthService.instance.logout();
  }

  @override
  Widget build(BuildContext context) {
    final user = AuthService.instance.user.value;
    final initial = user?.fullName.trim().isNotEmpty == true
        ? user!.fullName.trim().characters.first
        : 'م';
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(title: const Text('حسابي')),
        body: ListView(
          padding: const EdgeInsets.fromLTRB(18, 4, 18, 32),
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppTheme.darkTeal,
                borderRadius: BorderRadius.circular(22),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 34,
                    backgroundColor: AppTheme.gold,
                    child: Text(
                      initial,
                      style: const TextStyle(
                        color: AppTheme.darkTeal,
                        fontSize: 27,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user?.fullName ?? 'مستخدم المنارة',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          user?.username ?? '',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: .70),
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 8),
                        ManaraStatusChip(
                          label: user?.role == AppUserRole.admin
                              ? 'مدير النظام'
                              : 'قارئ',
                          color: AppTheme.gold,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 26),
            const ManaraSectionTitle(
              title: 'المكتبة والحساب',
              subtitle: 'اختصارات لصفحات مفيدة وليست مجرد إعدادات عامة.',
            ),
            const SizedBox(height: 10),
            _ProfileTile(
              icon: Icons.workspace_premium_outlined,
              title: 'العضوية',
              subtitle: 'الفترة والمزايا والسجل والتجديد',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const MembershipScreen()),
              ),
            ),
            _ProfileTile(
              icon: Icons.category_outlined,
              title: 'أقسام المكتبة',
              subtitle: 'تصفح الكتب حسب الاهتمام',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const CategoriesScreen()),
              ),
            ),
            _ProfileTile(
              icon: Icons.people_alt_outlined,
              title: 'المؤلفون',
              subtitle: 'تعرف على المؤلفين وكتبهم',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AuthorsScreen()),
              ),
            ),
            _ProfileTile(
              icon: Icons.calendar_month_outlined,
              title: 'تقويم المكتبة',
              subtitle: 'العطل ومواعيد الإغلاق القادمة',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const LibraryCalendarScreen(),
                ),
              ),
            ),
            const SizedBox(height: 22),
            const ManaraSectionTitle(title: 'تفضيلات التطبيق'),
            const SizedBox(height: 10),
            ValueListenableBuilder<ThemeMode>(
              valueListenable: ThemeController.themeMode,
              builder: (context, mode, _) => _ProfileTile(
                icon: mode == ThemeMode.dark
                    ? Icons.dark_mode_outlined
                    : Icons.light_mode_outlined,
                title: 'المظهر',
                subtitle: mode == ThemeMode.dark
                    ? 'الوضع الداكن'
                    : 'الوضع الفاتح',
                onTap: ThemeController.toggleTheme,
                trailing: Switch(
                  value: mode == ThemeMode.dark,
                  onChanged: (_) => ThemeController.toggleTheme(),
                ),
              ),
            ),
            _ProfileTile(
              icon: Icons.notifications_active_outlined,
              title: 'إشعارات Firebase',
              subtitle: NotificationService.instance.initialized
                  ? 'الخدمة مهيأة على هذا الجهاز'
                  : 'الكود جاهز؛ التفعيل النهائي يحتاج بيانات Firebase',
              onTap: null,
            ),
            const SizedBox(height: 22),
            OutlinedButton.icon(
              onPressed: () => _logout(context),
              icon: const Icon(Icons.logout_rounded),
              label: const Text('تسجيل الخروج'),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfileTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;
  final Widget? trailing;
  const _ProfileTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) => Card(
    margin: const EdgeInsets.only(bottom: 9),
    child: ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      onTap: onTap,
      leading: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: const Color(0xFFE7F1EE),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: AppTheme.teal),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w800)),
      subtitle: Text(subtitle),
      trailing:
          trailing ??
          (onTap == null ? null : const Icon(Icons.chevron_left_rounded)),
    ),
  );
}
