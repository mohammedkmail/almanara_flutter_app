import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';

class AdminOperationsScreen extends StatelessWidget {
  const AdminOperationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: DefaultTabController(
        length: 3,
        child: Scaffold(
          appBar: AppBar(
            title: const Text('العمليات'),
            bottom: const TabBar(
              tabs: [
                Tab(text: 'الاستعارات'),
                Tab(text: 'الحجوزات'),
                Tab(text: 'المبيعات'),
              ],
            ),
          ),
          body: TabBarView(
            children: [
              _OperationList(
                items: const [
                  _OperationItemData(
                    title: 'Clean Code',
                    subtitle: 'هادي • موعد الإرجاع 18 سبتمبر',
                    status: 'ACTIVE',
                  ),
                  _OperationItemData(
                    title: 'Database Systems',
                    subtitle: 'أحمد • متأخر يومين',
                    status: 'OVERDUE',
                    warning: true,
                  ),
                ],
              ),
              _OperationList(
                items: const [
                  _OperationItemData(
                    title: 'Design Patterns',
                    subtitle: 'سارة • بانتظار توفر نسخة',
                    status: 'WAITING',
                  ),
                  _OperationItemData(
                    title: 'غرفة الدراسة 2',
                    subtitle: 'محمد • اليوم 4:00 م',
                    status: 'CONFIRMED',
                  ),
                ],
              ),
              _OperationList(
                items: const [
                  _OperationItemData(
                    title: 'Atomic Habits',
                    subtitle: 'شراء نسخة ورقية • 18 ₪',
                    status: 'COMPLETED',
                  ),
                  _OperationItemData(
                    title: 'The Pragmatic Programmer',
                    subtitle: 'شراء رقمي • 13 ₪',
                    status: 'COMPLETED',
                  ),
                ],
              ),
            ],
          ),
          bottomNavigationBar: Padding(
            padding: const EdgeInsets.all(12),
            child: Text(
              'الحالات والعمليات المعروضة تجريبية، وستأتي لاحقاً من Controllers الاستعارات والحجوزات والمبيعات في الـ Backend.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: colors.onSurfaceVariant,
                fontSize: 10,
                height: 1.4,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _OperationList extends StatelessWidget {
  final List<_OperationItemData> items;

  const _OperationList({required this.items});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: items
          .map((item) => _OperationTile(item: item))
          .toList(),
    );
  }
}

class _OperationItemData {
  final String title;
  final String subtitle;
  final String status;
  final bool warning;

  const _OperationItemData({
    required this.title,
    required this.subtitle,
    required this.status,
    this.warning = false,
  });
}

class _OperationTile extends StatelessWidget {
  final _OperationItemData item;

  const _OperationTile({required this.item});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 13),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: theme.dividerColor)),
      ),
      child: Row(
        children: [
          Icon(
            item.warning ? Icons.warning_amber_rounded : Icons.receipt_long_outlined,
            color: item.warning ? Colors.redAccent : AppTheme.turquoise,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.title, style: const TextStyle(fontWeight: FontWeight.w800)),
                const SizedBox(height: 3),
                Text(
                  item.subtitle,
                  style: TextStyle(
                    color: theme.colorScheme.onSurfaceVariant,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          Text(
            item.status,
            style: TextStyle(
              color: item.warning ? Colors.redAccent : AppTheme.turquoise,
              fontSize: 10,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
