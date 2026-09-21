import 'package:flutter/material.dart';

import '../models/api_models.dart';
import '../models/library_book.dart';
import '../services/library_service.dart';
import '../theme/app_theme.dart';
import '../widgets/api_error_view.dart';
import '../widgets/manara_components.dart';
import 'authors_screen.dart';
import 'book_details_screen.dart';
import 'categories_screen.dart';

class BooksScreen extends StatefulWidget {
  final int? initialCategoryId;
  final int? initialAuthorId;

  const BooksScreen({
    super.key,
    this.initialCategoryId,
    this.initialAuthorId,
  });

  @override
  State<BooksScreen> createState() => _BooksScreenState();
}

class _BooksScreenState extends State<BooksScreen> {
  final _searchController = TextEditingController();

  late Future<_CatalogData> _future;

  int? _categoryId;
  bool _availableOnly = false;
  bool _digitalOnly = false;

  @override
  void initState() {
    super.initState();

    _categoryId = widget.initialCategoryId;

    _reload();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _reload() {
    _future = _fetch();
  }

  Future<_CatalogData> _fetch() async {
    final results = await Future.wait([
      LibraryService.instance.books(
        categoryId: _categoryId,
        authorId: widget.initialAuthorId,
        availableOnly: _availableOnly ? true : null,
        digitalOnly: _digitalOnly ? true : null,
      ),
      LibraryService.instance.categories(),
    ]);

    return _CatalogData(
      books: results[0] as List<LibraryBook>,
      categories: results[1] as List<CategoryItem>,
    );
  }

  List<LibraryBook> _filter(List<LibraryBook> source) {
    final q = _searchController.text.trim().toLowerCase();

    if (q.isEmpty) {
      return source;
    }

    return source.where((book) {
      return book.title.toLowerCase().contains(q) ||
          book.author.toLowerCase().contains(q) ||
          book.category.toLowerCase().contains(q) ||
          book.isbn.toLowerCase().contains(q);
    }).toList();
  }

  void _applyServerFilter() {
    setState(_reload);
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: AppTheme.teal,
          foregroundColor: Colors.white,
          elevation: 0,
          surfaceTintColor: Colors.transparent,
          title: const Text(
            'اكتشف الكتب',
            style: TextStyle(
              fontSize: 21,
              fontWeight: FontWeight.w900,
              color: Colors.white,
            ),
          ),
          actions: [
            IconButton(
              tooltip: 'المؤلفون',
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const AuthorsScreen(),
                ),
              ),
              icon: const Icon(
                Icons.person_search_outlined,
                size: 28,
              ),
            ),
            IconButton(
              tooltip: 'الأقسام',
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const CategoriesScreen(),
                ),
              ),
              icon: const Icon(
                Icons.grid_view_rounded,
                size: 28,
              ),
            ),
            const SizedBox(width: 8),
          ],
        ),
        body: FutureBuilder<_CatalogData>(
          future: _future,
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            if (snapshot.hasError) {
              return ApiErrorView(
                error: snapshot.error!,
                retry: () => setState(_reload),
              );
            }

            final data = snapshot.data!;
            final shown = _filter(data.books);

            return RefreshIndicator(
              onRefresh: () async {
                setState(_reload);
                await _future;
              },
              child: CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: [
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(
                      18,
                      16,
                      18,
                      0,
                    ),
                    sliver: SliverToBoxAdapter(
                      child: Column(
                        children: [
                          TextField(
                            controller: _searchController,
                            onChanged: (_) => setState(() {}),
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                            decoration: InputDecoration(
                              hintText: 'عنوان، مؤلف، قسم أو ISBN',
                              hintStyle: const TextStyle(
                                fontSize: 14,
                                color: AppTheme.muted,
                              ),
                              prefixIcon: const Icon(
                                Icons.search_rounded,
                                size: 25,
                              ),
                              suffixIcon:
                              _searchController.text.isNotEmpty
                                  ? IconButton(
                                onPressed: () {
                                  _searchController.clear();
                                  setState(() {});
                                },
                                icon: const Icon(
                                  Icons.close_rounded,
                                  size: 23,
                                ),
                              )
                                  : null,
                            ),
                          ),
                          const SizedBox(height: 14),
                          SizedBox(
                            height: 44,
                            child: ListView(
                              scrollDirection: Axis.horizontal,
                              children: [
                                _FilterChip(
                                  label: 'كل الكتب',
                                  selected: _categoryId == null,
                                  onTap: () {
                                    _categoryId = null;
                                    _applyServerFilter();
                                  },
                                ),
                                ...data.categories.map(
                                      (category) => _FilterChip(
                                    label: category.name,
                                    selected:
                                    _categoryId == category.id,
                                    onTap: () {
                                      _categoryId = category.id;
                                      _applyServerFilter();
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              FilterChip(
                                label: const Text(
                                  'متاح الآن',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                selected: _availableOnly,
                                onSelected: (value) {
                                  _availableOnly = value;
                                  _applyServerFilter();
                                },
                              ),
                              const SizedBox(width: 8),
                              FilterChip(
                                label: const Text(
                                  'نسخة رقمية',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                selected: _digitalOnly,
                                onSelected: (value) {
                                  _digitalOnly = value;
                                  _applyServerFilter();
                                },
                              ),
                              const Spacer(),
                              Text(
                                '${shown.length} نتيجة',
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: AppTheme.muted,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 18),
                        ],
                      ),
                    ),
                  ),
                  if (shown.isEmpty)
                    const SliverFillRemaining(
                      hasScrollBody: false,
                      child: ManaraEmptyState(
                        icon: Icons.search_off_rounded,
                        title: 'لا توجد نتائج بهذه المواصفات',
                        message:
                        'غيّر القسم أو أزل أحد الفلاتر وجرب من جديد.',
                      ),
                    )
                  else
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(
                        18,
                        0,
                        18,
                        30,
                      ),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate(
                              (context, index) {
                            final book = shown[index];

                            return Padding(
                              padding: const EdgeInsets.only(
                                bottom: 20,
                              ),
                              child: SizedBox(
                                width: double.infinity,
                                height: 570,
                                child: _CatalogBookCard(
                                  book: book,
                                  onTap: () => Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) =>
                                          BookDetailsScreen(
                                            book: book,
                                          ),
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                          childCount: shown.length,
                        ),
                      ),
                    ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _CatalogData {
  final List<LibraryBook> books;
  final List<CategoryItem> categories;

  const _CatalogData({
    required this.books,
    required this.categories,
  });
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 8),
      child: ChoiceChip(
        label: Text(
          label,
          style: TextStyle(
            fontSize: 12.5,
            fontWeight: selected
                ? FontWeight.w900
                : FontWeight.w700,
            color: selected
                ? AppTheme.teal
                : AppTheme.muted,
          ),
        ),
        selected: selected,
        onSelected: (_) => onTap(),
        selectedColor: const Color(0xFFDCEEEA),
        backgroundColor: Colors.white,
        side: BorderSide(
          color: selected
              ? AppTheme.teal.withOpacity(0.25)
              : AppTheme.border,
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: 7,
          vertical: 7,
        ),
      ),
    );
  }
}

class _CatalogBookCard extends StatefulWidget {
  final LibraryBook book;
  final VoidCallback onTap;

  const _CatalogBookCard({
    required this.book,
    required this.onTap,
  });

  @override
  State<_CatalogBookCard> createState() =>
      _CatalogBookCardState();
}

class _CatalogBookCardState
    extends State<_CatalogBookCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final book = widget.book;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) {
        setState(() {
          _hovered = true;
        });
      },
      onExit: (_) {
        setState(() {
          _hovered = false;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOut,
        transform: Matrix4.translationValues(
          0,
          _hovered ? -7 : 0,
          0,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: _hovered
                ? AppTheme.teal.withOpacity(0.45)
                : AppTheme.border,
            width: _hovered ? 1.3 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(
                _hovered ? 0.12 : 0.045,
              ),
              blurRadius: _hovered ? 22 : 9,
              offset: Offset(
                0,
                _hovered ? 10 : 3,
              ),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: widget.onTap,
            borderRadius: BorderRadius.circular(20),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    height: 360,
                    child: ManaraImage(
                      url: book.coverUrl,
                      width: double.infinity,
                      height: 360,
                      borderRadius: BorderRadius.zero,
                    ),
                  ),
                  Expanded(
                    child: Container(
                      width: double.infinity,
                      color: const Color(0xFFE3F2EF),
                      padding: const EdgeInsets.fromLTRB(
                        24,
                        18,
                        24,
                        18,
                      ),
                      child: Column(
                        mainAxisAlignment:
                        MainAxisAlignment.center,
                        crossAxisAlignment:
                        CrossAxisAlignment.center,
                        children: [
                          Text(
                            book.title,
                            maxLines: 2,
                            textAlign: TextAlign.center,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 21,
                              fontWeight: FontWeight.w900,
                              height: 1.2,
                              color: AppTheme.ink,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            book.author,
                            maxLines: 1,
                            textAlign: TextAlign.center,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 14,
                              color: AppTheme.muted,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 14),
                          Wrap(
                            alignment: WrapAlignment.center,
                            spacing: 12,
                            runSpacing: 8,
                            children: [
                              _LargeStatusChip(
                                label: book.available
                                    ? '${book.availableCopies} متاحة'
                                    : 'انتظار',
                                color: book.available
                                    ? AppTheme.teal
                                    : const Color(0xFF9B6F31),
                                icon: book.available
                                    ? Icons.check_circle_outline
                                    : Icons.hourglass_bottom_rounded,
                              ),
                              if (book.digitalAvailable)
                                const _LargeStatusChip(
                                  label: 'رقمي',
                                  color: Color(0xFF5966A6),
                                  icon: Icons.tablet_mac_outlined,
                                ),
                            ],
                          ),
                          const SizedBox(height: 13),
                          Text(
                            book.borrowingIncluded
                                ? 'الاستعارة مجانية لعضويتك'
                                : 'استعارة ${book.userBorrowingFee.toStringAsFixed(2)} USD',
                            maxLines: 1,
                            textAlign: TextAlign.center,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 14,
                              color: book.borrowingIncluded
                                  ? AppTheme.teal
                                  : AppTheme.ink,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          if (book.physicalSalePrice != null &&
                              book.physicalSaleStock > 0)
                            Padding(
                              padding: const EdgeInsets.only(
                                top: 5,
                              ),
                              child: Text(
                                'شراء ${book.physicalSalePrice!.toStringAsFixed(2)} USD',
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontSize: 12.5,
                                  color: AppTheme.muted,
                                  fontWeight: FontWeight.w700,
                                ),
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
        ),
      ),
    );
  }
}

class _LargeStatusChip extends StatelessWidget {
  final String label;
  final Color color;
  final IconData icon;

  const _LargeStatusChip({
    required this.label,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 4,
        vertical: 3,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 23,
            color: color,
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w900,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}