import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../models/api_models.dart';
import '../../models/study_room.dart';
import '../../services/library_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/api_error_view.dart';
import '../../widgets/manara_components.dart';

class AdminOperationsScreen extends StatefulWidget {
  const AdminOperationsScreen({super.key});

  @override
  State<AdminOperationsScreen> createState() => _AdminOperationsScreenState();
}

class _AdminOperationsScreenState extends State<AdminOperationsScreen>
    with SingleTickerProviderStateMixin {
  late Future<AdminOperations> _future;
  late final TabController _tabs;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 8, vsync: this);
    _reload();
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  void _reload() {
    _future = LibraryService.instance.adminOperations();
  }

  Future<void> _refresh() async {
    setState(_reload);
    await _future;
  }

  void _snack(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _run(Future<void> Function() action) async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      await action();
      if (mounted) await _refresh();
    } catch (error) {
      _snack(apiErrorMessage(error));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _returnBorrowing(BorrowingItem item) async {
    await _run(() async {
      final updated = await LibraryService.instance.adminReturnBorrowing(
        item.id,
      );
      _snack('تمت إعادة ${updated.bookTitle}.');
    });
  }

  Future<void> _assignCopy(BookReservation reservation) async {
    if (reservation.bookId == null) return;
    final copies = await LibraryService.instance.adminBookCopies(
      bookId: reservation.bookId,
    );
    final available = copies.where((e) => e.status == 'AVAILABLE').toList();
    if (!mounted) return;
    if (available.isEmpty) {
      _snack('لا توجد نسخة متاحة لهذا الكتاب.');
      return;
    }
    final selected = await showModalBottomSheet<BookCopyItem>(
      context: context,
      showDragHandle: true,
      builder: (context) => ListView(
        shrinkWrap: true,
        padding: const EdgeInsets.fromLTRB(18, 0, 18, 24),
        children: [
          const Text(
            'اختر النسخة التي ستُحجز',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 10),
          ...available.map(
            (copy) => Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                title: Text(copy.copyCode),
                subtitle: Text(copy.bookTitle),
                trailing: const Icon(Icons.chevron_left_rounded),
                onTap: () => Navigator.pop(context, copy),
              ),
            ),
          ),
        ],
      ),
    );
    if (selected == null) return;
    await _run(() async {
      await LibraryService.instance.adminAssignReservationCopy(
        reservation.id,
        selected.id,
      );
      _snack('تم تجهيز الحجز بالنسخة ${selected.copyCode}.');
    });
  }

  Future<void> _handover(BookReservation reservation) async {
    String method = 'CASH';
    final notes = TextEditingController();
    final confirmed = await showModalBottomSheet<bool>(
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
                'تسليم الكتاب للمستخدم',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 8),
              Text(
                reservation.feeAmount <= 0
                    ? 'الرسوم 0.00 USD حسب العضوية الحالية.'
                    : 'رسوم الاستعارة ${reservation.feeAmount.toStringAsFixed(2)} USD. إذا لم تكن مدفوعة سيُسجل الدفع على الكاونتر.',
                style: const TextStyle(color: AppTheme.muted),
              ),
              const SizedBox(height: 14),
              DropdownButtonFormField<String>(
                initialValue: method,
                decoration: const InputDecoration(labelText: 'طريقة الدفع'),
                items: const [
                  DropdownMenuItem(value: 'CASH', child: Text('نقدي')),
                  DropdownMenuItem(
                    value: 'CARD',
                    child: Text('بطاقة على الكاونتر'),
                  ),
                ],
                onChanged: (value) {
                  if (value != null) setSheetState(() => method = value);
                },
              ),
              const SizedBox(height: 12),
              TextField(
                controller: notes,
                decoration: const InputDecoration(
                  labelText: 'ملاحظات اختيارية',
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(sheetContext, true),
                  child: const Text('تأكيد التسليم'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
    if (confirmed != true) {
      notes.dispose();
      return;
    }
    await _run(() async {
      await LibraryService.instance.adminReservationHandover(
        reservation.id,
        paymentMethod: method,
        notes: notes.text,
      );
      _snack('تم تسليم الكتاب وفتح سجل الإعارة.');
    });
    notes.dispose();
  }

  Future<void> _outForDelivery(BookReservation reservation) async {
    await _run(() async {
      await LibraryService.instance.adminReservationOutForDelivery(
        reservation.id,
      );
      _snack('تم تحديث الحجز إلى خارج للتوصيل.');
    });
  }

  Future<void> _cancelRoom(RoomReservationItem item) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('إلغاء حجز الغرفة؟'),
        content: Text(
          'سيتم إلغاء حجز ${item.roomName} للمستخدم ${item.userName ?? ''}. لا ينفذ النظام استرداداً مالياً تلقائياً من هذه الشاشة.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('رجوع'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('إلغاء الحجز'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    await _run(() async {
      await LibraryService.instance.cancelRoomReservation(item.id);
      _snack('تم إلغاء حجز الغرفة.');
    });
  }

  Future<void> _cancelMembership(MembershipInfo item) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('إلغاء العضوية؟'),
        content: Text(
          'سيتم إلغاء عضوية ${item.userName.isEmpty ? 'المستخدم' : item.userName}. العضويات المدفوعة تحتاج معالجة الاسترداد إدارياً إذا كان ذلك مطلوباً.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('رجوع'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('إلغاء العضوية'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    await _run(() async {
      await LibraryService.instance.cancelMembership(item.id);
      _snack('تم إلغاء العضوية.');
    });
  }

  Future<void> _purchaseFulfillment(PurchaseItem item) async {
    final statuses = item.fulfillmentMethod == 'DELIVERY'
        ? const <String>['PREPARING', 'OUT_FOR_DELIVERY', 'FULFILLED']
        : const <String>['PREPARING', 'READY_FOR_PICKUP', 'FULFILLED'];
    final selected = await showModalBottomSheet<String>(
      context: context,
      showDragHandle: true,
      builder: (context) => ListView(
        shrinkWrap: true,
        padding: const EdgeInsets.fromLTRB(18, 0, 18, 24),
        children: [
          const Text(
            'تحديث حالة التجهيز',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 10),
          ...statuses.map(
            (status) => ListTile(
              title: Text(_fulfillmentLabel(status)),
              trailing: item.fulfillmentStatus == status
                  ? const Icon(Icons.check_circle, color: AppTheme.teal)
                  : const Icon(Icons.chevron_left_rounded),
              onTap: () => Navigator.pop(context, status),
            ),
          ),
        ],
      ),
    );
    if (selected == null) return;
    await _run(() async {
      await LibraryService.instance.adminUpdatePurchaseFulfillment(
        item.id,
        selected,
      );
      _snack('تم تحديث حالة التجهيز.');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('العمليات'),
          actions: [
            IconButton(
              tooltip: 'تحديث',
              onPressed: _busy ? null : () => setState(_reload),
              icon: const Icon(Icons.refresh_rounded),
            ),
          ],
          bottom: TabBar(
            controller: _tabs,
            isScrollable: true,
            tabAlignment: TabAlignment.start,
            tabs: const [
              Tab(text: 'الاستعارات'),
              Tab(text: 'حجوزات الكتب'),
              Tab(text: 'حجوزات الغرف'),
              Tab(text: 'إدارة الغرف'),
              Tab(text: 'المشتريات'),
              Tab(text: 'المدفوعات'),
              Tab(text: 'العضويات'),
              Tab(text: 'الرقمي'),
            ],
          ),
        ),
        body: FutureBuilder<AdminOperations>(
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
            return Stack(
              children: [
                TabBarView(
                  controller: _tabs,
                  children: [
                    _BorrowingOperations(
                      items: data.borrowings,
                      onRefresh: _refresh,
                      onReturn: _returnBorrowing,
                    ),
                    _ReservationOperations(
                      items: data.reservations,
                      onRefresh: _refresh,
                      onAssignCopy: _assignCopy,
                      onHandover: _handover,
                      onOutForDelivery: _outForDelivery,
                    ),
                    _RoomOperations(
                      items: data.roomReservations,
                      onRefresh: _refresh,
                      onCancel: _cancelRoom,
                    ),
                    const _RoomManagement(),
                    _PurchaseOperations(
                      items: data.purchases,
                      onRefresh: _refresh,
                      onFulfillment: _purchaseFulfillment,
                    ),
                    _PaymentOperations(
                      items: data.payments,
                      onRefresh: _refresh,
                    ),
                    _MembershipOperations(
                      items: data.memberships,
                      onRefresh: _refresh,
                      onCancel: _cancelMembership,
                    ),
                    _DigitalOperations(
                      items: data.digitalAccesses,
                      onRefresh: _refresh,
                    ),
                  ],
                ),
                if (_busy)
                  const Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    child: LinearProgressIndicator(),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _BorrowingOperations extends StatelessWidget {
  final List<BorrowingItem> items;
  final Future<void> Function() onRefresh;
  final Future<void> Function(BorrowingItem) onReturn;
  const _BorrowingOperations({
    required this.items,
    required this.onRefresh,
    required this.onReturn,
  });

  @override
  Widget build(BuildContext context) => _AdminList<BorrowingItem>(
    items: items,
    onRefresh: onRefresh,
    emptyTitle: 'لا توجد استعارات',
    builder: (item) => Card(
      child: Padding(
        padding: const EdgeInsets.all(13),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ManaraImage(
              url: item.bookCoverUrl,
              width: 64,
              height: 92,
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
                  Text(
                    item.userName,
                    style: const TextStyle(fontSize: 11, color: AppTheme.muted),
                  ),
                  const SizedBox(height: 6),
                  ManaraStatusChip(
                    label: item.statusLabel,
                    color: item.status == 'OVERDUE'
                        ? Colors.redAccent
                        : AppTheme.teal,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'موعد الإعادة: ${formatDate(item.dueDate)}',
                    style: const TextStyle(
                      fontSize: 10.5,
                      color: AppTheme.muted,
                    ),
                  ),
                  if (item.open)
                    Align(
                      alignment: Alignment.centerLeft,
                      child: TextButton.icon(
                        onPressed: () => onReturn(item),
                        icon: const Icon(
                          Icons.assignment_return_outlined,
                          size: 17,
                        ),
                        label: const Text('تسجيل الإعادة'),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

class _ReservationOperations extends StatelessWidget {
  final List<BookReservation> items;
  final Future<void> Function() onRefresh;
  final Future<void> Function(BookReservation) onAssignCopy;
  final Future<void> Function(BookReservation) onHandover;
  final Future<void> Function(BookReservation) onOutForDelivery;
  const _ReservationOperations({
    required this.items,
    required this.onRefresh,
    required this.onAssignCopy,
    required this.onHandover,
    required this.onOutForDelivery,
  });

  @override
  Widget build(BuildContext context) => _AdminList<BookReservation>(
    items: items,
    onRefresh: onRefresh,
    emptyTitle: 'لا توجد حجوزات كتب',
    builder: (item) {
      final canHandover = const [
        'READY',
        'PAID',
        'CONFIRMED',
      ].contains(item.status);
      final canDeliver =
          const ['PAID', 'CONFIRMED'].contains(item.status) &&
          item.fulfillmentMethod == 'DELIVERY' &&
          item.fulfillmentStatus != 'OUT_FOR_DELIVERY';
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(13),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ManaraImage(
                url: item.bookCoverUrl,
                width: 62,
                height: 90,
                borderRadius: BorderRadius.circular(10),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            item.bookTitle,
                            style: const TextStyle(fontWeight: FontWeight.w900),
                          ),
                        ),
                        ManaraStatusChip(
                          label: item.statusLabel,
                          color: AppTheme.teal,
                        ),
                      ],
                    ),
                    Text(
                      item.userName ?? '',
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppTheme.muted,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      'الرسوم: ${item.feeAmount.toStringAsFixed(2)} USD • ${item.fulfillmentMethod == 'DELIVERY' ? 'توصيل' : 'استلام'}',
                      style: const TextStyle(
                        fontSize: 10.5,
                        color: AppTheme.muted,
                      ),
                    ),
                    if (item.assignedCopyCode?.isNotEmpty == true)
                      Text(
                        'النسخة: ${item.assignedCopyCode}',
                        style: const TextStyle(
                          fontSize: 10.5,
                          color: AppTheme.muted,
                        ),
                      ),
                    Wrap(
                      spacing: 4,
                      children: [
                        if (item.status == 'WAITING')
                          TextButton(
                            onPressed: () => onAssignCopy(item),
                            child: const Text('تخصيص نسخة'),
                          ),
                        if (canHandover)
                          TextButton(
                            onPressed: () => onHandover(item),
                            child: const Text('تسليم'),
                          ),
                        if (canDeliver)
                          TextButton(
                            onPressed: () => onOutForDelivery(item),
                            child: const Text('خارج للتوصيل'),
                          ),
                      ],
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

class _RoomOperations extends StatelessWidget {
  final List<RoomReservationItem> items;
  final Future<void> Function() onRefresh;
  final Future<void> Function(RoomReservationItem) onCancel;

  const _RoomOperations({
    required this.items,
    required this.onRefresh,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) => _AdminList<RoomReservationItem>(
    items: items,
    onRefresh: onRefresh,
    emptyTitle: 'لا توجد حجوزات غرف',
    builder: (item) {
      final canCancel =
          item.status == 'CONFIRMED' &&
          (item.startTime?.isAfter(DateTime.now()) ?? false);
      return Card(
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ManaraImage(
              url: item.roomImageUrl,
              width: double.infinity,
              height: 130,
              borderRadius: BorderRadius.zero,
              fallbackIcon: Icons.meeting_room_outlined,
            ),
            Padding(
              padding: const EdgeInsets.all(13),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.roomName,
                          style: const TextStyle(fontWeight: FontWeight.w900),
                        ),
                        Text(
                          item.userName ?? '',
                          style: const TextStyle(
                            fontSize: 11,
                            color: AppTheme.muted,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${formatDate(item.startTime, time: true)} → ${formatDate(item.endTime, time: true)}',
                          style: const TextStyle(
                            fontSize: 10.5,
                            color: AppTheme.muted,
                          ),
                        ),
                        if (item.discountPercentage > 0)
                          Text(
                            'خصم ${item.discountPercentage.toStringAsFixed(0)}% • وفّر ${item.discountAmount.toStringAsFixed(2)} USD',
                            style: const TextStyle(
                              fontSize: 10.5,
                              color: AppTheme.teal,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        if (canCancel)
                          TextButton.icon(
                            onPressed: () => onCancel(item),
                            icon: const Icon(Icons.cancel_outlined, size: 17),
                            label: const Text('إلغاء الحجز'),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      ManaraStatusChip(
                        label: item.status,
                        color: item.status == 'CONFIRMED'
                            ? AppTheme.teal
                            : AppTheme.muted,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '${item.totalPrice.toStringAsFixed(2)} USD',
                        style: const TextStyle(fontWeight: FontWeight.w900),
                      ),
                    ],
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

class _RoomManagement extends StatefulWidget {
  const _RoomManagement();

  @override
  State<_RoomManagement> createState() => _RoomManagementState();
}

class _RoomManagementState extends State<_RoomManagement> {
  late Future<List<StudyRoom>> _future;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _reload();
  }

  void _reload() {
    _future = LibraryService.instance.rooms();
  }

  Future<void> _refresh() async {
    setState(_reload);
    await _future;
  }

  void _snack(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _openEditor([StudyRoom? room]) async {
    final changed = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: true,
      builder: (_) => _RoomEditorSheet(room: room),
    );

    if (changed == true && mounted) {
      await _refresh();
    }
  }

  Future<void> _deleteRoom(StudyRoom room) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('حذف الغرفة؟'),
        content: Text(
          'هل تريد حذف ${room.name.isEmpty ? 'غرفة ${room.roomNumber}' : room.name}؟ '
          'إذا كانت مرتبطة بحجوزات سابقة فسيقوم السيرفر بتعطيلها بدل حذفها نهائياً.',
        ),
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
    );

    if (confirmed != true || _busy) return;

    setState(() => _busy = true);
    try {
      final roomId = room.id;
      if (roomId == null) {
        _snack('تعذر تحديد رقم الغرفة.');
        return;
      }

      await LibraryService.instance.deleteRoom(roomId);
      _snack('تم تحديث الغرفة بنجاح.');
      if (mounted) await _refresh();
    } catch (error) {
      _snack(apiErrorMessage(error));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<StudyRoom>>(
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

        final rooms = snapshot.data ?? const <StudyRoom>[];

        return Stack(
          children: [
            RefreshIndicator(
              onRefresh: _refresh,
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(14, 14, 14, 92),
                children: [
                  Row(
                    children: [
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'إدارة غرف الدراسة',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            SizedBox(height: 3),
                            Text(
                              'أضف غرفة أو عدّل بياناتها وصورتها.',
                              style: TextStyle(
                                color: AppTheme.muted,
                                fontSize: 11.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                      FilledButton.icon(
                        onPressed: _busy ? null : () => _openEditor(),
                        icon: const Icon(Icons.add_rounded),
                        label: const Text('غرفة جديدة'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  if (rooms.isEmpty)
                    const ManaraEmptyState(
                      icon: Icons.meeting_room_outlined,
                      title: 'لا توجد غرف',
                      message: 'أضف أول غرفة دراسة من الزر بالأعلى.',
                    )
                  else
                    ...rooms.map(
                      (room) => Card(
                        clipBehavior: Clip.antiAlias,
                        margin: const EdgeInsets.only(bottom: 12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ManaraImage(
                              url: room.imageUrl,
                              width: double.infinity,
                              height: 155,
                              borderRadius: BorderRadius.zero,
                              fallbackIcon: Icons.meeting_room_outlined,
                            ),
                            Padding(
                              padding: const EdgeInsets.all(14),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Expanded(
                                        child: Text(
                                          room.name.isEmpty
                                              ? 'غرفة ${room.roomNumber}'
                                              : room.name,
                                          style: const TextStyle(
                                            fontSize: 17,
                                            fontWeight: FontWeight.w900,
                                          ),
                                        ),
                                      ),
                                      ManaraStatusChip(
                                        label: room.available
                                            ? 'فعالة'
                                            : 'غير فعالة',
                                        color: room.available
                                            ? AppTheme.teal
                                            : AppTheme.muted,
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    'رقم ${room.roomNumber} • ${room.capacity} أشخاص • '
                                    '${room.hourlyPrice.toStringAsFixed(2)} USD/ساعة',
                                    style: const TextStyle(
                                      color: AppTheme.muted,
                                      fontSize: 11,
                                    ),
                                  ),
                                  if (room.location.isNotEmpty) ...[
                                    const SizedBox(height: 4),
                                    Text(
                                      room.location,
                                      style: const TextStyle(
                                        color: AppTheme.muted,
                                        fontSize: 11,
                                      ),
                                    ),
                                  ],
                                  if (room.features.isNotEmpty) ...[
                                    const SizedBox(height: 9),
                                    Wrap(
                                      spacing: 6,
                                      runSpacing: 6,
                                      children: room.features
                                          .map(
                                            (feature) => Chip(
                                              visualDensity:
                                                  VisualDensity.compact,
                                              label: Text(
                                                feature,
                                                style: const TextStyle(
                                                  fontSize: 10,
                                                ),
                                              ),
                                            ),
                                          )
                                          .toList(),
                                    ),
                                  ],
                                  const SizedBox(height: 8),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      TextButton.icon(
                                        onPressed: _busy
                                            ? null
                                            : () => _openEditor(room),
                                        icon: const Icon(
                                          Icons.edit_outlined,
                                          size: 18,
                                        ),
                                        label: const Text('تعديل'),
                                      ),
                                      const SizedBox(width: 4),
                                      TextButton.icon(
                                        onPressed: _busy
                                            ? null
                                            : () => _deleteRoom(room),
                                        icon: const Icon(
                                          Icons.delete_outline,
                                          size: 18,
                                        ),
                                        label: const Text('حذف'),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
            if (_busy)
              const Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: LinearProgressIndicator(),
              ),
          ],
        );
      },
    );
  }
}

class _RoomEditorSheet extends StatefulWidget {
  final StudyRoom? room;

  const _RoomEditorSheet({this.room});

  @override
  State<_RoomEditorSheet> createState() => _RoomEditorSheetState();
}

class _RoomEditorSheetState extends State<_RoomEditorSheet> {
  final _formKey = GlobalKey<FormState>();
  final _picker = ImagePicker();

  late final TextEditingController _number;
  late final TextEditingController _name;
  late final TextEditingController _description;
  late final TextEditingController _location;
  late final TextEditingController _capacity;
  late final TextEditingController _price;
  late final TextEditingController _features;

  XFile? _selectedImage;
  Uint8List? _selectedBytes;
  bool _removeCurrentImage = false;
  bool _active = true;
  bool _saving = false;

  bool get _editing => widget.room != null;

  @override
  void initState() {
    super.initState();

    final room = widget.room;

    _number = TextEditingController(text: room?.roomNumber ?? '');
    _name = TextEditingController(text: room?.name ?? '');
    _description = TextEditingController(text: room?.description ?? '');
    _location = TextEditingController(text: room?.location ?? '');
    _capacity = TextEditingController(
      text: room == null ? '' : room.capacity.toString(),
    );
    _price = TextEditingController(
      text: room == null ? '' : room.hourlyPrice.toString(),
    );
    _features = TextEditingController(text: room?.features.join(', ') ?? '');

    _active = room?.available ?? true;
  }

  @override
  void dispose() {
    _number.dispose();
    _name.dispose();
    _description.dispose();
    _location.dispose();
    _capacity.dispose();
    _price.dispose();
    _features.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final image = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 88,
      maxWidth: 1800,
    );

    if (image == null) return;

    final bytes = await image.readAsBytes();

    if (!mounted) return;

    setState(() {
      _selectedImage = image;
      _selectedBytes = bytes;
      _removeCurrentImage = false;
    });
  }

  void _removeImage() {
    setState(() {
      _selectedImage = null;
      _selectedBytes = null;
      _removeCurrentImage = true;
    });
  }

  Future<void> _save() async {
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate() || _saving) {
      return;
    }

    setState(() => _saving = true);

    final features = _features.text
        .split(',')
        .map((value) => value.trim())
        .where((value) => value.isNotEmpty)
        .toList();

    final data = <String, dynamic>{
      'roomNumber': _number.text.trim(),
      'name': _name.text.trim(),
      'description': _description.text.trim(),
      'location': _location.text.trim(),
      'capacity': int.parse(_capacity.text.trim()),
      'hourlyPrice': double.parse(_price.text.trim()),
      'features': features,
      'active': _active,
    };

    try {
      if (_editing) {
        final roomId = widget.room!.id;
        if (roomId == null) {
          throw StateError('تعذر تحديد رقم الغرفة.');
        }

        await LibraryService.instance.updateRoomWithImage(
          roomId,
          data,
          image: _selectedImage,
          removeImage: _removeCurrentImage && _selectedImage == null,
        );
      } else {
        await LibraryService.instance.saveRoomWithImage(
          data,
          image: _selectedImage,
        );
      }

      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(apiErrorMessage(error))));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  String? _required(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'هذا الحقل مطلوب.';
    }
    return null;
  }

  String? _positiveInt(String? value) {
    final requiredError = _required(value);
    if (requiredError != null) return requiredError;

    final parsed = int.tryParse(value!.trim());
    if (parsed == null || parsed <= 0) {
      return 'أدخل رقماً صحيحاً أكبر من صفر.';
    }

    return null;
  }

  String? _positiveNumber(String? value) {
    final requiredError = _required(value);
    if (requiredError != null) return requiredError;

    final parsed = double.tryParse(value!.trim());
    if (parsed == null || parsed < 0) {
      return 'أدخل سعراً صحيحاً.';
    }

    return null;
  }

  Widget _imagePreview() {
    if (_selectedBytes != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Image.memory(
          _selectedBytes!,
          width: double.infinity,
          height: 185,
          fit: BoxFit.cover,
        ),
      );
    }

    if (!_removeCurrentImage && widget.room?.imageUrl?.isNotEmpty == true) {
      return ManaraImage(
        url: widget.room!.imageUrl,
        width: double.infinity,
        height: 185,
        borderRadius: BorderRadius.circular(16),
        fallbackIcon: Icons.meeting_room_outlined,
      );
    }

    return Container(
      width: double.infinity,
      height: 150,
      decoration: BoxDecoration(
        color: const Color(0xFFF1F3EE),
        borderRadius: BorderRadius.circular(16),
      ),
      alignment: Alignment.center,
      child: const Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.add_photo_alternate_outlined,
            size: 38,
            color: AppTheme.muted,
          ),
          SizedBox(height: 6),
          Text(
            'لا توجد صورة محددة',
            style: TextStyle(color: AppTheme.muted, fontSize: 11),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          18,
          0,
          18,
          18 + MediaQuery.viewInsetsOf(context).bottom,
        ),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _editing ? 'تعديل غرفة الدراسة' : 'إضافة غرفة دراسة',
                  style: const TextStyle(
                    fontSize: 21,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'أدخل بيانات الغرفة واختر صورة من الجهاز.',
                  style: TextStyle(color: AppTheme.muted, fontSize: 11.5),
                ),
                const SizedBox(height: 16),
                _imagePreview(),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    OutlinedButton.icon(
                      onPressed: _saving ? null : _pickImage,
                      icon: const Icon(Icons.photo_library_outlined),
                      label: Text(_editing ? 'تغيير الصورة' : 'اختيار صورة'),
                    ),
                    if (_selectedImage != null ||
                        (!_removeCurrentImage &&
                            widget.room?.imageUrl?.isNotEmpty == true))
                      TextButton.icon(
                        onPressed: _saving ? null : _removeImage,
                        icon: const Icon(Icons.delete_outline),
                        label: const Text('إزالة الصورة'),
                      ),
                  ],
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _number,
                  validator: _required,
                  decoration: const InputDecoration(
                    labelText: 'رقم الغرفة',
                    prefixIcon: Icon(Icons.tag_rounded),
                  ),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _name,
                  validator: _required,
                  decoration: const InputDecoration(
                    labelText: 'اسم الغرفة',
                    prefixIcon: Icon(Icons.meeting_room_outlined),
                  ),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _description,
                  minLines: 2,
                  maxLines: 4,
                  decoration: const InputDecoration(
                    labelText: 'الوصف',
                    prefixIcon: Icon(Icons.description_outlined),
                  ),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _location,
                  validator: _required,
                  decoration: const InputDecoration(
                    labelText: 'الموقع',
                    prefixIcon: Icon(Icons.location_on_outlined),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _capacity,
                        keyboardType: TextInputType.number,
                        validator: _positiveInt,
                        decoration: const InputDecoration(
                          labelText: 'السعة',
                          prefixIcon: Icon(Icons.groups_2_outlined),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextFormField(
                        controller: _price,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        validator: _positiveNumber,
                        decoration: const InputDecoration(
                          labelText: 'السعر/ساعة',
                          prefixIcon: Icon(Icons.attach_money_rounded),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _features,
                  minLines: 1,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'المميزات',
                    hintText: 'واي فاي، شاشة، سبورة',
                    prefixIcon: Icon(Icons.auto_awesome_outlined),
                  ),
                ),
                const SizedBox(height: 10),
                SwitchListTile.adaptive(
                  contentPadding: EdgeInsets.zero,
                  value: _active,
                  onChanged: _saving
                      ? null
                      : (value) => setState(() => _active = value),
                  title: const Text(
                    'الغرفة فعالة',
                    style: TextStyle(fontWeight: FontWeight.w800),
                  ),
                  subtitle: const Text(
                    'الغرفة الفعالة تظهر للمستخدمين ويمكن حجزها.',
                  ),
                ),
                const SizedBox(height: 14),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: _saving ? null : _save,
                    icon: _saving
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.save_outlined),
                    label: Text(
                      _saving
                          ? 'جارٍ الحفظ...'
                          : _editing
                          ? 'حفظ التعديلات'
                          : 'إضافة الغرفة',
                    ),
                  ),
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PurchaseOperations extends StatelessWidget {
  final List<PurchaseItem> items;
  final Future<void> Function() onRefresh;
  final Future<void> Function(PurchaseItem) onFulfillment;
  const _PurchaseOperations({
    required this.items,
    required this.onRefresh,
    required this.onFulfillment,
  });

  @override
  Widget build(BuildContext context) => _AdminList<PurchaseItem>(
    items: items,
    onRefresh: onRefresh,
    emptyTitle: 'لا توجد مشتريات',
    builder: (item) => Card(
      child: Padding(
        padding: const EdgeInsets.all(13),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ManaraImage(
              url: item.bookCoverUrl,
              width: 62,
              height: 90,
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
                  Text(
                    item.userName ?? '',
                    style: const TextStyle(fontSize: 11, color: AppTheme.muted),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    '${item.purchaseType} • ${item.totalAmount.toStringAsFixed(2)} USD • كمية ${item.quantity}',
                    style: const TextStyle(
                      fontSize: 10.5,
                      color: AppTheme.muted,
                    ),
                  ),
                  if (item.purchaseType == 'PHYSICAL') ...[
                    Text(
                      'التجهيز: ${_fulfillmentLabel(item.fulfillmentStatus)}',
                      style: const TextStyle(
                        fontSize: 10.5,
                        color: AppTheme.muted,
                      ),
                    ),
                    if (item.status == 'COMPLETED')
                      TextButton(
                        onPressed: () => onFulfillment(item),
                        child: const Text('تحديث التجهيز'),
                      ),
                  ],
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
    ),
  );
}

class _PaymentOperations extends StatelessWidget {
  final List<PaymentItem> items;
  final Future<void> Function() onRefresh;
  const _PaymentOperations({required this.items, required this.onRefresh});

  @override
  Widget build(BuildContext context) => _AdminList<PaymentItem>(
    items: items,
    onRefresh: onRefresh,
    emptyTitle: 'لا توجد مدفوعات',
    builder: (item) => Card(
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        leading: Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: const Color(0xFFE7F1EE),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(Icons.payments_outlined, color: AppTheme.teal),
        ),
        title: Text(
          '${item.amount.toStringAsFixed(2)} USD • ${item.purpose}',
          style: const TextStyle(fontWeight: FontWeight.w900),
        ),
        subtitle: Text(
          '${item.userName}\n${item.referenceCode} • ${formatDate(item.paidAt, time: true)}',
        ),
        isThreeLine: true,
        trailing: ManaraStatusChip(
          label: item.status,
          color: item.status == 'COMPLETED'
              ? AppTheme.teal
              : const Color(0xFF9A6D21),
        ),
      ),
    ),
  );
}

class _MembershipOperations extends StatelessWidget {
  final List<MembershipInfo> items;
  final Future<void> Function() onRefresh;
  final Future<void> Function(MembershipInfo) onCancel;

  const _MembershipOperations({
    required this.items,
    required this.onRefresh,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) => _AdminList<MembershipInfo>(
    items: items,
    onRefresh: onRefresh,
    emptyTitle: 'لا توجد عضويات',
    builder: (item) => Card(
      child: Padding(
        padding: const EdgeInsets.all(13),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: const Color(0xFFE7F1EE),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(
                Icons.workspace_premium_outlined,
                color: AppTheme.teal,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.userName.isEmpty
                        ? 'مستخدم #${item.userId ?? ''}'
                        : item.userName,
                    style: const TextStyle(fontWeight: FontWeight.w900),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    '${formatDate(item.startDate)} → ${formatDate(item.endDate)}',
                    style: const TextStyle(
                      fontSize: 10.5,
                      color: AppTheme.muted,
                    ),
                  ),
                  Text(
                    '${item.price.toStringAsFixed(2)} USD${item.paid ? ' • مدفوعة' : ''}',
                    style: const TextStyle(
                      fontSize: 10.5,
                      color: AppTheme.muted,
                    ),
                  ),
                  if (item.canCancel)
                    TextButton.icon(
                      onPressed: () => onCancel(item),
                      icon: const Icon(Icons.cancel_outlined, size: 17),
                      label: const Text('إلغاء العضوية'),
                    ),
                ],
              ),
            ),
            ManaraStatusChip(
              label: item.statusLabel,
              color: item.status == 'ACTIVE' ? AppTheme.teal : AppTheme.muted,
            ),
          ],
        ),
      ),
    ),
  );
}

class _DigitalOperations extends StatelessWidget {
  final List<AdminDigitalAccessItem> items;
  final Future<void> Function() onRefresh;

  const _DigitalOperations({required this.items, required this.onRefresh});

  @override
  Widget build(BuildContext context) => _AdminList<AdminDigitalAccessItem>(
    items: items,
    onRefresh: onRefresh,
    emptyTitle: 'لا توجد وصولات رقمية',
    builder: (item) => Card(
      child: Padding(
        padding: const EdgeInsets.all(13),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ManaraImage(
              url: item.bookCoverUrl,
              width: 62,
              height: 88,
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
                        fontSize: 10.5,
                        color: AppTheme.muted,
                      ),
                    ),
                  const SizedBox(height: 5),
                  Text(
                    item.userName,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    item.accessType == 'RENTAL'
                        ? '${item.accessLabel} • حتى ${formatDate(item.endDate)}'
                        : '${item.accessLabel} • وصول دائم',
                    style: const TextStyle(
                      fontSize: 10.5,
                      color: AppTheme.muted,
                    ),
                  ),
                  if (item.paidAmount > 0)
                    Text(
                      '${item.paidAmount.toStringAsFixed(2)} USD',
                      style: const TextStyle(
                        fontSize: 10.5,
                        color: AppTheme.teal,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                ],
              ),
            ),
            ManaraStatusChip(
              label: item.status,
              color: item.status == 'ACTIVE' ? AppTheme.teal : AppTheme.muted,
            ),
          ],
        ),
      ),
    ),
  );
}

class _AdminList<T> extends StatelessWidget {
  final List<T> items;
  final Future<void> Function() onRefresh;
  final String emptyTitle;
  final Widget Function(T item) builder;
  const _AdminList({
    required this.items,
    required this.onRefresh,
    required this.emptyTitle,
    required this.builder,
  });

  @override
  Widget build(BuildContext context) => RefreshIndicator(
    onRefresh: onRefresh,
    child: items.isEmpty
        ? ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            children: [
              ManaraEmptyState(
                icon: Icons.inbox_outlined,
                title: emptyTitle,
                message: 'اسحب للأسفل لتحديث البيانات.',
              ),
            ],
          )
        : ListView.separated(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 32),
            itemCount: items.length,
            separatorBuilder: (_, __) => const SizedBox(height: 9),
            itemBuilder: (_, index) => builder(items[index]),
          ),
  );
}

String _fulfillmentLabel(String value) => switch (value) {
  'PREPARING' => 'قيد التجهيز',
  'READY_FOR_PICKUP' => 'جاهز للاستلام',
  'OUT_FOR_DELIVERY' => 'خارج للتوصيل',
  'FULFILLED' => 'تم التسليم',
  _ => value,
};
