// lib/core/theme/app_theme.dart
import 'package:flutter/material.dart';

/// Vibrant oyun teması.
/// Canlı mor/turuncu renk paleti ile hem light hem dark modda tutarlı görünüm.
class AppTheme {
  AppTheme._();

  // ─── Renk Sabitleri ────────────────────────────────────────────
  static const Color primaryLight = Color(0xFF6C63FF);   // Violet
  static const Color primaryDark = Color(0xFF8B83FF);    // Lighter Violet

  static const Color secondaryLight = Color(0xFFFF6B35); // Tangerine
  static const Color secondaryDark = Color(0xFFFF8C5A);  // Softer Tangerine

  static const Color accentCyan = Color(0xFF00D9FF);     // Neon Cyan
  static const Color accentGold = Color(0xFFFFD700);     // Gold

  static const Color bgLight = Color(0xFFF2F0FF);        // Soft Lavender
  static const Color bgDark = Color(0xFF0D0D1A);         // Deep Navy

  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color surfaceDark = Color(0xFF16162A);    // Dark Navy Card

  static const Color cardLight = Color(0xFFFFFFFF);
  static const Color cardDark = Color(0xFF1E1E35);       // Slightly lighter

  // ─── NEON Theme Colors ─────────────────────────────────────────
  static const Color neonPrimaryMagenta = Color(0xFFFF006E);    // Electric Magenta
  static const Color neonCyan = Color(0xFF00D9FF);               // Bright Cyan
  static const Color neonLimeGreen = Color(0xFF39FF14);          // Neon Lime
  static const Color neonPurple = Color(0xFFB500FF);             // Electric Purple
  static const Color neonPink = Color(0xFFFF10F0);               // Hot Pink
  static const Color neonOrange = Color(0xFFFF6600);             // Neon Orange

  static const Color neonBgDark = Color(0xFF0A0A15);             // Deep Black
  static const Color neonSurfaceDark = Color(0xFF161129);        // Dark Purple

