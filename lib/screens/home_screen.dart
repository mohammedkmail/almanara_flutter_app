import 'package:flutter/material.dart';

import '../models/library_book.dart';
import '../services/library_service.dart';
import '../services/auth_service.dart';
import '../widgets/api_error_view.dart';
import '../theme/app_theme.dart';
import '../theme/theme_controller.dart';
import 'book_details_screen.dart';
import 'books_screen.dart';
import 'membership_screen.dart';
import 'notifications_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<LibraryBook> latestBooks = [];
  List<LibraryBook> get mostBorrowedBooks =>
      latestBooks.where((b) => b.available).take(6).toList();
  Object? _error;
  bool _loading = true;
  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final books = await LibraryService.instance.books();
      if (mounted) setState(() => latestBooks = books);
    } catch (error) {
      if (mounted) setState(() => _error = error);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
          ? ApiErrorView(error: _error!, retry: _load)
          : SafeArea(
              child: Directionality(
                textDirection: TextDirection.rtl,
                child: ListView(
                  padding: const EdgeInsets.only(bottom: 30),
                  children: [
                    // =====================================================
                    // TOP BAR
                    // =====================================================
                    Padding(
                      padding: const EdgeInsets.fromLTRB(18, 14, 18, 8),
                      child: Row(
                        children: [
                          Container(
                            width: 46,
                            height: 46,
                            decoration: BoxDecoration(
                              color: AppTheme.darkTeal,
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: const Icon(
                              Icons.menu_book_rounded,
                              color: AppTheme.turquoise,
                              size: 27,
                            ),
                          ),

                          const SizedBox(width: 11),

                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'المنارة',
                                  style: TextStyle(
                                    fontSize: 21,
                                    fontWeight: FontWeight.w800,
                                    color: colors.onSurface,
                                  ),
                                ),
                                Text(
                                  'مكتبتك للمعرفة',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: colors.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // DARK MODE
                          ValueListenableBuilder<ThemeMode>(
                            valueListenable: ThemeController.themeMode,
                            builder: (context, mode, child) {
                              final bool isDark = mode == ThemeMode.dark;

                              return IconButton(
                                tooltip: isDark
                                    ? 'الوضع النهاري'
                                    : 'الوضع الداكن',
                                onPressed: ThemeController.toggleTheme,
                                icon: Icon(
                                  isDark
                                      ? Icons.light_mode_outlined
                                      : Icons.dark_mode_outlined,
                                  color: colors.onSurface,
                                ),
                              );
                            },
                          ),

                          Stack(
                            children: [
                              IconButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          const NotificationsScreen(),
                                    ),
                                  );
                                },
                                icon: Icon(
                                  Icons.notifications_none_rounded,
                                  color: colors.onSurface,
                                ),
                              ),
                              const Positioned(
                                top: 8,
                                right: 8,
                                child: CircleAvatar(
                                  radius: 4,
                                  backgroundColor: Colors.redAccent,
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(width: 3),

                          const CircleAvatar(
                            radius: 20,
                            backgroundColor: AppTheme.darkTeal,
                            child: Text(
                              'H',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // =====================================================
                    // GREETING
                    // =====================================================
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 16, 20, 5),
                      child: Text(
                        'أهلاً، ${AuthService.instance.user.value?.fullName ?? ''}',
                        style: TextStyle(
                          fontSize: 27,
                          fontWeight: FontWeight.w800,
                          color: colors.onSurface,
                        ),
                      ),
                    ),

                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Text(
                        'كل كتاب تقرأه يضيف لك شيئاً جديداً.',
                        style: TextStyle(
                          fontSize: 13,
                          color: colors.onSurfaceVariant,
                        ),
                      ),
                    ),

                    const SizedBox(height: 18),

                    // =====================================================
                    // SEARCH
                    // =====================================================
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: TextField(
                        readOnly: true,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const BooksScreen(),
                            ),
                          );
                        },
                        decoration: InputDecoration(
                          hintText: 'ابحث عن كتاب، مؤلف، أو موضوع...',
                          prefixIcon: const Icon(Icons.search_rounded),
                          suffixIcon: IconButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const BooksScreen(),
                                ),
                              );
                            },
                            icon: const Icon(Icons.tune_rounded),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // =====================================================
                    // MEMBERSHIP
                    // =====================================================
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Container(
                        constraints: const BoxConstraints(minHeight: 200),
                        clipBehavior: Clip.antiAlias,
                        decoration: BoxDecoration(
                          color: AppTheme.darkTeal,
                          borderRadius: BorderRadius.circular(22),
                        ),
                        child: Stack(
                          children: [
                            Positioned.fill(
                              child: Image.asset(
                                'assets/images/home_hero_img.png',
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return const SizedBox();
                                },
                              ),
                            ),

                            Positioned.fill(
                              child: Container(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.centerRight,
                                    end: Alignment.centerLeft,
                                    colors: [
                                      AppTheme.darkTeal.withValues(alpha: 1.0),
                                      AppTheme.darkTeal.withValues(alpha: 0.90),
                                      AppTheme.darkTeal.withValues(alpha: 0.55),
                                      AppTheme.darkTeal.withValues(alpha: 0.25),
                                    ],
                                    stops: const [0.0, 0.38, 0.72, 1.0],
                                  ),
                                ),
                              ),
                            ),

                            Padding(
                              padding: const EdgeInsets.all(20),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.verified_rounded,
                                        color: AppTheme.turquoise,
                                        size: 21,
                                      ),
                                      SizedBox(width: 7),
                                      Text(
                                        'عضوية المكتبة',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 20,
                                          fontWeight: FontWeight.w800,
                                        ),
                                      ),
                                    ],
                                  ),

                                  const SizedBox(height: 8),

                                  const Text(
                                    'عرض خطط العضوية',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 13,
                                    ),
                                  ),

                                  const SizedBox(height: 3),

                                  Text(
                                    'تنتهي في 15 ديسمبر 2026',
                                    style: TextStyle(
                                      color: Colors.white.withValues(
                                        alpha: 0.78,
                                      ),
                                      fontSize: 12,
                                    ),
                                  ),

                                  const SizedBox(height: 15),

                                  OutlinedButton(
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              const MembershipScreen(),
                                        ),
                                      );
                                    },
                                    style: OutlinedButton.styleFrom(
                                      foregroundColor: Colors.white,
                                      side: BorderSide(
                                        color: Colors.white.withValues(
                                          alpha: 0.55,
                                        ),
                                      ),
                                    ),
                                    child: const Text('تفاصيل العضوية'),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 14),

                    // =====================================================
                    // QUICK STATS
                    // =====================================================
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: GridView.count(
                        crossAxisCount: 2,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        childAspectRatio: 2.15,
                        children: const [
                          _StatCard(
                            icon: Icons.menu_book_rounded,
                            number: '—',
                            label: 'كتب مستعارة',
                          ),
                          _StatCard(
                            icon: Icons.calendar_month_outlined,
                            number: '—',
                            label: 'حجز نشط',
                          ),
                          _StatCard(
                            icon: Icons.schedule_rounded,
                            number: '—',
                            label: 'قريبة للإرجاع',
                          ),
                          _StatCard(
                            icon: Icons.warning_amber_rounded,
                            number: '—',
                            label: 'متأخرة',
                            warning: true,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 26),

                    // =====================================================
                    // TODAY
                    // =====================================================
                    const _SectionTitle(title: 'اليوم'),

                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        children: const [
                          _TodayCard(
                            icon: Icons.menu_book_rounded,
                            title: 'Clean Code',
                            subtitle: 'موعد الإرجاع: 18 سبتمبر • متبقي 5 أيام',
                          ),

                          SizedBox(height: 10),

                          _TodayCard(
                            icon: Icons.meeting_room_outlined,
                            title: 'حجز غرفة الدراسة 3',
                            subtitle: 'اليوم • 2:00 م - 4:00 م',
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 27),

                    // =====================================================
                    // LATEST BOOKS - 6 BOOKS / 2 PER ROW
                    // =====================================================
                    _SectionTitle(
                      title: 'أحدث الكتب',
                      subtitle: 'وصل حديثاً إلى المنارة',
                      actionText: 'عرض المزيد',
                      onAction: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const BooksScreen(),
                          ),
                        );
                      },
                    ),

                    _BooksGrid(books: latestBooks.take(6).toList()),

                    const SizedBox(height: 32),

                    // =====================================================
                    // MOST BORROWED - 6 BOOKS / 2 PER ROW
                    // =====================================================
                    _SectionTitle(
                      title: 'متاح للاستعارة',
                      subtitle: 'كتب تتوفر منها نسخ حالياً',
                      actionText: 'عرض المزيد',
                      onAction: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const BooksScreen(),
                          ),
                        );
                      },
                    ),

                    _BooksGrid(books: mostBorrowedBooks),

                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
    );
  }
}

