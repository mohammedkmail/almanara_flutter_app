import 'package:flutter/material.dart';

import '../../models/api_models.dart';
import '../../services/auth_service.dart';
import '../../services/library_service.dart';
import '../../services/notification_inbox_service.dart';
import '../notifications_screen.dart';
import 'admin_book_form_screen.dart';
import 'admin_books_screen.dart';
import 'admin_counter_screen.dart';
import 'admin_more_screen.dart';
import 'admin_operations_screen.dart';
import 'admin_rooms_screen.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  late Future<DashboardSummary> _future;
  int _unreadNotifications = 0;

  static const Color _darkTeal = Color(0xFF102E2B);
  static const Color _teal = Color(0xFF146B67);
  static const Color _gold = Color(0xFFD9B36C);
  static const Color _canvas = Color(0xFFF7F5F0);
  static const Color _border = Color(0xFFE4E1D9);
  static const Color _muted = Color(0xFF6B7473);

  @override
  void initState() {
    super.initState();
    _reload();
    _loadUnreadNotifications();
  }

  void _reload() {
    _future = LibraryService.instance.dashboard();
  }

  Future<void> _loadUnreadNotifications() async {
    try {
      final inbox = await NotificationInboxService.instance.getNotifications(
        max: 1,
      );

      if (!mounted) {
        return;
      }

      setState(() {
        _unreadNotifications = inbox.unreadCount;
      });
    } catch (_) {
      // فشل الإشعارات لا يمنع لوحة الإدارة من العمل.
    }
  }

  Future<void> _openNotifications() async {
    await Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => const NotificationsScreen()));

    if (!mounted) {
      return;
    }

    await _loadUnreadNotifications();
  }

  Future<void> _refresh() async {
    setState(_reload);

    await Future.wait([_future, _loadUnreadNotifications()]);
  }

  void _push(Widget screen) {
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => screen));
  }

  String _firstName() {
    final user = AuthService.instance.user.value;
    final fullName = user?.fullName.trim() ?? '';

    if (fullName.isEmpty) {
      return 'مدير المنارة';
    }

    return fullName.split(RegExp(r'\s+')).first;
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: _canvas,
        body: SafeArea(
          child: FutureBuilder<DashboardSummary>(
            future: _future,
            builder: (context, snapshot) {
              if (snapshot.connectionState != ConnectionState.done) {
                return const Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError) {
                return _DashboardError(
                  message: snapshot.error.toString(),
                  onRetry: () {
                    setState(_reload);
                  },
                );
              }

              final summary = snapshot.data;

              if (summary == null) {
                return _DashboardError(
                  message: 'لم تصل بيانات لوحة التحكم من السيرفر.',
                  onRetry: () {
                    setState(_reload);
                  },
                );
              }

              return RefreshIndicator(
                onRefresh: _refresh,
                child: ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.only(bottom: 28),
                  children: [
                    _buildHero(summary),

                    const SizedBox(height: 18),

                    _buildStats(summary),

                    const SizedBox(height: 28),

                    _sectionTitle(
                      'إجراءات سريعة',
                      'اختصارات لأهم أعمال الإدارة اليومية.',
                    ),

                    const SizedBox(height: 12),

                    _buildActions(),

                    const SizedBox(height: 28),

                    _sectionTitle(
                      'يحتاج انتباهك',
                      'حالات تحتاج متابعة من المدير.',
                    ),

                    const SizedBox(height: 12),

                    _attentionCard(
                      title: 'استعارات متأخرة',
                      value: summary.count('overdueBorrowings'),
                      icon: Icons.warning_amber_rounded,
                      color: Colors.redAccent,
                      onTap: () => _push(const AdminOperationsScreen()),
                    ),

                    _attentionCard(
                      title: 'حجوزات كتب في الانتظار',
                      value: summary.count('waitingReservations'),
                      icon: Icons.hourglass_top_rounded,
                      color: const Color(0xFF9A6C20),
                      onTap: () => _push(const AdminOperationsScreen()),
                    ),

                    _attentionCard(
                      title: 'كتب جاهزة للتسليم',
                      value: summary.count('readyReservations'),
                      icon: Icons.inventory_2_outlined,
                      color: _teal,
                      onTap: () => _push(const AdminOperationsScreen()),
                    ),

                    _attentionCard(
                      title: 'حجوزات غرف مؤكدة',
                      value: summary.count('roomReservations'),
                      icon: Icons.meeting_room_outlined,
                      color: const Color(0xFF4A7182),
                      onTap: () => _push(const AdminOperationsScreen()),
                    ),

                    const SizedBox(height: 24),

                    _buildServices(summary),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildHero(DashboardSummary summary) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        image: DecorationImage(
          image: const AssetImage('assets/images/HERO.png'),
          fit: BoxFit.cover,
          alignment: Alignment.center,
          colorFilter: ColorFilter.mode(
            Colors.black.withValues(alpha: 0.38),
            BlendMode.darken,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: .10),
                  borderRadius: BorderRadius.circular(50),
                ),
                child: const Text(
                  'لوحة إدارة المنارة',
                  style: TextStyle(
                    color: _gold,
                    fontWeight: FontWeight.w800,
                    fontSize: 11,
                  ),
                ),
              ),

              const Spacer(),

              Material(
                color: Colors.black.withValues(alpha: .22),
                shape: const CircleBorder(),
                child: InkWell(
                  onTap: _openNotifications,
                  customBorder: const CircleBorder(),
                  child: SizedBox(
                    width: 44,
                    height: 44,
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        const Center(
                          child: Icon(
                            Icons.notifications_none_rounded,
                            color: Colors.white,
                          ),
                        ),

                        if (_unreadNotifications > 0)
                          Positioned(
                            top: -3,
                            left: -3,
                            child: Container(
                              constraints: const BoxConstraints(
                                minWidth: 19,
                                minHeight: 19,
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 5,
                              ),
                              decoration: BoxDecoration(
                                color: _gold,
                                borderRadius: BorderRadius.circular(999),
                                border: Border.all(
                                  color: Colors.white,
                                  width: 1.5,
                                ),
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                _unreadNotifications > 99
                                    ? '99+'
                                    : '$_unreadNotifications',
                                style: const TextStyle(
                                  color: _darkTeal,
                                  fontSize: 9,
                                  fontWeight: FontWeight.w900,
                                  height: 1,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 18),

          Text(
            'أهلاً ${_firstName()}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 29,
              fontWeight: FontWeight.w900,
            ),
          ),

          const SizedBox(height: 8),

          Text(
            'ملخص سريع لحركة المكتبة والمهام التي تحتاج متابعة.',
            style: TextStyle(
              color: Colors.white.withValues(alpha: .78),
              height: 1.5,
            ),
          ),

          const SizedBox(height: 18),

          Row(
            children: [
              const Icon(Icons.payments_outlined, color: _gold, size: 20),

              const SizedBox(width: 8),

              Expanded(
                child: Text(
                  'إجمالي المدفوعات المكتملة: '
                  '${summary.amount('paymentsTotal').toStringAsFixed(2)} USD',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStats(DashboardSummary summary) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final gap = 10.0;

          final width = (constraints.maxWidth - gap) / 2;

          return Wrap(
            spacing: gap,
            runSpacing: gap,
            children: [
              SizedBox(
                width: width,
                child: _metricCard(
                  label: 'إجمالي الكتب',
                  value: summary.count('books'),
                  icon: Icons.menu_book_outlined,
                  color: _teal,
                ),
              ),

              SizedBox(
                width: width,
                child: _metricCard(
                  label: 'المستخدمون',
                  value: summary.count('members'),
                  icon: Icons.people_alt_outlined,
                  color: const Color(0xFF5B6F98),
                ),
              ),

              SizedBox(
                width: width,
                child: _metricCard(
                  label: 'استعارات نشطة',
                  value: summary.count('activeBorrowings'),
                  icon: Icons.assignment_return_outlined,
                  color: const Color(0xFF8B6A34),
                ),
              ),

              SizedBox(
                width: width,
                child: _metricCard(
                  label: 'استعارات متأخرة',
                  value: summary.count('overdueBorrowings'),
                  icon: Icons.warning_amber_rounded,
                  color: Colors.redAccent,
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _metricCard({
    required String label,
    required int value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(17),
        border: Border.all(color: _border),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: color.withValues(alpha: .10),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color),
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$value',
                  style: const TextStyle(
                    fontSize: 23,
                    fontWeight: FontWeight.w900,
                  ),
                ),

                const SizedBox(height: 2),

                Text(
                  label,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: _muted, fontSize: 11.5),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String title, String subtitle) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w900),
          ),

          const SizedBox(height: 4),

          Text(subtitle, style: const TextStyle(color: _muted, fontSize: 11.5)),
        ],
      ),
    );
  }

  Widget _buildActions() {
    final actions = <_DashboardAction>[
      _DashboardAction(
        title: 'كتاب جديد',
        subtitle: 'إضافة كتاب جديد للمكتبة',
        icon: Icons.add_box_outlined,
        color: _teal,
        onTap: () => _push(const AdminBookFormScreen()),
      ),

      _DashboardAction(
        title: 'كاونتر المكتبة',
        subtitle: 'إعارة أو بيع مباشر',
        icon: Icons.point_of_sale_outlined,
        color: const Color(0xFF8B6A34),
        onTap: () => _push(const AdminCounterScreen()),
      ),

      _DashboardAction(
        title: 'إدارة الكتب',
        subtitle: 'الكتب والنسخ والمخزون',
        icon: Icons.library_books_outlined,
        color: const Color(0xFF426B7D),
        onTap: () => _push(const AdminBooksScreen()),
      ),

      _DashboardAction(
        title: 'العمليات',
        subtitle: 'استعارات وحجوزات ومدفوعات',
        icon: Icons.receipt_long_outlined,
        color: const Color(0xFF6F5A86),
        onTap: () => _push(const AdminOperationsScreen()),
      ),

      _DashboardAction(
        title: 'الغرف',
        subtitle: 'إدارة غرف الدراسة',
        icon: Icons.meeting_room_outlined,
        color: const Color(0xFF587A63),
        onTap: () => _push(const AdminRoomsScreen()),
      ),

      _DashboardAction(
        title: 'المزيد',
        subtitle: 'إعدادات وبيانات النظام',
        icon: Icons.tune_rounded,
        color: const Color(0xFF885E50),
        onTap: () => _push(const AdminMoreScreen()),
      ),
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final gap = 10.0;

          final width = (constraints.maxWidth - gap) / 2;

          return Wrap(
            spacing: gap,
            runSpacing: gap,
            children: actions
                .map(
                  (action) =>
                      SizedBox(width: width, child: _actionCard(action)),
                )
                .toList(),
          );
        },
      ),
    );
  }

  Widget _actionCard(_DashboardAction action) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(17),
      child: InkWell(
        borderRadius: BorderRadius.circular(17),
        onTap: action.onTap,
        child: Container(
          constraints: const BoxConstraints(minHeight: 132),
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(17),
            border: Border.all(color: _border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: action.color.withValues(alpha: .10),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(action.icon, color: action.color),
              ),

              const SizedBox(height: 18),

              Text(
                action.title,
                style: const TextStyle(fontWeight: FontWeight.w900),
              ),

              const SizedBox(height: 4),

              Text(
                action.subtitle,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: _muted, fontSize: 10.5),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _attentionCard({
    required String title,
    required int value,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 9),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(15),
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: _border),
            ),
            child: Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: .10),
                    borderRadius: BorderRadius.circular(11),
                  ),
                  child: Icon(icon, color: color),
                ),

                const SizedBox(width: 12),

                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(fontWeight: FontWeight.w800),
                  ),
                ),

                Text(
                  '$value',
                  style: TextStyle(
                    color: color,
                    fontSize: 21,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildServices(DashboardSummary summary) {
    final paymentReady = summary.count('paymentConfigured') == 1;

    final firebaseReady = summary.count('firebaseConfigured') == 1;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(17),
          border: Border.all(color: _border),
        ),
        child: Column(
          children: [
            _serviceRow(
              icon: Icons.credit_card_rounded,
              title: 'الدفع الإلكتروني',
              ready: paymentReady,
            ),

            const Divider(height: 24),

            _serviceRow(
              icon: Icons.notifications_active_outlined,
              title: 'Firebase Cloud Messaging',
              ready: firebaseReady,
            ),
          ],
        ),
      ),
    );
  }

  Widget _serviceRow({
    required IconData icon,
    required String title,
    required bool ready,
  }) {
    final color = ready ? _teal : const Color(0xFF9A6C20);

    return Row(
      children: [
        Icon(icon, color: color),

        const SizedBox(width: 11),

        Expanded(
          child: Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.w800),
          ),
        ),

        Text(
          ready ? 'جاهز' : 'غير مهيأ',
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.w800,
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}

class _DashboardAction {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _DashboardAction({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.onTap,
  });
}

class _DashboardError extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _DashboardError({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(24),
      children: [
        const SizedBox(height: 100),

        const Icon(
          Icons.error_outline_rounded,
          size: 54,
          color: Colors.redAccent,
        ),

        const SizedBox(height: 16),

        const Text(
          'تعذر تحميل لوحة التحكم',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
        ),

        const SizedBox(height: 8),

        Text(message, textAlign: TextAlign.center),

        const SizedBox(height: 18),

        Center(
          child: FilledButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('إعادة المحاولة'),
          ),
        ),
      ],
    );
  }
}
