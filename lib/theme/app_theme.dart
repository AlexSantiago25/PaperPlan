import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Paper & Notebook Base Colors
  static const Color paperBackground = Color(0xFFFDFBF7); // Warm Notebook Paper
  static const Color paperSurface = Color(0xFFFFFFFF); // Clean Paper Card
  static const Color paperSurfaceWarm = Color(0xFFFEF9C3); // Sticky Note Yellow
  static const Color paperGridLine = Color(0x7393C5FD); // Notebook Blue Ruled Line
  static const Color paperMarginLine = Color(0xFFEF4444); // School Notebook Red Margin
  static const Color paperHoles = Color(0xFFCBD5E1); // Binder Hole Rings
  static const Color paperBorder = Color(0xFF1E40AF); // Ballpoint Blue Border

  // Ballpoint Pen Inks (Sea Battle 2 Palette)
  static const Color penBlue = Color(0xFF1D4ED8); // Classic Bic Royal Blue
  static const Color penBlueDark = Color(0xFF1E3A8A); // Deep Navy Ink
  static const Color penBlueLight = Color(0xFF3B82F6); // Light Pen Blue
  static const Color penBlack = Color(0xFF18181B); // Jet Black Pen
  static const Color penRed = Color(0xFFDC2626); // Teacher's Red Pen / Margin
  static const Color penGreen = Color(0xFF16A34A); // Emerald Green Pen
  static const Color penPurple = Color(0xFF7C3AED); // Violet Gel Pen
  static const Color penGold = Color(0xFFD97706); // Golden Amber Pen
  static const Color highlighterYellow = Color(0xFFFACC15); // Neon Highlighter Yellow
  static const Color highlighterYellowGlow = Color(0x66FACC15);

  // Rarity Colors in Pen Inks
  static const Color rarityCommon = Color(0xFF2563EB); // Royal Blue Bic
  static const Color rarityUncommon = Color(0xFF16A34A); // Green Pen
  static const Color rarityRare = Color(0xFF0284C7); // Sky Blue Pen
  static const Color rarityEpic = Color(0xFF7C3AED); // Purple Pen
  static const Color rarityLegendary = Color(0xFFD97706); // Highlighter Gold Pen

  // Grid Canvas Specifics
  static const Color gridGhostValid = Color(0x8016A34A);
  static const Color gridGhostInvalid = Color(0x80DC2626);

  static ThemeData get notebookTheme {
    final baseFont = GoogleFonts.patrickHandTextTheme();

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: paperBackground,
      primaryColor: penBlue,
      colorScheme: const ColorScheme.light(
        primary: penBlue,
        secondary: penGreen,
        surface: paperSurface,
        error: penRed,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: penBlack,
        onError: Colors.white,
      ),
      textTheme: baseFont.apply(
        bodyColor: penBlack,
        displayColor: penBlueDark,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: penBlueDark,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: GoogleFonts.patrickHand(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.5,
          color: penBlueDark,
        ),
        iconTheme: const IconThemeData(color: penBlueDark),
      ),
      cardTheme: CardThemeData(
        color: paperSurface,
        elevation: 2,
        shadowColor: penBlueDark.withValues(alpha: 0.15),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: penBlue, width: 1.5),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: paperSurface,
        hintStyle: GoogleFonts.patrickHand(
          color: penBlack.withValues(alpha: 0.4),
          fontSize: 16,
        ),
        prefixIconColor: penBlue,
        suffixIconColor: penBlue,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: penBlue, width: 1.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: penBlue, width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: penBlueDark, width: 2.2),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: penBlue,
          foregroundColor: Colors.white,
          elevation: 3,
          shadowColor: penBlueDark.withValues(alpha: 0.3),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
            side: const BorderSide(color: penBlueDark, width: 1.2),
          ),
          textStyle: GoogleFonts.patrickHand(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.3,
          ),
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: penBlue,
        foregroundColor: Colors.white,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: const BorderRadius.all(Radius.circular(16)),
          side: const BorderSide(color: penBlueDark, width: 2),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: paperSurface,
        elevation: 6,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: penBlue, width: 2),
        ),
        titleTextStyle: GoogleFonts.patrickHand(
          fontSize: 22,
          fontWeight: FontWeight.bold,
          color: penBlueDark,
        ),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: paperSurface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          side: BorderSide(color: penBlue, width: 1.8),
        ),
      ),
    );
  }
}
