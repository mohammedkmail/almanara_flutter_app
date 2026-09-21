import 'package:flutter/material.dart';

import '../../models/study_room.dart';
import '../../services/library_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/api_error_view.dart';
import '../../widgets/manara_components.dart';

class AdminRoomFormScreen extends StatefulWidget {
  final StudyRoom? room;

  const AdminRoomFormScreen({super.key, this.room});

  @override
  State<AdminRoomFormScreen> createState() => _AdminRoomFormScreenState();
}

class _AdminRoomFormScreenState extends State<AdminRoomFormScreen> {
  final _form = GlobalKey<FormState>();
  late final TextEditingController number;
  late final TextEditingController name;
  late final TextEditingController description;
  late final TextEditingController location;
  late final TextEditingController capacity;
  late final TextEditingController price;
  late final TextEditingController features;
  bool active = true;
  bool busy = false;

  bool get editing => widget.room?.id != null;

  @override
  void initState() {
    super.initState();
    final room = widget.room;
    number = TextEditingController(text: room?.roomNumber ?? '');
    name = TextEditingController(text: room?.name ?? '');
    description = TextEditingController(text: room?.description ?? '');
    location = TextEditingController(text: room?.location ?? '');
    capacity = TextEditingController(
      text: room == null ? '' : room.capacity.toString(),
    );
    price = TextEditingController(
      text: room == null ? '' : room.hourlyPrice.toStringAsFixed(2),
    );
    features = TextEditingController(text: room?.features.join(', ') ?? '');
    active = room?.available ?? true;
  }

