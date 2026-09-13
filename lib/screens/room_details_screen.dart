import 'package:flutter/material.dart';

import '../models/study_room.dart';
import '../theme/app_theme.dart';
import 'reserve_room_screen.dart';

class RoomDetailsScreen extends StatelessWidget {
  final StudyRoom room;

  const RoomDetailsScreen({
    super.key,
    required this.room,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(title: const Text('تفاصيل الغرفة')),
        body: ListView(
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 30),
          children: [
            Container(
              height: 180,
              decoration: BoxDecoration(
                color: AppTheme.darkTeal,
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Center(
                child: Icon(
                  Icons.meeting_room_outlined,
                  color: AppTheme.turquoise,
                  size: 64,
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              room.name,
              style: TextStyle(
                color: colors.onSurface,
                fontSize: 24,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              room.location,
              style: TextStyle(color: colors.onSurfaceVariant),
            ),
            const SizedBox(height: 22),
            _InfoRow(
              icon: Icons.groups_outlined,
              label: 'السعة',
              value: '${room.capacity} أشخاص',
            ),
            _InfoRow(
              icon: Icons.payments_outlined,
              label: 'سعر الساعة',
              value: '${room.hourlyPrice.toStringAsFixed(0)} ₪',
            ),
            _InfoRow(
              icon: Icons.event_available_outlined,
              label: 'الحالة',
              value: room.available ? 'متاحة للحجز' : 'غير متاحة حالياً',
            ),
            const SizedBox(height: 22),
            Text(
              'التجهيزات',
              style: TextStyle(
                color: colors.onSurface,
                fontSize: 17,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: room.features
                  .map(
                    (feature) => Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 7,
                      ),
                      decoration: BoxDecoration(
                        color: theme.cardColor,
                        borderRadius: BorderRadius.circular(9),
                        border: Border.all(color: theme.dividerColor),
                      ),
                      child: Text(feature, style: const TextStyle(fontSize: 12)),
                    ),
                  )
                  .toList(),
            ),
            const SizedBox(height: 30),
            FilledButton.icon(
              onPressed: room.available
                  ? () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ReserveRoomScreen(room: room),
                        ),
                      );
                    }
                  : null,
              icon: const Icon(Icons.calendar_month_outlined),
              label: Text(room.available ? 'حجز الغرفة' : 'غير متاحة للحجز'),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: AppTheme.turquoise, size: 21),
          const SizedBox(width: 10),
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
