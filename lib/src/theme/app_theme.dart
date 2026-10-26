import 'package:flutter/material.dart';

enum AppThemeMode {
  ocean,
  sunset,
  forest,
  midnight,
}

class AppTheme {
  // Ocean Theme - Light
  static const Color primaryOcean = Color(0xFF0077B6); // Azure blue
  static const Color secondaryLagoon = Color(0xFF00A896); // Teal green
  static const Color accentSunrise = Color(0xFFFFC857); // Warm accent
  static const Color deepSea = Color(0xFF023E8A); // Deep navy

  // Sunset Theme - Light
  static const Color primarySunset = Color(0xFFFF6B6B); // Coral red
  static const Color secondarySunset = Color(0xFFFF8E53); // Orange
  static const Color accentSunset = Color(0xFFFECA57); // Golden yellow

  // Forest Theme - Light
  static const Color primaryForest = Color(0xFF2ECC71); // Emerald green
  static const Color secondaryForest = Color(0xFF27AE60); // Forest green
  static const Color accentForest = Color(0xFF7DCEA0); // Mint

  // Midnight Theme - Dark
  static const Color primaryMidnight = Color(0xFF6C5CE7); // Purple
  static const Color secondaryMidnight = Color(0xFF5F27CD); // Deep purple
  static const Color accentMidnight = Color(0xFFA29BFE); // Light purple

  // Legacy aliases (backward compatibility within the codebase)
  static const Color primaryOrange = primaryOcean;
  static const Color secondaryRed = deepSea;
  static const Color accentOrange = accentSunrise;

  // Neutral Colors - Light
  static const Color backgroundColor = Color(0xFFF1F7FD);
  static const Color surfaceColor = Color(0xFFFFFFFF);
  static const Color textPrimary = Color(0xFF1B1F3B);
  static const Color textSecondary = Color(0xFF4A5568);
  static const Color textLight = Color(0xFF9AA5B1);

  // Neutral Colors - Dark
  static const Color backgroundColorDark = Color(0xFF1A1A2E);
  static const Color surfaceColorDark = Color(0xFF16213E);
  static const Color textPrimaryDark = Color(0xFFEEEEEE);
  static const Color textSecondaryDark = Color(0xFFB4B4B4);
  static const Color textLightDark = Color(0xFF7A7A7A);

