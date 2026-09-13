import 'package:flutter/material.dart';

class AppTheme {
  // ============================
  // PROJECT BRAND COLORS
  // ============================

  static const Color darkTeal =
  Color(0xFF0B4F4C);

  static const Color teal =
  Color(0xFF146B67);

  static const Color turquoise =
  Color(0xFF20B8B2);

  // ============================
  // LIGHT COLORS
  // ============================

  static const Color lightBackground =
  Color(0xFFF6F6F2);

  static const Color lightSurface =
  Color(0xFFFFFFFF);

  static const Color lightCard =
  Color(0xFFFDFDFC);

  static const Color lightText =
  Color(0xFF172826);

  static const Color lightMuted =
  Color(0xFF6C7A78);

  static const Color lightBorder =
  Color(0xFFDDE5E2);

  // ============================
  // DARK COLORS
  // ============================

  static const Color darkBackground =
  Color(0xFF091412);

  static const Color darkSurface =
  Color(0xFF10201D);

  static const Color darkCard =
  Color(0xFF152925);

  static const Color darkText =
  Color(0xFFF1F6F5);

  static const Color darkMuted =
  Color(0xFF9BAEAA);

  static const Color darkBorder =
  Color(0xFF29413D);

  // ============================
  // LIGHT THEME
  // ============================

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,

      scaffoldBackgroundColor:
      lightBackground,

      colorScheme:
      ColorScheme.fromSeed(
        seedColor: teal,
        brightness: Brightness.light,
        primary: teal,
        secondary: turquoise,
        surface: lightSurface,
      ),

      appBarTheme:
      const AppBarTheme(
        backgroundColor:
        lightBackground,
        foregroundColor:
        lightText,
        elevation: 0,
        centerTitle: false,
      ),

      cardTheme: CardThemeData(
        color: lightCard,
        elevation: 0,
        shape:
        RoundedRectangleBorder(
          borderRadius:
          BorderRadius.circular(18),
          side: const BorderSide(
            color: lightBorder,
          ),
        ),
      ),

      inputDecorationTheme:
      InputDecorationTheme(
        filled: true,
        fillColor: lightSurface,

        hintStyle:
        const TextStyle(
          color: lightMuted,
        ),

        border:
        OutlineInputBorder(
          borderRadius:
          BorderRadius.circular(14),
          borderSide:
          const BorderSide(
            color: lightBorder,
          ),
        ),

        enabledBorder:
        OutlineInputBorder(
          borderRadius:
          BorderRadius.circular(14),
          borderSide:
          const BorderSide(
            color: lightBorder,
          ),
        ),

        focusedBorder:
        OutlineInputBorder(
          borderRadius:
          BorderRadius.circular(14),
          borderSide:
          const BorderSide(
            color: turquoise,
            width: 1.5,
          ),
        ),
      ),

      elevatedButtonTheme:
      ElevatedButtonThemeData(
        style:
        ElevatedButton.styleFrom(
          backgroundColor: teal,
          foregroundColor:
          Colors.white,
          elevation: 0,

          shape:
          RoundedRectangleBorder(
            borderRadius:
            BorderRadius.circular(
              14,
            ),
          ),
        ),
      ),

      bottomNavigationBarTheme:
      const BottomNavigationBarThemeData(
        backgroundColor:
        Colors.white,

        selectedItemColor:
        turquoise,

        unselectedItemColor:
        lightMuted,

        type:
        BottomNavigationBarType.fixed,

        elevation: 10,
      ),

      dividerColor:
      lightBorder,
    );
  }

  // ============================
  // DARK THEME
  // ============================

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,

      scaffoldBackgroundColor:
      darkBackground,

      colorScheme:
      ColorScheme.fromSeed(
        seedColor: turquoise,
        brightness: Brightness.dark,
        primary: turquoise,
        secondary: teal,
        surface: darkSurface,
      ),

      appBarTheme:
      const AppBarTheme(
        backgroundColor:
        darkBackground,
        foregroundColor:
        darkText,
        elevation: 0,
        centerTitle: false,
      ),

      cardTheme: CardThemeData(
        color: darkCard,
        elevation: 0,

        shape:
        RoundedRectangleBorder(
          borderRadius:
          BorderRadius.circular(18),

          side: const BorderSide(
            color: darkBorder,
          ),
        ),
      ),

      inputDecorationTheme:
      InputDecorationTheme(
        filled: true,
        fillColor: darkSurface,

        hintStyle:
        const TextStyle(
          color: darkMuted,
        ),

        border:
        OutlineInputBorder(
          borderRadius:
          BorderRadius.circular(14),

          borderSide:
          const BorderSide(
            color: darkBorder,
          ),
        ),

        enabledBorder:
        OutlineInputBorder(
          borderRadius:
          BorderRadius.circular(14),

          borderSide:
          const BorderSide(
            color: darkBorder,
          ),
        ),

        focusedBorder:
        OutlineInputBorder(
          borderRadius:
          BorderRadius.circular(14),

          borderSide:
          const BorderSide(
            color: turquoise,
            width: 1.5,
          ),
        ),
      ),

      elevatedButtonTheme:
      ElevatedButtonThemeData(
        style:
        ElevatedButton.styleFrom(
          backgroundColor:
          turquoise,

          foregroundColor:
          const Color(
            0xFF071B19,
          ),

          elevation: 0,

          shape:
          RoundedRectangleBorder(
            borderRadius:
            BorderRadius.circular(
              14,
            ),
          ),
        ),
      ),

      bottomNavigationBarTheme:
      const BottomNavigationBarThemeData(
        backgroundColor:
        darkSurface,

        selectedItemColor:
        turquoise,

        unselectedItemColor:
        darkMuted,

        type:
        BottomNavigationBarType.fixed,

        elevation: 10,
      ),

      dividerColor:
      darkBorder,
    );
  }
}