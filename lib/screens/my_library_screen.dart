import 'package:flutter/material.dart';

import '../models/api_models.dart';
import '../services/library_service.dart';
import '../theme/app_theme.dart';
import 'digital_reader_screen.dart';

class MyLibraryScreen extends StatefulWidget {
  const MyLibraryScreen({super.key});

  @override
  State<MyLibraryScreen> createState() => _MyLibraryScreenState();
}

class _MyLibraryScreenState extends State<MyLibraryScreen> {
  late Future<List<DigitalAccessItem>> _digitalFuture;

  @override
  void initState() {
    super.initState();
    _loadDigital();
  }

  void _loadDigital() {
    _digitalFuture = LibraryService.instance.digitalAccess();
  }

  Future<void> _refreshDigital() async {
    setState(_loadDigital);
    await _digitalFuture;
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: DefaultTabController(
        length: 3,
        child: Scaffold(
          appBar: AppBar(
            elevation: 0,
            scrolledUnderElevation: 0,
            backgroundColor: const Color(0xFF0F5B52),
            foregroundColor: Colors.white,
            automaticallyImplyLeading: false,
            toolbarHeight: 20,
            flexibleSpace: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topRight,
                  end: Alignment.bottomLeft,
                  colors: [
                    Color(0xFF0F5B52),
                    Color(0xFF0A403A),
                  ],
                ),
              ),
            ),
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(58),
              child: Container(
                height: 58,
                margin: const EdgeInsets.fromLTRB(14, 8, 14, 8),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.08),
                  ),
                ),
                child: TabBar(
                  dividerColor: Colors.transparent,
                  indicatorSize: TabBarIndicatorSize.tab,
                  indicatorPadding: const EdgeInsets.all(5),
                  indicator: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.12),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  labelColor: const Color(0xFF0F5B52),
                  unselectedLabelColor: Colors.white.withValues(alpha: 0.72),
                  labelStyle: const TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w900,
                  ),
                  unselectedLabelStyle: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                  splashBorderRadius: BorderRadius.circular(12),
                  tabs: const [
                    Tab(
                      icon: Icon(Icons.menu_book_outlined, size: 20),
                      text: 'استعاراتي',
                    ),
                    Tab(
                      icon: Icon(Icons.bookmark_outline_rounded, size: 20),
                      text: 'حجوزاتي',
                    ),
                    Tab(
                      icon: Icon(Icons.tablet_android_outlined, size: 20),
                      text: 'رقمياتي',
                    ),
                  ],
                ),
              ),
            ),
          ),
          body: TabBarView(
            children: [
              _borrowingsTab(),
              _reservationsTab(),
              _digitalTab(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _borrowingsTab() {
    return ListView(
      padding: const EdgeInsets.fromLTRB(18, 20, 18, 28),
      children: const [
        _LibrarySectionHeader(
          icon: Icons.menu_book_rounded,
          title: 'استعاراتي',
          subtitle: 'الكتب التي تستعيرها حاليًا وموعد إعادتها.',
        ),
        SizedBox(height: 16),
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
    );
  }

  Widget _reservationsTab() {
    return ListView(
      padding: const EdgeInsets.fromLTRB(18, 20, 18, 28),
      children: const [
        _LibrarySectionHeader(
          icon: Icons.bookmark_rounded,
          title: 'حجوزاتي',
          subtitle: 'تابع حالة حجوزات الكتب والغرف الخاصة بك.',
        ),
        SizedBox(height: 16),
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
    );
  }

  Widget _digitalTab() {
    return FutureBuilder<List<DigitalAccessItem>>(
      future: _digitalFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Center(
            child: CircularProgressIndicator(
              color: Color(0xFF0F5B52),
            ),
          );
        }

        if (snapshot.hasError) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      color: Colors.redAccent.withValues(alpha: 0.10),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.error_outline,
                      size: 38,
                      color: Colors.redAccent,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'تعذر تحميل مكتبتك الرقمية.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 14),
                  FilledButton.icon(
                    onPressed: () {
                      setState(_loadDigital);
                    },
                    icon: const Icon(Icons.refresh),
                    label: const Text('إعادة المحاولة'),
                  ),
                ],
              ),
            ),
          );
        }

        final items = snapshot.data ?? const <DigitalAccessItem>[];

        if (items.isEmpty) {
          return RefreshIndicator(
            color: const Color(0xFF0F5B52),
            onRefresh: _refreshDigital,
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(24, 40, 24, 30),
              children: const [
                _DigitalEmptyState(),
              ],
            ),
          );
        }

        return RefreshIndicator(
          color: const Color(0xFF0F5B52),
          onRefresh: _refreshDigital,
          child: ListView.builder(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(18, 20, 18, 30),
            itemCount: items.length + 1,
            itemBuilder: (context, index) {
              if (index == 0) {
                return const Padding(
                  padding: EdgeInsets.only(bottom: 16),
                  child: _LibrarySectionHeader(
                    icon: Icons.tablet_android_rounded,
                    title: 'مكتبتي الرقمية',
                    subtitle:
                    'كل الكتب الرقمية المتاحة لك من الشراء أو الاستئجار أو العضوية.',
                  ),
                );
              }

              final item = items[index - 1];

              return _LibraryItem(
                icon: _digitalIcon(item.source),
                title: item.bookTitle,
                subtitle: _digitalSubtitle(item),
                status: _digitalStatus(item.source),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => DigitalReaderScreen(
                        bookId: item.bookId,
                      ),
                    ),
                  );
                },
              );
            },
          ),
        );
      },
    );
  }

  IconData _digitalIcon(String source) {
    switch (source) {
      case 'PURCHASE':
        return Icons.shopping_bag_outlined;

      case 'RENTAL':
        return Icons.schedule_outlined;

      case 'MEMBERSHIP':
        return Icons.workspace_premium_outlined;

      default:
        return Icons.tablet_android_outlined;
    }
  }

  String _digitalStatus(String source) {
    switch (source) {
      case 'PURCHASE':
        return 'مشتَرى';

      case 'RENTAL':
        return 'مستأجر';

      case 'MEMBERSHIP':
        return 'العضوية';

      default:
        return 'رقمي';
    }
  }

  String _digitalSubtitle(DigitalAccessItem item) {
    switch (item.source) {
      case 'PURCHASE':
        return 'نسخة رقمية مشتراة — الوصول دائم';

      case 'MEMBERSHIP':
        return 'متاح ضمن عضويتك الفعالة';

      case 'RENTAL':
        if (item.endDate != null) {
          return 'الاستئجار فعال حتى ${_formatDate(item.endDate!)}';
        }

        return 'استئجار رقمي فعال';

      default:
        return 'لديك وصول رقمي لهذا الكتاب';
    }
  }

  String _formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');

    return '$day/$month/${date.year}';
  }
}

