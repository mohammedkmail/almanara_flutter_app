import 'package:flutter/material.dart';

import '../../data/sample_data.dart';
import '../../models/library_book.dart';
import '../../theme/app_theme.dart';
import 'admin_book_form_screen.dart';

class AdminBooksScreen extends StatefulWidget {
  const AdminBooksScreen({super.key});

  @override
  State<AdminBooksScreen> createState() => _AdminBooksScreenState();
}

class _AdminBooksScreenState extends State<AdminBooksScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<LibraryBook> get _books {
    final query = _searchController.text.trim().toLowerCase();
    if (query.isEmpty) return SampleData.books;
    return SampleData.books.where((book) {
      return book.title.toLowerCase().contains(query) ||
          book.author.toLowerCase().contains(query) ||
          book.category.toLowerCase().contains(query);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('إدارة الكتب'),
          actions: [
            IconButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AdminBookFormScreen(),
                  ),
                );
              },
              icon: const Icon(Icons.add_rounded),
              tooltip: 'إضافة كتاب',
            ),
          ],
        ),
        body: ListView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 30),
          children: [
            TextField(
              controller: _searchController,
              onChanged: (_) => setState(() {}),
              decoration: const InputDecoration(
                hintText: 'بحث في الكتب...',
                prefixIcon: Icon(Icons.search_rounded),
              ),
            ),
            const SizedBox(height: 18),
            ..._books.map((book) => _AdminBookTile(book: book)),
            const SizedBox(height: 12),
            Text(
              'عمليات الإضافة والتعديل والحذف ستُربط بـ POST / PUT / DELETE عند توصيل API الكتب.',
              style: TextStyle(
                color: colors.onSurfaceVariant,
                fontSize: 11,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AdminBookTile extends StatelessWidget {
  final LibraryBook book;

  const _AdminBookTile({required this.book});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: theme.dividerColor)),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 54,
            decoration: BoxDecoration(
              color: book.coverColor,
              borderRadius: BorderRadius.circular(7),
            ),
            child: const Icon(Icons.menu_book_outlined, color: Colors.white70, size: 20),
          ),
          const SizedBox(width: 11),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(book.title, style: const TextStyle(fontWeight: FontWeight.w800)),
                const SizedBox(height: 3),
                Text(
                  '${book.author} • ${book.category}',
                  style: TextStyle(
                    color: theme.colorScheme.onSurfaceVariant,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AdminBookFormScreen(book: book),
                ),
              );
            },
            icon: const Icon(Icons.edit_outlined, color: AppTheme.turquoise),
          ),
          IconButton(
            onPressed: () {
              showDialog<void>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('حذف الكتاب'),
                  content: Text('هل تريد حذف ${book.title}؟'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('إلغاء'),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('سيتم تنفيذ الحذف من الـ API لاحقاً')),
                        );
                      },
                      child: const Text('حذف'),
                    ),
                  ],
                ),
              );
            },
            icon: const Icon(Icons.delete_outline),
          ),
        ],
      ),
    );
  }
}
