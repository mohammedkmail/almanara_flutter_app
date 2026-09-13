import 'package:flutter/material.dart';

import '../theme/theme_controller.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  static const Color brandTeal = Color(0xFF0B4F4C);
  static const Color turquoise = Color(0xFF20B8B2);

  static const List<BookItem> latestBooks = [
    BookItem(
      title: 'Clean Code',
      author: 'Robert C. Martin',
      category: 'برمجة',
      available: true,
      coverColor: Color(0xFF123C3A),
    ),
    BookItem(
      title: 'Atomic Habits',
      author: 'James Clear',
      category: 'تطوير ذاتي',
      available: true,
      coverColor: Color(0xFFE8DED0),
    ),
    BookItem(
      title: 'Database Systems',
      author: 'Ramez Elmasri',
      category: 'قواعد بيانات',
      available: true,
      coverColor: Color(0xFF16364B),
    ),
    BookItem(
      title: 'Design Patterns',
      author: 'Erich Gamma',
      category: 'برمجة',
      available: false,
      coverColor: Color(0xFF1F3234),
    ),
    BookItem(
      title: 'Thinking, Fast and Slow',
      author: 'Daniel Kahneman',
      category: 'فكر',
      available: true,
      coverColor: Color(0xFFD9D0C2),
    ),
    BookItem(
      title: 'The Pragmatic Programmer',
      author: 'Andrew Hunt',
      category: 'برمجة',
      available: true,
      coverColor: Color(0xFF171717),
    ),
  ];

  static const List<BookItem> mostBorrowedBooks = [
    BookItem(
      title: 'The Pragmatic Programmer',
      author: 'Andrew Hunt',
      category: 'برمجة',
      available: true,
      coverColor: Color(0xFF171717),
    ),
    BookItem(
      title: 'Clean Architecture',
      author: 'Robert C. Martin',
      category: 'برمجة',
      available: false,
      coverColor: Color(0xFF274A46),
    ),
    BookItem(
      title: 'Atomic Habits',
      author: 'James Clear',
      category: 'تطوير ذاتي',
      available: true,
      coverColor: Color(0xFFE8DED0),
    ),
    BookItem(
      title: 'Database Systems',
      author: 'Ramez Elmasri',
      category: 'قواعد بيانات',
      available: true,
      coverColor: Color(0xFF16364B),
    ),
    BookItem(
      title: 'Design Patterns',
      author: 'Erich Gamma',
      category: 'برمجة',
      available: true,
      coverColor: Color(0xFF1F3234),
    ),
    BookItem(
      title: 'فن اللامبالاة',
      author: 'Mark Manson',
      category: 'تطوير ذاتي',
      available: true,
      coverColor: Color(0xFFB46D43),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Directionality(
          textDirection: TextDirection.rtl,
          child: ListView(
            padding: const EdgeInsets.only(bottom: 30),
            children: [
              // =====================================================
              // TOP BAR
              // =====================================================
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  18,
                  14,
                  18,
                  8,
                ),
                child: Row(
                  children: [
                    Container(
                      width: 46,
                      height: 46,
                      decoration: BoxDecoration(
                        color: brandTeal,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(
                        Icons.menu_book_rounded,
                        color: turquoise,
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
                        final bool isDark =
                            mode == ThemeMode.dark;

                        return IconButton(
                          tooltip:
                          isDark ? 'الوضع النهاري' : 'الوضع الداكن',
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
                          onPressed: () {},
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
                      backgroundColor: brandTeal,
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
                padding: const EdgeInsets.fromLTRB(
                  20,
                  16,
                  20,
                  5,
                ),
                child: Text(
                  'صباح الخير، هادي',
                  style: TextStyle(
                    fontSize: 27,
                    fontWeight: FontWeight.w800,
                    color: colors.onSurface,
                  ),
                ),
              ),

              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                ),
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
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                ),
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'ابحث عن كتاب، مؤلف، أو موضوع...',
                    prefixIcon: const Icon(
                      Icons.search_rounded,
                    ),
                    suffixIcon: IconButton(
                      onPressed: () {},
                      icon: const Icon(
                        Icons.tune_rounded,
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // =====================================================
              // MEMBERSHIP
              // =====================================================
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                ),
                child: Container(
                  height: 180,
                  clipBehavior: Clip.antiAlias,
                  decoration: BoxDecoration(
                    color: brandTeal,
                    borderRadius: BorderRadius.circular(22),
                  ),
                  child: Stack(
                    children: [
                      Positioned.fill(
                        child: Image.asset(
                          'assets/images/home_hero_img.png',
                          fit: BoxFit.cover,
                          errorBuilder: (
                              context,
                              error,
                              stackTrace,
                              ) {
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
                            brandTeal.withValues(alpha: 1.0),
                            brandTeal.withValues(alpha: 0.90),
                            brandTeal.withValues(alpha: 0.55),
                            brandTeal.withValues(alpha: 0.25),
                          ],
                          stops: const [
                            0.0,
                            0.38,
                            0.72,
                            1.0,
                          ],
                        ),
                      ),
                    ),
                  ),

                      Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment:
                          CrossAxisAlignment.start,
                          mainAxisAlignment:
                          MainAxisAlignment.center,
                          children: [
                            const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.verified_rounded,
                                  color: turquoise,
                                  size: 21,
                                ),
                                SizedBox(width: 7),
                                Text(
                                  'عضويتك فعّالة',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 20,
                                    fontWeight:
                                    FontWeight.w800,
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 8),

                            const Text(
                              'عضو طالب',
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
                              onPressed: () {},
                              style: OutlinedButton.styleFrom(
                                foregroundColor: Colors.white,
                                side: BorderSide(
                                  color:
                                  Colors.white.withValues(
                                    alpha: 0.55,
                                  ),
                                ),
                              ),
                              child: const Text(
                                'تفاصيل العضوية',
                              ),
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
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                ),
                child: GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics:
                  const NeverScrollableScrollPhysics(),
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 2.15,
                  children: const [
                    _StatCard(
                      icon: Icons.menu_book_rounded,
                      number: '3',
                      label: 'كتب مستعارة',
                    ),
                    _StatCard(
                      icon: Icons.calendar_month_outlined,
                      number: '1',
                      label: 'حجز نشط',
                    ),
                    _StatCard(
                      icon: Icons.schedule_rounded,
                      number: '2',
                      label: 'قريبة للإرجاع',
                    ),
                    _StatCard(
                      icon: Icons.warning_amber_rounded,
                      number: '0',
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
              const _SectionTitle(
                title: 'اليوم',
              ),

              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                ),
                child: Column(
                  children: const [
                    _TodayCard(
                      icon: Icons.menu_book_rounded,
                      title: 'Clean Code',
                      subtitle:
                      'موعد الإرجاع: 18 سبتمبر • متبقي 5 أيام',
                    ),

                    SizedBox(height: 10),

                    _TodayCard(
                      icon: Icons.meeting_room_outlined,
                      title: 'حجز غرفة الدراسة 3',
                      subtitle:
                      'اليوم • 2:00 م - 4:00 م',
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 27),

              // =====================================================
              // CATEGORIES - SMALL FILTERS ONLY
              // =====================================================
              _SectionTitle(
                title: 'التصنيفات',
                actionText: 'عرض الكل',
                onAction: () {},
              ),

              SizedBox(
                height: 43,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                  ),
                  children: const [
                    _CategoryChip(
                      label: 'برمجة',
                      icon: Icons.code_rounded,
                    ),
                    _CategoryChip(
                      label: 'علوم',
                      icon: Icons.science_outlined,
                    ),
                    _CategoryChip(
                      label: 'تاريخ',
                      icon: Icons.history_edu_outlined,
                    ),
                    _CategoryChip(
                      label: 'أدب',
                      icon: Icons.auto_stories_outlined,
                    ),
                    _CategoryChip(
                      label: 'تطوير ذاتي',
                      icon: Icons.psychology_alt_outlined,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 28),

              // =====================================================
              // LATEST BOOKS - 6 BOOKS / 2 PER ROW
              // =====================================================
              _SectionTitle(
                title: 'أحدث الكتب',
                subtitle: 'وصل حديثاً إلى المنارة',
                actionText: 'عرض المزيد',
                onAction: () {},
              ),

              _BooksGrid(
                books: latestBooks,
              ),

              const SizedBox(height: 32),

              // =====================================================
              // MOST BORROWED - 6 BOOKS / 2 PER ROW
              // =====================================================
              _SectionTitle(
                title: 'الأكثر استعارة',
                subtitle: 'الأكثر قراءة بين أعضاء المكتبة',
                actionText: 'عرض المزيد',
                onAction: () {},
              ),

              _BooksGrid(
                books: mostBorrowedBooks,
              ),

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

class BookItem {
  final String title;
  final String author;
  final String category;
  final bool available;
  final Color coverColor;

  const BookItem({
    required this.title,
    required this.author,
    required this.category,
    required this.available,
    required this.coverColor,
  });
}

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
      padding: const EdgeInsets.fromLTRB(
        20,
        0,
        20,
        13,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,
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
                      color:
                      colors.onSurfaceVariant,
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
                  color: HomeScreen.turquoise,
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
      padding: const EdgeInsets.symmetric(
        horizontal: 14,
        vertical: 12,
      ),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: theme.dividerColor,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 41,
            height: 41,
            decoration: BoxDecoration(
              color: warning
                  ? Colors.red.withValues(alpha: 0.10)
                  : HomeScreen.turquoise
                  .withValues(alpha: 0.11),
              borderRadius:
              BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: warning
                  ? Colors.redAccent
                  : HomeScreen.turquoise,
              size: 22,
            ),
          ),

          const SizedBox(width: 11),

          Column(
            mainAxisAlignment:
            MainAxisAlignment.center,
            crossAxisAlignment:
            CrossAxisAlignment.start,
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
                style: TextStyle(
                  color: colors.onSurfaceVariant,
                  fontSize: 11,
                ),
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
        border: Border.all(
          color: theme.dividerColor,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 43,
            height: 43,
            decoration: BoxDecoration(
              color: HomeScreen.turquoise
                  .withValues(alpha: 0.11),
              borderRadius:
              BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: HomeScreen.turquoise,
            ),
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,
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
                    color:
                    colors.onSurfaceVariant,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),

          Icon(
            Icons.chevron_left_rounded,
            color: colors.onSurfaceVariant,
          ),
        ],
      ),
    );
  }
}

// =============================================================
// CATEGORY CHIP
// =============================================================

class _CategoryChip extends StatelessWidget {
  final String label;
  final IconData icon;

  const _CategoryChip({
    required this.label,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Container(
      margin: const EdgeInsets.only(left: 8),
      padding: const EdgeInsets.symmetric(
        horizontal: 14,
      ),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(13),
        border: Border.all(
          color: theme.dividerColor,
        ),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.circle,
            size: 0,
          ),
          Icon(
            icon,
            size: 17,
            color: HomeScreen.turquoise,
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              color: colors.onSurface,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

// =============================================================
// BOOKS GRID
// =============================================================

class _BooksGrid extends StatelessWidget {
  final List<BookItem> books;

  const _BooksGrid({
    required this.books,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.symmetric(
        horizontal: 20,
      ),
      shrinkWrap: true,
      physics:
      const NeverScrollableScrollPhysics(),
      itemCount: books.length,
      gridDelegate:
      const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 13,
        mainAxisSpacing: 15,
        childAspectRatio: 0.66,
      ),
      itemBuilder: (context, index) {
        return _BookCard(
          book: books[index],
        );
      },
    );
  }
}

// =============================================================
// BOOK CARD
// =============================================================

class _BookCard extends StatelessWidget {
  final BookItem book;

  const _BookCard({
    required this.book,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: () {
        // لاحقاً:
        // Navigator.push(... BookDetailsScreen(book: book));
      },
      child: Container(
        padding: const EdgeInsets.all(9),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: theme.dividerColor,
          ),
        ),
        child: Column(
          crossAxisAlignment:
          CrossAxisAlignment.start,
          children: [
            // BOOK COVER
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: book.coverColor,
                  borderRadius:
                  BorderRadius.circular(13),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(13),
                  child: Column(
                    mainAxisAlignment:
                    MainAxisAlignment.center,
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
                        overflow:
                        TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          height: 1.2,
                          fontWeight:
                          FontWeight.w800,
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
              style: TextStyle(
                color: colors.onSurfaceVariant,
                fontSize: 11,
              ),
            ),

            const SizedBox(height: 8),

            Row(
              children: [
                Container(
                  width: 7,
                  height: 7,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: book.available
                        ? Colors.green
                        : Colors.orange,
                  ),
                ),

                const SizedBox(width: 5),

                Text(
                  book.available
                      ? 'متاح'
                      : 'غير متاح',
                  style: TextStyle(
                    color: book.available
                        ? Colors.green
                        : Colors.orange,
                    fontSize: 11,
                    fontWeight:
                    FontWeight.w600,
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