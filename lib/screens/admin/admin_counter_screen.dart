import 'package:flutter/material.dart';

import '../../models/api_models.dart';
import '../../models/library_book.dart';
import '../../services/library_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/api_error_view.dart';
import '../../widgets/manara_components.dart';

class AdminCounterScreen extends StatefulWidget {
  const AdminCounterScreen({super.key});

  @override
  State<AdminCounterScreen> createState() => _AdminCounterScreenState();
}

class _AdminCounterScreenState extends State<AdminCounterScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabs;
  late Future<_CounterData> _future;

  int? _selectedUserId;
  int? _selectedCopyId;
  int? _selectedSaleBookId;
  String _saleType = 'PHYSICAL';
  String _paymentMethod = 'CASH';
  String _fulfillmentMethod = 'PICKUP';
  int _quantity = 1;
  bool _busy = false;

  final _deliveryAddress = TextEditingController();
  final _notes = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 2, vsync: this);
    _reload();
  }

  void _reload() {
    _future = _load();
  }

  Future<_CounterData> _load() async {
    final values = await Future.wait([
      LibraryService.instance.adminUsers(),
      LibraryService.instance.adminBookCopies(),
      LibraryService.instance.books(),
    ]);
    return _CounterData(
      users: values[0] as List<AdminUserItem>,
      copies: values[1] as List<BookCopyItem>,
      books: values[2] as List<LibraryBook>,
    );
  }

  @override
  void dispose() {
    _tabs.dispose();
    _deliveryAddress.dispose();
    _notes.dispose();
    super.dispose();
  }

  void _snack(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _refresh() async {
    setState(_reload);
    await _future;
  }

  Future<void> _borrow(_CounterData data) async {
    if (_busy) return;
    if (_selectedUserId == null) {
      _snack('اختر المستخدم أولاً.');
      return;
    }
    if (_selectedCopyId == null) {
      _snack('اختر نسخة متاحة.');
      return;
    }

    setState(() => _busy = true);
    try {
      final result = await LibraryService.instance.adminCounterBorrow(
        userId: _selectedUserId!,
        bookCopyId: _selectedCopyId!,
        paymentMethod: _paymentMethod,
        notes: _notes.text,
      );
      final payment = result['payment'];
      _snack(
        payment == null
            ? 'تمت الاستعارة بدون رسوم لأن العضوية فعالة.'
            : 'تمت الاستعارة وتسجيل الدفع بنجاح.',
      );
      if (!mounted) return;
      setState(() {
        _selectedCopyId = null;
        _notes.clear();
        _reload();
      });
    } catch (error) {
      _snack(apiErrorMessage(error));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _sale(_CounterData data) async {
    if (_busy) return;
    if (_selectedUserId == null) {
      _snack('اختر المستخدم أولاً.');
      return;
    }
    if (_selectedSaleBookId == null) {
      _snack('اختر الكتاب.');
      return;
    }
    if (_saleType == 'PHYSICAL' &&
        _fulfillmentMethod == 'DELIVERY' &&
        _deliveryAddress.text.trim().isEmpty) {
      _snack('أدخل عنوان التوصيل.');
      return;
    }

    setState(() => _busy = true);
    try {
      await LibraryService.instance.adminCounterSale(
        userId: _selectedUserId!,
        bookId: _selectedSaleBookId!,
        purchaseType: _saleType,
        quantity: _saleType == 'DIGITAL' ? 1 : _quantity,
        fulfillmentMethod: _saleType == 'DIGITAL'
            ? 'DIGITAL'
            : _fulfillmentMethod,
        paymentMethod: _paymentMethod,
        deliveryAddress: _deliveryAddress.text,
        notes: _notes.text,
      );
      _snack('تم تسجيل البيع والدفع بنجاح.');
      if (!mounted) return;
      setState(() {
        _selectedSaleBookId = null;
        _quantity = 1;
        _deliveryAddress.clear();
        _notes.clear();
        _reload();
      });
    } catch (error) {
      _snack(apiErrorMessage(error));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('كاونتر المكتبة'),
          bottom: TabBar(
            controller: _tabs,
            tabs: const [
              Tab(text: 'إعارة مباشرة'),
              Tab(text: 'بيع كتاب'),
            ],
          ),
        ),
        body: FutureBuilder<_CounterData>(
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
            return RefreshIndicator(
              onRefresh: _refresh,
              child: TabBarView(
                controller: _tabs,
                children: [_borrowTab(data), _saleTab(data)],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _borrowTab(_CounterData data) {
    final available = data.copies
        .where((copy) => copy.status == 'AVAILABLE')
        .toList();
    final selectedUser = _user(data.users, _selectedUserId);
    final selectedCopy = _copy(data.copies, _selectedCopyId);
    final selectedBook = _book(data.books, selectedCopy?.bookId);
    final included = selectedUser?.membership?.status == 'ACTIVE';
    final estimatedFee = included ? 0.0 : (selectedBook?.borrowingFee ?? 0.0);

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 34),
      children: [
        const _CounterHero(
          title: 'تسليم كتاب من الكاونتر',
          subtitle:
              'اختر المستخدم والنسخة الفعلية. الخادم يعيد فحص العضوية والتوفر قبل إنشاء الاستعارة.',
          icon: Icons.local_library_outlined,
        ),
        const SizedBox(height: 24),
        const ManaraSectionTitle(
          title: '1. المستخدم',
          subtitle: 'العضوية الفعالة تجعل رسوم الاستعارة 0.00 USD.',
        ),
        const SizedBox(height: 10),
        _userPicker(data.users),
        if (selectedUser != null) ...[
          const SizedBox(height: 9),
          _UserSummary(user: selectedUser),
        ],
        const SizedBox(height: 24),
        const ManaraSectionTitle(
          title: '2. النسخة',
          subtitle: 'تظهر النسخ المتاحة فقط، وليس مخزون البيع الورقي.',
        ),
        const SizedBox(height: 10),
        DropdownButtonFormField<int>(
          isExpanded: true,
          initialValue: available.any((e) => e.id == _selectedCopyId)
              ? _selectedCopyId
              : null,
          decoration: const InputDecoration(
            labelText: 'اختر نسخة متاحة',
            prefixIcon: Icon(Icons.qr_code_2_rounded),
          ),
          items: available
              .map(
                (copy) => DropdownMenuItem(
                  value: copy.id,
                  child: Text(
                    '${copy.copyCode} — ${copy.bookTitle}',
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              )
              .toList(),
          onChanged: (value) => setState(() => _selectedCopyId = value),
        ),
        if (selectedCopy != null) ...[
          const SizedBox(height: 12),
          _SelectedBookCard(
            title: selectedCopy.bookTitle,
            coverUrl: selectedCopy.bookCoverUrl,
            line1: 'النسخة: ${selectedCopy.copyCode}',
            line2: included
                ? 'السعر المتوقع: 0.00 USD — عضوية فعالة'
                : 'السعر المتوقع: ${estimatedFee.toStringAsFixed(2)} USD',
          ),
        ],
        const SizedBox(height: 22),
        _paymentAndNotes(),
        const SizedBox(height: 20),
        ElevatedButton.icon(
          onPressed: _busy ? null : () => _borrow(data),
          icon: _busy
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : const Icon(Icons.how_to_reg_outlined),
          label: const Text('تأكيد الاستعارة'),
        ),
      ],
    );
  }

  Widget _saleTab(_CounterData data) {
    final physicalBooks = data.books
        .where((book) => book.active && book.physicalSalePrice != null)
        .toList();
    final digitalBooks = data.books
        .where(
          (book) =>
              book.active &&
              book.digitalAvailable &&
              book.digitalPurchasePrice != null,
        )
        .toList();
    final source = _saleType == 'DIGITAL' ? digitalBooks : physicalBooks;
    final selectedBook = _book(data.books, _selectedSaleBookId);
    final unitPrice = _saleType == 'DIGITAL'
        ? selectedBook?.digitalPurchasePrice
        : selectedBook?.physicalSalePrice;
    final total = (unitPrice ?? 0) * (_saleType == 'DIGITAL' ? 1 : _quantity);

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 34),
      children: [
        const _CounterHero(
          title: 'بيع من داخل المكتبة',
          subtitle:
              'بيع ورقي مع استلام/توصيل أو شراء رقمي. المخزون والوصول الرقمي يُراجعان في الخادم.',
          icon: Icons.point_of_sale_outlined,
        ),
        const SizedBox(height: 24),
        const ManaraSectionTitle(title: 'المستخدم'),
        const SizedBox(height: 10),
        _userPicker(data.users),
        const SizedBox(height: 22),
        SegmentedButton<String>(
          segments: const [
            ButtonSegment(
              value: 'PHYSICAL',
              icon: Icon(Icons.menu_book_outlined),
              label: Text('ورقي'),
            ),
            ButtonSegment(
              value: 'DIGITAL',
              icon: Icon(Icons.tablet_android_outlined),
              label: Text('رقمي'),
            ),
          ],
          selected: {_saleType},
          onSelectionChanged: (values) => setState(() {
            _saleType = values.first;
            _selectedSaleBookId = null;
            _quantity = 1;
          }),
        ),
        const SizedBox(height: 14),
        DropdownButtonFormField<int>(
          isExpanded: true,
          initialValue: source.any((e) => e.id == _selectedSaleBookId)
              ? _selectedSaleBookId
              : null,
          decoration: const InputDecoration(
            labelText: 'اختر الكتاب',
            prefixIcon: Icon(Icons.auto_stories_outlined),
          ),
          items: source
              .where((book) => book.id != null)
              .map(
                (book) => DropdownMenuItem(
                  value: book.id!,
                  child: Text(book.title, overflow: TextOverflow.ellipsis),
                ),
              )
              .toList(),
          onChanged: (value) => setState(() => _selectedSaleBookId = value),
        ),
        if (selectedBook != null) ...[
          const SizedBox(height: 12),
          _SelectedBookCard(
            title: selectedBook.title,
            coverUrl: selectedBook.coverUrl,
            line1: _saleType == 'DIGITAL'
                ? 'شراء رقمي • ${selectedBook.digitalPurchasePrice?.toStringAsFixed(2) ?? '—'} USD'
                : 'نسخة ورقية • ${selectedBook.physicalSalePrice?.toStringAsFixed(2) ?? '—'} USD',
            line2: _saleType == 'DIGITAL'
                ? 'يُمنح الوصول الرقمي بعد تسجيل الدفع.'
                : 'المخزون الحالي: ${selectedBook.physicalSaleStock}',
          ),
        ],
        if (_saleType == 'PHYSICAL') ...[
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: _stepper(
                  title: 'الكمية',
                  value: _quantity,
                  onMinus: _quantity > 1
                      ? () => setState(() => _quantity--)
                      : null,
                  onPlus: () => setState(() => _quantity++),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: DropdownButtonFormField<String>(
                  initialValue: _fulfillmentMethod,
                  decoration: const InputDecoration(labelText: 'التسليم'),
                  items: const [
                    DropdownMenuItem(value: 'PICKUP', child: Text('استلام')),
                    DropdownMenuItem(value: 'DELIVERY', child: Text('توصيل')),
                  ],
                  onChanged: (value) =>
                      setState(() => _fulfillmentMethod = value ?? 'PICKUP'),
                ),
              ),
            ],
          ),
          if (_fulfillmentMethod == 'DELIVERY') ...[
            const SizedBox(height: 12),
            TextField(
              controller: _deliveryAddress,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'عنوان التوصيل',
                prefixIcon: Icon(Icons.location_on_outlined),
              ),
            ),
          ],
        ],
        const SizedBox(height: 18),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFEAF3EE),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              const Icon(Icons.receipt_long_outlined, color: AppTheme.teal),
              const SizedBox(width: 10),
              const Expanded(
                child: Text(
                  'الإجمالي المتوقع',
                  style: TextStyle(fontWeight: FontWeight.w800),
                ),
              ),
              Text(
                '${total.toStringAsFixed(2)} USD',
                style: const TextStyle(
                  color: AppTheme.teal,
                  fontWeight: FontWeight.w900,
                  fontSize: 18,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),
        _paymentAndNotes(),
        const SizedBox(height: 20),
        ElevatedButton.icon(
          onPressed: _busy ? null : () => _sale(data),
          icon: _busy
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : const Icon(Icons.check_circle_outline),
          label: const Text('تأكيد البيع والدفع'),
        ),
      ],
    );
  }

  Widget _userPicker(List<AdminUserItem> users) {
    return DropdownButtonFormField<int>(
      isExpanded: true,
      initialValue: users.any((user) => user.id == _selectedUserId)
          ? _selectedUserId
          : null,
      decoration: const InputDecoration(
        labelText: 'اختر المستخدم',
        prefixIcon: Icon(Icons.person_search_outlined),
      ),
      items: users
          .map(
            (user) => DropdownMenuItem(
              value: user.id,
              child: Text(
                '${user.fullName} • ${user.username}',
                overflow: TextOverflow.ellipsis,
              ),
            ),
          )
          .toList(),
      onChanged: (value) => setState(() => _selectedUserId = value),
    );
  }

  Widget _paymentAndNotes() {
    return Column(
      children: [
        DropdownButtonFormField<String>(
          initialValue: _paymentMethod,
          decoration: const InputDecoration(
            labelText: 'طريقة الدفع في الكاونتر',
            prefixIcon: Icon(Icons.payments_outlined),
          ),
          items: const [
            DropdownMenuItem(value: 'CASH', child: Text('نقدي')),
            DropdownMenuItem(value: 'CARD', child: Text('بطاقة')),
          ],
          onChanged: (value) =>
              setState(() => _paymentMethod = value ?? 'CASH'),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _notes,
          maxLines: 2,
          decoration: const InputDecoration(
            labelText: 'ملاحظة إدارية (اختياري)',
            prefixIcon: Icon(Icons.edit_note_outlined),
          ),
        ),
      ],
    );
  }

  Widget _stepper({
    required String title,
    required int value,
    VoidCallback? onMinus,
    VoidCallback? onPlus,
  }) {
    return Container(
      height: 58,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(13),
        border: Border.all(color: AppTheme.border),
      ),
      child: Row(
        children: [
          IconButton(onPressed: onMinus, icon: const Icon(Icons.remove)),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '$value',
                  style: const TextStyle(fontWeight: FontWeight.w900),
                ),
                Text(
                  title,
                  style: const TextStyle(fontSize: 9, color: AppTheme.muted),
                ),
              ],
            ),
          ),
          IconButton(onPressed: onPlus, icon: const Icon(Icons.add)),
        ],
      ),
    );
  }

  AdminUserItem? _user(List<AdminUserItem> users, int? id) {
    if (id == null) return null;
    for (final user in users) {
      if (user.id == id) return user;
    }
    return null;
  }

  BookCopyItem? _copy(List<BookCopyItem> copies, int? id) {
    if (id == null) return null;
    for (final copy in copies) {
      if (copy.id == id) return copy;
    }
    return null;
  }

  LibraryBook? _book(List<LibraryBook> books, int? id) {
    if (id == null) return null;
    for (final book in books) {
      if (book.id == id) return book;
    }
    return null;
  }
}

