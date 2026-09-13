import 'package:flutter/material.dart';

import '../../models/library_book.dart';

class AdminBookFormScreen extends StatefulWidget {
  final LibraryBook? book;

  const AdminBookFormScreen({super.key, this.book});

  @override
  State<AdminBookFormScreen> createState() => _AdminBookFormScreenState();
}

class _AdminBookFormScreenState extends State<AdminBookFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _authorController;
  late final TextEditingController _categoryController;
  late final TextEditingController _isbnController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _borrowingFeeController;
  bool _digitalAvailable = false;
  bool _available = true;

  @override
  void initState() {
    super.initState();
    final book = widget.book;
    _titleController = TextEditingController(text: book?.title ?? '');
    _authorController = TextEditingController(text: book?.author ?? '');
    _categoryController = TextEditingController(text: book?.category ?? '');
    _isbnController = TextEditingController(text: book?.isbn ?? '');
    _descriptionController = TextEditingController(text: book?.description ?? '');
    _borrowingFeeController = TextEditingController(
      text: book?.borrowingFee?.toString() ?? '',
    );
    _digitalAvailable = book?.digitalAvailable ?? false;
    _available = book?.available ?? true;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _authorController.dispose();
    _categoryController.dispose();
    _isbnController.dispose();
    _descriptionController.dispose();
    _borrowingFeeController.dispose();
    super.dispose();
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(widget.book == null ? 'تم تجهيز إضافة الكتاب' : 'تم تجهيز تعديل الكتاب'),
      ),
    );
    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.book == null ? 'إضافة كتاب' : 'تعديل كتاب'),
        ),
        body: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 14, 20, 30),
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'عنوان الكتاب'),
                validator: (value) => value == null || value.trim().isEmpty ? 'أدخل عنوان الكتاب' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _authorController,
                decoration: const InputDecoration(labelText: 'المؤلف'),
                validator: (value) => value == null || value.trim().isEmpty ? 'أدخل اسم المؤلف' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _categoryController,
                decoration: const InputDecoration(labelText: 'التصنيف'),
                validator: (value) => value == null || value.trim().isEmpty ? 'أدخل التصنيف' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _isbnController,
                decoration: const InputDecoration(labelText: 'ISBN'),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _borrowingFeeController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(labelText: 'رسوم الاستعارة'),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _descriptionController,
                maxLines: 4,
                decoration: const InputDecoration(labelText: 'الوصف'),
              ),
              const SizedBox(height: 8),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('متاح للاستعارة'),
                value: _available,
                onChanged: (value) => setState(() => _available = value),
              ),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('نسخة رقمية متوفرة'),
                value: _digitalAvailable,
                onChanged: (value) => setState(() => _digitalAvailable = value),
              ),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: _save,
                child: Text(widget.book == null ? 'إضافة الكتاب' : 'حفظ التعديلات'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
