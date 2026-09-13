import 'package:flutter/material.dart';

import '../models/api_models.dart';

class ReservationResultScreen extends StatelessWidget {
  final BookReservation reservation;
  const ReservationResultScreen({super.key, required this.reservation});
  @override
  Widget build(BuildContext context) => Directionality(
    textDirection: TextDirection.rtl,
    child: Scaffold(
      appBar: AppBar(title: const Text('نتيجة الحجز')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Icon(
              Icons.check_circle_outline,
              size: 64,
              color: Colors.teal,
            ),
            const SizedBox(height: 20),
            Text(
              'تم تسجيل الحجز رقم ${reservation.id}',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 12),
            Text(reservation.bookTitle),
            const SizedBox(height: 12),
            Text(reservation.statusLabel),
            const SizedBox(height: 12),
            Text('الرسوم: ${reservation.feeAmount.toStringAsFixed(2)} ₪'),
            const SizedBox(height: 20),
            const Text(
              'تابع حالة الحجز من مكتبتي. إذا احتاج دفعاً أو تأكيداً، أكمله من موقع المكتبة أو لدى الموظف.',
            ),
          ],
        ),
      ),
    ),
  );
}
