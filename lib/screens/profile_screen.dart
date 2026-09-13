import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import '../theme/theme_controller.dart';
import 'membership_screen.dart';
import '../services/auth_service.dart';
import '../widgets/api_error_view.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

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
                'حسابي',
                style: TextStyle(
                  color: colors.onSurface,
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 22),
              Row(
                children: [
                  const CircleAvatar(
                    radius: 30,
                    backgroundColor: AppTheme.darkTeal,
                    child: Text(
                      'H',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          AuthService.instance.user.value?.fullName ?? '',
                          style: TextStyle(
                            color: colors.onSurface,
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          AuthService.instance.user.value?.username ?? '',
                          style: TextStyle(
                            color: colors.onSurfaceVariant,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 26),
              _ProfileItem(
                icon: Icons.card_membership_outlined,
                title: 'العضوية',
                subtitle: 'عرض حالة العضوية وخطط الاشتراك',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const MembershipScreen(),
                    ),
                  );
                },
              ),
              ValueListenableBuilder<ThemeMode>(
                valueListenable: ThemeController.themeMode,
                builder: (context, mode, child) {
                  return _ProfileItem(
                    icon: mode == ThemeMode.dark
                        ? Icons.light_mode_outlined
                        : Icons.dark_mode_outlined,
                    title: mode == ThemeMode.dark
                        ? 'الوضع النهاري'
                        : 'الوضع الداكن',
                    subtitle: 'تغيير مظهر التطبيق',
                    onTap: ThemeController.toggleTheme,
                  );
                },
              ),
              _ProfileItem(
                icon: Icons.lock_outline,
                title: 'الأمان',
                subtitle: 'تغيير كلمة المرور لاحقاً من الحساب',
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('سيتم ربط إعدادات الحساب بالـ API لاحقاً'),
                    ),
                  );
                },
              ),
              _ProfileItem(
                icon: Icons.info_outline,
                title: 'عن المنارة',
                subtitle: 'نظام إدارة مكتبة وخدمات دراسة',
                onTap: () {
                  showAboutDialog(
                    context: context,
                    applicationName: 'المنارة',
                    applicationVersion: '1.0.0',
                  );
                },
              ),
              const SizedBox(height: 12),
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
              const SizedBox(height: 12),
              Text(
                'بيانات الحساب من السيرفر. بعض الخدمات الأخرى ما زالت قيد الربط.',
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

class _ProfileItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _ProfileItem({
    required this.icon,
    required this.title,
    required this.subtitle,
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
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