  @override
  void dispose() {
    number.dispose();
    name.dispose();
    description.dispose();
    location.dispose();
    capacity.dispose();
    price.dispose();
    features.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (busy || !_form.currentState!.validate()) return;

    final parsedCapacity = int.tryParse(capacity.text.trim());
    final parsedPrice = double.tryParse(price.text.trim());

    if (parsedCapacity == null || parsedCapacity < 1) {
      _showError('السعة يجب أن تكون رقماً أكبر من صفر.');
      return;
    }
    if (parsedPrice == null || parsedPrice < 0) {
      _showError('سعر الساعة غير صالح.');
      return;
    }

    setState(() => busy = true);

    final data = <String, dynamic>{
      'roomNumber': number.text.trim(),
      'name': name.text.trim(),
      'description': description.text.trim(),
      'location': location.text.trim(),
      'capacity': parsedCapacity,
      'hourlyPrice': parsedPrice,
      'features': features.text
          .split(',')
          .map((value) => value.trim())
          .where((value) => value.isNotEmpty)
          .toList(),
      'active': active,
    };

    try {
      if (!editing) {
        await LibraryService.instance.saveRoom(data);
      } else {
        await LibraryService.instance.updateRoom(widget.room!.id!, data);
      }
      if (mounted) Navigator.pop(context, true);
    } catch (error) {
      _showError(apiErrorMessage(error));
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: Text(editing ? 'تعديل غرفة الدراسة' : 'غرفة دراسة جديدة'),
        ),
        body: Form(
          key: _form,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(18, 8, 18, 34),
            children: [
              _RoomVisual(room: widget.room),
              const SizedBox(height: 22),
              const ManaraSectionTitle(
                title: 'هوية الغرفة',
                subtitle:
                    'هذه المعلومات تظهر للمستخدم في قائمة الغرف وصفحة التفاصيل.',
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: _field(
                      name,
                      'اسم الغرفة',
                      required: true,
                      hint: 'مثال: غرفة الهدوء',
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _field(
                      number,
                      'الرقم',
                      required: true,
                      hint: 'R-04',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 11),
              _field(
                description,
                'الوصف',
                maxLines: 4,
                hint: 'صف التجربة المناسبة لهذه الغرفة وما يميزها...',
              ),
              const SizedBox(height: 23),
              const ManaraSectionTitle(
                title: 'الموقع والسعة',
                subtitle: 'معلومات عملية تظهر قبل أن يبدأ المستخدم الحجز.',
              ),
              const SizedBox(height: 14),
              _field(
                location,
                'الموقع داخل المكتبة',
                required: true,
                hint: 'الطابق الثاني • الجناح الشرقي',
                prefixIcon: Icons.location_on_outlined,
              ),
              const SizedBox(height: 11),
              Row(
                children: [
                  Expanded(
                    child: _field(
                      capacity,
                      'السعة',
                      required: true,
                      numeric: true,
                      suffix: 'أشخاص',
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _field(
                      price,
                      'سعر الساعة',
                      required: true,
                      numeric: true,
                      suffix: 'USD',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 23),
              const ManaraSectionTitle(
                title: 'تجهيزات الغرفة',
                subtitle:
                    'افصل التجهيزات بفاصلة، مثال: شاشة, سبورة, Wi-Fi, مقابس كهرباء.',
              ),
              const SizedBox(height: 14),
              _field(
                features,
                'التجهيزات',
                maxLines: 3,
                hint: 'شاشة, سبورة, Wi-Fi, مقابس كهرباء',
              ),
              const SizedBox(height: 15),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppTheme.border),
                ),
                child: SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  value: active,
                  onChanged: (value) => setState(() => active = value),
                  title: const Text(
                    'الغرفة متاحة للحجز',
                    style: TextStyle(fontWeight: FontWeight.w800),
                  ),
                  subtitle: const Text(
                    'إيقافها يمنع ظهورها كخيار جديد للمستخدم دون حذف سجلها.',
                  ),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: busy ? null : _save,
                  icon: busy
                      ? const SizedBox(
                          width: 19,
                          height: 19,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.save_outlined),
                  label: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 3),
                    child: Text(
                      busy
                          ? 'جاري الحفظ...'
                          : editing
                          ? 'حفظ تعديلات الغرفة'
                          : 'إضافة الغرفة',
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _field(
    TextEditingController controller,
    String label, {
    bool required = false,
    bool numeric = false,
    int maxLines = 1,
    String? hint,
    String? suffix,
    IconData? prefixIcon,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: numeric
          ? const TextInputType.numberWithOptions(decimal: true)
          : null,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        suffixText: suffix,
        prefixIcon: prefixIcon == null ? null : Icon(prefixIcon),
      ),
      validator: required
          ? (value) =>
                (value?.trim().isEmpty ?? true) ? 'هذا الحقل مطلوب' : null
          : null,
    );
  }
}

class _RoomVisual extends StatelessWidget {
  final StudyRoom? room;

  const _RoomVisual({required this.room});

  @override
  Widget build(BuildContext context) {
    final hasImage = room?.imageUrl?.trim().isNotEmpty == true;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (hasImage)
          Stack(
            children: [
              ManaraImage(
                url: room!.imageUrl,
                width: double.infinity,
                height: 205,
                borderRadius: BorderRadius.circular(22),
                fallbackIcon: Icons.meeting_room_outlined,
              ),
              Positioned(
                right: 13,
                bottom: 13,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 11,
                    vertical: 7,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: .55),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: const Text(
                    'صورة الغرفة الحالية',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
          )
        else
          const ManaraDecorativeImageSlot(
            height: 205,
            icon: Icons.meeting_room_outlined,
            borderRadius: BorderRadius.all(Radius.circular(22)),
          ),
        const SizedBox(height: 9),
        const Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.image_outlined, color: AppTheme.gold, size: 18),
            SizedBox(width: 7),
            Expanded(
              child: Text(
                'مكان الصورة محفوظ في التصميم. صور الغرف الحالية تأتي تلقائياً من الويب/السيرفر، ويمكن إضافة صورة نهائية لاحقاً دون تغيير شكل الصفحة.',
                style: TextStyle(
                  color: AppTheme.muted,
                  fontSize: 10.5,
                  height: 1.45,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
