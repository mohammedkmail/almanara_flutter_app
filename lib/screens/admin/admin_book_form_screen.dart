import 'package:flutter/material.dart';

import '../../models/api_models.dart';
import '../../models/library_book.dart';
import '../../services/library_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/api_error_view.dart';
import '../../widgets/manara_components.dart';

class AdminBookFormScreen extends StatefulWidget {
  final LibraryBook? book;
  const AdminBookFormScreen({super.key, this.book});

  @override
  State<AdminBookFormScreen> createState() => _AdminBookFormScreenState();
}

class _AdminBookFormScreenState extends State<AdminBookFormScreen> {
  final _form = GlobalKey<FormState>();
  late final TextEditingController _title;
  late final TextEditingController _isbn;
  late final TextEditingController _author;
  late final TextEditingController _category;
  late final TextEditingController _description;
  late final TextEditingController _publisher;
  late final TextEditingController _year;
  late final TextEditingController _pages;
  late final TextEditingController _language;
  late final TextEditingController _stock;
  late final TextEditingController _physicalPrice;
  late final TextEditingController _borrowingFee;
  late final TextEditingController _digitalBuy;
  late final TextEditingController _digitalRent;
  late final TextEditingController _digitalContent;

  late Future<_BookReferenceData> _referenceFuture;
  int? _authorId;
  int? _categoryId;
  bool _digital = false;
  bool _membershipIncluded = false;
  bool _active = true;
  bool _busy = false;
  String? _lookupCover;
  String? _metadataSource;

  @override
  void initState() {
    super.initState();
    final book = widget.book;
    _title = TextEditingController(text: book?.title ?? '');
    _isbn = TextEditingController(text: book?.isbn ?? '');
    _author = TextEditingController(text: book?.author ?? '');
    _category = TextEditingController(text: book?.category ?? '');
    _description = TextEditingController(text: book?.description ?? '');
    _publisher = TextEditingController(text: book?.publisher ?? '');
    _year = TextEditingController(text: book?.publishYear?.toString() ?? '');
    _pages = TextEditingController(text: book?.pageCount?.toString() ?? '');
    _language = TextEditingController(text: book?.language ?? '');
    _stock = TextEditingController(text: '${book?.physicalSaleStock ?? 0}');
    _physicalPrice = TextEditingController(
      text: book?.physicalSalePrice?.toString() ?? '',
    );
    _borrowingFee = TextEditingController(
      text: book?.borrowingFee?.toString() ?? '3.00',
    );
    _digitalBuy = TextEditingController(
      text: book?.digitalPurchasePrice?.toString() ?? '',
    );
    _digitalRent = TextEditingController(
      text: book?.digitalRentalPrice?.toString() ?? '',
    );
    _digitalContent = TextEditingController(text: book?.digitalContent ?? '');
    _authorId = book?.authorId;
    _categoryId = book?.categoryId;
    _digital = book?.digitalAvailable ?? false;
    _membershipIncluded = book?.membershipIncluded ?? false;
    _active = book?.active ?? true;
    _metadataSource = book?.metadataSource;
    _referenceFuture = _loadReference();
  }

  Future<_BookReferenceData> _loadReference() async {
    final values = await Future.wait([
      LibraryService.instance.authors(),
      LibraryService.instance.categories(),
    ]);
    return _BookReferenceData(
      authors: values[0] as List<AuthorItem>,
      categories: values[1] as List<CategoryItem>,
    );
  }

  @override
  void dispose() {
    for (final controller in [
      _title,
      _isbn,
      _author,
      _category,
      _description,
      _publisher,
      _year,
      _pages,
      _language,
      _stock,
      _physicalPrice,
      _borrowingFee,
      _digitalBuy,
      _digitalRent,
      _digitalContent,
    ]) {
      controller.dispose();
    }
    super.dispose();
  }

