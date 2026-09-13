import 'package:flutter/material.dart';

import '../books_screen.dart';
import 'admin_dashboard_screen.dart';
import 'admin_more_screen.dart';
import 'admin_operations_screen.dart';
import 'admin_rooms_screen.dart';

class AdminMainScreen extends StatefulWidget {
  const AdminMainScreen({super.key});

  @override
  State<AdminMainScreen> createState() => _AdminMainScreenState();
}

class _AdminMainScreenState extends State<AdminMainScreen> {
  int currentIndex = 0;

  final List<Widget> pages = const [
    AdminDashboardScreen(),
    BooksScreen(),
    AdminOperationsScreen(),
    AdminRoomsScreen(),
    AdminMoreScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        body: IndexedStack(index: currentIndex, children: pages),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: currentIndex,
          onTap: (index) => setState(() => currentIndex = index),
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.dashboard_outlined),
              activeIcon: Icon(Icons.dashboard_rounded),
              label: 'الرئيسية',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.menu_book_outlined),
              activeIcon: Icon(Icons.menu_book_rounded),
              label: 'الكتب',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.receipt_long_outlined),
              activeIcon: Icon(Icons.receipt_long_rounded),
              label: 'العمليات',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.meeting_room_outlined),
              activeIcon: Icon(Icons.meeting_room_rounded),
              label: 'الغرف',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.more_horiz_rounded),
              label: 'المزيد',
            ),
          ],
        ),
      ),
    );
  }
}