  // ─── Light Theme ──────────────────────────────────────────────
  static ThemeData get lightTheme => ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        colorScheme: const ColorScheme.light(
          primary: primaryLight,
          onPrimary: Colors.white,
          secondary: secondaryLight,
          onSecondary: Colors.white,
          tertiary: accentCyan,
          surface: surfaceLight,
          onSurface: Color(0xFF1A1A2E),
        ),
        scaffoldBackgroundColor: bgLight,
        cardTheme: CardThemeData(
          color: cardLight,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
          scrolledUnderElevation: 0,
          centerTitle: true,
          titleTextStyle: TextStyle(
            color: Color(0xFF1A1A2E),
            fontSize: 20,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.5,
          ),
          iconTheme: IconThemeData(color: Color(0xFF1A1A2E)),
        ),
        switchTheme: SwitchThemeData(
          thumbColor: WidgetStateProperty.resolveWith(
            (s) => s.contains(WidgetState.selected) ? primaryLight : Colors.grey,
          ),
          trackColor: WidgetStateProperty.resolveWith(
            (s) => s.contains(WidgetState.selected)
                ? primaryLight.withOpacity(0.4)
                : Colors.grey.withOpacity(0.3),
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: primaryLight,
            foregroundColor: Colors.white,
            elevation: 4,
            shadowColor: primaryLight.withOpacity(0.4),
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
            textStyle: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.5,
            ),
          ),
        ),
        textTheme: _buildTextTheme(const Color(0xFF1A1A2E)),
        dividerTheme: DividerThemeData(
          color: Colors.grey.withOpacity(0.2),
          thickness: 1,
        ),
      );

  // ─── Dark Theme ───────────────────────────────────────────────
  static ThemeData get darkTheme => ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorScheme: const ColorScheme.dark(
          primary: primaryDark,
          onPrimary: Colors.white,
          secondary: secondaryDark,
          onSecondary: Colors.white,
          tertiary: accentCyan,
          surface: surfaceDark,
          onSurface: Colors.white,
        ),
        scaffoldBackgroundColor: bgDark,
        cardTheme: CardThemeData(
          color: cardDark,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
          scrolledUnderElevation: 0,
          centerTitle: true,
          titleTextStyle: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.5,
          ),
          iconTheme: IconThemeData(color: Colors.white),
        ),
        switchTheme: SwitchThemeData(
          thumbColor: WidgetStateProperty.resolveWith(
            (s) => s.contains(WidgetState.selected) ? primaryDark : Colors.grey,
          ),
          trackColor: WidgetStateProperty.resolveWith(
            (s) => s.contains(WidgetState.selected)
                ? primaryDark.withOpacity(0.5)
                : Colors.grey.withOpacity(0.3),
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: primaryDark,
            foregroundColor: Colors.white,
            elevation: 6,
            shadowColor: primaryDark.withOpacity(0.5),
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
            textStyle: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.5,
            ),
          ),
        ),
        textTheme: _buildTextTheme(Colors.white),
        dividerTheme: DividerThemeData(
          color: Colors.white.withOpacity(0.1),
          thickness: 1,
        ),
      );

  // ─── Text Theme ───────────────────────────────────────────────
  static TextTheme _buildTextTheme(Color baseColor) => TextTheme(
        displayLarge: TextStyle(
          color: baseColor,
          fontSize: 32,
          fontWeight: FontWeight.w900,
          letterSpacing: -0.5,
        ),
        displayMedium: TextStyle(
          color: baseColor,
          fontSize: 26,
          fontWeight: FontWeight.w800,
        ),
        headlineLarge: TextStyle(
          color: baseColor,
          fontSize: 22,
          fontWeight: FontWeight.w700,
        ),
        headlineMedium: TextStyle(
          color: baseColor,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
        titleLarge: TextStyle(
          color: baseColor,
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
        bodyLarge: TextStyle(
          color: baseColor,
          fontSize: 15,
          fontWeight: FontWeight.w400,
        ),
        bodyMedium: TextStyle(
          color: baseColor.withOpacity(0.7),
          fontSize: 13,
          fontWeight: FontWeight.w400,
        ),
        labelSmall: TextStyle(
          color: baseColor.withOpacity(0.5),
          fontSize: 11,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.5,
        ),
      );

  // ─── Gradient Yardımcıları ─────────────────────────────────────
  static LinearGradient primaryGradient(Brightness brightness) =>
      LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: brightness == Brightness.dark
            ? [const Color(0xFF16162A), const Color(0xFF0D0D1A)]
            : [const Color(0xFFF2F0FF), const Color(0xFFE8E4FF)],
      );

  static LinearGradient accentGradient() => const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFF6C63FF), Color(0xFFFF6B35)],
      );

  static LinearGradient splashGradient() => const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFF0D0D2B), Color(0xFF1A1050), Color(0xFF0D0D1A)],
      );

  // ─── NEON Theme ───────────────────────────────────────────────
  static ThemeData get neonTheme => ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorScheme: const ColorScheme.dark(
          primary: neonPrimaryMagenta,
          onPrimary: Color(0xFF0A0A15),
          secondary: neonCyan,
          onSecondary: Color(0xFF0A0A15),
          tertiary: neonLimeGreen,
          surface: neonSurfaceDark,
          onSurface: Color(0xFF00D9FF),
          error: neonPink,
        ),
        scaffoldBackgroundColor: neonBgDark,
        cardTheme: CardThemeData(
          color: neonSurfaceDark,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(
              color: neonCyan,
              width: 2,
            ),
          ),
          shadowColor: neonCyan.withOpacity(0.5),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: neonBgDark,
          elevation: 0,
          scrolledUnderElevation: 0,
          centerTitle: true,
          titleTextStyle: TextStyle(
            color: neonCyan,
            fontSize: 20,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.2,
            shadows: [
              Shadow(
                color: neonCyan,
                offset: Offset(0, 0),
                blurRadius: 10,
              ),
            ],
          ),
          iconTheme: IconThemeData(color: neonCyan),
        ),
        switchTheme: SwitchThemeData(
          thumbColor: WidgetStateProperty.resolveWith(
            (s) => s.contains(WidgetState.selected)
                ? neonPrimaryMagenta
                : neonCyan,
          ),
          trackColor: WidgetStateProperty.resolveWith(
            (s) => s.contains(WidgetState.selected)
                ? neonPrimaryMagenta.withOpacity(0.3)
                : neonCyan.withOpacity(0.2),
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: neonPrimaryMagenta,
            foregroundColor: Color(0xFF0A0A15),
            elevation: 0,
            shadowColor: neonPrimaryMagenta.withOpacity(0.8),
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
              side: const BorderSide(
                color: neonCyan,
                width: 2,
              ),
            ),
            textStyle: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              letterSpacing: 1,
            ),
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: neonCyan,
            side: const BorderSide(
              color: neonCyan,
              width: 2,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
            textStyle: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              letterSpacing: 1,
            ),
          ),
        ),
        textTheme: _buildNeonTextTheme(),
        dividerTheme: DividerThemeData(
          color: neonCyan.withOpacity(0.2),
          thickness: 1,
        ),
      );

  // ─── Neon Text Theme ───────────────────────────────────────────
  static TextTheme _buildNeonTextTheme() => const TextTheme(
        displayLarge: TextStyle(
          color: neonCyan,
          fontSize: 32,
          fontWeight: FontWeight.w900,
          letterSpacing: 1,
          shadows: [
            Shadow(
              color: neonCyan,
              offset: Offset(0, 0),
              blurRadius: 8,
            ),
          ],
        ),
        displayMedium: TextStyle(
          color: neonCyan,
          fontSize: 26,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.8,
          shadows: [
            Shadow(
              color: neonCyan,
              offset: Offset(0, 0),
              blurRadius: 6,
            ),
          ],
        ),
        headlineLarge: TextStyle(
          color: neonPrimaryMagenta,
          fontSize: 22,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.5,
        ),
        headlineMedium: TextStyle(
          color: neonCyan,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
        titleLarge: TextStyle(
          color: neonLimeGreen,
          fontSize: 16,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        ),
        bodyLarge: TextStyle(
          color: Colors.white,
          fontSize: 15,
          fontWeight: FontWeight.w400,
        ),
        bodyMedium: TextStyle(
          color: Color(0xFFB0B0D9),
          fontSize: 13,
          fontWeight: FontWeight.w400,
        ),
        labelSmall: TextStyle(
          color: neonCyan,
          fontSize: 11,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.8,
        ),
      );

  // ─── Neon Gradients ────────────────────────────────────────────
  static LinearGradient neonGradient1() => const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Color(0xFF0A0A15),
          Color(0xFF1A0A2E),
        ],
      );

  static LinearGradient neonGradient2() => const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          neonPrimaryMagenta,
          neonPurple,
          neonBgDark,
        ],
      );

  static LinearGradient neonGradient3() => const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          neonCyan,
          neonLimeGreen,
        ],
      );
}
