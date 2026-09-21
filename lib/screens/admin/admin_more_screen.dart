import 'package:flutter/material.dart';

import '../../services/auth_service.dart';
import '../../services/library_service.dart';
import '../../services/notification_service.dart';
import '../../theme/app_theme.dart';
import '../../theme/theme_controller.dart';
import '../../widgets/api_error_view.dart';
import '../../widgets/manara_components.dart';
import 'admin_book_copies_screen.dart';
import 'admin_system_screens.dart';

class AdminMoreScreen extends StatefulWidget {
  const AdminMoreScreen({super.key});

  @override
  State<AdminMoreScreen> createState() => _AdminMoreScreenState();
}

class _AdminMoreScreenState extends State<AdminMoreScreen> {
  late Future<Map<String, dynamic>> _future;
  bool _syncing = false;
  bool _loggingOut = false;

  @override
  void initState() {
    super.initState();
    _reload();
  }

  void _reload() {
    _future = LibraryService.instance.adminReference();
  }

  Future<void> _refresh() async {
    setState(() {
      _reload();
    });
    await _future;
  }

  void _open(Widget page) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => page));
  }

  Future<void> _syncHolidays() async {
    if (_syncing) return;
    setState(() => _syncing = true);
    try {
      final result = await LibraryService.instance.syncHolidays();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            (result['message'] ?? 'تم تحديث تقويم العطل.').toString(),
          ),
        ),
      );
      await _refresh();
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(apiErrorMessage(error))));
    } finally {
      if (mounted) setState(() => _syncing = false);
    }
  }

  Future<void> _logout() async {
    if (_loggingOut) return;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تسجيل الخروج؟'),
        content: const Text(
          'سيتم إنهاء جلسة الإدارة الحالية وإلغاء تسجيل هذا الجهاز للإشعارات.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('إلغاء'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('تسجيل الخروج'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    setState(() => _loggingOut = true);
    try {
      await NotificationService.instance.unregisterDevice();
      await AuthService.instance.logout();
    } finally {
      if (mounted) setState(() => _loggingOut = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = AuthService.instance.user.value;
    final adminName = user?.fullName.trim().isNotEmpty == true
        ? user!.fullName.trim()
        : 'مدير المنارة';

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        body: SafeArea(
          bottom: false,
          child: FutureBuilder<Map<String, dynamic>>(
            future: _future,
            builder: (context, snapshot) {
              if (snapshot.connectionState != ConnectionState.done) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return ApiErrorView(
                  error: snapshot.error!,
                  retry: () {
                    setState(() {
                      _reload();
                    });
                  },
                );
              }

              final data = snapshot.data!;
              final authors = data['authors'] as List? ?? const [];
              final categories = data['categories'] as List? ?? const [];
              final rules = data['discountRules'] as List? ?? const [];
              final holidays = data['upcomingHolidays'] as List? ?? const [];
              final paymentReady = data['paymentConfigured'] == true;
              final firebaseReady = data['firebaseConfigured'] == true;

              return RefreshIndicator(
                onRefresh: _refresh,
                child: ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(18, 14, 18, 110),
                  children: [
                    _SystemHeader(
                      adminName: adminName,
                      paymentReady: paymentReady,
                      firebaseReady: firebaseReady,
                    ),
                    const SizedBox(height: 24),
                    const ManaraSectionTitle(
                      title: 'إدارة النظام',
                      subtitle:
                          'بيانات المنارة الأساسية التي تظهر للمستخدم في التطبيق والويب.',
                    ),
                    const SizedBox(height: 13),
                    _ManagementEntry(
                      icon: Icons.people_alt_outlined,
                      title: 'المستخدمون والعضويات',
                      description:
                          'راجع الحسابات وحالة العضوية قبل الإعارة والبيع من الكاونتر.',
                      accent: const Color(0xFFE5F1ED),
                      iconColor: AppTheme.teal,
                      onTap: () => _open(const AdminUsersScreen()),
                    ),
                    _ManagementEntry(
                      icon: Icons.category_outlined,
                      title: 'التصنيفات',
                      description:
                          '${categories.length} تصنيف • تنظيم ظهور الكتب ومسارات الاستكشاف.',
                      accent: const Color(0xFFF4EEE1),
                      iconColor: const Color(0xFF8B6B31),
                      onTap: () => _open(const AdminCategoriesScreen()),
                    ),
                    _ManagementEntry(
                      icon: Icons.person_search_outlined,
                      title: 'المؤلفون',
                      description:
                          '${authors.length} مؤلف • السيرة والصورة والكتب المرتبطة بكل مؤلف.',
                      accent: const Color(0xFFEAF0F3),
                      iconColor: const Color(0xFF3F6872),
                      onTap: () => _open(const AdminAuthorsScreen()),
                    ),
                    _ManagementEntry(
                      icon: Icons.inventory_2_outlined,
                      title: 'نسخ الكتب الورقية',
                      description:
                          'إدارة رمز كل نسخة وحالتها: متاحة، مفقودة، تالفة أو مرتبطة بعملية.',
                      accent: const Color(0xFFE9F0E9),
                      iconColor: const Color(0xFF42664E),
                      onTap: () => _open(const AdminBookCopiesScreen()),
                    ),
                    _ManagementEntry(
                      icon: Icons.event_available_outlined,
                      title: 'تقويم العطل',
                      description:
                          '${holidays.length} مواعيد قادمة • تؤثر على الإغلاق وحجوزات الغرف.',
                      accent: const Color(0xFFF3E9E7),
                      iconColor: const Color(0xFF99554B),
                      onTap: () => _open(const AdminHolidaysScreen()),
                    ),
                    _ManagementEntry(
                      icon: Icons.percent_rounded,
                      title: 'قواعد الخصم',
                      description:
                          '${rules.length} قاعدة • تضبط تسعير حجوزات غرف الدراسة تلقائياً.',
                      accent: const Color(0xFFE7EEF4),
                      iconColor: const Color(0xFF42667D),
                      onTap: () => _open(const AdminDiscountRulesScreen()),
                    ),
                    const SizedBox(height: 25),
                    ManaraSectionTitle(
                      title: 'التكامل والخدمات',
                      subtitle:
                          'هذه الحالة قادمة من السيرفر وليست قيمة تجريبية داخل التطبيق.',
                      trailing: IconButton(
                        tooltip: 'تحديث',
                        onPressed: _refresh,
                        icon: const Icon(Icons.refresh_rounded),
                      ),
                    ),
                    const SizedBox(height: 13),
                    _IntegrationPanel(
                      paymentReady: paymentReady,
                      firebaseReady: firebaseReady,
                    ),
                    const SizedBox(height: 12),
                    OutlinedButton.icon(
                      onPressed: _syncing ? null : _syncHolidays,
                      icon: _syncing
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.calendar_month_outlined),
                      label: Text(
                        _syncing
                            ? 'جاري مزامنة التقويم...'
                            : 'مزامنة تقويم العطل الآن',
                      ),
                    ),
                    const SizedBox(height: 25),
                    const ManaraSectionTitle(
                      title: 'التطبيق والحساب',
                      subtitle: 'خيارات محلية لا تغيّر بيانات المكتبة.',
                    ),
                    const SizedBox(height: 12),
                    _SimpleSetting(
                      icon: Icons.contrast_rounded,
                      title: 'تغيير المظهر',
                      description: 'التبديل بين المظهر الفاتح والداكن.',
                      onTap: ThemeController.toggleTheme,
                    ),
                    _SimpleSetting(
                      icon: Icons.logout_rounded,
                      title: 'تسجيل الخروج',
                      description: 'إنهاء جلسة الإدارة على هذا الجهاز.',
                      destructive: true,
                      busy: _loggingOut,
                      onTap: _logout,
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _SystemHeader extends StatelessWidget {
  final String adminName;
  final bool paymentReady;
  final bool firebaseReady;

  const _SystemHeader({
    required this.adminName,
    required this.paymentReady,
    required this.firebaseReady,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.darkTeal,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: .10),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: const Icon(Icons.tune_rounded, color: AppTheme.gold),
              ),
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'مركز تحكم المنارة',
                      style: Theme.of(
                        context,
                      ).textTheme.titleLarge?.copyWith(color: Colors.white),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      adminName,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: .70),
                        fontSize: 11.5,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            'عدّل المحتوى وقواعد التشغيل من مكان واحد، مع بقاء نفس البيانات متزامنة بين الويب والموبايل.',
            style: TextStyle(
              color: Colors.white.withValues(alpha: .82),
              height: 1.65,
              fontSize: 12.5,
            ),
          ),
          const SizedBox(height: 17),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _HeaderStatus(
                label: paymentReady ? 'الدفع جاهز' : 'الدفع يحتاج إعداد',
                icon: Icons.credit_card_rounded,
                ready: paymentReady,
              ),
              _HeaderStatus(
                label: firebaseReady
                    ? 'Firebase متصل'
                    : 'Firebase بانتظار الربط',
                icon: Icons.notifications_active_outlined,
                ready: firebaseReady,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _HeaderStatus extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool ready;

  const _HeaderStatus({
    required this.label,
    required this.icon,
    required this.ready,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: .08),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.white.withValues(alpha: .10)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 15,
            color: ready ? const Color(0xFF87D5B0) : AppTheme.gold,
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 10.5,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _ManagementEntry extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final Color accent;
  final Color iconColor;
  final VoidCallback onTap;

  const _ManagementEntry({
    required this.icon,
    required this.title,
    required this.description,
    required this.accent,
    required this.iconColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 9),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(17),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(17),
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(17),
              border: Border.all(color: AppTheme.border),
            ),
            child: Row(
              children: [
                Container(
                  width: 54,
                  height: 54,
                  decoration: BoxDecoration(
                    color: accent,
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Icon(icon, color: iconColor, size: 26),
                ),
                const SizedBox(width: 13),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontWeight: FontWeight.w900,
                          fontSize: 14.5,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        description,
                        style: const TextStyle(
                          color: AppTheme.muted,
                          fontSize: 10.5,
                          height: 1.45,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(
                  Icons.arrow_back_ios_new_rounded,
                  size: 16,
                  color: AppTheme.muted,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _IntegrationPanel extends StatelessWidget {
  final bool paymentReady;
  final bool firebaseReady;

  const _IntegrationPanel({
    required this.paymentReady,
    required this.firebaseReady,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppTheme.border),
      ),
      child: Column(
        children: [
          _IntegrationRow(
            icon: Icons.payments_outlined,
            title: 'Braintree / الدفع الإلكتروني',
            detail: paymentReady
                ? 'بوابة الدفع مهيأة على السيرفر وجاهزة لطلبات التطبيق.'
                : 'أكمل إعداد مفاتيح Braintree على السيرفر قبل الدفع الحقيقي.',
            ready: paymentReady,
          ),
          const Divider(height: 25),
          _IntegrationRow(
            icon: Icons.notifications_active_outlined,
            title: 'Firebase Cloud Messaging',
            detail: firebaseReady
                ? 'خدمة الإشعارات متصلة ويمكن تسجيل أجهزة المستخدمين.'
                : 'الكود جاهز؛ أضف Service Account و google-services.json عند الربط النهائي.',
            ready: firebaseReady,
          ),
        ],
      ),
    );
  }
}

class _IntegrationRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String detail;
  final bool ready;

  const _IntegrationRow({
    required this.icon,
    required this.title,
    required this.detail,
    required this.ready,
  });

  @override
  Widget build(BuildContext context) {
    final tone = ready ? AppTheme.teal : const Color(0xFF9A7132);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: tone.withValues(alpha: .10),
            borderRadius: BorderRadius.circular(13),
          ),
          child: Icon(icon, color: tone, size: 22),
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
                      title,
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 12.5,
                      ),
                    ),
                  ),
                  ManaraStatusChip(
                    label: ready ? 'جاهز' : 'قيد الإعداد',
                    color: tone,
                    icon: ready
                        ? Icons.check_circle_outline_rounded
                        : Icons.schedule_rounded,
                  ),
                ],
              ),
              const SizedBox(height: 5),
              Text(
                detail,
                style: const TextStyle(
                  color: AppTheme.muted,
                  fontSize: 10.5,
                  height: 1.45,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _SimpleSetting extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final VoidCallback onTap;
  final bool destructive;
  final bool busy;

  const _SimpleSetting({
    required this.icon,
    required this.title,
    required this.description,
    required this.onTap,
    this.destructive = false,
    this.busy = false,
  });

  @override
  Widget build(BuildContext context) {
    final tone = destructive ? Colors.redAccent : AppTheme.teal;
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 2, vertical: 2),
      onTap: busy ? null : onTap,
      leading: Container(
        width: 43,
        height: 43,
        decoration: BoxDecoration(
          color: tone.withValues(alpha: .09),
          borderRadius: BorderRadius.circular(13),
        ),
        child: busy
            ? const Padding(
                padding: EdgeInsets.all(12),
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : Icon(icon, color: tone),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.w800,
          color: destructive ? Colors.redAccent : null,
        ),
      ),
      subtitle: Text(description),
      trailing: const Icon(Icons.arrow_back_ios_new_rounded, size: 15),
    );
  }
}