class _CounterData {
  final List<AdminUserItem> users;
  final List<BookCopyItem> copies;
  final List<LibraryBook> books;

  const _CounterData({
    required this.users,
    required this.copies,
    required this.books,
  });
}

class _CounterHero extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;

  const _CounterHero({
    required this.title,
    required this.subtitle,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.darkTeal,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 7),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: .70),
                    fontSize: 11.5,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 14),
          Container(
            width: 66,
            height: 66,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: .10),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Icon(icon, color: AppTheme.gold, size: 32),
          ),
        ],
      ),
    );
  }
}

class _UserSummary extends StatelessWidget {
  final AdminUserItem user;
  const _UserSummary({required this.user});

  @override
  Widget build(BuildContext context) {
    final membership = user.membership;
    final active = membership?.status == 'ACTIVE';
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: active ? const Color(0xFFE8F2ED) : const Color(0xFFF5F3ED),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Icon(
            active ? Icons.workspace_premium_rounded : Icons.person_outline,
            color: active ? AppTheme.teal : AppTheme.muted,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.fullName,
                  style: const TextStyle(fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 3),
                Text(
                  active
                      ? 'عضوية فعالة حتى ${formatDate(membership?.endDate)}'
                      : 'لا توجد عضوية فعالة — تطبق رسوم الكتاب',
                  style: const TextStyle(fontSize: 10.5, color: AppTheme.muted),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SelectedBookCard extends StatelessWidget {
  final String title;
  final String? coverUrl;
  final String line1;
  final String line2;

  const _SelectedBookCard({
    required this.title,
    required this.coverUrl,
    required this.line1,
    required this.line2,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.border),
      ),
      child: Row(
        children: [
          ManaraImage(
            url: coverUrl,
            width: 64,
            height: 88,
            borderRadius: BorderRadius.circular(10),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 6),
                Text(
                  line1,
                  style: const TextStyle(fontSize: 10.5, color: AppTheme.muted),
                ),
                const SizedBox(height: 3),
                Text(
                  line2,
                  style: const TextStyle(
                    fontSize: 10.5,
                    color: AppTheme.teal,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
