import 'package:flutter/material.dart';

import '../services/library_service.dart';
import '../theme/app_theme.dart';
import '../widgets/api_error_view.dart';
import '../widgets/manara_components.dart';

class DigitalReaderScreen extends StatefulWidget {
  final int bookId;
  const DigitalReaderScreen({super.key, required this.bookId});

  @override
  State<DigitalReaderScreen> createState() => _DigitalReaderScreenState();
}

class _DigitalReaderScreenState extends State<DigitalReaderScreen> {
  late Future<Map<String, dynamic>> _future;
  double _fontSize = 18;

  @override
  void initState() {
    super.initState();
    _reload();
  }

  void _reload() {
    _future = LibraryService.instance.digitalRead(widget.bookId);
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF7F4EC),
        appBar: AppBar(
          title: const Text('القارئ الرقمي'),
          actions: [
            IconButton(
              tooltip: 'تصغير الخط',
              onPressed: _fontSize <= 14
                  ? null
                  : () => setState(() => _fontSize -= 2),
              icon: const Icon(Icons.text_decrease_rounded),
            ),
            IconButton(
              tooltip: 'تكبير الخط',
              onPressed: _fontSize >= 28
                  ? null
                  : () => setState(() => _fontSize += 2),
              icon: const Icon(Icons.text_increase_rounded),
            ),
          ],
        ),
        body: FutureBuilder<Map<String, dynamic>>(
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

            final data = snapshot.data!;
            final content = (data['content'] ?? '').toString().trim();
            final title = (data['title'] ?? '').toString();
            final author = (data['author'] ?? '').toString();
            final coverUrl = data['coverUrl']?.toString();

            if (content.isEmpty) {
              return const ManaraEmptyState(
                icon: Icons.auto_stories_outlined,
                title: 'المحتوى غير مرفوع بعد',
                message:
                    'وصولك للكتاب فعّال، لكن نص النسخة الرقمية لم تتم إضافته بعد.',
              );
            }

            return SelectionArea(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 52),
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ManaraImage(
                        url: coverUrl,
                        width: 76,
                        height: 108,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                title,
                                style: Theme.of(
                                  context,
                                ).textTheme.titleLarge?.copyWith(fontSize: 21),
                              ),
                              if (author.isNotEmpty) ...[
                                const SizedBox(height: 6),
                                Text(
                                  author,
                                  style: const TextStyle(
                                    color: AppTheme.muted,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                              const SizedBox(height: 12),
                              const ManaraStatusChip(
                                label: 'وصول رقمي فعّال',
                                color: AppTheme.teal,
                                icon: Icons.verified_outlined,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 28),
                  Container(
                    padding: const EdgeInsets.fromLTRB(22, 24, 22, 34),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFFDF8),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: const Color(0xFFE7E0D2)),
                    ),
                    child: Text(
                      content,
                      style: TextStyle(
                        fontSize: _fontSize,
                        height: 2,
                        color: const Color(0xFF2B302E),
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
