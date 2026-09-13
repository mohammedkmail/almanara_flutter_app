import 'package:flutter/material.dart';

import '../data/sample_data.dart';
import '../models/study_room.dart';
import '../theme/app_theme.dart';
import 'room_details_screen.dart';

class StudyRoomsScreen extends StatelessWidget {
  const StudyRoomsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        body: SafeArea(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 30),
            children: [
              Text(
                'غرف الدراسة',
                style: TextStyle(
                  color: colors.onSurface,
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'اختر الغرفة المناسبة وشاهد تفاصيل الحجز.',
                style: TextStyle(
                  color: colors.onSurfaceVariant,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 22),
              ...SampleData.rooms.map(
                (room) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _RoomTile(room: room),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RoomTile extends StatelessWidget {
  final StudyRoom room;

  const _RoomTile({required this.room});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Material(
      color: theme.cardColor,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => RoomDetailsScreen(room: room),
            ),
          );
        },
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: theme.dividerColor),
          ),
          child: Row(
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: AppTheme.turquoise.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.meeting_room_outlined,
                  color: AppTheme.turquoise,
                  size: 30,
                ),
              ),
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      room.name,
                      style: TextStyle(
                        color: colors.onSurface,
                        fontWeight: FontWeight.w800,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      '${room.location} • ${room.capacity} أشخاص',
                      style: TextStyle(
                        color: colors.onSurfaceVariant,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 7),
                    Text(
                      '${room.hourlyPrice.toStringAsFixed(0)} ₪ / ساعة',
                      style: const TextStyle(
                        color: AppTheme.turquoise,
                        fontWeight: FontWeight.w700,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: room.available ? Colors.green : Colors.orange,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Icon(
                    Icons.chevron_left_rounded,
                    color: colors.onSurfaceVariant,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
