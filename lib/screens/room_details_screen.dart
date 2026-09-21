import 'package:flutter/material.dart';

import '../models/study_room.dart';
import '../theme/app_theme.dart';
import '../widgets/manara_components.dart';
import 'reserve_room_screen.dart';

class RoomDetailsScreen extends StatelessWidget {
  final StudyRoom room;
  const RoomDetailsScreen({super.key, required this.room});

  @override
  Widget build(BuildContext context) {
    final title = room.name.isEmpty ? 'غرفة ${room.roomNumber}' : room.name;
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        body: CustomScrollView(
          slivers: [
            SliverAppBar(
              pinned: true,
              expandedHeight: 310,
              title: const Text('تفاصيل الغرفة'),
              flexibleSpace: FlexibleSpaceBar(
                background: ManaraImage(
                  url: room.imageUrl,
                  width: double.infinity,
                  height: 310,
                  borderRadius: BorderRadius.zero,
                  fallbackIcon: Icons.meeting_room_outlined,
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 120),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              title,
                              style: Theme.of(context).textTheme.headlineMedium,
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                const Icon(
                                  Icons.location_on_outlined,
                                  size: 18,
                                  color: AppTheme.muted,
                                ),
                                const SizedBox(width: 5),
                                Text(
                                  room.location.isEmpty
                                      ? 'داخل المكتبة'
                                      : room.location,
                                  style: const TextStyle(color: AppTheme.muted),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      ManaraStatusChip(
                        label: room.available ? 'فعالة' : 'غير فعالة',
                        color: room.available
                            ? AppTheme.teal
                            : Colors.redAccent,
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: _RoomFact(
                          icon: Icons.groups_2_outlined,
                          label: 'السعة',
                          value: '${room.capacity} أشخاص',
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _RoomFact(
                          icon: Icons.payments_outlined,
                          label: 'السعر الأساسي',
                          value:
                              '${room.hourlyPrice.toStringAsFixed(2)} USD/ساعة',
                        ),
                      ),
                    ],
                  ),
                  if (room.description.trim().isNotEmpty) ...[
                    const SizedBox(height: 28),
                    const ManaraSectionTitle(title: 'عن الغرفة'),
                    const SizedBox(height: 10),
                    Text(
                      room.description,
                      style: const TextStyle(
                        height: 1.7,
                        color: AppTheme.muted,
                      ),
                    ),
                  ],
                  if (room.features.isNotEmpty) ...[
                    const SizedBox(height: 28),
                    const ManaraSectionTitle(
                      title: 'التجهيزات',
                      subtitle: 'كل ما يتوفر داخل هذه الغرفة',
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 9,
                      runSpacing: 9,
                      children: room.features
                          .map(
                            (feature) => Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFEAF2EE),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.check_rounded,
                                    color: AppTheme.teal,
                                    size: 17,
                                  ),
                                  const SizedBox(width: 5),
                                  Text(feature),
                                ],
                              ),
                            ),
                          )
                          .toList(),
                    ),
                  ],
                  const SizedBox(height: 28),
                  Container(
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF4F1E8),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: const Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.info_outline, color: Color(0xFF8A6A34)),
                        SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'السعر النهائي يُحسب عند اختيار الموعد. قواعد الخصم والعطل وتعارض المواعيد تُفحص من الخادم قبل الدفع.',
                            style: TextStyle(
                              color: AppTheme.muted,
                              fontSize: 12,
                              height: 1.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ]),
              ),
            ),
          ],
        ),
        bottomNavigationBar: SafeArea(
          minimum: const EdgeInsets.fromLTRB(18, 8, 18, 14),
          child: ElevatedButton.icon(
            onPressed: !room.available || room.id == null
                ? null
                : () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ReserveRoomScreen(room: room),
                    ),
                  ),
            icon: const Icon(Icons.calendar_month_outlined),
            label: const Text('اختيار موعد وحساب السعر'),
          ),
        ),
      ),
    );
  }
}

class _RoomFact extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _RoomFact({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(15),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(15),
      border: Border.all(color: AppTheme.border),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: AppTheme.teal),
        const SizedBox(height: 12),
        Text(
          label,
          style: const TextStyle(fontSize: 11, color: AppTheme.muted),
        ),
        const SizedBox(height: 3),
        Text(value, style: const TextStyle(fontWeight: FontWeight.w900)),
      ],
    ),
  );
}
