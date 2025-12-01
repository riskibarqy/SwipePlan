import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppPalette {
  static const Color deepInk = Color(0xFF2F3A4D);
  static const Color terracotta = Color(0xFFDB7857);
  static const Color mistySage = Color(0xFF8DB89F);
  static const Color warmGlow = Color(0xFFF8D7BF);
  static const Color blushSky = Color(0xFFFDEFE1);
  static const Color driftwood = Color(0xFF8A7763);
  static const Color parchment = Color(0xFFFFF9F1);
}

class AppTheme {
  static ThemeData get light {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: AppPalette.deepInk,
      brightness: Brightness.light,
    ).copyWith(
      primary: AppPalette.deepInk,
      onPrimary: Colors.white,
      primaryContainer: const Color(0xFF44566C),
      secondary: AppPalette.terracotta,
      onSecondary: Colors.white,
      secondaryContainer: const Color(0xFFF6CABB),
      onSecondaryContainer: AppPalette.deepInk,
      tertiary: AppPalette.mistySage,
      onTertiary: Colors.white,
      tertiaryContainer: const Color(0xFFD2E8DA),
      surface: AppPalette.parchment,
      surfaceTint: AppPalette.deepInk,
      outline: const Color(0xFFBCAEA2),
    );

    final baseTextTheme = GoogleFonts.workSansTextTheme();
    final displayTheme = GoogleFonts.playfairDisplayTextTheme();

    final textTheme = baseTextTheme.copyWith(
      headlineLarge: displayTheme.headlineLarge?.copyWith(
        color: AppPalette.deepInk,
        fontWeight: FontWeight.w600,
        height: 1.1,
      ),
      headlineMedium: displayTheme.headlineMedium?.copyWith(
        color: AppPalette.deepInk,
        fontWeight: FontWeight.w600,
        height: 1.15,
      ),
      headlineSmall: displayTheme.headlineSmall?.copyWith(
        color: AppPalette.deepInk,
        fontWeight: FontWeight.w600,
      ),
      titleLarge: baseTextTheme.titleLarge?.copyWith(
        fontWeight: FontWeight.w700,
        letterSpacing: -0.2,
      ),
      bodyLarge: baseTextTheme.bodyLarge?.copyWith(
        color: AppPalette.deepInk.withValues(alpha: 0.85),
        height: 1.4,
      ),
      bodyMedium: baseTextTheme.bodyMedium?.copyWith(
        color: AppPalette.deepInk.withValues(alpha: 0.7),
      ),
    );

    final roundedShape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(24),
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      textTheme: textTheme,
      scaffoldBackgroundColor: Colors.transparent,
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        titleSpacing: 0,
        foregroundColor: colorScheme.primary,
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: AppPalette.parchment,
        shape: roundedShape,
        margin: EdgeInsets.zero,
      ),
      dialogTheme: DialogThemeData(shape: roundedShape),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppPalette.parchment,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide(
            color: colorScheme.outline.withValues(alpha: 0.5),
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide(
            color: colorScheme.outline.withValues(alpha: 0.4),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide(color: colorScheme.primary, width: 1.6),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 14,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: colorScheme.primary,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: colorScheme.secondary,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: colorScheme.secondary,
          side: BorderSide(color: colorScheme.secondary.withValues(alpha: 0.4)),
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: colorScheme.secondary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
        ),
      ),
      tabBarTheme: TabBarThemeData(
        labelStyle: textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: textTheme.titleMedium,
        labelColor: colorScheme.primary,
        unselectedLabelColor: colorScheme.primary.withValues(alpha: 0.5),
        indicatorSize: TabBarIndicatorSize.tab,
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: colorScheme.secondary,
        contentTextStyle: textTheme.bodyMedium?.copyWith(color: Colors.white),
      ),
    );
  }
}

class AppGradients {
  static const background = LinearGradient(
    colors: [AppPalette.blushSky, AppPalette.warmGlow, AppPalette.mistySage],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const surface = LinearGradient(
    colors: [Color(0xFFFFFEFA), AppPalette.parchment, Color(0xFFF4E8DA)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const accent = LinearGradient(
    colors: [Color(0xFF9AC6B4), Color(0xFF6E9D9A)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
}

class AppShadows {
  static final soft = BoxShadow(
    color: Colors.black.withValues(alpha: 0.12),
    blurRadius: 40,
    spreadRadius: 0,
    offset: const Offset(0, 28),
  );

  static final layered = [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.15),
      blurRadius: 50,
      offset: const Offset(0, 32),
    ),
    BoxShadow(
      color: AppPalette.terracotta.withValues(alpha: 0.15),
      blurRadius: 30,
      offset: const Offset(0, 12),
    ),
  ];
}
