import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  AppTheme._();

  // ─── SCADA Color Palette ───────────────────────────────────────
  static const Color primaryColor = Color(0xFF0D47A1);
  static const Color primaryMedium = Color(0xFF1565C0);
  static const Color primaryLight = Color(0xFF42A5F5);
  static const Color secondaryColor = Color(0xFF00897B);
  static const Color accentColor = Color(0xFF00897B);

  static const Color successColor = Color(0xFF2E7D32);
  static const Color warningColor = Color(0xFFF57F17);
  static const Color errorColor = Color(0xFFC62828);
  static const Color infoColor = Color(0xFF1565C0);

  // Light theme
  static const Color lightBackground = Color(0xFFF8FAFE);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightCard = Color(0xFFFFFFFF);
  static const Color lightCardBorder = Color(0xFFE3F2FD);
  static const Color lightTextPrimary = Color(0xFF1A237E);
  static const Color lightTextSecondary = Color(0xFF546E7A);
  static const Color lightDivider = Color(0xFFE8EAF6);
  static const Color lightInputFill = Color(0xFFF0F4FF);

  // Dark theme
  static const Color darkBackground = Color(0xFF0A1929);
  static const Color darkSurface = Color(0xFF132F4C);
  static const Color darkCard = Color(0xFF173A5E);
  static const Color darkCardBorder = Color(0xFF1E4976);
  static const Color darkTextPrimary = Color(0xFFE3F2FD);
  static const Color darkTextSecondary = Color(0xFF90A4AE);
  static const Color darkDivider = Color(0xFF1E4976);
  static const Color darkInputFill = Color(0xFF0D2137);

  // ─── Gradients ─────────────────────────────────────────────────
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primaryColor, primaryMedium, primaryLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient darkAppBarGradient = LinearGradient(
    colors: [Color(0xFF071E3D), Color(0xFF0D47A1)],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  static const LinearGradient loginGradient = LinearGradient(
    colors: [Color(0xFF071E3D), Color(0xFF0D47A1), Color(0xFF00897B)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient drawerHeaderGradient = LinearGradient(
    colors: [Color(0xFF071E3D), Color(0xFF0D47A1), Color(0xFF00897B)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // ─── Text Styles ───────────────────────────────────────────────
  static TextTheme _buildTextTheme(TextTheme base) {
    return GoogleFonts.cairoTextTheme(base).copyWith(
      displayLarge: GoogleFonts.cairo(
        fontSize: 32,
        fontWeight: FontWeight.bold,
        color: lightTextPrimary,
      ),
      headlineLarge: GoogleFonts.cairo(
        fontSize: 28,
        fontWeight: FontWeight.bold,
        color: lightTextPrimary,
      ),
      headlineMedium: GoogleFonts.cairo(
        fontSize: 22,
        fontWeight: FontWeight.w700,
        color: lightTextPrimary,
      ),
      titleLarge: GoogleFonts.cairo(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: lightTextPrimary,
      ),
      titleMedium: GoogleFonts.cairo(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: lightTextPrimary,
      ),
      bodyLarge: GoogleFonts.cairo(
        fontSize: 16,
        color: lightTextPrimary,
      ),
      bodyMedium: GoogleFonts.cairo(
        fontSize: 14,
        color: lightTextSecondary,
      ),
      bodySmall: GoogleFonts.cairo(
        fontSize: 12,
        color: lightTextSecondary,
      ),
      labelLarge: GoogleFonts.cairo(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: Colors.white,
      ),
    );
  }

  static TextTheme _buildDarkTextTheme(TextTheme base) {
    return GoogleFonts.cairoTextTheme(base).copyWith(
      displayLarge: GoogleFonts.cairo(
        fontSize: 32,
        fontWeight: FontWeight.bold,
        color: darkTextPrimary,
      ),
      headlineLarge: GoogleFonts.cairo(
        fontSize: 28,
        fontWeight: FontWeight.bold,
        color: darkTextPrimary,
      ),
      headlineMedium: GoogleFonts.cairo(
        fontSize: 22,
        fontWeight: FontWeight.w700,
        color: darkTextPrimary,
      ),
      titleLarge: GoogleFonts.cairo(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: darkTextPrimary,
      ),
      titleMedium: GoogleFonts.cairo(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: darkTextPrimary,
      ),
      bodyLarge: GoogleFonts.cairo(
        fontSize: 16,
        color: darkTextPrimary,
      ),
      bodyMedium: GoogleFonts.cairo(
        fontSize: 14,
        color: darkTextSecondary,
      ),
      bodySmall: GoogleFonts.cairo(
        fontSize: 12,
        color: darkTextSecondary,
      ),
      labelLarge: GoogleFonts.cairo(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: Colors.white,
      ),
    );
  }

  // ─── Light Theme ───────────────────────────────────────────────
  static ThemeData lightTheme() {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: primaryColor,
      brightness: Brightness.light,
      primary: primaryColor,
      onPrimary: Colors.white,
      secondary: secondaryColor,
      onSecondary: Colors.white,
      error: errorColor,
      surface: lightSurface,
      onSurface: lightTextPrimary,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: colorScheme,
      textTheme: _buildTextTheme(ThemeData.light().textTheme),
      scaffoldBackgroundColor: lightBackground,

      // ── AppBar ──
      appBarTheme: AppBarTheme(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: GoogleFonts.cairo(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(16)),
        ),
      ),

      // ── Cards ──
      cardTheme: CardTheme(
        elevation: 0,
        color: lightCard,
        shadowColor: primaryColor.withOpacity(0.08),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: lightCardBorder, width: 1),
        ),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),

      // ── Elevated Buttons ──
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          elevation: 4,
          shadowColor: primaryColor.withOpacity(0.3),
          textStyle: GoogleFonts.cairo(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      // ── Text Buttons ──
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primaryColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          textStyle: GoogleFonts.cairo(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      // ── Input Decoration ──
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: lightInputFill,
        hintStyle: GoogleFonts.cairo(color: lightTextSecondary.withOpacity(0.6)),
        labelStyle: GoogleFonts.cairo(color: lightTextSecondary),
        prefixIconColor: lightTextSecondary,
        suffixIconColor: lightTextSecondary,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: lightCardBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: lightCardBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: primaryColor, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: errorColor),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: errorColor, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      ),

      // ── Bottom Navigation ──
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: Colors.white.withOpacity(0.85),
        selectedItemColor: primaryColor,
        unselectedItemColor: lightTextSecondary,
        type: BottomNavigationBarType.fixed,
        elevation: 20,
        selectedLabelStyle: GoogleFonts.cairo(fontSize: 11, fontWeight: FontWeight.w600),
        unselectedLabelStyle: GoogleFonts.cairo(fontSize: 11),
      ),

      // ── Drawer ──
      drawerTheme: const DrawerThemeData(
        backgroundColor: lightSurface,
        elevation: 16,
        width: 290,
      ),

      // ── Divider ──
      dividerTheme: const DividerThemeData(
        color: lightDivider,
        thickness: 1,
        space: 1,
      ),

      // ── SnackBar ──
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: darkSurface,
        contentTextStyle: GoogleFonts.cairo(color: Colors.white, fontSize: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),

      // ── Chip ──
      chipTheme: ChipThemeData(
        backgroundColor: lightInputFill,
        selectedColor: primaryColor.withOpacity(0.15),
        labelStyle: GoogleFonts.cairo(color: lightTextPrimary, fontSize: 13),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: const BorderSide(color: lightCardBorder),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      ),

      // ── Dialog ──
      dialogTheme: DialogTheme(
        backgroundColor: lightSurface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        elevation: 16,
        titleTextStyle: GoogleFonts.cairo(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: lightTextPrimary,
        ),
        contentTextStyle: GoogleFonts.cairo(
          fontSize: 14,
          color: lightTextSecondary,
        ),
      ),

      // ── ListTile ──
      listTileTheme: ListTileThemeData(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        titleTextStyle: GoogleFonts.cairo(fontSize: 15, color: lightTextPrimary),
        subtitleTextStyle: GoogleFonts.cairo(fontSize: 13, color: lightTextSecondary),
      ),
    );
  }

  // ─── Dark Theme ────────────────────────────────────────────────
  static ThemeData darkTheme() {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: primaryColor,
      brightness: Brightness.dark,
      primary: const Color(0xFF90CAF9),
      onPrimary: darkBackground,
      secondary: secondaryColor,
      onSecondary: Colors.white,
      error: errorColor,
      surface: darkSurface,
      onSurface: darkTextPrimary,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: colorScheme,
      textTheme: _buildDarkTextTheme(ThemeData.dark().textTheme),
      scaffoldBackgroundColor: darkBackground,

      // ── AppBar ──
      appBarTheme: AppBarTheme(
        backgroundColor: darkSurface,
        foregroundColor: darkTextPrimary,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: GoogleFonts.cairo(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: darkTextPrimary,
        ),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(16)),
        ),
      ),

      // ── Cards ──
      cardTheme: CardTheme(
        elevation: 0,
        color: darkCard,
        shadowColor: Colors.black.withOpacity(0.3),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: darkCardBorder, width: 1),
        ),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),

      // ── Elevated Buttons ──
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF90CAF9),
          foregroundColor: darkBackground,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          elevation: 4,
          shadowColor: Colors.black.withOpacity(0.4),
          textStyle: GoogleFonts.cairo(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      // ── Text Buttons ──
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: const Color(0xFF90CAF9),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          textStyle: GoogleFonts.cairo(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      // ── Input Decoration ──
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: darkInputFill,
        hintStyle: GoogleFonts.cairo(color: darkTextSecondary.withOpacity(0.6)),
        labelStyle: GoogleFonts.cairo(color: darkTextSecondary),
        prefixIconColor: darkTextSecondary,
        suffixIconColor: darkTextSecondary,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: darkCardBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: darkCardBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFF90CAF9), width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: errorColor),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: errorColor, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      ),

      // ── Bottom Navigation ──
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: darkSurface.withOpacity(0.9),
        selectedItemColor: const Color(0xFF90CAF9),
        unselectedItemColor: darkTextSecondary,
        type: BottomNavigationBarType.fixed,
        elevation: 20,
        selectedLabelStyle: GoogleFonts.cairo(fontSize: 11, fontWeight: FontWeight.w600),
        unselectedLabelStyle: GoogleFonts.cairo(fontSize: 11),
      ),

      // ── Drawer ──
      drawerTheme: const DrawerThemeData(
        backgroundColor: darkSurface,
        elevation: 16,
        width: 290,
      ),

      // ── Divider ──
      dividerTheme: const DividerThemeData(
        color: darkDivider,
        thickness: 1,
        space: 1,
      ),

      // ── SnackBar ──
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: darkCard,
        contentTextStyle: GoogleFonts.cairo(color: darkTextPrimary, fontSize: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),

      // ── Chip ──
      chipTheme: ChipThemeData(
        backgroundColor: darkInputFill,
        selectedColor: const Color(0xFF90CAF9).withOpacity(0.15),
        labelStyle: GoogleFonts.cairo(color: darkTextPrimary, fontSize: 13),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: const BorderSide(color: darkCardBorder),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      ),

      // ── Dialog ──
      dialogTheme: DialogTheme(
        backgroundColor: darkSurface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        elevation: 16,
        titleTextStyle: GoogleFonts.cairo(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: darkTextPrimary,
        ),
        contentTextStyle: GoogleFonts.cairo(
          fontSize: 14,
          color: darkTextSecondary,
        ),
      ),

      // ── ListTile ──
      listTileTheme: ListTileThemeData(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        titleTextStyle: GoogleFonts.cairo(fontSize: 15, color: darkTextPrimary),
        subtitleTextStyle: GoogleFonts.cairo(fontSize: 13, color: darkTextSecondary),
      ),
    );
  }
}
