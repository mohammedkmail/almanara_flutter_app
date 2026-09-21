import 'package:flutter/material.dart';

import '../models/study_room.dart';
import '../services/library_service.dart';
import '../services/payment_launcher.dart';
import '../theme/app_theme.dart';
import '../widgets/api_error_view.dart';
import '../widgets/manara_components.dart';

class ReserveRoomScreen extends StatefulWidget {
  final StudyRoom room;
  const ReserveRoomScreen({super.key, required this.room});

  @override
  State<ReserveRoomScreen> createState() => _ReserveRoomScreenState();
}

class _ReserveRoomScreenState extends State<ReserveRoomScreen> {
  DateTime? _start;
  DateTime? _end;
  Map<String, dynamic>? _quote;
  bool _busy = false;

  Future<DateTime?> _pickDateTime(DateTime initial) async {
    final date = await showDatePicker(
      context: context,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      initialDate: initial.isBefore(DateTime.now()) ? DateTime.now() : initial,
    );
    if (date == null || !mounted) return null;
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(initial),
    );
    if (time == null) return null;
    return DateTime(date.year, date.month, date.day, time.hour, time.minute);
  }

  Future<void> _chooseStart() async {
    final chosen = await _pickDateTime(
      _start ?? DateTime.now().add(const Duration(hours: 1)),
    );
    if (chosen == null) return;
    setState(() {
      _start = chosen;
      if (_end == null || !_end!.isAfter(chosen)) {
        _end = chosen.add(const Duration(hours: 1));
      }
      _quote = null;
    });
  }

  Future<void> _chooseEnd() async {
    final chosen = await _pickDateTime(
      _end ?? (_start ?? DateTime.now()).add(const Duration(hours: 1)),
    );
    if (chosen == null) return;
    setState(() {
      _end = chosen;
      _quote = null;
    });
  }

  Future<void> _quotePrice() async {
    if (_start == null || _end == null || widget.room.id == null) return;
    setState(() => _busy = true);
    try {
      final result = await LibraryService.instance.roomQuote(
        roomId: widget.room.id!,
        start: _start!,
        end: _end!,
      );
      if (mounted) setState(() => _quote = result);
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(apiErrorMessage(error))));
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _checkout() async {
    if (_start == null || _end == null || widget.room.id == null) return;
    if (_quote == null) {
      await _quotePrice();
      if (_quote == null) return;
    }
    setState(() => _busy = true);
    try {
      final launch = await LibraryService.instance.roomCheckout(
        roomId: widget.room.id!,
        start: _start!,
        end: _end!,
      );
      await openPaymentUrl(launch.paymentUrl);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('أكمل الدفع، وبعد نجاحه سيظهر الحجز في مكتبتك.'),
          ),
        );
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(apiErrorMessage(error))));
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final room = widget.room;
    final title = room.name.isEmpty ? 'غرفة ${room.roomNumber}' : room.name;
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(title: const Text('حجز غرفة')),
        body: ListView(
          padding: const EdgeInsets.fromLTRB(18, 4, 18, 32),
          children: [
            Row(
              children: [
                ManaraImage(
                  url: room.imageUrl,
                  width: 92,
                  height: 92,
                  borderRadius: BorderRadius.circular(15),
                  fallbackIcon: Icons.meeting_room_outlined,
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '${room.capacity} أشخاص • ${room.hourlyPrice.toStringAsFixed(2)} USD/ساعة',
                        style: const TextStyle(color: AppTheme.muted),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 28),
            const ManaraSectionTitle(
              title: 'اختر الفترة',
              subtitle: 'الحد الأدنى 30 دقيقة، ويجب أن يبدأ الحجز في المستقبل.',
            ),
            const SizedBox(height: 12),
            _DateBox(
              label: 'وقت البداية',
              value: formatDate(_start, time: true),
              icon: Icons.login_rounded,
              onTap: _chooseStart,
            ),
            const SizedBox(height: 10),
            _DateBox(
              label: 'وقت النهاية',
              value: formatDate(_end, time: true),
              icon: Icons.logout_rounded,
              onTap: _chooseEnd,
            ),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: _busy || _start == null || _end == null
                  ? null
                  : _quotePrice,
              icon: const Icon(Icons.calculate_outlined),
              label: const Text('تحقق من التوفر واحسب السعر'),
            ),
            if (_busy) ...[
              const SizedBox(height: 14),
              const LinearProgressIndicator(),
            ],
            if (_quote != null) ...[
              const SizedBox(height: 28),
              const ManaraSectionTitle(
                title: 'ملخص الحجز',
                subtitle:
                    'هذا السعر أعاده الخادم بعد فحص التوفر والعطل والخصومات.',
              ),
              const SizedBox(height: 12),
              _QuoteCard(quote: _quote!),
              const SizedBox(height: 18),
              ElevatedButton.icon(
                onPressed: _busy ? null : _checkout,
                icon: const Icon(Icons.lock_outline_rounded),
                label: const Text('المتابعة إلى الدفع الآمن'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _DateBox extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final VoidCallback onTap;
  const _DateBox({
    required this.label,
    required this.value,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) => Material(
    color: Colors.white,
    borderRadius: BorderRadius.circular(15),
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(15),
      child: Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: AppTheme.border),
        ),
        child: Row(
          children: [
            Icon(icon, color: AppTheme.teal),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(fontSize: 11, color: AppTheme.muted),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: const TextStyle(fontWeight: FontWeight.w800),
                  ),
                ],
              ),
            ),
            const Icon(Icons.edit_calendar_outlined, color: AppTheme.muted),
          ],
        ),
      ),
    ),
  );
}

class _QuoteCard extends StatelessWidget {
  final Map<String, dynamic> quote;
  const _QuoteCard({required this.quote});

  double _n(String key) {
    final value = quote[key];
    if (value is num) return value.toDouble();
    return double.tryParse('$value') ?? 0;
  }

  @override
  Widget build(BuildContext context) {
    final discount = _n('discountAmount');
    final percentage = _n('discountPercentage');
    return Container(
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(17),
        border: Border.all(color: AppTheme.border),
      ),
      child: Column(
        children: [
          _line('المدة', '${_n('durationHours').toStringAsFixed(1)} ساعة'),
          _line('السعر الأساسي', '${_n('basePrice').toStringAsFixed(2)} USD'),
          if (discount > 0)
            _line(
              'الخصم (${percentage.toStringAsFixed(0)}%)',
              '-${discount.toStringAsFixed(2)} USD',
              valueColor: AppTheme.teal,
            ),
          if ((quote['ruleName'] ?? '').toString().isNotEmpty)
            _line('قاعدة السعر', quote['ruleName'].toString()),
          const Divider(height: 24),
          _line(
            'الإجمالي',
            '${_n('totalPrice').toStringAsFixed(2)} USD',
            bold: true,
            valueColor: AppTheme.teal,
          ),
        ],
      ),
    );
  }

  Widget _line(
    String label,
    String value, {
    bool bold = false,
    Color? valueColor,
  }) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 5),
    child: Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              color: bold ? AppTheme.ink : AppTheme.muted,
              fontWeight: bold ? FontWeight.w900 : FontWeight.w500,
            ),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: valueColor ?? AppTheme.ink,
            fontWeight: bold ? FontWeight.w900 : FontWeight.w700,
          ),
        ),
      ],
    ),
  );
}
