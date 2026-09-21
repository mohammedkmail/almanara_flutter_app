import 'package:flutter/material.dart';

import '../models/api_models.dart';
import '../services/library_service.dart';
import '../theme/app_theme.dart';
import '../widgets/api_error_view.dart';
import '../widgets/manara_components.dart';
import 'book_details_screen.dart';

class AuthorDetailsScreen extends StatefulWidget {
  final int authorId;
  const AuthorDetailsScreen({super.key, required this.authorId});

  @override
  State<AuthorDetailsScreen> createState() => _AuthorDetailsScreenState();
}

class _AuthorDetailsScreenState extends State<AuthorDetailsScreen> {
  late Future<AuthorItem> _future;

  @override
  void initState() {
    super.initState();
    _future = LibraryService.instance.author(widget.authorId);
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(),
        body: FutureBuilder<AuthorItem>(
          future: _future,
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return ApiErrorView(
                error: snapshot.error!,
                retry: () => setState(() {
                  _future = LibraryService.instance.author(widget.authorId);
                }),
              );
            }
            final author = snapshot.data!;
            return ListView(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 30),
              children: [
                Center(
                  child: ManaraImage(
                    url: author.imageUrl,
                    width: 122,
                    height: 122,
                    borderRadius: BorderRadius.circular(99),
                    fallbackIcon: Icons.person_outline_rounded,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  author.name,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 27,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                if (author.nationality.trim().isNotEmpty) ...[
                  const SizedBox(height: 5),
                  Text(
                    author.nationality,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: AppTheme.muted),
                  ),
                ],
                if (author.biography.trim().isNotEmpty) ...[
                  const SizedBox(height: 24),
                  const ManaraSectionTitle(title: 'عن المؤلف'),
                  const SizedBox(height: 8),
                  Text(author.biography, style: const TextStyle(height: 1.8)),
                ],
                const SizedBox(height: 26),
                ManaraSectionTitle(
                  title: 'كتبه في المنارة',
                  subtitle: '${author.books.length} كتاب',
                ),
                const SizedBox(height: 12),
                ...author.books.map(
                  (book) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(8),
                      tileColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                        side: const BorderSide(color: AppTheme.border),
                      ),
                      leading: ManaraImage(
                        url: book.coverUrl,
                        width: 48,
                        height: 66,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      title: Text(
                        book.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      subtitle: Text(book.category),
                      trailing: const Icon(
                        Icons.arrow_back_ios_new_rounded,
                        size: 14,
                      ),
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => BookDetailsScreen(book: book),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
