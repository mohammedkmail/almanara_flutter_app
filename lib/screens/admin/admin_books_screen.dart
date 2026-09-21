import 'package:flutter/material.dart';

import '../../models/library_book.dart';
import '../../services/library_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/api_error_view.dart';
import '../../widgets/manara_components.dart';
import 'admin_book_copies_screen.dart';
import 'admin_book_form_screen.dart';

class AdminBooksScreen extends StatefulWidget {
  const AdminBooksScreen({super.key});

  @override
  State<AdminBooksScreen> createState() => _AdminBooksScreenState();
}

class _AdminBooksScreenState extends State<AdminBooksScreen> {
  late Future<List<LibraryBook>> _future;
  final _search = TextEditingController();
  bool? _activeFilter;

  @override
  void initState() {
    super.initState();
    _reload();
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  void _reload() {
    _future = LibraryService.instance.books(search: _search.text.trim());
  }

  Future<void> _refresh() async {
    setState(_reload);
    await _future;
  }

  Future<void> _openForm([LibraryBook? book]) async {
    final changed = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => AdminBookFormScreen(book: book)),
    );
    if (changed == true && mounted) setState(_reload);
  }

  Future<void> _delete(LibraryBook book) async {
    final ok =
        await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('حذف أو تعطيل الكتاب؟'),
            content: const Text(
              'إذا كان الكتاب مرتبطاً بسجل سابق فسيتم تعطيله بدلاً من حذف التاريخ المرتبط به.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('رجوع'),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('متابعة'),
              ),
            ],
          ),
        ) ??
        false;
    if (!ok || book.id == null) return;
    try {
      await LibraryService.instance.deleteBook(book.id!);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('تم تطبيق الحذف/التعطيل وفق علاقات الكتاب الحالية.'),
          ),
        );
        await _refresh();
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(apiErrorMessage(error))));
      }
    }
  }

  @override
  Widget build(BuildContext context) => Directionality(
    textDirection: TextDirection.rtl,
    child: Scaffold(
      appBar: AppBar(title: const Text('إدارة الكتب')),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: null,
        onPressed: () => _openForm(),
        icon: const Icon(Icons.add_rounded),
        label: const Text('كتاب جديد'),
      ),
      body: FutureBuilder<List<LibraryBook>>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return ApiErrorView(
              error: snapshot.error!,
              retry: () => setState(_reload),
            );
          }
          final all = snapshot.data!;
          final books = all
              .where(
                (book) => _activeFilter == null || book.active == _activeFilter,
              )
              .toList();
          final inactive = all.where((e) => !e.active).length;
          final digital = all.where((e) => e.digitalAvailable).length;
          return RefreshIndicator(
            onRefresh: _refresh,
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 14),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: _BookAdminMetric(
                                label: 'كل الكتب',
                                value: all.length,
                                tone: AppTheme.teal,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: _BookAdminMetric(
                                label: 'رقمية',
                                value: digital,
                                tone: const Color(0xFF62548D),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: _BookAdminMetric(
                                label: 'معطلة',
                                value: inactive,
                                tone: Colors.redAccent,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: _search,
                          textInputAction: TextInputAction.search,
                          onChanged: (_) => setState(_reload),
                          decoration: InputDecoration(
                            hintText: 'عنوان، مؤلف أو ISBN...',
                            prefixIcon: const Icon(Icons.search_rounded),
                            suffixIcon: _search.text.isEmpty
                                ? null
                                : IconButton(
                                    onPressed: () {
                                      _search.clear();
                                      setState(_reload);
                                    },
                                    icon: const Icon(Icons.close_rounded),
                                  ),
                          ),
                        ),
                        const SizedBox(height: 9),
                        Row(
                          children: [
                            FilterChip(
                              label: const Text('الكل'),
                              selected: _activeFilter == null,
                              onSelected: (_) =>
                                  setState(() => _activeFilter = null),
                            ),
                            const SizedBox(width: 7),
                            FilterChip(
                              label: const Text('الفعالة'),
                              selected: _activeFilter == true,
                              onSelected: (_) =>
                                  setState(() => _activeFilter = true),
                            ),
                            const SizedBox(width: 7),
                            FilterChip(
                              label: const Text('المعطلة'),
                              selected: _activeFilter == false,
                              onSelected: (_) =>
                                  setState(() => _activeFilter = false),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                if (books.isEmpty)
                  const SliverToBoxAdapter(
                    child: ManaraEmptyState(
                      icon: Icons.menu_book_outlined,
                      title: 'لا توجد كتب مطابقة',
                      message: 'غيّر البحث أو الفلتر.',
                    ),
                  )
                else
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 90),
                    sliver: SliverList.separated(
                      itemCount: books.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 10),
                      itemBuilder: (_, index) {
                        final book = books[index];
                        return _AdminBookCard(
                          book: book,
                          onEdit: () => _openForm(book),
                          onCopies: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => AdminBookCopiesScreen(book: book),
                            ),
                          ),
                          onDelete: () => _delete(book),
                        );
                      },
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

class _BookAdminMetric extends StatelessWidget {
  final String label;
  final int value;
  final Color tone;
  const _BookAdminMetric({
    required this.label,
    required this.value,
    required this.tone,
  });

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: AppTheme.border),
    ),
    child: Column(
      children: [
        Text(
          '$value',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w900,
            color: tone,
          ),
        ),
        Text(
          label,
          style: const TextStyle(fontSize: 10, color: AppTheme.muted),
        ),
      ],
    ),
  );
}

