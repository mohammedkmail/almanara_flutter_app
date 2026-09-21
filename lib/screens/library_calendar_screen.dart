import 'package:flutter/material.dart';

import '../services/library_service.dart';
import '../theme/app_theme.dart';
import '../widgets/api_error_view.dart';
import '../widgets/manara_components.dart';

class LibraryCalendarScreen extends StatefulWidget {
  const LibraryCalendarScreen({super.key});

  @override
  State<LibraryCalendarScreen> createState() => _LibraryCalendarScreenState();
}

class _LibraryCalendarScreenState extends State<LibraryCalendarScreen> {
  late Future<List<Map<String, dynamic>>> _future;

  @override
  void initState() {
    super.initState();
    _reload();
  }

  void _reload() {
    _future = LibraryService.instance.holidays(limit: 30);
  }

  Future<void> _refresh() async {
    setState(_reload);
    await _future;
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(title: const Text('تقويم المكتبة')),
        body: FutureBuilder<List<Map<String, dynamic>>>(
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

            final items = snapshot.data ?? const <Map<String, dynamic>>[];
            return RefreshIndicator(
              onRefresh: _refresh,
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(18, 8, 18, 32),
                children: [
                  const _CalendarHero(),
                  const SizedBox(height: 24),
                  const ManaraSectionTitle(
                    title: 'المواعيد القادمة',
                    subtitle:
                        'الأيام المغلقة تؤثر على توفر المكتبة وحجوزات غرف الدراسة.',
                  ),
                  const SizedBox(height: 12),
                  if (items.isEmpty)
                    const ManaraEmptyState(
                      icon: Icons.event_available_outlined,
                      title: 'لا توجد مواعيد قادمة',
                      message: 'عند إضافة عطلة أو إغلاق سيظهر هنا تلقائياً.',
                    )
                  else
                    ...items.map((item) => _HolidayTile(item: item)),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _CalendarHero extends StatelessWidget {
  const _CalendarHero();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 185,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: AppTheme.darkTeal,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'خطّط زيارتك قبل أن تخرج',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 23,
                    fontWeight: FontWeight.w900,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'مواعيد الإغلاق والعطل الرسمية القادمة من نفس تقويم النظام.',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: .72),
                    fontSize: 12,
                    height: 1.55,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Container(
            width: 78,
            height: 96,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: .09),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white.withValues(alpha: .12)),
            ),
            child: const Icon(
              Icons.calendar_month_rounded,
              color: AppTheme.gold,
              size: 42,
            ),
          ),
        ],
      ),
    );
  }
}

class _HolidayTile extends StatelessWidget {
  final Map<String, dynamic> item;
  const _HolidayTile({required this.item});

  DateTime? get date {
    final value = item['date'];
    if (value is num) {
      return DateTime.fromMillisecondsSinceEpoch(value.toInt());
    }
    return DateTime.tryParse(value?.toString() ?? '');
  }

  @override
  Widget build(BuildContext context) {
    final closed = item['closed'] == true;
    final source = (item['source'] ?? '').toString();
    final day = date;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(17),
        border: Border.all(color: AppTheme.border),
      ),
      child: Row(
        children: [
          Container(
            width: 58,
            height: 62,
            decoration: BoxDecoration(
              color: closed ? const Color(0xFFF7EAE7) : const Color(0xFFE7F2EE),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  day == null ? '—' : '${day.day}',
                  style: TextStyle(
                    color: closed ? const Color(0xFF9D5148) : AppTheme.teal,
                    fontSize: 21,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                Text(
                  day == null ? '' : '${day.month}/${day.year}',
                  style: const TextStyle(fontSize: 9.5, color: AppTheme.muted),
                ),
              ],
            ),
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  (item['name'] ?? 'موعد').toString(),
                  style: const TextStyle(fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 5),
                Text(
                  closed
                      ? 'المكتبة مغلقة في هذا اليوم'
                      : 'المكتبة تعمل حسب الجدول',
                  style: const TextStyle(fontSize: 11, color: AppTheme.muted),
                ),
                if (source.isNotEmpty) ...[
                  const SizedBox(height: 5),
                  Text(
                    source == 'API'
                        ? 'مزامن من التقويم الخارجي'
                        : source == 'MANUAL'
                        ? 'أضيف من إدارة المكتبة'
                        : source,
                    style: const TextStyle(
                      fontSize: 9.5,
                      color: AppTheme.muted,
                    ),
                  ),
                ],
              ],
            ),
          ),
          ManaraStatusChip(
            label: closed ? 'مغلق' : 'مفتوح',
            color: closed ? const Color(0xFF9D5148) : AppTheme.teal,
          ),
        ],
      ),
    );
  }
}
