import 'package:flutter/material.dart';

import '../models/study_room.dart';
import '../services/library_service.dart';
import '../theme/app_theme.dart';
import '../widgets/api_error_view.dart';
import '../widgets/manara_components.dart';
import 'room_details_screen.dart';

class StudyRoomsScreen extends StatefulWidget {
  const StudyRoomsScreen({super.key});

  @override
  State<StudyRoomsScreen> createState() => _StudyRoomsScreenState();
}

class _StudyRoomsScreenState extends State<StudyRoomsScreen> {
  late Future<List<StudyRoom>> _future;
  String _search = '';
  int? _capacity;

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

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(title: const Text('غرف الدراسة')),
        body: FutureBuilder<List<StudyRoom>>(
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

            final all = snapshot.data!;
            final rooms = all.where((room) {
              final query = _search.trim().toLowerCase();
              final matchesText =
                  query.isEmpty ||
                  room.name.toLowerCase().contains(query) ||
                  room.location.toLowerCase().contains(query) ||
                  room.roomNumber.toLowerCase().contains(query);
              final matchesCapacity =
                  _capacity == null || room.capacity >= _capacity!;
              return matchesText && matchesCapacity;
            }).toList();

            return RefreshIndicator(
              onRefresh: _refresh,
              child: CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: [
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(18, 4, 18, 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: AppTheme.darkTeal,
                              borderRadius: BorderRadius.circular(22),
                            ),
                            child: const Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'مساحة تناسب طريقة دراستك',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 22,
                                          fontWeight: FontWeight.w900,
                                        ),
                                      ),
                                      SizedBox(height: 7),
                                      Text(
                                        'شاهد الصور والسعة والتجهيزات والسعر قبل أن تختار الموعد.',
                                        style: TextStyle(
                                          color: Color(0xCCFFFFFF),
                                          height: 1.5,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(width: 14),
                                ManaraDecorativeImageSlot(
                                  height: 96,
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(16),
                                  ),
                                  icon: Icons.meeting_room_outlined,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),
                          TextField(
                            onChanged: (value) =>
                                setState(() => _search = value),
                            decoration: const InputDecoration(
                              hintText: 'ابحث باسم الغرفة أو الموقع...',
                              prefixIcon: Icon(Icons.search_rounded),
                            ),
                          ),
                          const SizedBox(height: 10),
                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children: [
                                _CapacityChip(
                                  label: 'أي سعة',
                                  selected: _capacity == null,
                                  onTap: () => setState(() => _capacity = null),
                                ),
                                const SizedBox(width: 8),
                                for (final value in const [2, 4, 6, 8]) ...[
                                  _CapacityChip(
                                    label: '$value+ أشخاص',
                                    selected: _capacity == value,
                                    onTap: () =>
                                        setState(() => _capacity = value),
                                  ),
                                  const SizedBox(width: 8),
                                ],
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (rooms.isEmpty)
                    const SliverToBoxAdapter(
                      child: ManaraEmptyState(
                        icon: Icons.meeting_room_outlined,
                        title: 'لا توجد غرفة مطابقة',
                        message: 'غيّر البحث أو السعة المطلوبة وحاول مرة أخرى.',
                      ),
                    )
                  else
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(18, 0, 18, 30),
                      sliver: SliverList.separated(
                        itemCount: rooms.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 14),
                        itemBuilder: (context, index) =>
                            _RoomCard(room: rooms[index]),
                      ),
                    ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _CapacityChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _CapacityChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) => ChoiceChip(
    label: Text(label),
    selected: selected,
    onSelected: (_) => onTap(),
  );
}

class _RoomCard extends StatelessWidget {
  final StudyRoom room;
  const _RoomCard({required this.room});

  @override
  Widget build(BuildContext context) {
    final title = room.name.isEmpty ? 'غرفة ${room.roomNumber}' : room.name;
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => RoomDetailsScreen(room: room)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                ManaraImage(
                  url: room.imageUrl,
                  width: double.infinity,
                  height: 205,
                  borderRadius: BorderRadius.zero,
                  fallbackIcon: Icons.meeting_room_outlined,
                ),
                Positioned(
                  top: 12,
                  right: 12,
                  child: ManaraStatusChip(
                    label: room.available ? 'متاحة للحجز' : 'غير فعالة',
                    color: room.available ? AppTheme.teal : Colors.redAccent,
                    icon: room.available
                        ? Icons.check_circle_outline
                        : Icons.block_outlined,
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(17),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                      Text(
                        '${room.hourlyPrice.toStringAsFixed(2)} USD/ساعة',
                        style: const TextStyle(
                          color: AppTheme.teal,
                          fontWeight: FontWeight.w900,
                          fontSize: 15,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(
                        Icons.location_on_outlined,
                        size: 17,
                        color: AppTheme.muted,
                      ),
                      const SizedBox(width: 5),
                      Expanded(
                        child: Text(
                          room.location.isEmpty
                              ? 'داخل المكتبة'
                              : room.location,
                          style: const TextStyle(color: AppTheme.muted),
                        ),
                      ),
                      const Icon(
                        Icons.groups_2_outlined,
                        size: 17,
                        color: AppTheme.muted,
                      ),
                      const SizedBox(width: 5),
                      Text(
                        '${room.capacity} أشخاص',
                        style: const TextStyle(color: AppTheme.muted),
                      ),
                    ],
                  ),
                  if (room.features.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: room.features
                          .take(4)
                          .map(
                            (feature) => Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 9,
                                vertical: 5,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF1F3EE),
                                borderRadius: BorderRadius.circular(999),
                              ),
                              child: Text(
                                feature,
                                style: const TextStyle(
                                  fontSize: 10.5,
                                  color: AppTheme.muted,
                                ),
                              ),
                            ),
                          )
                          .toList(),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