  void _snack(String message) {
    if (mounted)
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _lookupIsbn() async {
    if (_isbn.text.trim().isEmpty || _busy) return;
    setState(() => _busy = true);
    try {
      final metadata = await LibraryService.instance.isbnLookup(_isbn.text);
      if (!mounted) return;
      setState(() {
        if (metadata.title.isNotEmpty) _title.text = metadata.title;
        if (metadata.authors.isNotEmpty) {
          _author.text = metadata.authors.first;
          _authorId = null;
        }
        if (metadata.categories.isNotEmpty) {
          _category.text = metadata.categories.first;
          _categoryId = null;
        }
        if (metadata.description.isNotEmpty)
          _description.text = metadata.description;
        if (metadata.publisher?.isNotEmpty == true)
          _publisher.text = metadata.publisher!;
        if (metadata.publishYear != null)
          _year.text = '${metadata.publishYear}';
        if (metadata.pageCount != null) _pages.text = '${metadata.pageCount}';
        if (metadata.language?.isNotEmpty == true)
          _language.text = metadata.language!;
        _lookupCover = metadata.externalCoverUrl;
        _metadataSource = metadata.source;
      });
      _snack('تم جلب البيانات. راجعها قبل الحفظ.');
    } catch (error) {
      _snack(apiErrorMessage(error));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _save() async {
    if (_busy || !_form.currentState!.validate()) return;
    setState(() => _busy = true);
    final data = <String, dynamic>{
      'title': _title.text.trim(),
      'isbn': _isbn.text.trim(),
      if (_authorId != null)
        'authorId': _authorId
      else
        'authorName': _author.text.trim(),
      if (_categoryId != null)
        'categoryId': _categoryId
      else
        'categoryName': _category.text.trim(),
      'description': _description.text.trim(),
      'publisher': _publisher.text.trim(),
      'publishYear': int.tryParse(_year.text.trim()),
      'pageCount': int.tryParse(_pages.text.trim()),
      'language': _language.text.trim(),
      'physicalSaleStock': int.tryParse(_stock.text.trim()) ?? 0,
      'physicalSalePrice': double.tryParse(_physicalPrice.text.trim()),
      'borrowingFee': double.tryParse(_borrowingFee.text.trim()) ?? 3.0,
      'digitalAvailable': _digital,
      'digitalPurchasePrice': _digital
          ? double.tryParse(_digitalBuy.text.trim())
          : null,
      'digitalRentalPrice': _digital
          ? double.tryParse(_digitalRent.text.trim())
          : null,
      'membershipIncluded': _digital && _membershipIncluded,
      'digitalContent': _digital ? _digitalContent.text : null,
      'active': _active,
      if (_lookupCover?.trim().isNotEmpty == true)
        'externalCoverUrl': _lookupCover,
      if (_metadataSource?.trim().isNotEmpty == true)
        'metadataSource': _metadataSource,
    };

    try {
      if (widget.book?.id == null) {
        await LibraryService.instance.saveBook(data);
      } else {
        await LibraryService.instance.updateBook(widget.book!.id!, data);
      }
      if (mounted) Navigator.pop(context, true);
    } catch (error) {
      _snack(apiErrorMessage(error));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) => Directionality(
    textDirection: TextDirection.rtl,
    child: Scaffold(
      appBar: AppBar(
        title: Text(widget.book == null ? 'إضافة كتاب' : 'تعديل الكتاب'),
      ),
      body: FutureBuilder<_BookReferenceData>(
        future: _referenceFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return ApiErrorView(
              error: snapshot.error!,
              retry: () => setState(() => _referenceFuture = _loadReference()),
            );
          }
          final reference = snapshot.data!;
          return Form(
            key: _form,
            child: ListView(
              padding: const EdgeInsets.fromLTRB(18, 4, 18, 34),
              children: [
                _BookPreviewHeader(
                  book: widget.book,
                  lookupCover: _lookupCover,
                  title: _title.text,
                  source: _metadataSource,
                ),
                const SizedBox(height: 24),
                const ManaraSectionTitle(
                  title: 'بيانات الفهرس',
                  subtitle: 'يمكنك جلب الأساس من ISBN ثم مراجعته يدوياً.',
                ),
                const SizedBox(height: 12),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: _field(
                        _isbn,
                        'ISBN',
                        required: true,
                        keyboard: TextInputType.number,
                      ),
                    ),
                    const SizedBox(width: 8),
                    SizedBox(
                      height: 56,
                      child: OutlinedButton.icon(
                        onPressed: _busy ? null : _lookupIsbn,
                        icon: const Icon(Icons.travel_explore_outlined),
                        label: const Text('جلب'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 11),
                _field(_title, 'عنوان الكتاب', required: true),
                const SizedBox(height: 11),
                DropdownButtonFormField<int>(
                  isExpanded: true,
                  initialValue: reference.authors.any((e) => e.id == _authorId)
                      ? _authorId
                      : null,
                  decoration: const InputDecoration(
                    labelText: 'اختيار مؤلف موجود',
                    prefixIcon: Icon(Icons.person_outline_rounded),
                  ),
                  items: reference.authors
                      .map(
                        (item) => DropdownMenuItem(
                          value: item.id,
                          child: Text(
                            item.name,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      )
                      .toList(),
                  onChanged: (id) {
                    setState(() {
                      _authorId = id;
                      for (final item in reference.authors) {
                        if (item.id == id) _author.text = item.name;
                      }
                    });
                  },
                ),
                const SizedBox(height: 8),
                _field(
                  _author,
                  'أو اسم مؤلف جديد / ناتج ISBN',
                  required: _authorId == null,
                  onChanged: (_) {
                    if (_authorId != null) setState(() => _authorId = null);
                  },
                ),
                const SizedBox(height: 11),
                DropdownButtonFormField<int>(
                  isExpanded: true,
                  initialValue:
                      reference.categories.any((e) => e.id == _categoryId)
                      ? _categoryId
                      : null,
                  decoration: const InputDecoration(
                    labelText: 'اختيار قسم موجود',
                    prefixIcon: Icon(Icons.category_outlined),
                  ),
                  items: reference.categories
                      .map(
                        (item) => DropdownMenuItem(
                          value: item.id,
                          child: Text(
                            item.name,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      )
                      .toList(),
                  onChanged: (id) {
                    setState(() {
                      _categoryId = id;
                      for (final item in reference.categories) {
                        if (item.id == id) _category.text = item.name;
                      }
                    });
                  },
                ),
                const SizedBox(height: 8),
                _field(
                  _category,
                  'أو قسم جديد / ناتج ISBN',
                  required: _categoryId == null,
                  onChanged: (_) {
                    if (_categoryId != null) setState(() => _categoryId = null);
                  },
                ),
                const SizedBox(height: 11),
                _field(_description, 'الوصف', maxLines: 5),
                const SizedBox(height: 11),
                Row(
                  children: [
                    Expanded(child: _field(_publisher, 'الناشر')),
                    const SizedBox(width: 9),
                    Expanded(child: _field(_language, 'اللغة')),
                  ],
                ),
                const SizedBox(height: 11),
                Row(
                  children: [
                    Expanded(
                      child: _field(
                        _year,
                        'سنة النشر',
                        keyboard: TextInputType.number,
                      ),
                    ),
                    const SizedBox(width: 9),
                    Expanded(
                      child: _field(
                        _pages,
                        'عدد الصفحات',
                        keyboard: TextInputType.number,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 28),
                const ManaraSectionTitle(
                  title: 'النسخة الورقية والأسعار',
                  subtitle:
                      'عدد نسخ الاستعارة الفعلية يُدار من شاشة النسخ؛ مخزون البيع مستقل.',
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _field(
                        _borrowingFee,
                        'رسوم الاستعارة',
                        required: true,
                        keyboard: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        suffix: 'USD',
                      ),
                    ),
                    const SizedBox(width: 9),
                    Expanded(
                      child: _field(
                        _physicalPrice,
                        'سعر البيع الورقي',
                        keyboard: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        suffix: 'USD',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 11),
                _field(
                  _stock,
                  'مخزون البيع الورقي',
                  keyboard: TextInputType.number,
                ),
                const SizedBox(height: 9),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEAF3EE),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.workspace_premium_outlined,
                        color: AppTheme.teal,
                      ),
                      SizedBox(width: 9),
                      Expanded(
                        child: Text(
                          'رسوم الاستعارة هنا هي السعر الأساسي فقط. إذا كان المستخدم صاحب عضوية فعالة، MembershipService يحول الرسوم الفعلية إلى 0.00 USD.',
                          style: TextStyle(
                            fontSize: 11.5,
                            color: AppTheme.muted,
                            height: 1.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 28),
                const ManaraSectionTitle(
                  title: 'النسخة الرقمية',
                  subtitle:
                      'المحتوى لا يخرج عبر Catalog API للمستخدم؛ القراءة تمر من endpoint محمي.',
                ),
                SwitchListTile.adaptive(
                  contentPadding: EdgeInsets.zero,
                  value: _digital,
                  onChanged: (value) => setState(() {
                    _digital = value;
                    if (!value) _membershipIncluded = false;
                  }),
                  title: const Text(
                    'نسخة رقمية متاحة',
                    style: TextStyle(fontWeight: FontWeight.w800),
                  ),
                ),
                if (_digital) ...[
                  Row(
                    children: [
                      Expanded(
                        child: _field(
                          _digitalBuy,
                          'سعر الشراء الرقمي',
                          keyboard: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          suffix: 'USD',
                        ),
                      ),
                      const SizedBox(width: 9),
                      Expanded(
                        child: _field(
                          _digitalRent,
                          'سعر الإيجار/يوم',
                          keyboard: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          suffix: 'USD',
                        ),
                      ),
                    ],
                  ),
                  SwitchListTile.adaptive(
                    contentPadding: EdgeInsets.zero,
                    value: _membershipIncluded,
                    onChanged: (value) =>
                        setState(() => _membershipIncluded = value),
                    title: const Text(
                      'القراءة الرقمية مشمولة بالعضوية',
                      style: TextStyle(fontWeight: FontWeight.w800),
                    ),
                    subtitle: const Text('تطبق فقط أثناء العضوية الفعالة.'),
                  ),
                  _field(
                    _digitalContent,
                    'محتوى القراءة الرقمية',
                    maxLines: 10,
                    hint: 'ألصق النص الذي سيظهر داخل القارئ الرقمي...',
                  ),
                ],
                const SizedBox(height: 22),
                SwitchListTile.adaptive(
                  contentPadding: EdgeInsets.zero,
                  value: _active,
                  onChanged: (value) => setState(() => _active = value),
                  title: const Text(
                    'الكتاب فعال في الفهرس',
                    style: TextStyle(fontWeight: FontWeight.w800),
                  ),
                  subtitle: const Text(
                    'تعطيله يخفيه عن المستخدمين مع الحفاظ على السجل التاريخي.',
                  ),
                ),
                const SizedBox(height: 18),
                ElevatedButton.icon(
                  onPressed: _busy ? null : _save,
                  icon: _busy
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.save_outlined),
                  label: Text(
                    widget.book == null ? 'إضافة الكتاب' : 'حفظ التعديلات',
                  ),
                ),
              ],
            ),
          );
        },
      ),
    ),
  );

  Widget _field(
    TextEditingController controller,
    String label, {
    bool required = false,
    int maxLines = 1,
    TextInputType? keyboard,
    String? suffix,
    String? hint,
    ValueChanged<String>? onChanged,
  }) => TextFormField(
    controller: controller,
    maxLines: maxLines,
    keyboardType: keyboard,
    onChanged: onChanged,
    decoration: InputDecoration(
      labelText: label,
      hintText: hint,
      suffixText: suffix,
    ),
    validator: required
        ? (value) =>
              value == null || value.trim().isEmpty ? 'هذا الحقل مطلوب' : null
        : null,
  );
}

class _BookReferenceData {
  final List<AuthorItem> authors;
  final List<CategoryItem> categories;
  const _BookReferenceData({required this.authors, required this.categories});
}

class _BookPreviewHeader extends StatelessWidget {
  final LibraryBook? book;
  final String? lookupCover;
  final String title;
  final String? source;
  const _BookPreviewHeader({
    required this.book,
    required this.lookupCover,
    required this.title,
    required this.source,
  });

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(15),
    decoration: BoxDecoration(
      color: AppTheme.darkTeal,
      borderRadius: BorderRadius.circular(20),
    ),
    child: Row(
      children: [
        ManaraImage(
          url: lookupCover ?? book?.coverUrl,
          width: 82,
          height: 118,
          borderRadius: BorderRadius.circular(11),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title.trim().isEmpty ? 'معاينة الكتاب' : title,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 7),
              Text(
                source?.trim().isNotEmpty == true
                    ? 'مصدر البيانات: $source'
                    : 'يمكن ترك مكان الغلاف الآن وإضافته من الويب لاحقاً.',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: .68),
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}
