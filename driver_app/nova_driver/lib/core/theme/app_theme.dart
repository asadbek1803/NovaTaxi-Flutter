import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Nova Taxi haydovchi ilovasi rang palitrasi.
/// Yoshi kattalar uchun yuqori kontrast va aniq ranglar.
class NovaColors {
  static const Color amber = Color(0xFFFFCC00);
  static const Color amberDark = Color(0xFFE6B800);
  static const Color amberDeep = Color(0xFFD4A000);
  static const Color amberLight = Color(0xFFFFF8E1);
  static const Color online = Color(0xFF22C55E);
  static const Color onlineDark = Color(0xFF16A34A);
  static const Color offline = Color(0xFF6B7280);
  static const Color danger = Color(0xFFEF4444);
  static const Color backgroundLight = Color(0xFFF5F5F7);
  static const Color backgroundDark = Color(0xFF121212);
  static const Color surfaceDark = Color(0xFF1E1E1E);
  static const Color cardDark = Color(0xFF2A2A2A);
  static const Color navBarDark = Color(0xFF1A1A1A);
  static const Color textPrimary = Color(0xFF111827);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color textOnDark = Color(0xFFE5E7EB);
  static const Color mapGreen = Color(0xFFDCECC8);
  static const Color mapGreenDark = Color(0xFFC5DBA8);
}

class AppTheme {
  static ThemeData light() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: NovaColors.backgroundLight,
      colorScheme: const ColorScheme.light(
        primary: NovaColors.amber,
        onPrimary: Color(0xFF1A1A1A),
        secondary: NovaColors.online,
        onSecondary: Colors.white,
        surface: Colors.white,
        onSurface: NovaColors.textPrimary,
        error: NovaColors.danger,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.white,
        foregroundColor: NovaColors.textPrimary,
        elevation: 0,
        scrolledUnderElevation: 0.5,
        centerTitle: false,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        titleTextStyle: TextStyle(
          color: NovaColors.textPrimary,
          fontSize: 24,
          fontWeight: FontWeight.w800,
          letterSpacing: -0.3,
        ),
      ),
      textTheme: const TextTheme(
        headlineLarge: TextStyle(
          fontSize: 34,
          fontWeight: FontWeight.w800,
          color: NovaColors.textPrimary,
          letterSpacing: -0.5,
        ),
        headlineMedium: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.w800,
          color: NovaColors.textPrimary,
        ),
        headlineSmall: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w700,
          color: NovaColors.textPrimary,
        ),
        titleLarge: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w700,
          color: NovaColors.textPrimary,
        ),
        titleMedium: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: NovaColors.textPrimary,
        ),
        bodyLarge: TextStyle(fontSize: 18, color: NovaColors.textPrimary, height: 1.35),
        bodyMedium: TextStyle(fontSize: 16, color: NovaColors.textPrimary, height: 1.35),
        labelLarge: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: Colors.white),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Colors.white,
        selectedItemColor: NovaColors.textPrimary,
        unselectedItemColor: NovaColors.textSecondary,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
        selectedLabelStyle: TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
        unselectedLabelStyle: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
      ),
      cardTheme: CardThemeData(
        color: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: NovaColors.amber,
          foregroundColor: NovaColors.textPrimary,
          elevation: 0,
          minimumSize: const Size(0, 58),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
        ),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          return Colors.white;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return NovaColors.online;
          }
          return NovaColors.offline;
        }),
      ),
    );
  }

  static ThemeData dark() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: NovaColors.backgroundDark,
      colorScheme: const ColorScheme.dark(
        primary: NovaColors.amber,
        onPrimary: Color(0xFF1A1A1A),
        secondary: NovaColors.online,
        onSecondary: Colors.white,
        surface: NovaColors.surfaceDark,
        onSurface: NovaColors.textOnDark,
        error: NovaColors.danger,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: NovaColors.surfaceDark,
        foregroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0.5,
        centerTitle: false,
        systemOverlayStyle: SystemUiOverlayStyle.light,
        titleTextStyle: TextStyle(
          color: Colors.white,
          fontSize: 24,
          fontWeight: FontWeight.w800,
          letterSpacing: -0.3,
        ),
      ),
      textTheme: const TextTheme(
        headlineLarge: TextStyle(
          fontSize: 34,
          fontWeight: FontWeight.w800,
          color: Colors.white,
          letterSpacing: -0.5,
        ),
        headlineMedium: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.w800,
          color: Colors.white,
        ),
        headlineSmall: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w700,
          color: Colors.white,
        ),
        titleLarge: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w700,
          color: Colors.white,
        ),
        titleMedium: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
        bodyLarge: TextStyle(fontSize: 18, color: NovaColors.textOnDark, height: 1.35),
        bodyMedium: TextStyle(fontSize: 16, color: NovaColors.textOnDark, height: 1.35),
        labelLarge: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: Colors.white),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: NovaColors.navBarDark,
        selectedItemColor: NovaColors.amber,
        unselectedItemColor: NovaColors.textSecondary,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
        selectedLabelStyle: TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
        unselectedLabelStyle: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
      ),
      cardTheme: CardThemeData(
        color: NovaColors.cardDark,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: NovaColors.amber,
          foregroundColor: NovaColors.textPrimary,
          elevation: 0,
          minimumSize: const Size(0, 58),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
        ),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          return Colors.white;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return NovaColors.online;
          }
          return NovaColors.offline;
        }),
      ),
    );
  }
}
