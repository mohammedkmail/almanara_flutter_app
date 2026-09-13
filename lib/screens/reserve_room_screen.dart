import 'package:flutter/material.dart';

import '../models/study_room.dart';

class ReserveRoomScreen extends StatefulWidget {
  final StudyRoom room;

  const ReserveRoomScreen({
    super.key,
    required this.room,
  });

  @override
  State<ReserveRoomScreen> createState() => _ReserveRoomScreenState();
}

class _ReserveRoomScreenState extends State<ReserveRoomScreen> {
  final _formKey = GlobalKey<FormState>();
  DateTime? selectedDate;
  TimeOfDay? selectedTime;
  int durationHours = 1;

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final value = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: now,
      lastDate: now.add(const Duration(days: 90)),
    );
    if (value != null) {
      setState(() => selectedDate = value);
    }
  }

  Future<void> _pickTime() async {
    final value = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (value != null) {
      setState(() => selectedTime = value);
    }
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    if (selectedDate == null || selectedTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('اختر التاريخ والوقت أولاً')),
      );
      return;
    }

    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تأكيد الحجز'),
        content: Text(
          'الغرفة: ${widget.room.name}\n'
          'المدة: $durationHours ساعة\n'
          'المبلغ المبدئي: ${(widget.room.hourlyPrice * durationHours).toStringAsFixed(0)} ₪',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(this.context).showSnackBar(
                const SnackBar(
                  content: Text('تم تجهيز الحجز، وسيتم ربط الدفع بالـ API لاحقاً'),
                ),
              );
            },
            child: const Text('متابعة'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    String formatDate() {
      if (selectedDate == null) return 'اختر التاريخ';
      return '${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}';
    }

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(title: const Text('حجز غرفة')),
        body: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 14, 20, 30),
            children: [
              Text(
                widget.room.name,
                style: TextStyle(
                  color: colors.onSurface,
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                '${widget.room.hourlyPrice.toStringAsFixed(0)} ₪ لكل ساعة',
                style: TextStyle(color: colors.onSurfaceVariant),
              ),
              const SizedBox(height: 28),
              _PickerField(
                label: 'التاريخ',
                value: formatDate(),
                icon: Icons.calendar_today_outlined,
                onTap: _pickDate,
              ),
              const SizedBox(height: 14),
              _PickerField(
                label: 'وقت البداية',
                value: selectedTime?.format(context) ?? 'اختر الوقت',
                icon: Icons.schedule_outlined,
                onTap: _pickTime,
              ),
              const SizedBox(height: 14),
              DropdownButtonFormField<int>(
                initialValue: durationHours,
                decoration: const InputDecoration(
                  labelText: 'مدة الحجز',
                  prefixIcon: Icon(Icons.timelapse_outlined),
                ),
                items: const [1, 2, 3, 4]
                    .map(
                      (hours) => DropdownMenuItem(
                        value: hours,
                        child: Text('$hours ساعة'),
                      ),
                    )
                    .toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() => durationHours = value);
                  }
                },
              ),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: theme.cardColor,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: theme.dividerColor),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        'المبلغ المبدئي',
                        style: TextStyle(color: colors.onSurfaceVariant),
                      ),
                    ),
                    Text(
                      '${(widget.room.hourlyPrice * durationHours).toStringAsFixed(0)} ₪',
                      style: TextStyle(
                        color: colors.onSurface,
                        fontWeight: FontWeight.w800,
                        fontSize: 17,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              FilledButton(
                onPressed: _submit,
                child: const Text('متابعة الحجز'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PickerField extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final VoidCallback onTap;

  const _PickerField({
    required this.label,
    required this.value,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon),
        ),
        child: Text(
          value,
          style: TextStyle(color: theme.colorScheme.onSurface),
        ),
      ),
    );
  }
}
