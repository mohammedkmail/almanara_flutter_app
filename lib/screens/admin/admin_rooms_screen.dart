import 'package:flutter/material.dart';

import '../../data/sample_data.dart';
import '../../models/study_room.dart';
import '../../theme/app_theme.dart';
import 'admin_room_form_screen.dart';

class AdminRoomsScreen extends StatelessWidget {
  const AdminRoomsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('إدارة الغرف'),
          actions: [
            IconButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AdminRoomFormScreen(),
                  ),
                );
              },
              icon: const Icon(Icons.add_rounded),
            ),
          ],
        ),
        body: ListView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 30),
          children: SampleData.rooms.map((room) => _RoomAdminTile(room: room)).toList(),
        ),
      ),
    );
  }
}

class _RoomAdminTile extends StatelessWidget {
  final StudyRoom room;

  const _RoomAdminTile({required this.room});

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
          const Icon(Icons.meeting_room_outlined, color: AppTheme.turquoise),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(room.name, style: const TextStyle(fontWeight: FontWeight.w800)),
                const SizedBox(height: 3),
                Text(
                  '${room.location} • ${room.capacity} أشخاص • ${room.hourlyPrice.toStringAsFixed(0)} ₪/ساعة',
                  style: TextStyle(
                    color: theme.colorScheme.onSurfaceVariant,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AdminRoomFormScreen(room: room),
                ),
              );
            },
            icon: const Icon(Icons.edit_outlined),
          ),
        ],
      ),
    );
  }
}
