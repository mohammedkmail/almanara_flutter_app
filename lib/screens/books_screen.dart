import 'package:flutter/material.dart';

import '../services/library_service.dart';
import '../widgets/api_error_view.dart';
import '../models/library_book.dart';
import '../theme/app_theme.dart';
import 'book_details_screen.dart';

class BooksScreen extends StatefulWidget {
  const BooksScreen({super.key});

  @override
  State<BooksScreen> createState() => _BooksScreenState();
}

class _BooksScreenState extends State<BooksScreen> {
  final TextEditingController _searchController = TextEditingController();

  String selectedCategory = 'الكل';

  List<String> get categories => [
    'الكل',
    ...books.map((b) => b.category).where((c) => c.isNotEmpty).toSet(),
  ];
  List<LibraryBook> books = [];
  bool _loading = true;
  Object? _error;

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
      final result = await LibraryService.instance.books();
      if (mounted) {
        setState(() {
          books = result;
          selectedCategory = 'الكل';
        });
      }
    } catch (error) {
      if (mounted) setState(() => _error = error);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  List<LibraryBook> get filteredBooks {
    final String search = _searchController.text.trim().toLowerCase();

    return books.where((book) {
      final bool matchesCategory =
          selectedCategory == 'الكل' || book.category == selectedCategory;

      final bool matchesSearch =
          search.isEmpty ||
          book.title.toLowerCase().contains(search) ||
          book.author.toLowerCase().contains(search) ||
          book.category.toLowerCase().contains(search);

      return matchesCategory && matchesSearch;
    }).toList();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    final List<LibraryBook> displayedBooks = filteredBooks;

    return Scaffold(
      appBar: AppBar(
        title: const Text('الكتب'),
        actions: [
          IconButton(
            onPressed: _loading ? null : _load,
            icon: const Icon(Icons.refresh),
            tooltip: 'تحديث',
          ),
        ],
      ),
      backgroundColor: theme.scaffoldBackgroundColor,

      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
          ? ApiErrorView(error: _error!, retry: _load)
          : SafeArea(
              child: Directionality(
                textDirection: TextDirection.rtl,

                child: CustomScrollView(
                  slivers: [
                    // =============================
                    // HEADER
                    // =============================
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(20, 18, 20, 8),

                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,

                                children: [
                                  Text(
                                    'الكتب',
                                    style: TextStyle(
                                      fontSize: 29,
                                      fontWeight: FontWeight.w800,
                                      color: colors.onSurface,
                                    ),
                                  ),

                                  const SizedBox(height: 4),

                                  Text(
                                    '${displayedBooks.length} كتاب',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: colors.onSurfaceVariant,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            Container(
                              width: 44,
                              height: 44,

                              decoration: BoxDecoration(
                                color: AppTheme.turquoise.withValues(
                                  alpha: 0.12,
                                ),

                                borderRadius: BorderRadius.circular(13),
                              ),

                              child: const Icon(
                                Icons.auto_stories_outlined,
                                color: AppTheme.turquoise,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // =============================
                    // SEARCH
                    // =============================
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(20, 14, 20, 10),

                        child: TextField(
                          controller: _searchController,

                          onChanged: (_) {
                            setState(() {});
                          },

                          decoration: InputDecoration(
                            hintText: 'ابحث عن كتاب، مؤلف، أو تصنيف...',

                            prefixIcon: const Icon(Icons.search_rounded),

                            suffixIcon: _searchController.text.isEmpty
                                ? null
                                : IconButton(
                                    onPressed: () {
                                      _searchController.clear();

                                      setState(() {});
                                    },

                                    icon: const Icon(Icons.close_rounded),
                                  ),
                          ),
                        ),
                      ),
                    ),

                    // =============================
                    // CATEGORIES
                    // =============================
                    SliverToBoxAdapter(
                      child: SizedBox(
                        height: 52,

                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,

                          padding: const EdgeInsets.symmetric(horizontal: 20),

                          itemCount: categories.length,

                          separatorBuilder: (context, index) =>
                              const SizedBox(width: 8),

                          itemBuilder: (context, index) {
                            final category = categories[index];

                            final bool selected = selectedCategory == category;

                            return ChoiceChip(
                              selected: selected,

                              label: Text(category),

                              showCheckmark: false,

                              onSelected: (_) {
                                setState(() {
                                  selectedCategory = category;
                                });
                              },

                              backgroundColor: theme.cardColor,

                              selectedColor: AppTheme.turquoise.withValues(
                                alpha: 0.16,
                              ),

                              side: BorderSide(
                                color: selected
                                    ? AppTheme.turquoise
                                    : theme.dividerColor,
                              ),

                              labelStyle: TextStyle(
                                color: selected
                                    ? AppTheme.turquoise
                                    : colors.onSurface,
                                fontSize: 12,
                                fontWeight: selected
                                    ? FontWeight.w700
                                    : FontWeight.w500,
                              ),

                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            );
                          },
                        ),
                      ),
                    ),

                    // =============================
                    // SMALL TITLE
                    // =============================
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(20, 22, 20, 13),

                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                selectedCategory == 'الكل'
                                    ? 'جميع الكتب'
                                    : selectedCategory,

                                style: TextStyle(
                                  fontSize: 19,
                                  fontWeight: FontWeight.w800,
                                  color: colors.onSurface,
                                ),
                              ),
                            ),

                            Icon(
                              Icons.grid_view_rounded,
                              color: colors.onSurfaceVariant,
                              size: 20,
                            ),
                          ],
                        ),
                      ),
                    ),

                    // =============================
                    // EMPTY SEARCH RESULT
                    // =============================
                    if (displayedBooks.isEmpty)
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.only(top: 70),

                          child: Column(
                            children: [
                              Icon(
                                Icons.search_off_rounded,
                                size: 55,
                                color: colors.onSurfaceVariant,
                              ),

                              const SizedBox(height: 12),

                              Text(
                                'لم يتم العثور على كتب',
                                style: TextStyle(
                                  color: colors.onSurface,
                                  fontSize: 17,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),

                              const SizedBox(height: 5),

                              Text(
                                'جرّب البحث بكلمة أخرى',
                                style: TextStyle(
                                  color: colors.onSurfaceVariant,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                    // =============================
                    // BOOKS GRID
                    // كتابين بالسطر
                    // =============================
                    if (displayedBooks.isNotEmpty)
                      SliverPadding(
                        padding: const EdgeInsets.fromLTRB(20, 0, 20, 30),

                        sliver: SliverGrid(
                          delegate: SliverChildBuilderDelegate(
                            childCount: displayedBooks.length,

                            (context, index) {
                              final book = displayedBooks[index];

                              return _BookCard(
                                book: book,

                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          BookDetailsScreen(book: book),
                                    ),
                                  );
                                },
                              );
                            },
                          ),

                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,

                                crossAxisSpacing: 13,

                                mainAxisSpacing: 15,

                                childAspectRatio: 0.64,
                              ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
    );
  }
}

// =====================================================
// BOOK CARD
// =====================================================

class _BookCard extends StatelessWidget {
  final LibraryBook book;
  final VoidCallback onTap;

  const _BookCard({required this.book, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Material(
      color: Colors.transparent,

      child: InkWell(
        onTap: onTap,

        borderRadius: BorderRadius.circular(18),

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
              // =============================
              // COVER
              // =============================
              Expanded(
                child: Container(
                  width: double.infinity,

                  decoration: BoxDecoration(
                    color: book.coverColor,

                    borderRadius: BorderRadius.circular(13),
                  ),

                  child: Stack(
                    children: [
                      Positioned(
                        left: 10,
                        top: 10,

                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 7,
                            vertical: 4,
                          ),

                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.15),

                            borderRadius: BorderRadius.circular(8),
                          ),

                          child: Text(
                            book.category,

                            style: TextStyle(
                              color: book.darkText
                                  ? const Color(0xFF283B39)
                                  : Colors.white,

                              fontSize: 9,

                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),

                      Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 13),

                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,

                            children: [
                              Icon(
                                Icons.auto_stories_rounded,

                                color: book.darkText
                                    ? AppTheme.darkTeal
                                    : Colors.white70,

                                size: 34,
                              ),

                              const SizedBox(height: 13),

                              Text(
                                book.title,

                                textAlign: TextAlign.center,

                                maxLines: 3,

                                overflow: TextOverflow.ellipsis,

                                style: TextStyle(
                                  color: book.darkText
                                      ? const Color(0xFF273936)
                                      : Colors.white,

                                  fontSize: 14,

                                  height: 1.25,

                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 10),

              // TITLE
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

              // AUTHOR
              Text(
                book.author,

                maxLines: 1,

                overflow: TextOverflow.ellipsis,

                style: TextStyle(color: colors.onSurfaceVariant, fontSize: 11),
              ),

              const SizedBox(height: 9),

              // AVAILABLE + BOOKMARK
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

                  IconButton(
                    padding: EdgeInsets.zero,

                    constraints: const BoxConstraints(),

                    onPressed: () {
                      // المفضلة لاحقاً
                    },

                    icon: Icon(
                      Icons.bookmark_border_rounded,

                      size: 21,

                      color: colors.onSurfaceVariant,
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
