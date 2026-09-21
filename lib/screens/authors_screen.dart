import 'package:flutter/material.dart';

import '../models/api_models.dart';
import '../services/library_service.dart';
import '../theme/app_theme.dart';
import '../widgets/api_error_view.dart';
import '../widgets/manara_components.dart';
import 'author_details_screen.dart';

class AuthorsScreen extends StatefulWidget {
  const AuthorsScreen({super.key});

  @override
  State<AuthorsScreen> createState() => _AuthorsScreenState();
}

class _AuthorsScreenState extends State<AuthorsScreen> {
  final _search = TextEditingController();
  late Future<List<AuthorItem>> _future;

  @override
  void initState() {
    super.initState();
    _future = LibraryService.instance.authors();
    _search.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(title: const Text('المؤلفون')),
        body: FutureBuilder<List<AuthorItem>>(
          future: _future,
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return ApiErrorView(
                error: snapshot.error!,
                retry: () => setState(() {
                  _future = LibraryService.instance.authors();
                }),
              );
            }
            final q = _search.text.trim().toLowerCase();
            final authors = (snapshot.data ?? const <AuthorItem>[])
                .where((a) => q.isEmpty || a.name.toLowerCase().contains(q))
                .toList();
            return ListView(
              padding: const EdgeInsets.fromLTRB(18, 8, 18, 28),
              children: [
                const ManaraSectionTitle(
                  title: 'وجوه خلف الكتب',
                  subtitle:
                      'ادخل إلى صفحة المؤلف لترى نبذته وكل كتبه في المكتبة.',
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _search,
                  decoration: const InputDecoration(
                    hintText: 'ابحث باسم المؤلف',
                    prefixIcon: Icon(Icons.search_rounded),
                  ),
                ),
                const SizedBox(height: 18),
                if (authors.isEmpty)
                  const ManaraEmptyState(
                    icon: Icons.person_search_outlined,
                    title: 'لا توجد نتائج',
                    message: 'جرب كتابة اسم مختلف.',
                  )
                else
                  ...authors.map(
                    (author) => Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(16),
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                AuthorDetailsScreen(authorId: author.id),
                          ),
                        ),
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: AppTheme.border),
                          ),
                          child: Row(
                            children: [
                              ClipOval(
                                child: ManaraImage(
                                  url: author.imageUrl,
                                  width: 64,
                                  height: 64,
                                  borderRadius: BorderRadius.circular(99),
                                  fallbackIcon: Icons.person_outline_rounded,
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      author.name,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w900,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      author.nationality.trim().isEmpty
                                          ? '${author.bookCount} كتاب في المنارة'
                                          : '${author.nationality} • ${author.bookCount} كتاب',
                                      style: const TextStyle(
                                        fontSize: 11.5,
                                        color: AppTheme.muted,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const Icon(
                                Icons.arrow_back_ios_new_rounded,
                                size: 15,
                                color: AppTheme.muted,
                              ),
                            ],
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