  // Gradient Colors - Ocean
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF9AD8FF), primaryOcean],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient secondaryGradient = LinearGradient(
    colors: [Color(0xFFA7F3D0), secondaryLagoon],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient subtleGradient = LinearGradient(
    colors: [Color(0xFFE8F4FF), Color(0xFFFAFEFF)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient cardGradient = LinearGradient(
    colors: [Color(0xFFFFFFFF), Color(0xFFE4F2FF)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Gradient Colors - Sunset
  static const LinearGradient primaryGradientSunset = LinearGradient(
    colors: [Color(0xFFFFB347), primarySunset],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient cardGradientSunset = LinearGradient(
    colors: [Color(0xFFFFFFFF), Color(0xFFFFE8E0)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Gradient Colors - Forest
  static const LinearGradient primaryGradientForest = LinearGradient(
    colors: [Color(0xFFA8E6CF), primaryForest],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient cardGradientForest = LinearGradient(
    colors: [Color(0xFFFFFFFF), Color(0xFFE8F8F5)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Gradient Colors - Midnight (Dark)
  static const LinearGradient primaryGradientMidnight = LinearGradient(
    colors: [Color(0xFF8B7FD9), primaryMidnight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient cardGradientMidnight = LinearGradient(
    colors: [surfaceColorDark, Color(0xFF1F2640)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Theme Data
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryOcean,
        primary: primaryOcean,
        secondary: secondaryLagoon,
        tertiary: accentSunrise,
        surface: surfaceColor,
        brightness: Brightness.light,
      ),
      scaffoldBackgroundColor: backgroundColor,
      fontFamily: 'Poppins',

      appBarTheme: const AppBarTheme(
        elevation: 0,
        centerTitle: true,
        backgroundColor: Colors.transparent,
        foregroundColor: textPrimary,
        titleTextStyle: TextStyle(
          fontFamily: 'Poppins',
          fontSize: 22,
          fontWeight: FontWeight.w700,
          color: textPrimary,
        ),
      ),

      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        color: surfaceColor,
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: primaryOcean,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          textStyle: const TextStyle(
            fontFamily: 'Poppins',
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          side: const BorderSide(color: primaryOcean, width: 2),
          foregroundColor: primaryOcean,
          textStyle: const TextStyle(
            fontFamily: 'Poppins',
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceColor,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(color: Colors.blueGrey.shade100),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(color: Colors.blueGrey.shade100),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: primaryOcean, width: 2),
        ),
        labelStyle: const TextStyle(
          fontFamily: 'Poppins',
          color: textSecondary,
        ),
      ),

      textTheme: const TextTheme(
        displayLarge: TextStyle(
          fontFamily: 'Poppins',
          fontSize: 34,
          fontWeight: FontWeight.w700,
          color: textPrimary,
        ),
        displayMedium: TextStyle(
          fontFamily: 'Poppins',
          fontSize: 28,
          fontWeight: FontWeight.w700,
          color: textPrimary,
        ),
        displaySmall: TextStyle(
          fontFamily: 'Poppins',
          fontSize: 24,
          fontWeight: FontWeight.w600,
          color: textPrimary,
        ),
        headlineMedium: TextStyle(
          fontFamily: 'Poppins',
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: textPrimary,
        ),
        titleLarge: TextStyle(
          fontFamily: 'Poppins',
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: textPrimary,
        ),
        bodyLarge: TextStyle(
          fontFamily: 'Poppins',
          fontSize: 16,
          color: textPrimary,
        ),
        bodyMedium: TextStyle(
          fontFamily: 'Poppins',
          fontSize: 14,
          color: textSecondary,
        ),
        labelLarge: TextStyle(
          fontFamily: 'Poppins',
          fontSize: 12,
          letterSpacing: 1.2,
          fontWeight: FontWeight.w600,
          color: textSecondary,
        ),
      ),
    );
  }

  // Dark Theme
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryMidnight,
        primary: primaryMidnight,
        secondary: secondaryMidnight,
        tertiary: accentMidnight,
        surface: surfaceColorDark,
        brightness: Brightness.dark,
      ),
      scaffoldBackgroundColor: backgroundColorDark,
      fontFamily: 'Poppins',

      appBarTheme: const AppBarTheme(
        elevation: 0,
        centerTitle: true,
        backgroundColor: Colors.transparent,
        foregroundColor: textPrimaryDark,
        titleTextStyle: TextStyle(
          fontFamily: 'Poppins',
          fontSize: 22,
          fontWeight: FontWeight.w700,
          color: textPrimaryDark,
        ),
      ),

      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        color: surfaceColorDark,
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: primaryMidnight,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          textStyle: const TextStyle(
            fontFamily: 'Poppins',
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          side: const BorderSide(color: primaryMidnight, width: 2),
          foregroundColor: primaryMidnight,
          textStyle: const TextStyle(
            fontFamily: 'Poppins',
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceColorDark,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: Color(0xFF2D3561)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: Color(0xFF2D3561)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: primaryMidnight, width: 2),
        ),
        labelStyle: const TextStyle(
          fontFamily: 'Poppins',
          color: textSecondaryDark,
        ),
      ),

      textTheme: const TextTheme(
        displayLarge: TextStyle(
          fontFamily: 'Poppins',
          fontSize: 34,
          fontWeight: FontWeight.w700,
          color: textPrimaryDark,
        ),
        displayMedium: TextStyle(
          fontFamily: 'Poppins',
          fontSize: 28,
          fontWeight: FontWeight.w700,
          color: textPrimaryDark,
        ),
        displaySmall: TextStyle(
          fontFamily: 'Poppins',
          fontSize: 24,
          fontWeight: FontWeight.w600,
          color: textPrimaryDark,
        ),
        headlineMedium: TextStyle(
          fontFamily: 'Poppins',
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: textPrimaryDark,
        ),
        titleLarge: TextStyle(
          fontFamily: 'Poppins',
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: textPrimaryDark,
        ),
        bodyLarge: TextStyle(
          fontFamily: 'Poppins',
          fontSize: 16,
          color: textPrimaryDark,
        ),
        bodyMedium: TextStyle(
          fontFamily: 'Poppins',
          fontSize: 14,
          color: textSecondaryDark,
        ),
        labelLarge: TextStyle(
          fontFamily: 'Poppins',
          fontSize: 12,
          letterSpacing: 1.2,
          fontWeight: FontWeight.w600,
          color: textSecondaryDark,
        ),
      ),
    );
  }

  // Helper methods for theme selection
  static ThemeData getThemeForMode(AppThemeMode mode, bool isDark) {
    if (isDark || mode == AppThemeMode.midnight) {
      return darkTheme;
    }
    return lightTheme;
  }

  static LinearGradient getPrimaryGradientForMode(AppThemeMode mode) {
    switch (mode) {
      case AppThemeMode.ocean:
        return primaryGradient;
      case AppThemeMode.sunset:
        return primaryGradientSunset;
      case AppThemeMode.forest:
        return primaryGradientForest;
      case AppThemeMode.midnight:
        return primaryGradientMidnight;
    }
  }

  static LinearGradient getCardGradientForMode(AppThemeMode mode) {
    switch (mode) {
      case AppThemeMode.ocean:
        return cardGradient;
      case AppThemeMode.sunset:
        return cardGradientSunset;
      case AppThemeMode.forest:
        return cardGradientForest;
      case AppThemeMode.midnight:
        return cardGradientMidnight;
    }
  }

  static Color getPrimaryColorForMode(AppThemeMode mode) {
    switch (mode) {
      case AppThemeMode.ocean:
        return primaryOcean;
      case AppThemeMode.sunset:
        return primarySunset;
      case AppThemeMode.forest:
        return primaryForest;
      case AppThemeMode.midnight:
        return primaryMidnight;
    }
  }

  // Decorations
  static BoxDecoration get gradientBoxDecoration => BoxDecoration(
        gradient: primaryGradient,
        borderRadius: BorderRadius.circular(28),
      );

  static BoxDecoration gradientBoxDecorationForMode(AppThemeMode mode) =>
      BoxDecoration(
        gradient: getPrimaryGradientForMode(mode),
        borderRadius: BorderRadius.circular(28),
      );

  static BoxDecoration get cardDecoration => BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(26),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      );

  static BoxDecoration get cardDecorationDark => BoxDecoration(
        color: surfaceColorDark,
        borderRadius: BorderRadius.circular(26),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      );

  static BoxDecoration get subtleCardDecoration => BoxDecoration(
        gradient: cardGradient,
        borderRadius: BorderRadius.circular(26),
        border: Border.all(
          color: const Color(0xFFD2E6F5),
          width: 1,
        ),
      );

  static BoxDecoration subtleCardDecorationForMode(AppThemeMode mode) =>
      BoxDecoration(
        gradient: getCardGradientForMode(mode),
        borderRadius: BorderRadius.circular(26),
        border: Border.all(
          color: mode == AppThemeMode.midnight
              ? const Color(0xFF2D3561)
              : const Color(0xFFD2E6F5),
          width: 1,
        ),
      );
}
