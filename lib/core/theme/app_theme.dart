import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Primary Palette
  static const Color emeraldGreen = Color(0xFF10B981);
  static const Color emeraldDark = Color(0xFF059669);
  static const Color emeraldLight = Color(0xFF34D399);

  // Accent Colors
  static const Color accentBlue = Color(0xFF3B82F6);
  static const Color accentPurple = Color(0xFF8B5CF6);
  static const Color accentOrange = Color(0xFFF59E0B);
  static const Color accentRed = Color(0xFFEF4444);

  // Neutral Palette
  static const Color scaffoldBackground = Color(0xFFF8FAFB);
  static const Color cardWhite = Color(0xFFFFFFFF);
  static const Color darkText = Color(0xFF0F172A);
  static const Color subtleText = Color(0xFF64748B);
  static const Color mutedText = Color(0xFF94A3B8);
  static const Color dividerColor = Color(0xFFE2E8F0);
  static const Color surfaceLight = Color(0xFFF1F5F9);

  // Gradients
  static const LinearGradient emeraldGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF10B981), Color(0xFF059669)],
  );

  static const LinearGradient darkGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF1E293B), Color(0xFF0F172A)],
  );

  static const LinearGradient premiumGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF10B981), Color(0xFF3B82F6)],
  );

  // Shadows
  static List<BoxShadow> softShadow = [
    BoxShadow(
      color: Colors.black.withOpacity(0.04),
      blurRadius: 24,
      offset: const Offset(0, 8),
    ),
  ];

  static List<BoxShadow> emeraldShadow = [
    BoxShadow(
      color: emeraldGreen.withOpacity(0.25),
      blurRadius: 24,
      offset: const Offset(0, 8),
    ),
  ];

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: emeraldGreen,
        primary: emeraldGreen,
        surface: scaffoldBackground,
      ),
      textTheme: GoogleFonts.interTextTheme(),
      scaffoldBackgroundColor: scaffoldBackground,
      appBarTheme: AppBarTheme(
        backgroundColor: scaffoldBackground,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: GoogleFonts.inter(
          color: darkText,
          fontSize: 22,
          fontWeight: FontWeight.w800,
        ),
        iconTheme: const IconThemeData(color: darkText),
      ),
      cardTheme: CardTheme(
        elevation: 0,
        color: cardWhite,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
      ),
    );
  }
}
