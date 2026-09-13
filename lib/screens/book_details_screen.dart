import 'package:flutter/material.dart';

import '../models/library_book.dart';
import '../theme/app_theme.dart';
import '../models/api_models.dart';
import '../services/library_service.dart';
import '../services/auth_service.dart';
import '../models/app_user_role.dart';
import '../widgets/api_error_view.dart';
import 'reservation_result_screen.dart';

class BookDetailsScreen extends StatefulWidget {
  final LibraryBook book;

  const BookDetailsScreen({super.key, required this.book});

  @override
  State<BookDetailsScreen> createState() => _BookDetailsScreenState();
}

class _BookDetailsScreenState extends State<BookDetailsScreen> {
  LibraryBook get book => widget.book;
  bool _submitting = false;

  Future<void> _reserve() async {
    if (_submitting || book.id == null) return;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('حجز كتاب للاستعارة'),
        content: Text(
          'إرسال طلب حجز «${book.title}»؟ قد يحتاج الحجز إلى دفع أو تأكيد لاحقاً.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('إلغاء'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('تأكيد'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    setState(() => _submitting = true);
    try {
      final result = await LibraryService.instance.reserve(
        ReservationRequest(book.id!),
      );
      if (!mounted) return;
      await Navigator.push(
        context,
        MaterialPageRoute<void>(
          builder: (_) => ReservationResultScreen(reservation: result),
        ),
      );
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(apiErrorMessage(error))));
      }
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  String _money(double? value) {
    if (value == null) return '-';
    final String text = value % 1 == 0
        ? value.toStringAsFixed(0)
        : value.toStringAsFixed(2);
    return '$text ₪';
  }

  void _showActionResult(BuildContext context, String title, String message) {
    showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('إلغاء'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('هذه العملية غير متاحة عبر التطبيق حالياً.'),
                  ),
                );
              },
              child: const Text('تأكيد'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(title: const Text('تفاصيل الكتاب')),
        body: ListView(
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 30),
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 118,
                  height: 168,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: book.coverColor,
                    borderRadius: BorderRadius.circular(14),
                  ),
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
                      const SizedBox(height: 12),
                      Text(
                        book.title,
                        textAlign: TextAlign.center,
                        maxLines: 4,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: book.darkText
                              ? AppTheme.darkTeal
                              : Colors.white,
                          fontWeight: FontWeight.w800,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        book.title,
                        style: TextStyle(
                          color: colors.onSurface,
                          fontSize: 23,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        book.author,
                        style: TextStyle(
                          color: colors.onSurfaceVariant,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 14),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          _InfoChip(
                            icon: Icons.category_outlined,
                            text: book.category,
                          ),
                          _InfoChip(
                            icon: book.available
                                ? Icons.check_circle_outline
                                : Icons.schedule_outlined,
                            text: book.available ? 'متاح' : 'غير متاح',
                          ),
                        ],
                      ),
                      if (book.isbn.isNotEmpty) ...[
                        const SizedBox(height: 12),
                        Text(
                          'ISBN: ${book.isbn}',
                          style: TextStyle(
                            color: colors.onSurfaceVariant,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 28),
            Text(
              'عن الكتاب',
              style: TextStyle(
                color: colors.onSurface,
                fontSize: 18,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              book.description.isEmpty
                  ? 'سيظهر وصف الكتاب هنا عند ربط التطبيق بالـ API.'
                  : book.description,
              style: TextStyle(
                color: colors.onSurfaceVariant,
                height: 1.7,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 26),
            const _SectionLabel('النسخة الورقية'),
            const SizedBox(height: 10),
            _SimpleInfoRow(
              label: 'رسوم الاستعارة',
              value: _money(book.borrowingFee),
            ),
            _SimpleInfoRow(
              label: 'سعر الشراء',
              value: _money(book.physicalSalePrice),
            ),
            _SimpleInfoRow(
              label: 'المخزون للبيع',
              value: '${book.physicalSaleStock}',
            ),
            const SizedBox(height: 22),
            const _SectionLabel('النسخة الرقمية'),
            const SizedBox(height: 10),
            _SimpleInfoRow(
              label: 'متوفرة رقمياً',
              value: book.digitalAvailable ? 'نعم' : 'لا',
            ),
            if (book.digitalAvailable) ...[
              _SimpleInfoRow(
                label: 'شراء رقمي',
                value: _money(book.digitalPurchasePrice),
              ),
              _SimpleInfoRow(
                label: 'استئجار رقمي',
                value: _money(book.digitalRentalPrice),
              ),
              _SimpleInfoRow(
                label: 'ضمن العضوية',
                value: book.membershipIncluded ? 'نعم' : 'لا',
              ),
            ],
            const SizedBox(height: 28),
            FilledButton.icon(
              onPressed:
                  book.id != null &&
                      !_submitting &&
                      AuthService.instance.user.value?.role ==
                          AppUserRole.customer
                  ? _reserve
                  : null,
              icon: const Icon(Icons.menu_book_outlined),
              label: Text(
                _submitting ? 'جارٍ إرسال الطلب...' : 'حجز كتاب للاستعارة',
              ),
            ),
            if (book.physicalSaleStock > 0) ...[
              const SizedBox(height: 10),
              OutlinedButton.icon(
                onPressed: () => _showActionResult(
                  context,
                  'شراء النسخة الورقية',
                  'هل تريد متابعة شراء النسخة الورقية؟',
                ),
                icon: const Icon(Icons.shopping_bag_outlined),
                label: const Text('شراء نسخة ورقية'),
              ),
            ],
            if (book.digitalAvailable) ...[
              const SizedBox(height: 10),
              OutlinedButton.icon(
                onPressed: () => _showActionResult(
                  context,
                  'النسخة الرقمية',
                  'سيتم ربط خيارات القراءة والشراء الرقمي بالـ API لاحقاً.',
                ),
                icon: const Icon(Icons.tablet_android_outlined),
                label: const Text('خيارات النسخة الرقمية'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String text;

  const _InfoChip({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(9),
        border: Border.all(color: theme.dividerColor),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 15, color: AppTheme.turquoise),
          const SizedBox(width: 5),
          Text(text, style: const TextStyle(fontSize: 11)),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;

  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        color: Theme.of(context).colorScheme.onSurface,
        fontSize: 17,
        fontWeight: FontWeight.w800,
      ),
    );
  }
}

class _SimpleInfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _SimpleInfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: TextStyle(color: theme.colorScheme.onSurfaceVariant),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: theme.colorScheme.onSurface,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
