import 'package:flutter/material.dart';

import '../../models/study_room.dart';
import '../../services/library_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/api_error_view.dart';
import '../../widgets/manara_components.dart';
import 'admin_room_form_screen.dart';

class AdminRoomsScreen extends StatefulWidget {
  const AdminRoomsScreen({super.key});

  @override
  State<AdminRoomsScreen> createState() => _AdminRoomsScreenState();
}

class _AdminRoomsScreenState extends State<AdminRoomsScreen> {
  late Future<List<StudyRoom>> _future;
  final _search = TextEditingController();
  String _query = '';
  String _filter = 'ALL';

  @override
  void initState() {
    super.initState();
    _reload();
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  void _reload() {
    _future = LibraryService.instance.rooms();
  }

  Future<void> _refresh() async {
    setState(() {
      _reload();
    });
    await _future;
  }

  Future<void> _open([StudyRoom? room]) async {
    final changed = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => AdminRoomFormScreen(room: room)),
    );
    if (changed == true && mounted) {
      setState(() {
        _reload();
      });
    }
  }

  Future<void> _delete(StudyRoom room) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('حذف أو تعطيل الغرفة؟'),
        content: Text(
          'سيحاول النظام حذف ${room.name}. إذا كانت مرتبطة بسجل حجوزات فسيحافظ على السجل ويمنع الحذف غير الآمن.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('إلغاء'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('متابعة'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    try {
      await LibraryService.instance.deleteRoom(room.id!);
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('تم تحديث الغرفة.')));
      setState(() {
        _reload();
      });
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(apiErrorMessage(error))));
    }
  }

  List<StudyRoom> _filtered(List<StudyRoom> rooms) {
    final q = _query.trim().toLowerCase();
    return rooms.where((room) {
      final matchesState =
          _filter == 'ALL' ||
          (_filter == 'ACTIVE' && room.available) ||
          (_filter == 'INACTIVE' && !room.available);
      if (!matchesState) return false;
      if (q.isEmpty) return true;
      return room.name.toLowerCase().contains(q) ||
          room.roomNumber.toLowerCase().contains(q) ||
          room.location.toLowerCase().contains(q) ||
          room.features.any((value) => value.toLowerCase().contains(q));
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        floatingActionButton: FloatingActionButton.extended(
          heroTag: null,
          onPressed: () => _open(),
          icon: const Icon(Icons.add_rounded),
          label: const Text('غرفة جديدة'),
        ),
        body: SafeArea(
          bottom: false,
          child: FutureBuilder<List<StudyRoom>>(
            future: _future,
            builder: (context, snapshot) {
              if (snapshot.connectionState != ConnectionState.done) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return ApiErrorView(
                  error: snapshot.error!,
                  retry: () {
                    setState(() {
                      _reload();
                    });
                  },
                );
              }

              final all = snapshot.data!;
              final rooms = _filtered(all);
              final active = all.where((room) => room.available).length;
              final totalCapacity = all.fold<int>(
                0,
                (sum, room) => sum + room.capacity,
              );

              return RefreshIndicator(
                onRefresh: _refresh,
                child: ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(18, 14, 18, 110),
                  children: [
                    _RoomsHeader(
                      count: all.length,
                      active: active,
                      totalCapacity: totalCapacity,
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      controller: _search,
                      onChanged: (value) => setState(() => _query = value),
                      decoration: const InputDecoration(
                        hintText: 'ابحث بالاسم، الرقم، الموقع أو التجهيز...',
                        prefixIcon: Icon(Icons.search_rounded),
                      ),
                    ),
                    const SizedBox(height: 11),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          _FilterChip(
                            label: 'الكل',
                            selected: _filter == 'ALL',
                            onTap: () => setState(() => _filter = 'ALL'),
                          ),
                          _FilterChip(
                            label: 'فعالة',
                            selected: _filter == 'ACTIVE',
                            onTap: () => setState(() => _filter = 'ACTIVE'),
                          ),
                          _FilterChip(
                            label: 'متوقفة',
                            selected: _filter == 'INACTIVE',
                            onTap: () => setState(() => _filter = 'INACTIVE'),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 23),
                    ManaraSectionTitle(
                      title: 'غرف الدراسة',
                      subtitle: rooms.length == all.length
                          ? '${rooms.length} غرفة مرتبطة بنفس بيانات موقع الويب'
                          : '${rooms.length} نتيجة من أصل ${all.length}',
                    ),
                    const SizedBox(height: 13),
                    if (rooms.isEmpty)
                      ManaraEmptyState(
                        icon: Icons.meeting_room_outlined,
                        title: 'لا توجد غرف مطابقة',
                        message: all.isEmpty
                            ? 'ابدأ بإضافة أول غرفة دراسة للمنارة.'
                            : 'غيّر البحث أو الفلتر لعرض غرف أخرى.',
                        action: all.isEmpty
                            ? ElevatedButton.icon(
                                onPressed: () => _open(),
                                icon: const Icon(Icons.add_rounded),
                                label: const Text('إضافة غرفة'),
                              )
                            : null,
                      )
                    else
                      ...rooms.map(
                        (room) => _RoomAdminCard(
                          room: room,
                          onEdit: () => _open(room),
                          onDelete: () => _delete(room),
                        ),
                      ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _RoomsHeader extends StatelessWidget {
  final int count;
  final int active;
  final int totalCapacity;

  const _RoomsHeader({
    required this.count,
    required this.active,
    required this.totalCapacity,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.darkTeal,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: .10),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(
                  Icons.meeting_room_outlined,
                  color: AppTheme.gold,
                  size: 27,
                ),
              ),
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'مساحات الدراسة',
                      style: Theme.of(
                        context,
                      ).textTheme.titleLarge?.copyWith(color: Colors.white),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'الصورة، السعة، السعر والتجهيزات كما يراها المستخدم.',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: .72),
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _HeaderMetric(value: '$count', label: 'إجمالي الغرف'),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _HeaderMetric(value: '$active', label: 'غرف فعالة'),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _HeaderMetric(
                  value: '$totalCapacity',
                  label: 'إجمالي المقاعد',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _HeaderMetric extends StatelessWidget {
  final String value;
  final String label;

  const _HeaderMetric({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: .08),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: Colors.white.withValues(alpha: .67),
              fontSize: 9.5,
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 7),
      child: ChoiceChip(
        label: Text(label),
        selected: selected,
        onSelected: (_) => onTap(),
      ),
    );
  }
}

class _RoomAdminCard extends StatelessWidget {
  final StudyRoom room;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _RoomAdminCard({
    required this.room,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 13),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.border),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              ManaraImage(
                url: room.imageUrl,
                width: double.infinity,
                height: 172,
                borderRadius: BorderRadius.zero,
                fallbackIcon: Icons.meeting_room_outlined,
              ),
              Positioned(
                top: 12,
                right: 12,
                child: ManaraStatusChip(
                  label: room.available ? 'فعالة' : 'متوقفة',
                  color: room.available ? AppTheme.teal : Colors.redAccent,
                  icon: room.available
                      ? Icons.check_circle_outline_rounded
                      : Icons.pause_circle_outline_rounded,
                ),
              ),
              Positioned(
                top: 8,
                left: 8,
                child: PopupMenuButton<String>(
                  color: Colors.white,
                  onSelected: (value) {
                    if (value == 'edit') onEdit();
                    if (value == 'delete') onDelete();
                  },
                  itemBuilder: (_) => const [
                    PopupMenuItem(value: 'edit', child: Text('تعديل الغرفة')),
                    PopupMenuItem(value: 'delete', child: Text('حذف / تعطيل')),
                  ],
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            room.name,
                            style: const TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            'غرفة ${room.roomNumber.isEmpty ? '—' : room.roomNumber} • ${room.location}',
                            style: const TextStyle(
                              color: AppTheme.muted,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      '${room.hourlyPrice.toStringAsFixed(2)} USD',
                      style: const TextStyle(
                        color: AppTheme.teal,
                        fontSize: 15,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
                if (room.description.trim().isNotEmpty) ...[
                  const SizedBox(height: 10),
                  Text(
                    room.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppTheme.muted,
                      fontSize: 11,
                      height: 1.45,
                    ),
                  ),
                ],
                const SizedBox(height: 13),
                Wrap(
                  spacing: 7,
                  runSpacing: 7,
                  children: [
                    _RoomFact(
                      icon: Icons.people_outline_rounded,
                      label: '${room.capacity} أشخاص',
                    ),
                    _RoomFact(
                      icon: Icons.schedule_rounded,
                      label:
                          '${room.hourlyPrice.toStringAsFixed(2)} USD / ساعة',
                    ),
                    ...room.features
                        .take(3)
                        .map(
                          (feature) => _RoomFact(
                            icon: Icons.check_rounded,
                            label: feature,
                          ),
                        ),
                  ],
                ),
                const SizedBox(height: 14),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: onEdit,
                    icon: const Icon(Icons.edit_outlined),
                    label: const Text('تعديل التفاصيل والتسعير'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _RoomFact extends StatelessWidget {
  final IconData icon;
  final String label;

  const _RoomFact({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F4F1),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: AppTheme.teal),
          const SizedBox(width: 5),
          Text(
            label,
            style: const TextStyle(fontSize: 9.5, fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}
