import 'package:flutter/material.dart';

import '../../models/api_models.dart';
import '../../models/library_book.dart';
import '../../services/library_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/api_error_view.dart';
import '../../widgets/manara_components.dart';

class AdminBookCopiesScreen extends StatefulWidget {
  final LibraryBook? book;
  const AdminBookCopiesScreen({super.key, this.book});

  @override
  State<AdminBookCopiesScreen> createState() => _AdminBookCopiesScreenState();
}

class _AdminBookCopiesScreenState extends State<AdminBookCopiesScreen> {
  late Future<List<BookCopyItem>> _future;

  @override
  void initState() {
    super.initState();
    _reload();
  }

  void _reload() {
    _future = LibraryService.instance.adminBookCopies(bookId: widget.book?.id);
  }

  Future<void> _refresh() async {
    setState(_reload);
    await _future;
  }

  void _snack(String text) {
    if (mounted)
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  }

  Future<void> _add() async {
    LibraryBook? selectedBook = widget.book;
    final code = TextEditingController();
    List<LibraryBook> books = const [];
    if (selectedBook == null) {
      try {
        books = await LibraryService.instance.books();
      } catch (e) {
        _snack(apiErrorMessage(e));
        code.dispose();
        return;
      }
    }
    if (!mounted) return;
    final ok = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (sheetContext) => StatefulBuilder(
        builder: (context, setSheetState) => Padding(
          padding: EdgeInsets.fromLTRB(
            18,
            0,
            18,
            20 + MediaQuery.viewInsetsOf(context).bottom,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'إضافة نسخة ورقية',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 14),
              if (widget.book == null)
                DropdownButtonFormField<int>(
                  isExpanded: true,
                  initialValue: selectedBook?.id,
                  decoration: const InputDecoration(labelText: 'الكتاب'),
                  items: books
                      .where((e) => e.id != null && e.active)
                      .map(
                        (book) => DropdownMenuItem(
                          value: book.id!,
                          child: Text(
                            book.title,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      )
                      .toList(),
                  onChanged: (id) {
                    setSheetState(() {
                      selectedBook = null;
                      for (final book in books) {
                        if (book.id == id) {
                          selectedBook = book;
                          break;
                        }
                      }
                    });
                  },
                )
              else
                Text(
                  widget.book!.title,
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
              const SizedBox(height: 12),
              TextField(
                controller: code,
                decoration: const InputDecoration(
                  labelText: 'رمز النسخة',
                  hintText: 'مثال: BK-00041',
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    if (selectedBook?.id == null || code.text.trim().isEmpty)
                      return;
                    Navigator.pop(sheetContext, true);
                  },
                  child: const Text('إضافة النسخة'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
    if (ok != true || selectedBook?.id == null) {
      code.dispose();
      return;
    }
    try {
      await LibraryService.instance.adminSaveBookCopy(
        bookId: selectedBook!.id!,
        copyCode: code.text.trim(),
      );
      _snack('تمت إضافة النسخة.');
      await _refresh();
    } catch (e) {
      _snack(apiErrorMessage(e));
    } finally {
      code.dispose();
    }
  }

  Future<void> _changeStatus(BookCopyItem item) async {
    if (item.operationallyLocked) {
      _snack('حالة هذه النسخة يديرها نظام الإعارة أو الحجز تلقائياً.');
      return;
    }
    final status = await showModalBottomSheet<String>(
      context: context,
      showDragHandle: true,
      builder: (context) => ListView(
        shrinkWrap: true,
        padding: const EdgeInsets.fromLTRB(18, 0, 18, 24),
        children: [
          const Text(
            'حالة النسخة',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 8),
          for (final value in const ['AVAILABLE', 'LOST', 'DAMAGED'])
            ListTile(
              title: Text(_copyStatus(value)),
              trailing: item.status == value
                  ? const Icon(Icons.check_circle, color: AppTheme.teal)
                  : null,
              onTap: () => Navigator.pop(context, value),
            ),
        ],
      ),
    );
    if (status == null) return;
    try {
      await LibraryService.instance.adminUpdateBookCopy(item.id, {
        'status': status,
      });
      await _refresh();
    } catch (e) {
      _snack(apiErrorMessage(e));
    }
  }

  Future<void> _delete(BookCopyItem item) async {
    final ok =
        await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('حذف النسخة؟'),
            content: Text(
              item.hasHistory
                  ? 'هذه النسخة مرتبطة بسجل سابق ولن يسمح النظام بحذفها.'
                  : 'سيتم حذف النسخة ${item.copyCode} نهائياً.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('رجوع'),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('حذف'),
              ),
            ],
          ),
        ) ??
        false;
    if (!ok) return;
    try {
      await LibraryService.instance.adminDeleteBookCopy(item.id);
      _snack('تم حذف النسخة.');
      await _refresh();
    } catch (e) {
      _snack(apiErrorMessage(e));
    }
  }

  @override
  Widget build(BuildContext context) => Directionality(
    textDirection: TextDirection.rtl,
    child: Scaffold(
      appBar: AppBar(
        title: Text(
          widget.book == null ? 'نسخ الكتب' : 'نسخ ${widget.book!.title}',
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: null,
        onPressed: _add,
        icon: const Icon(Icons.add_rounded),
        label: const Text('نسخة جديدة'),
      ),
      body: FutureBuilder<List<BookCopyItem>>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done)
            return const Center(child: CircularProgressIndicator());
          if (snapshot.hasError)
            return ApiErrorView(
              error: snapshot.error!,
              retry: () => setState(_reload),
            );
          final items = snapshot.data!;
          return RefreshIndicator(
            onRefresh: _refresh,
            child: items.isEmpty
                ? ListView(
                    children: const [
                      ManaraEmptyState(
                        icon: Icons.inventory_2_outlined,
                        title: 'لا توجد نسخ ورقية',
                        message:
                            'أضف نسخة فعلية ليصبح الكتاب قابلاً للاستعارة.',
                      ),
                    ],
                  )
                : ListView.separated(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(16, 10, 16, 90),
                    itemCount: items.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (_, index) {
                      final item = items[index];
                      final tone = switch (item.status) {
                        'AVAILABLE' => AppTheme.teal,
                        'BORROWED' => const Color(0xFF8B6A34),
                        'RESERVED' => const Color(0xFF586B9A),
                        _ => Colors.redAccent,
                      };
                      return Card(
                        child: Padding(
                          padding: const EdgeInsets.all(13),
                          child: Row(
                            children: [
                              ManaraImage(
                                url: item.bookCoverUrl,
                                width: 54,
                                height: 76,
                                borderRadius: BorderRadius.circular(9),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item.copyCode,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w900,
                                        fontSize: 16,
                                      ),
                                    ),
                                    Text(
                                      item.bookTitle,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontSize: 11,
                                        color: AppTheme.muted,
                                      ),
                                    ),
                                    const SizedBox(height: 7),
                                    ManaraStatusChip(
                                      label: _copyStatus(item.status),
                                      color: tone,
                                    ),
                                  ],
                                ),
                              ),
                              PopupMenuButton<String>(
                                onSelected: (value) {
                                  if (value == 'status') _changeStatus(item);
                                  if (value == 'delete') _delete(item);
                                },
                                itemBuilder: (_) => [
                                  const PopupMenuItem(
                                    value: 'status',
                                    child: Text('تغيير الحالة'),
                                  ),
                                  PopupMenuItem(
                                    value: 'delete',
                                    enabled:
                                        !item.hasHistory &&
                                        !item.operationallyLocked,
                                    child: const Text('حذف'),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          );
        },
      ),
    ),
  );
}

String _copyStatus(String value) => switch (value) {
  'AVAILABLE' => 'متاحة',
  'BORROWED' => 'مُعارة',
  'RESERVED' => 'محجوزة',
  'LOST' => 'مفقودة',
  'DAMAGED' => 'تالفة',
  _ => value,
};
