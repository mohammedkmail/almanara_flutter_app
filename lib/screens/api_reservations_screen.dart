import 'package:flutter/material.dart';

import '../models/api_models.dart';
import '../services/library_service.dart';
import '../widgets/api_error_view.dart';
import 'reservation_result_screen.dart';

class ApiReservationsScreen extends StatefulWidget {
  const ApiReservationsScreen({super.key});
  @override
  State<ApiReservationsScreen> createState() => _ApiReservationsScreenState();
}

class _ApiReservationsScreenState extends State<ApiReservationsScreen> {
  late Future<List<BookReservation>> _request;
  @override
  void initState() {
    super.initState();
    _request = LibraryService.instance.reservations();
  }

  void _reload() =>
      setState(() => _request = LibraryService.instance.reservations());
  @override
  Widget build(BuildContext context) => Directionality(
    textDirection: TextDirection.rtl,
    child: Scaffold(
      appBar: AppBar(
        title: const Text('حجوزاتي'),
        actions: [
          IconButton(
            onPressed: _reload,
            icon: const Icon(Icons.refresh),
            tooltip: 'تحديث',
          ),
        ],
      ),
      body: FutureBuilder<List<BookReservation>>(
        future: _request,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return ApiErrorView(error: snapshot.error!, retry: _reload);
          }
          final items = snapshot.data!;
          if (items.isEmpty) {
            return const Center(
              child: Text('لا توجد حجوزات بعد. اختر كتاباً من قائمة الكتب.'),
            );
          }
          return ListView.builder(
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index];
              return ListTile(
                title: Text(item.bookTitle),
                subtitle: Text(item.statusLabel),
                trailing: Text('#${item.id}'),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute<void>(
                    builder: (_) => ReservationResultScreen(reservation: item),
                  ),
                ),
              );
            },
          );
        },
      ),
    ),
  );
}