// =============================================================
// BOOK MODEL
// =============================================================

// =============================================================
// SECTION TITLE
// =============================================================

class _SectionTitle extends StatelessWidget {
  final String title;
  final String? subtitle;
  final String? actionText;
  final VoidCallback? onAction;

  const _SectionTitle({
    required this.title,
    this.subtitle,
    this.actionText,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 13),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 21,
                    fontWeight: FontWeight.w800,
                    color: colors.onSurface,
                  ),
                ),

                if (subtitle != null) ...[
                  const SizedBox(height: 3),
                  Text(
                    subtitle!,
                    style: TextStyle(
                      fontSize: 11,
                      color: colors.onSurfaceVariant,
                    ),
                  ),
                ],
              ],
            ),
          ),

          if (actionText != null)
            TextButton(
              onPressed: onAction,
              child: Text(
                actionText!,
                style: const TextStyle(
                  color: AppTheme.turquoise,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// =============================================================
// STAT CARD
// =============================================================

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String number;
  final String label;
  final bool warning;

  const _StatCard({
    required this.icon,
    required this.number,
    required this.label,
    this.warning = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: theme.dividerColor),
      ),
      child: Row(
        children: [
          Container(
            width: 41,
            height: 41,
            decoration: BoxDecoration(
              color: warning
                  ? Colors.red.withValues(alpha: 0.10)
                  : AppTheme.turquoise.withValues(alpha: 0.11),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: warning ? Colors.redAccent : AppTheme.turquoise,
              size: 22,
            ),
          ),

          const SizedBox(width: 11),

          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                number,
                style: TextStyle(
                  color: colors.onSurface,
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                ),
              ),
              Text(
                label,
                style: TextStyle(color: colors.onSurfaceVariant, fontSize: 11),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// =============================================================
// TODAY CARD
// =============================================================

class _TodayCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _TodayCard({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(17),
        border: Border.all(color: theme.dividerColor),
      ),
      child: Row(
        children: [
          Container(
            width: 43,
            height: 43,
            decoration: BoxDecoration(
              color: AppTheme.turquoise.withValues(alpha: 0.11),
              borderRadius: BorderRadius.circular(12),
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
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: colors.onSurfaceVariant,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),

          Icon(Icons.chevron_left_rounded, color: colors.onSurfaceVariant),
        ],
      ),
    );
  }
}

// =============================================================
// BOOKS GRID
// =============================================================

class _BooksGrid extends StatelessWidget {
  final List<LibraryBook> books;

  const _BooksGrid({required this.books});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: books.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 13,
        mainAxisSpacing: 15,
        childAspectRatio: 0.66,
      ),
      itemBuilder: (context, index) {
        return _BookCard(book: books[index]);
      },
    );
  }
}

// =============================================================
// BOOK CARD
// =============================================================

class _BookCard extends StatelessWidget {
  final LibraryBook book;

  const _BookCard({required this.book});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => BookDetailsScreen(book: book),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(9),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: theme.dividerColor),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // BOOK COVER
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: book.coverColor,
                  borderRadius: BorderRadius.circular(13),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(13),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.auto_stories_rounded,
                        color: Colors.white70,
                        size: 31,
                      ),

                      const SizedBox(height: 11),

                      Text(
                        book.title,
                        textAlign: TextAlign.center,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          height: 1.2,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 10),

            Text(
              book.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: colors.onSurface,
                fontSize: 13,
                fontWeight: FontWeight.w800,
              ),
            ),

            const SizedBox(height: 3),

            Text(
              book.author,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(color: colors.onSurfaceVariant, fontSize: 11),
            ),

            const SizedBox(height: 8),

            Row(
              children: [
                Container(
                  width: 7,
                  height: 7,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: book.available ? Colors.green : Colors.orange,
                  ),
                ),

                const SizedBox(width: 5),

                Text(
                  book.available ? 'متاح' : 'غير متاح',
                  style: TextStyle(
                    color: book.available ? Colors.green : Colors.orange,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),

                const Spacer(),

                Icon(
                  Icons.bookmark_border_rounded,
                  size: 20,
                  color: colors.onSurfaceVariant,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
