import 'package:flutter/material.dart';

import '../models/api_models.dart';
import '../services/library_service.dart';
import '../theme/app_theme.dart';
import '../widgets/api_error_view.dart';
import '../widgets/manara_components.dart';
import 'digital_reader_screen.dart';

class ApiReservationsScreen extends StatefulWidget {
  const ApiReservationsScreen({super.key});

  @override
  State<ApiReservationsScreen> createState() => _ApiReservationsScreenState();
}

class _ApiReservationsScreenState extends State<ApiReservationsScreen> {
  late Future<_LibraryShelfData> _future;

  @override
  void initState() {
    super.initState();
    _reload();
  }

  void _reload() {
    _future = _fetch();
  }

  Future<_LibraryShelfData> _fetch() async {
    final values = await Future.wait([
      LibraryService.instance.borrowings(),
      LibraryService.instance.reservations(),
      LibraryService.instance.roomReservations(),
      LibraryService.instance.digitalAccess(),
      LibraryService.instance.purchases(),
      LibraryService.instance.payments(),
    ]);
    return _LibraryShelfData(
      borrowings: values[0] as List<BorrowingItem>,
      reservations: values[1] as List<BookReservation>,
      roomReservations: values[2] as List<RoomReservationItem>,
      digital: values[3] as List<DigitalAccessItem>,
      purchases: values[4] as List<PurchaseItem>,
      payments: values[5] as List<PaymentItem>,
    );
  }

  Future<void> _refresh() async {
    setState(_reload);
    await _future;
  }

  Future<void> _cancelBookReservation(BookReservation reservation) async {
    final ok = await _confirm(
      title: 'إلغاء حجز الكتاب؟',
      message: 'سيتم تحرير الحجز وفق قواعد النظام الحالية.',
    );
    if (!ok) return;
    try {
      await LibraryService.instance.cancelReservation(reservation.id);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('تم إلغاء حجز الكتاب.')));
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

  Future<void> _cancelRoom(RoomReservationItem reservation) async {
    final ok = await _confirm(
      title: 'إلغاء حجز الغرفة؟',
      message: 'لا يمكن إلغاء الحجز بعد بدء موعده.',
    );
    if (!ok) return;
    try {
      await LibraryService.instance.cancelRoomReservation(reservation.id);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('تم إلغاء حجز الغرفة.')));
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

  Future<bool> _confirm({
    required String title,
    required String message,
  }) async {
    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(title),
            content: Text(message),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('رجوع'),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('تأكيد'),
              ),
            ],
          ),
        ) ??
        false;
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(title: const Text('مكتبتي')),
        body: FutureBuilder<_LibraryShelfData>(
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
              child: DefaultTabController(
                length: 6,
                child: NestedScrollView(
                  headerSliverBuilder: (context, innerScrolled) => [
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(18, 4, 18, 18),
                        child: _ShelfHero(data: data),
                      ),
                    ),
                    SliverPersistentHeader(
                      pinned: true,
                      delegate: _TabHeaderDelegate(
                        child: Container(
                          color: Theme.of(context).scaffoldBackgroundColor,
                          child: const TabBar(
                            isScrollable: true,
                            tabAlignment: TabAlignment.start,
                            tabs: [
                              Tab(text: 'الاستعارات'),
                              Tab(text: 'حجوزات الكتب'),
                              Tab(text: 'الغرف'),
                              Tab(text: 'الرقمية'),
                              Tab(text: 'المشتريات'),
                              Tab(text: 'المدفوعات'),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                  body: TabBarView(
                    children: [
                      _BorrowingsTab(items: data.borrowings),
                      _ReservationsTab(
                        items: data.reservations,
                        onCancel: _cancelBookReservation,
                      ),
                      _RoomsTab(
                        items: data.roomReservations,
                        onCancel: _cancelRoom,
                      ),
                      _DigitalTab(items: data.digital),
                      _PurchasesTab(items: data.purchases),
                      _PaymentsTab(items: data.payments),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _LibraryShelfData {
  final List<BorrowingItem> borrowings;
  final List<BookReservation> reservations;
  final List<RoomReservationItem> roomReservations;
  final List<DigitalAccessItem> digital;
  final List<PurchaseItem> purchases;
  final List<PaymentItem> payments;

  const _LibraryShelfData({
    required this.borrowings,
    required this.reservations,
    required this.roomReservations,
    required this.digital,
    required this.purchases,
    required this.payments,
  });
}

class _ShelfHero extends StatelessWidget {
  final _LibraryShelfData data;
  const _ShelfHero({required this.data});

  @override
  Widget build(BuildContext context) {
    final active = data.borrowings.where((e) => e.open).length;
    final ready = data.reservations.where((e) => e.readyForCustomer).length;
    final upcomingRooms = data.roomReservations
        .where((e) => e.status == 'CONFIRMED')
        .length;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.darkTeal,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'كل ما يخصك في مكان واحد',
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'تابع الكتب المستعارة والحجوزات والوصول الرقمي والمشتريات من نفس الشاشة.',
            style: TextStyle(
              color: Colors.white.withValues(alpha: .72),
              fontSize: 12,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              _HeroNumber(value: '$active', label: 'مستعارة الآن'),
              _HeroNumber(value: '$ready', label: 'جاهزة'),
              _HeroNumber(value: '$upcomingRooms', label: 'غرف قادمة'),
              _HeroNumber(value: '${data.digital.length}', label: 'رقمية'),
            ],
          ),
        ],
      ),
    );
  }
}

class _HeroNumber extends StatelessWidget {
  final String value;
  final String label;
  const _HeroNumber({required this.value, required this.label});

  @override
  Widget build(BuildContext context) => Expanded(
    child: Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            color: AppTheme.gold,
            fontWeight: FontWeight.w900,
            fontSize: 20,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.white.withValues(alpha: .68),
            fontSize: 9.5,
          ),
        ),
      ],
    ),
  );
}

class _TabHeaderDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;
  const _TabHeaderDelegate({required this.child});

  @override
  double get minExtent => 50;
  @override
  double get maxExtent => 50;
  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) => child;
  @override
  bool shouldRebuild(covariant _TabHeaderDelegate oldDelegate) => false;
}

