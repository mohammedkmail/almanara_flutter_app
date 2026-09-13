import 'package:flutter/material.dart';

import '../models/app_user_role.dart';
import 'admin/admin_navigation_screen.dart';
import 'books_screen.dart';
import 'home_screen.dart';
import 'api_reservations_screen.dart';
import 'profile_screen.dart';
import 'study_rooms_screen.dart';

class MainScreen extends StatelessWidget {
  final AppUserRole role;

  const MainScreen({super.key, this.role = AppUserRole.customer});

  @override
  Widget build(BuildContext context) {
    if (role == AppUserRole.admin) {
      return const AdminMainScreen();
    }

    return const UserMainScreen();
  }
}

class UserMainScreen extends StatefulWidget {
  const UserMainScreen({super.key});

  @override
  State<UserMainScreen> createState() => _UserMainScreenState();
}

class _UserMainScreenState extends State<UserMainScreen> {
  int currentIndex = 0;

  final List<Widget> pages = const [
    HomeScreen(),
    BooksScreen(),
    StudyRoomsScreen(),
    ApiReservationsScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        body: pages[currentIndex],
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: currentIndex,
          onTap: (index) {
            setState(() {
              currentIndex = index;
            });
          },
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home),
              label: 'الرئيسية',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.menu_book_outlined),
              activeIcon: Icon(Icons.menu_book),
              label: 'الكتب',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.meeting_room_outlined),
              activeIcon: Icon(Icons.meeting_room),
              label: 'الغرف',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.bookmark_border),
              activeIcon: Icon(Icons.bookmark),
              label: 'مكتبتي',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline),
              activeIcon: Icon(Icons.person),
              label: 'حسابي',
            ),
          ],
        ),
      ),
    );
  }
}
