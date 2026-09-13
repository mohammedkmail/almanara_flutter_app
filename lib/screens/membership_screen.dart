import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

class MembershipScreen extends StatelessWidget {
  const MembershipScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(title: const Text('العضوية')),
        body: ListView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 30),
          children: [
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: AppTheme.darkTeal,
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.verified_rounded, color: AppTheme.turquoise),
                      SizedBox(width: 8),
                      Text(
                        'عضويتك فعّالة',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                          fontSize: 19,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 12),
                  Text('عضو طالب', style: TextStyle(color: Colors.white70)),
                  SizedBox(height: 4),
                  Text(
                    'تنتهي في 15 ديسمبر 2026',
                    style: TextStyle(color: Colors.white70),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'خطط العضوية',
              style: TextStyle(
                color: colors.onSurface,
                fontSize: 18,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 12),
            const _PlanTile(days: 30, subtitle: 'شهر واحد'),
            const _PlanTile(days: 90, subtitle: '3 أشهر'),
            const _PlanTile(days: 180, subtitle: '6 أشهر'),
            const _PlanTile(days: 365, subtitle: 'سنة'),
            const SizedBox(height: 12),
            Text(
              'الأسعار والخصومات الفعلية ستأتي من نظام العضويات في الـ Backend عند ربط الـ API.',
              style: TextStyle(
                color: colors.onSurfaceVariant,
                fontSize: 12,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PlanTile extends StatelessWidget {
  final int days;
  final String subtitle;

  const _PlanTile({
    required this.days,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.dividerColor),
      ),
      child: Row(
        children: [
          const Icon(Icons.card_membership_outlined, color: AppTheme.turquoise),
          const SizedBox(width: 11),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  subtitle,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                Text(
                  '$days يوم',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('سيتم ربط الاشتراك والدفع بالـ API لاحقاً')),
              );
            },
            child: const Text('اختيار'),
          ),
        ],
      ),
    );
  }
}