class _LibrarySectionHeader extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _LibrarySectionHeader({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: const Color(0xFFE4F1EE),
            borderRadius: BorderRadius.circular(15),
          ),
          child: const Icon(
            Icons.auto_stories_rounded,
            color: Color(0xFF0F5B52),
            size: 25,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 19,
                  fontWeight: FontWeight.w900,
                  color: AppTheme.ink,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                subtitle,
                style: const TextStyle(
                  fontSize: 11.5,
                  height: 1.4,
                  color: AppTheme.muted,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _DigitalEmptyState extends StatelessWidget {
  const _DigitalEmptyState();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 110,
          height: 110,
          decoration: BoxDecoration(
            color: const Color(0xFFE4F1EE),
            shape: BoxShape.circle,
            border: Border.all(
              color: const Color(0xFFBBDCD5),
              width: 1.5,
            ),
          ),
          child: const Icon(
            Icons.tablet_android_rounded,
            size: 54,
            color: Color(0xFF0F5B52),
          ),
        ),
        const SizedBox(height: 22),
        const Text(
          'مكتبتك الرقمية فارغة',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 9),
        const Text(
          'ستظهر هنا الكتب التي اشتريتها رقمياً أو استأجرتها أو أصبحت متاحة لك ضمن العضوية.',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 13,
            height: 1.6,
            color: AppTheme.muted,
          ),
        ),
      ],
    );
  }
}

class _LibraryItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String status;
  final VoidCallback? onTap;

  const _LibraryItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.status,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    final isActive =
        status == 'نشط' ||
            status == 'CONFIRMED' ||
            status == 'مشتَرى' ||
            status == 'العضوية';

    final isWaiting = status == 'WAITING';

    final statusColor = isWaiting
        ? const Color(0xFF9A6D21)
        : isActive
        ? const Color(0xFF0F5B52)
        : const Color(0xFF66508B);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: theme.dividerColor.withValues(alpha: 0.8),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.035),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(18),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(18),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topRight,
                      end: Alignment.bottomLeft,
                      colors: [
                        Color(0xFFE4F1EE),
                        Color(0xFFD5E9E4),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Icon(
                    icon,
                    color: const Color(0xFF0F5B52),
                    size: 25,
                  ),
                ),
                const SizedBox(width: 13),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: colors.onSurface,
                          fontSize: 14.5,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        subtitle,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: colors.onSurfaceVariant,
                          fontSize: 11.5,
                          height: 1.35,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 9,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: statusColor.withValues(alpha: 0.10),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        status,
                        style: TextStyle(
                          color: statusColor,
                          fontSize: 10,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                    if (onTap != null) ...[
                      const SizedBox(height: 7),
                      Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          color: const Color(0xFFEAF3F1),
                          borderRadius: BorderRadius.circular(9),
                        ),
                        child: const Icon(
                          Icons.chevron_left_rounded,
                          size: 19,
                          color: Color(0xFF0F5B52),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}