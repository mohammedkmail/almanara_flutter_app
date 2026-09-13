import 'package:flutter/material.dart';

import '../../models/study_room.dart';

class AdminRoomFormScreen extends StatefulWidget {
  final StudyRoom? room;

  const AdminRoomFormScreen({super.key, this.room});

  @override
  State<AdminRoomFormScreen> createState() => _AdminRoomFormScreenState();
}

class _AdminRoomFormScreenState extends State<AdminRoomFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _locationController;
  late final TextEditingController _capacityController;
  late final TextEditingController _priceController;
  bool _available = true;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.room?.name ?? '');
    _locationController = TextEditingController(text: widget.room?.location ?? '');
    _capacityController = TextEditingController(text: widget.room?.capacity.toString() ?? '');
    _priceController = TextEditingController(text: widget.room?.hourlyPrice.toString() ?? '');
    _available = widget.room?.available ?? true;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _locationController.dispose();
    _capacityController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('تم تجهيز بيانات الغرفة للربط بالـ API')),
    );
    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(title: Text(widget.room == null ? 'إضافة غرفة' : 'تعديل غرفة')),
        body: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 14, 20, 30),
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'اسم الغرفة'),
                validator: (value) => value == null || value.trim().isEmpty ? 'أدخل اسم الغرفة' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _locationController,
                decoration: const InputDecoration(labelText: 'الموقع'),
                validator: (value) => value == null || value.trim().isEmpty ? 'أدخل الموقع' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _capacityController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'السعة'),
                validator: (value) => int.tryParse(value ?? '') == null ? 'أدخل سعة صحيحة' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _priceController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(labelText: 'سعر الساعة'),
                validator: (value) => double.tryParse(value ?? '') == null ? 'أدخل سعراً صحيحاً' : null,
              ),
              const SizedBox(height: 8),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('متاحة للحجز'),
                value: _available,
                onChanged: (value) => setState(() => _available = value),
              ),
              const SizedBox(height: 18),
              FilledButton(
                onPressed: _save,
                child: const Text('حفظ'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
