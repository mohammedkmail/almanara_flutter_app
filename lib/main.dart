import 'package:flutter/material.dart';

import 'screens/login_screen.dart';
import 'screens/splash_screen.dart';
import 'theme/app_theme.dart';
import 'theme/theme_controller.dart';
import 'services/auth_service.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final _navigatorKey = GlobalKey<NavigatorState>();
  @override
  void initState() {
    super.initState();
    AuthService.instance.user.addListener(_sessionChanged);
  }

  void _sessionChanged() {
    if (AuthService.instance.user.value == null) {
      _navigatorKey.currentState?.pushNamedAndRemoveUntil(
        '/login',
        (_) => false,
      );
    }
  }

  @override
  void dispose() {
    AuthService.instance.user.removeListener(_sessionChanged);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: ThemeController.themeMode,

      builder: (context, themeMode, child) {
        return MaterialApp(
          navigatorKey: _navigatorKey,
          debugShowCheckedModeBanner: false,

          title: 'المنارة',

          theme: AppTheme.lightTheme,

          darkTheme: AppTheme.darkTheme,

          themeMode: themeMode,

          routes: {'/login': (context) => const LoginScreen()},

          home: const SplashScreen(),
        );
      },
    );
  }
}