class _BorrowingsTab extends StatelessWidget {
  final List<BorrowingItem> items;
  const _BorrowingsTab({required this.items});

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return const SingleChildScrollView(
        child: ManaraEmptyState(
          icon: Icons.import_contacts_outlined,
          title: 'لا توجد استعارات بعد',
          message: 'عندما تستعير كتاباً سيظهر تاريخه وموعد إعادته هنا.',
        ),
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 32),
      itemCount: items.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (_, index) {
        final item = items[index];
        final tone = item.status == 'OVERDUE'
            ? Colors.redAccent
            : AppTheme.teal;
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(13),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ManaraImage(
                  url: item.bookCoverUrl,
                  width: 68,
                  height: 98,
                  borderRadius: BorderRadius.circular(10),
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
                              item.bookTitle,
                              style: const TextStyle(
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                          ManaraStatusChip(
                            label: item.statusLabel,
                            color: tone,
                          ),
                        ],
                      ),
                      if (item.bookAuthor.isNotEmpty) ...[
                        const SizedBox(height: 3),
                        Text(
                          item.bookAuthor,
                          style: const TextStyle(
                            color: AppTheme.muted,
                            fontSize: 11,
                          ),
                        ),
                      ],
                      const SizedBox(height: 10),
                      Text(
                        'استعير: ${formatDate(item.borrowDate)}',
                        style: const TextStyle(fontSize: 11),
                      ),
                      Text(
                        'موعد الإعادة: ${formatDate(item.dueDate)}',
                        style: TextStyle(
                          fontSize: 11,
                          color: item.status == 'OVERDUE'
                              ? Colors.redAccent
                              : AppTheme.muted,
                        ),
                      ),
                      if (item.lateFee > 0)
                        Text(
                          'رسوم التأخير: ${item.lateFee.toStringAsFixed(2)} USD',
                          style: const TextStyle(
                            color: Colors.redAccent,
                            fontWeight: FontWeight.w800,
                            fontSize: 11,
                          ),
                        ),
                      if (item.copyCode.isNotEmpty)
                        Text(
                          'النسخة: ${item.copyCode}',
                          style: const TextStyle(
                            fontSize: 10.5,
                            color: AppTheme.muted,
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _ReservationsTab extends StatelessWidget {
  final List<BookReservation> items;
  final Future<void> Function(BookReservation) onCancel;
  const _ReservationsTab({required this.items, required this.onCancel});

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return const SingleChildScrollView(
        child: ManaraEmptyState(
          icon: Icons.bookmark_outline,
          title: 'لا توجد حجوزات كتب',
          message:
              'احجز كتاباً من صفحة التفاصيل وسيتابع النظام التوفر تلقائياً.',
        ),
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 32),
      itemCount: items.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (_, index) {
        final item = items[index];
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(13),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ManaraImage(
                  url: item.bookCoverUrl,
                  width: 68,
                  height: 98,
                  borderRadius: BorderRadius.circular(10),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.bookTitle,
                        style: const TextStyle(fontWeight: FontWeight.w900),
                      ),
                      if (item.bookAuthor.isNotEmpty)
                        Text(
                          item.bookAuthor,
                          style: const TextStyle(
                            fontSize: 11,
                            color: AppTheme.muted,
                          ),
                        ),
                      const SizedBox(height: 7),
                      ManaraStatusChip(
                        label: item.statusLabel,
                        color: item.readyForCustomer
                            ? const Color(0xFF9A6D21)
                            : AppTheme.teal,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        item.feeAmount <= 0
                            ? 'رسوم الاستعارة: 0.00 USD'
                            : 'رسوم الاستعارة: ${item.feeAmount.toStringAsFixed(2)} USD',
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      if (item.readyUntil != null)
                        Text(
                          'المهلة: ${formatDate(item.readyUntil, time: true)}',
                          style: const TextStyle(
                            fontSize: 10.5,
                            color: AppTheme.muted,
                          ),
                        ),
                      if (item.fulfillmentMethod.isNotEmpty)
                        Text(
                          item.fulfillmentMethod == 'DELIVERY'
                              ? 'توصيل'
                              : 'استلام من المكتبة',
                          style: const TextStyle(
                            fontSize: 10.5,
                            color: AppTheme.muted,
                          ),
                        ),
                      if (item.canCancel) ...[
                        const SizedBox(height: 6),
                        TextButton.icon(
                          onPressed: () => onCancel(item),
                          icon: const Icon(Icons.close_rounded, size: 17),
                          label: const Text('إلغاء الحجز'),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _RoomsTab extends StatelessWidget {
  final List<RoomReservationItem> items;
  final Future<void> Function(RoomReservationItem) onCancel;
  const _RoomsTab({required this.items, required this.onCancel});

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return const SingleChildScrollView(
        child: ManaraEmptyState(
          icon: Icons.meeting_room_outlined,
          title: 'لا توجد حجوزات غرف',
          message: 'اختر غرفة ووقتاً مناسباً وسيظهر الحجز هنا بعد الدفع.',
        ),
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 32),
      itemCount: items.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (_, index) {
        final item = items[index];
        final canCancel =
            item.status == 'CONFIRMED' &&
            item.startTime != null &&
            item.startTime!.isAfter(DateTime.now());
        return Card(
          clipBehavior: Clip.antiAlias,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ManaraImage(
                url: item.roomImageUrl,
                width: double.infinity,
                height: 145,
                borderRadius: BorderRadius.zero,
                fallbackIcon: Icons.meeting_room_outlined,
              ),
              Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            item.roomName,
                            style: const TextStyle(
                              fontWeight: FontWeight.w900,
                              fontSize: 16,
                            ),
                          ),
                        ),
                        ManaraStatusChip(
                          label: item.status == 'CONFIRMED'
                              ? 'مؤكد'
                              : item.status == 'COMPLETED'
                              ? 'مكتمل'
                              : item.status,
                          color: item.status == 'CONFIRMED'
                              ? AppTheme.teal
                              : AppTheme.muted,
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${formatDate(item.startTime, time: true)} → ${formatDate(item.endTime, time: true)}',
                      style: const TextStyle(
                        fontSize: 11.5,
                        color: AppTheme.muted,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '${item.totalPrice.toStringAsFixed(2)} USD',
                      style: const TextStyle(
                        color: AppTheme.teal,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    if (item.discountAmount > 0)
                      Text(
                        'وفرت ${item.discountAmount.toStringAsFixed(2)} USD',
                        style: const TextStyle(
                          fontSize: 10.5,
                          color: AppTheme.teal,
                        ),
                      ),
                    if (canCancel)
                      Align(
                        alignment: Alignment.centerLeft,
                        child: TextButton(
                          onPressed: () => onCancel(item),
                          child: const Text('إلغاء الحجز'),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _DigitalTab extends StatelessWidget {
  final List<DigitalAccessItem> items;
  const _DigitalTab({required this.items});

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return const SingleChildScrollView(
        child: ManaraEmptyState(
          icon: Icons.tablet_android_outlined,
          title: 'مكتبتك الرقمية فارغة',
          message:
              'اشترِ أو استأجر نسخة رقمية، أو استفد من الكتب المشمولة بالعضوية.',
        ),
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 32),
      itemCount: items.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (_, index) {
        final item = items[index];
        return Card(
          child: InkWell(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => DigitalReaderScreen(bookId: item.bookId),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(13),
              child: Row(
                children: [
                  ManaraImage(
                    url: item.bookCoverUrl,
                    width: 66,
                    height: 96,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.bookTitle,
                          style: const TextStyle(fontWeight: FontWeight.w900),
                        ),
                        if (item.bookAuthor.isNotEmpty)
                          Text(
                            item.bookAuthor,
                            style: const TextStyle(
                              fontSize: 11,
                              color: AppTheme.muted,
                            ),
                          ),
                        const SizedBox(height: 8),
                        ManaraStatusChip(
                          label: item.source == 'MEMBERSHIP'
                              ? 'ضمن العضوية'
                              : item.source == 'RENTAL'
                              ? 'استئجار رقمي'
                              : 'نسخة رقمية',
                          color: const Color(0xFF66508B),
                        ),
                        if (item.endDate != null) ...[
                          const SizedBox(height: 5),
                          Text(
                            'الوصول حتى ${formatDate(item.endDate)}',
                            style: const TextStyle(
                              fontSize: 10.5,
                              color: AppTheme.muted,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const Icon(
                    Icons.chrome_reader_mode_outlined,
                    color: AppTheme.teal,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _PurchasesTab extends StatelessWidget {
  final List<PurchaseItem> items;
  const _PurchasesTab({required this.items});

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return const SingleChildScrollView(
        child: ManaraEmptyState(
          icon: Icons.shopping_bag_outlined,
          title: 'لا توجد مشتريات',
          message: 'مشتريات النسخ الورقية والرقمية ستظهر هنا.',
        ),
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 32),
      itemCount: items.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (_, index) {
        final item = items[index];
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(13),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ManaraImage(
                  url: item.bookCoverUrl,
                  width: 66,
                  height: 94,
                  borderRadius: BorderRadius.circular(10),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.bookTitle,
                        style: const TextStyle(fontWeight: FontWeight.w900),
                      ),
                      if (item.bookAuthor.isNotEmpty)
                        Text(
                          item.bookAuthor,
                          style: const TextStyle(
                            fontSize: 11,
                            color: AppTheme.muted,
                          ),
                        ),
                      const SizedBox(height: 7),
                      Text(
                        '${item.totalAmount.toStringAsFixed(2)} USD • كمية ${item.quantity}',
                        style: const TextStyle(fontWeight: FontWeight.w800),
                      ),
                      Text(
                        item.purchaseType == 'DIGITAL'
                            ? 'نسخة رقمية'
                            : 'نسخة ورقية',
                        style: const TextStyle(
                          fontSize: 10.5,
                          color: AppTheme.muted,
                        ),
                      ),
                      if (item.purchaseType != 'DIGITAL')
                        Text(
                          'التسليم: ${item.fulfillmentStatus}',
                          style: const TextStyle(
                            fontSize: 10.5,
                            color: AppTheme.muted,
                          ),
                        ),
                      Text(
                        formatDate(item.purchaseDate, time: true),
                        style: const TextStyle(
                          fontSize: 10,
                          color: AppTheme.muted,
                        ),
                      ),
                    ],
                  ),
                ),
                ManaraStatusChip(
                  label: item.status,
                  color: item.status == 'COMPLETED'
                      ? AppTheme.teal
                      : const Color(0xFF9A6D21),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _PaymentsTab extends StatelessWidget {
  final List<PaymentItem> items;
  const _PaymentsTab({required this.items});

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return const SingleChildScrollView(
        child: ManaraEmptyState(
          icon: Icons.receipt_long_outlined,
          title: 'لا توجد مدفوعات',
          message: 'سجل عمليات الدفع المكتملة سيظهر هنا.',
        ),
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 32),
      itemCount: items.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (_, index) {
        final item = items[index];
        return Card(
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 15,
              vertical: 8,
            ),
            leading: Container(
              width: 43,
              height: 43,
              decoration: BoxDecoration(
                color: const Color(0xFFE7F1EE),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.payments_outlined, color: AppTheme.teal),
            ),
            title: Text(
              item.purpose,
              style: const TextStyle(fontWeight: FontWeight.w800),
            ),
            subtitle: Text(
              '${item.referenceCode}\n${formatDate(item.paidAt, time: true)}',
            ),
            isThreeLine: true,
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${item.amount.toStringAsFixed(2)} USD',
                  style: const TextStyle(fontWeight: FontWeight.w900),
                ),
                Text(
                  item.paymentMethod,
                  style: const TextStyle(fontSize: 9.5, color: AppTheme.muted),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
