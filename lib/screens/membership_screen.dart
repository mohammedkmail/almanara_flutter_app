import 'package:flutter/material.dart';

import '../models/api_models.dart';
import '../services/library_service.dart';
import '../services/payment_launcher.dart';
import '../theme/app_theme.dart';
import '../widgets/api_error_view.dart';
import '../widgets/manara_components.dart';

class MembershipScreen extends StatefulWidget {
  const MembershipScreen({super.key});

  @override
  State<MembershipScreen> createState() => _MembershipScreenState();
}

class _MembershipScreenState extends State<MembershipScreen> {
  late Future<MembershipOverview> _future;
  DateTime _start = DateTime.now();
  DateTime _end = DateTime.now().add(const Duration(days: 29));
  Map<String, dynamic>? _quote;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _reload();
  }

  void _reload() {
    _future = LibraryService.instance.membership();
  }

  Future<void> _refresh() async {
    setState(_reload);
    await _future;
  }

  Future<void> _pickStart() async {
    final now = DateTime.now();
    final value = await showDatePicker(
      context: context,
      firstDate: DateTime(now.year, now.month, now.day),
      lastDate: now.add(const Duration(days: 730)),
      initialDate: _start.isBefore(now) ? now : _start,
    );
    if (value == null) return;
    setState(() {
      _start = value;
      if (_end.isBefore(_start)) _end = _start.add(const Duration(days: 29));
      _quote = null;
    });
  }

  Future<void> _pickEnd() async {
    final value = await showDatePicker(
      context: context,
      firstDate: _start,
      lastDate: _start.add(const Duration(days: 730)),
      initialDate: _end.isBefore(_start) ? _start : _end,
    );
    if (value == null) return;
    setState(() {
      _end = value;
      _quote = null;
    });
  }

  Future<void> _calculate() async {
    setState(() => _busy = true);
    try {
      final quote = await LibraryService.instance.membershipQuote(_start, _end);
      if (mounted) setState(() => _quote = quote);
    } catch (error) {
      if (mounted) _snack(apiErrorMessage(error));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _checkout() async {
    setState(() => _busy = true);
    try {
      final launch = await LibraryService.instance.membershipCheckout(
        _start,
        _end,
      );
      await openPaymentUrl(launch.paymentUrl);
      if (mounted) {
        _snack('أكمل الدفع ثم ارجع للتطبيق. ستتفعل العضوية بعد نجاح العملية.');
      }
    } catch (error) {
      if (mounted) _snack(apiErrorMessage(error));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _cancel(MembershipInfo item) async {
    final ok =
        await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('إلغاء العضوية؟'),
            content: const Text(
              'يمكن إلغاء الطلبات القابلة للإلغاء فقط. العضوية المدفوعة الفعالة تحتاج معالجة من الإدارة.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('رجوع'),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('تأكيد الإلغاء'),
              ),
            ],
          ),
        ) ??
        false;
    if (!ok) return;
    try {
      await LibraryService.instance.cancelMembership(item.id);
      _snack('تم إلغاء العضوية.');
      await _refresh();
    } catch (error) {
      _snack(apiErrorMessage(error));
    }
  }

  void _snack(String text) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(title: const Text('عضوية المنارة')),
        body: FutureBuilder<MembershipOverview>(
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
            final active = data.current;
            return RefreshIndicator(
              onRefresh: _refresh,
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(18, 4, 18, 32),
                children: [
                  _MembershipHero(active: active),
                  const SizedBox(height: 24),
                  const ManaraSectionTitle(
                    title: 'ما الذي تحصل عليه؟',
                    subtitle:
                        'المزايا مأخوذة من منطق النظام الحالي، بدون وعود غير موجودة.',
                  ),
                  const SizedBox(height: 12),
                  const _Benefit(
                    icon: Icons.local_library_outlined,
                    title: 'استعارة الكتب الورقية بدون رسوم',
                    text:
                        'طالما العضوية فعالة، يحسب الخادم رسوم الاستعارة للكتاب بقيمة 0.00 USD.',
                  ),
                  const _Benefit(
                    icon: Icons.auto_stories_outlined,
                    title: 'كتب رقمية مشمولة بالعضوية',
                    text:
                        'الكتب التي فعلت الإدارة خيار “مشمول بالعضوية” تصبح قابلة للقراءة خلال فترة العضوية.',
                  ),
                  const _Benefit(
                    icon: Icons.shield_outlined,
                    title: 'سعر موحد من الخادم',
                    text:
                        'التطبيق لا يحسب أهلية العضوية بنفسه؛ السعر النهائي والتحقق من المدة يأتيان من Grails.',
                  ),
                  const SizedBox(height: 26),
                  if (active == null) ...[
                    const ManaraSectionTitle(
                      title: 'ابدأ عضويتك',
                      subtitle: 'اختر الفترة ثم شاهد الخصم والسعر قبل الدفع.',
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _DateChoice(
                            label: 'من',
                            value: formatDate(_start),
                            onTap: _pickStart,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _DateChoice(
                            label: 'إلى',
                            value: formatDate(_end),
                            onTap: _pickEnd,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    OutlinedButton.icon(
                      onPressed: _busy ? null : _calculate,
                      icon: const Icon(Icons.calculate_outlined),
                      label: const Text('احسب السعر'),
                    ),
                    if (_quote != null) ...[
                      const SizedBox(height: 14),
                      _MembershipQuote(quote: _quote!),
                      const SizedBox(height: 14),
                      ElevatedButton.icon(
                        onPressed: _busy ? null : _checkout,
                        icon: const Icon(Icons.lock_outline_rounded),
                        label: const Text('المتابعة للدفع'),
                      ),
                    ],
                  ] else ...[
                    const ManaraSectionTitle(
                      title: 'عضويتك الحالية',
                      subtitle:
                          'الاستعارة المجانية تستمر حتى نهاية هذه الفترة.',
                    ),
                    const SizedBox(height: 12),
                    _MembershipHistoryCard(item: active),
                  ],
                  if (data.discountTiers.isNotEmpty) ...[
                    const SizedBox(height: 26),
                    const ManaraSectionTitle(
                      title: 'خصم المدة',
                      subtitle:
                          'كلما طالت العضوية يطبق النظام مستوى الخصم المناسب.',
                    ),
                    const SizedBox(height: 10),
                    ...data.discountTiers.map(
                      (tier) => ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: const Icon(
                          Icons.sell_outlined,
                          color: AppTheme.teal,
                        ),
                        title: Text((tier['label'] ?? '').toString()),
                        trailing: Text(
                          '${tier['percentage'] ?? 0}%',
                          style: const TextStyle(
                            color: AppTheme.teal,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                    ),
                  ],
                  if (data.history.isNotEmpty) ...[
                    const SizedBox(height: 26),
                    const ManaraSectionTitle(
                      title: 'سجل العضوية',
                      subtitle: 'الطلبات السابقة وحالتها الحالية.',
                    ),
                    const SizedBox(height: 10),
                    ...data.history.map(
                      (item) => Padding(
                        padding: const EdgeInsets.only(bottom: 9),
                        child: _MembershipHistoryCard(
                          item: item,
                          onCancel: item.canCancel ? () => _cancel(item) : null,
                        ),
                      ),
                    ),
                  ],
                  if (_busy) ...[
                    const SizedBox(height: 12),
                    const LinearProgressIndicator(),
                  ],
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _MembershipHero extends StatelessWidget {
  final MembershipInfo? active;
  const _MembershipHero({this.active});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [Color(0xFF133F3A), Color(0xFF0A2A28)],
        ),
        borderRadius: BorderRadius.circular(23),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  active == null
                      ? 'عضوية تعطي القراءة مساحة أكبر'
                      : 'عضويتك فعالة',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 23,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  active == null
                      ? 'استعارة الكتب الورقية تصبح بلا رسوم أثناء فترة العضوية الفعالة.'
                      : 'حتى ${formatDate(active!.endDate)} • استعارة الكتب الورقية 0.00 USD',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: .75),
                    height: 1.55,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppTheme.gold.withValues(alpha: .16),
            ),
            child: const Icon(
              Icons.workspace_premium_outlined,
              color: AppTheme.gold,
              size: 34,
            ),
          ),
        ],
      ),
    );
  }
}

class _Benefit extends StatelessWidget {
  final IconData icon;
  final String title;
  final String text;
  const _Benefit({required this.icon, required this.title, required this.text});

  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.only(bottom: 9),
    padding: const EdgeInsets.all(15),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(15),
      border: Border.all(color: AppTheme.border),
    ),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: const Color(0xFFE7F1EE),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: AppTheme.teal),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.w900)),
              const SizedBox(height: 4),
              Text(
                text,
                style: const TextStyle(
                  fontSize: 11.5,
                  height: 1.5,
                  color: AppTheme.muted,
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

class _DateChoice extends StatelessWidget {
  final String label;
  final String value;
  final VoidCallback onTap;
  const _DateChoice({
    required this.label,
    required this.value,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) => Material(
    color: Colors.white,
    borderRadius: BorderRadius.circular(14),
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppTheme.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(fontSize: 10.5, color: AppTheme.muted),
            ),
            const SizedBox(height: 5),
            Row(
              children: [
                const Icon(
                  Icons.calendar_today_outlined,
                  size: 17,
                  color: AppTheme.teal,
                ),
                const SizedBox(width: 7),
                Expanded(
                  child: Text(
                    value,
                    style: const TextStyle(fontWeight: FontWeight.w800),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    ),
  );
}

class _MembershipQuote extends StatelessWidget {
  final Map<String, dynamic> quote;
  const _MembershipQuote({required this.quote});

  double _number(String key) {
    final value = quote[key];
    if (value is num) return value.toDouble();
    return double.tryParse('$value') ?? 0;
  }

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: const Color(0xFFEAF3EE),
      borderRadius: BorderRadius.circular(16),
    ),
    child: Column(
      children: [
        _line('عدد الأيام', '${quote['days'] ?? 0}'),
        _line(
          'السعر الأساسي',
          '${_number('basePrice').toStringAsFixed(2)} USD',
        ),
        if (_number('discountAmount') > 0)
          _line(
            'الخصم (${_number('discountPercentage').toStringAsFixed(0)}%)',
            '-${_number('discountAmount').toStringAsFixed(2)} USD',
          ),
        const Divider(),
        _line(
          'الإجمالي',
          '${_number('totalPrice').toStringAsFixed(2)} USD',
          bold: true,
        ),
      ],
    ),
  );

  Widget _line(String title, String value, {bool bold = false}) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 4),
    child: Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: TextStyle(
              fontWeight: bold ? FontWeight.w900 : FontWeight.w500,
            ),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: AppTheme.teal,
            fontWeight: bold ? FontWeight.w900 : FontWeight.w700,
          ),
        ),
      ],
    ),
  );
}

class _MembershipHistoryCard extends StatelessWidget {
  final MembershipInfo item;
  final VoidCallback? onCancel;
  const _MembershipHistoryCard({required this.item, this.onCancel});

  @override
  Widget build(BuildContext context) {
    final tone = switch (item.status) {
      'ACTIVE' => AppTheme.teal,
      'PENDING' => const Color(0xFF9B6B1F),
      'SCHEDULED' => const Color(0xFF516B9E),
      'CANCELLED' => Colors.redAccent,
      _ => AppTheme.muted,
    };
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ManaraStatusChip(label: item.statusLabel, color: tone),
                  const SizedBox(height: 8),
                  Text(
                    '${formatDate(item.startDate)} → ${formatDate(item.endDate)}',
                    style: const TextStyle(fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    '${item.price.toStringAsFixed(2)} USD${item.paid ? ' • مدفوعة' : ''}',
                    style: const TextStyle(fontSize: 11, color: AppTheme.muted),
                  ),
                ],
              ),
            ),
            if (onCancel != null)
              TextButton(onPressed: onCancel, child: const Text('إلغاء')),
          ],
        ),
      ),
    );
  }
}