class _AdminBookCard extends StatelessWidget {
  final LibraryBook book;
  final VoidCallback onEdit;
  final VoidCallback onCopies;
  final VoidCallback onDelete;
  const _AdminBookCard({
    required this.book,
    required this.onEdit,
    required this.onCopies,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(13),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ManaraImage(
            url: book.coverUrl,
            width: 76,
            height: 108,
            borderRadius: BorderRadius.circular(11),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        book.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontWeight: FontWeight.w900,
                          fontSize: 15,
                        ),
                      ),
                    ),
                    PopupMenuButton<String>(
                      padding: EdgeInsets.zero,
                      onSelected: (value) {
                        if (value == 'edit') onEdit();
                        if (value == 'copies') onCopies();
                        if (value == 'delete') onDelete();
                      },
                      itemBuilder: (_) => const [
                        PopupMenuItem(
                          value: 'edit',
                          child: Text('تعديل بيانات الكتاب'),
                        ),
                        PopupMenuItem(
                          value: 'copies',
                          child: Text('إدارة النسخ الورقية'),
                        ),
                        PopupMenuItem(
                          value: 'delete',
                          child: Text('حذف / تعطيل'),
                        ),
                      ],
                    ),
                  ],
                ),
                Text(
                  book.author,
                  style: const TextStyle(fontSize: 11, color: AppTheme.muted),
                ),
                const SizedBox(height: 7),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    ManaraStatusChip(
                      label: book.active ? 'فعال' : 'معطل',
                      color: book.active ? AppTheme.teal : Colors.redAccent,
                    ),
                    ManaraStatusChip(
                      label:
                          '${book.availableCopies}/${book.totalCopies} متاحة',
                      color: const Color(0xFF536D86),
                    ),
                    if (book.digitalAvailable)
                      const ManaraStatusChip(
                        label: 'رقمي',
                        color: Color(0xFF66518C),
                      ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'استعارة ${book.borrowingFee?.toStringAsFixed(2) ?? '—'} USD'
                  '${book.physicalSalePrice == null ? '' : ' • بيع ${book.physicalSalePrice!.toStringAsFixed(2)} USD'}',
                  style: const TextStyle(fontSize: 10.5, color: AppTheme.muted),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}
