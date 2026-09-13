import 'package:flutter/material.dart';

import 'screens/splash_screen.dart';
import 'theme/app_theme.dart';
import 'theme/theme_controller.dart';

void main() {
  runApp(
    const MyApp(),
  );
}

class MyApp
    extends StatelessWidget {
  const MyApp({
    super.key,
  });

  @override
  Widget build(
      BuildContext context,
      ) {
    return ValueListenableBuilder<
        ThemeMode>(
      valueListenable:
      ThemeController.themeMode,

      builder: (
          context,
          themeMode,
          child,
          ) {
        return MaterialApp(
          debugShowCheckedModeBanner:
          false,

          title: 'المنارة',

          theme:
          AppTheme.lightTheme,

          darkTheme:
          AppTheme.darkTheme,

          themeMode:
          themeMode,

          home:
          const SplashScreen(),
        );
      },
    );
  }
}