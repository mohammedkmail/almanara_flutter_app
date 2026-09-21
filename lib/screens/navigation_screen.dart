import 'package:flutter/material.dart';

import '../models/app_user_role.dart';
import 'admin/admin_navigation_screen.dart';
import 'books_screen.dart';
import 'home_screen.dart';
import 'my_library_screen.dart';
import 'profile_screen.dart';
import 'study_rooms_screen.dart';

class MainScreen extends StatelessWidget {
  final AppUserRole role;

  const MainScreen({
    super.key,
    this.role = AppUserRole.customer,
  });

  @override
  Widget build(BuildContext context) {
    return role == AppUserRole.admin
        ? const AdminMainScreen()
        : const UserMainScreen();
  }
}

class UserMainScreen extends StatefulWidget {
  const UserMainScreen({super.key});

  @override
  State<UserMainScreen> createState() => _UserMainScreenState();
}

class _UserMainScreenState extends State<UserMainScreen> {
  int _index = 0;

  static const _pages = <Widget>[
    HomeScreen(),
    BooksScreen(),
    MyLibraryScreen(),
    StudyRoomsScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        body: IndexedStack(
          index: _index,
          children: _pages,
        ),
        bottomNavigationBar: NavigationBar(
          selectedIndex: _index,
          onDestinationSelected: (value) {
            setState(() {
              _index = value;
            });
          },
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.home_outlined),
              selectedIcon: Icon(Icons.home_rounded),
              label: 'الرئيسية',
            ),
            NavigationDestination(
              icon: Icon(Icons.travel_explore_outlined),
              selectedIcon: Icon(Icons.travel_explore_rounded),
              label: 'اكتشف',
            ),
            NavigationDestination(
              icon: Icon(Icons.collections_bookmark_outlined),
              selectedIcon: Icon(Icons.collections_bookmark_rounded),
              label: 'مكتبتي',
            ),
            NavigationDestination(
              icon: Icon(Icons.meeting_room_outlined),
              selectedIcon: Icon(Icons.meeting_room_rounded),
              label: 'الغرف',
            ),
            NavigationDestination(
              icon: Icon(Icons.person_outline_rounded),
              selectedIcon: Icon(Icons.person_rounded),
              label: 'حسابي',
            ),
          ],
        ),
      ),
    );
  }
}