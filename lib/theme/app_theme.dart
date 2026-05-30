import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// ─────────────────────────────────────────────
//  CONTEXT-AWARE COLORS — C.of(context)
//  Usage: final colors = C.of(context);
//         colors.background, colors.surface, colors.cardShadow, etc.
// ─────────────────────────────────────────────
class C {
  final Brightness brightness;

  const C._(this.brightness);

  factory C.of(BuildContext context) {
    return C._(Theme.of(context).brightness);
  }

  bool get isDark => brightness == Brightness.dark;

  // ── Surfaces ──
  Color get background =>
      isDark ? const Color(0xFF0A0E14) : const Color(0xFFF4F7FA);
  Color get surface => isDark ? const Color(0xFF121820) : Colors.white;
  Color get surfaceElevated => isDark ? const Color(0xFF182028) : Colors.white;
  Color get surfaceOverlay =>
      isDark ? Colors.white.withAlpha(8) : Colors.black.withAlpha(5);

  // ── Text ──
  Color get textPrimary =>
      isDark ? const Color(0xFFF1F4F8) : const Color(0xFF0F172A);
  Color get textSecondary =>
      isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);
  Color get textTertiary =>
      isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8);
  Color get textOnPrimary => Colors.white;

  // ── Blush / Dividers ──
  Color get blush => isDark ? const Color(0xFF1E2A36) : const Color(0xFFE2E8F0);
  Color get divider =>
      isDark ? const Color(0xFF1E2A36) : const Color(0xFFE2E8F0);

  // ── Shadow helpers ──
  Color cardShadow(double opacity) => isDark
      ? Colors.black.withAlpha((opacity * 255 * 1.5).toInt().clamp(0, 255))
      : Colors.black.withAlpha((opacity * 255).toInt().clamp(0, 255));

  // ── Card decorations (dynamic) ──
  BoxDecoration get card => BoxDecoration(
    color: surfaceElevated,
    borderRadius: AppRadius.xlAll,
    boxShadow: [
      BoxShadow(
        color: cardShadow(0.04),
        blurRadius: 15,
        offset: const Offset(0, 6),
        spreadRadius: 1,
      ),
    ],
  );

  BoxDecoration get elevatedCard => BoxDecoration(
    color: surfaceElevated,
    borderRadius: AppRadius.xlAll,
    boxShadow: [
      BoxShadow(
        color: cardShadow(0.06),
        blurRadius: 25,
        offset: const Offset(0, 10),
        spreadRadius: 2,
      ),
    ],
  );

  BoxDecoration get borderedCard => BoxDecoration(
    color: surfaceElevated,
    borderRadius: AppRadius.xlAll,
    border: Border.all(color: blush.withAlpha(isDark ? 60 : 128), width: 1.5),
    boxShadow: [
      BoxShadow(
        color: cardShadow(0.03),
        blurRadius: 10,
        offset: const Offset(0, 5),
      ),
    ],
  );

  BoxDecoration statusCard({required bool isOnline}) => BoxDecoration(
    color: isOnline ? AppColors.primary : surfaceElevated,
    borderRadius: AppRadius.xlAll,
    boxShadow: [
      BoxShadow(
        color: isOnline ? AppColors.primary.withAlpha(102) : cardShadow(0.04),
        blurRadius: 20,
        offset: const Offset(0, 10),
        spreadRadius: 2,
      ),
    ],
  );

  BoxDecoration get accentBorderedCard => BoxDecoration(
    color: surfaceElevated,
    borderRadius: AppRadius.xlAll,
    border: Border.all(
      color: AppColors.primaryAccent.withAlpha(isDark ? 50 : 77),
      width: 1.5,
    ),
    boxShadow: [
      BoxShadow(
        color: AppColors.primary.withAlpha(isDark ? 20 : 38),
        blurRadius: 25,
        offset: const Offset(0, 10),
        spreadRadius: 2,
      ),
    ],
  );

  BoxDecoration get infoRow => BoxDecoration(
    color: blush.withAlpha(isDark ? 40 : 77),
    borderRadius: AppRadius.lgAll,
  );

  BoxDecoration iconContainer({required Color color}) => BoxDecoration(
    color: color.withAlpha(isDark ? 35 : 25),
    borderRadius: AppRadius.smAll,
  );

  // ── Glassmorphism Decorations ──
  BoxDecoration get glassCard => BoxDecoration(
    color: isDark
        ? AppColors.primary.withAlpha(15)
        : AppColors.primary.withAlpha(10),
    borderRadius: AppRadius.xlAll,
    border: Border.all(
      color: isDark
          ? AppColors.primary.withAlpha(40)
          : AppColors.primary.withAlpha(30),
      width: 1.0,
    ),
    boxShadow: [
      BoxShadow(
        color: AppColors.primary.withAlpha(isDark ? 15 : 8),
        blurRadius: 20,
        offset: const Offset(0, 8),
        spreadRadius: 2,
      ),
    ],
  );

  BoxDecoration get glassCardStrong => BoxDecoration(
    gradient: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: isDark
          ? [
              AppColors.primary.withAlpha(25),
              AppColors.secondaryCyan.withAlpha(15),
            ]
          : [
              AppColors.primary.withAlpha(15),
              AppColors.secondaryCyan.withAlpha(8),
            ],
    ),
    borderRadius: AppRadius.xlAll,
    border: Border.all(
      color: AppColors.primary.withAlpha(isDark ? 50 : 35),
      width: 1.5,
    ),
    boxShadow: [
      BoxShadow(
        color: AppColors.primary.withAlpha(isDark ? 20 : 12),
        blurRadius: 25,
        offset: const Offset(0, 10),
        spreadRadius: 2,
      ),
    ],
  );

  // ── Button decorations ──
  BoxDecoration get quickActionIcon => BoxDecoration(
    color: surfaceElevated,
    borderRadius: AppRadius.lgAll,
    boxShadow: [
      BoxShadow(
        color: cardShadow(0.05),
        blurRadius: 10,
        offset: const Offset(0, 4),
      ),
    ],
  );

  BoxDecoration get actionListItem => BoxDecoration(
    color: surfaceElevated,
    borderRadius: AppRadius.lgAll,
    boxShadow: [
      BoxShadow(
        color: cardShadow(0.03),
        blurRadius: 10,
        offset: const Offset(0, 4),
      ),
    ],
  );
}

// ─────────────────────────────────────────────
//  STATIC COLORS (brand / semantic — same in both modes)
// ─────────────────────────────────────────────
class AppColors {
  AppColors._();

  // Brand — Caby24
  static const Color primary = Color(0xFF12E0FF);
  static const Color primaryAccent = Color(0xFF00B8D4);
  static const Color secondary = Color(0xFF12E0FF);
  static const Color secondaryCyan = Color(0xFF008396);
  static const Color silver = Color(0xFF737373);
  static const Color darkCyan = Color(0xFF005A6B);

  // Semantic
  static const Color success = Color(0xFF10B981);
  static const Color successLight = Color(0xFFD1FAE5);
  static const Color warning = Color(0xFFF59E0B);
  static const Color warningLight = Color(0xFFFEF3C7);
  static const Color info = Color(0xFF3B82F6);
  static const Color infoLight = Color(0xFFDBEAFE);
  static const Color error = Color(0xFFEF4444);
  static const Color errorLight = Color(0xFFFEE2E2);

  // Misc
  static const Color online = Color(0xFF22C55E);
  static const Color offline = Color(0xFF9CA3AF);
  static const Color starYellow = Color(0xFFFFB800);
  static const Color purple = Color(0xFF8B5CF6);

  // Service Categories
  static const Color ambulance = Color(0xFFE53E3E);
  static const Color parcel = Color(0xFF008396);
  static const Color heavyHaul = Color(0xFF2B6CB0);
  static const Color carBooking = Color(0xFF12E0FF);
  static const Color foodDelivery = Color(0xFF38A169);
  static const Color beverages = Color(0xFF805AD5);
  static const Color medicine = Color(0xFFE53E8C);

  // Legacy convenience (light-mode defaults, used where context unavailable)
  static const Color background = Color(0xFFF4F7FA);
  static const Color surface = Colors.white;
  static const Color blush = Color(0xFFE2E8F0);
  static const Color divider = Color(0xFFE2E8F0);
  static const Color textPrimary = Color(0xFF0F172A);
  static const Color textSecondary = Color(0xFF64748B);
  static const Color textTertiary = Color(0xFF94A3B8);
  static const Color textOnPrimary = Colors.white;
}

// ─────────────────────────────────────────────
//  SPACING
// ─────────────────────────────────────────────
class AppSpacing {
  AppSpacing._();

  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 20;
  static const double xxl = 24;
  static const double xxxl = 32;
  static const double huge = 40;
}

// ─────────────────────────────────────────────
//  BORDER RADIUS
// ─────────────────────────────────────────────
class AppRadius {
  AppRadius._();

  static const double sm = 10;
  static const double md = 14;
  static const double lg = 18;
  static const double xl = 22;
  static const double xxl = 26;
  static const double pill = 30;

  static BorderRadius get smAll => BorderRadius.circular(sm);
  static BorderRadius get mdAll => BorderRadius.circular(md);
  static BorderRadius get lgAll => BorderRadius.circular(lg);
  static BorderRadius get xlAll => BorderRadius.circular(xl);
  static BorderRadius get xxlAll => BorderRadius.circular(xxl);
  static BorderRadius get pillAll => BorderRadius.circular(pill);
}

// ─────────────────────────────────────────────
//  TEXT STYLES  (Poppins-based)
// ─────────────────────────────────────────────
class AppTextStyles {
  AppTextStyles._();

  static TextStyle headingXl = GoogleFonts.poppins(
    fontSize: 32,
    fontWeight: FontWeight.w800,
    letterSpacing: -0.5,
  );

  static TextStyle headingLg = GoogleFonts.poppins(
    fontSize: 28,
    fontWeight: FontWeight.bold,
  );

  static TextStyle headingMd = GoogleFonts.poppins(
    fontSize: 22,
    fontWeight: FontWeight.bold,
  );

  static TextStyle headingSm = GoogleFonts.poppins(
    fontSize: 18,
    fontWeight: FontWeight.w600,
  );

  static TextStyle bodyLg = GoogleFonts.poppins(
    fontSize: 16,
    fontWeight: FontWeight.w500,
  );

  static TextStyle bodyMd = GoogleFonts.poppins(
    fontSize: 15,
    fontWeight: FontWeight.w500,
  );

  static TextStyle bodySm = GoogleFonts.poppins(
    fontSize: 14,
    fontWeight: FontWeight.w400,
  );

  static TextStyle label = GoogleFonts.poppins(
    fontSize: 13,
    fontWeight: FontWeight.w500,
  );

  static TextStyle caption = GoogleFonts.poppins(
    fontSize: 12,
    fontWeight: FontWeight.w400,
  );

  static TextStyle overline = GoogleFonts.poppins(
    fontSize: 11,
    fontWeight: FontWeight.w600,
    letterSpacing: 1.5,
  );

  static TextStyle earningsLarge = GoogleFonts.poppins(
    fontSize: 36,
    fontWeight: FontWeight.w800,
    color: AppColors.primary,
    letterSpacing: -0.5,
  );

  static TextStyle earningsMd = GoogleFonts.poppins(
    fontSize: 32,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.5,
  );

  static TextStyle statValue = GoogleFonts.poppins(
    fontSize: 20,
    fontWeight: FontWeight.bold,
  );

  static TextStyle buttonText = GoogleFonts.poppins(
    fontSize: 16,
    fontWeight: FontWeight.w600,
  );
}

// ─────────────────────────────────────────────
//  STATIC DECORATIONS (non-theme-dependent)
// ─────────────────────────────────────────────
class AppDecorations {
  AppDecorations._();

  static BoxDecoration get gradientCard => BoxDecoration(
    borderRadius: AppRadius.xxlAll,
    gradient: const LinearGradient(
      colors: [AppColors.darkCyan, AppColors.primary],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    boxShadow: [
      BoxShadow(
        color: AppColors.darkCyan.withAlpha(77),
        blurRadius: 20,
        offset: const Offset(0, 10),
      ),
    ],
  );
}

// ─────────────────────────────────────────────
//  STATIC BUTTON STYLES
// ─────────────────────────────────────────────
class AppButtonStyles {
  AppButtonStyles._();

  static BoxDecoration get primaryButton => BoxDecoration(
    gradient: const LinearGradient(
      colors: [AppColors.secondaryCyan, AppColors.primary],
    ),
    borderRadius: AppRadius.pillAll,
    boxShadow: [
      BoxShadow(
        color: AppColors.primary.withAlpha(102),
        blurRadius: 15,
        offset: const Offset(0, 8),
      ),
    ],
  );

  static BoxDecoration outlineButton({Color? borderColor}) => BoxDecoration(
    borderRadius: AppRadius.pillAll,
    border: Border.all(color: borderColor ?? AppColors.primary.withAlpha(51)),
  );
}

// ─────────────────────────────────────────────
//  THEME DATA (Light + Dark)
// ─────────────────────────────────────────────
class AppTheme {
  AppTheme._();

  // ── Light Theme ──
  static ThemeData get lightTheme => ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.secondaryCyan,
      brightness: Brightness.light,
      surface: Colors.white,
      primary: AppColors.secondaryCyan,
    ),
    scaffoldBackgroundColor: const Color(0xFFF4F7FA),
    textTheme: GoogleFonts.poppinsTextTheme(ThemeData.light().textTheme),
    appBarTheme: AppBarTheme(
      backgroundColor: const Color(0xFFF4F7FA),
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
      titleTextStyle: AppTextStyles.headingSm.copyWith(
        color: const Color(0xFF0F172A),
      ),
      iconTheme: const IconThemeData(color: Color(0xFF0F172A)),
    ),
    elevatedButtonTheme: _elevatedButtonTheme,
    outlinedButtonTheme: _outlinedButtonTheme,
    textButtonTheme: _textButtonTheme,
    snackBarTheme: _snackBarTheme(Brightness.light),
    progressIndicatorTheme: const ProgressIndicatorThemeData(
      color: AppColors.secondaryCyan,
    ),
  );

  // ── Dark Theme ──
  static ThemeData get darkTheme => ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      brightness: Brightness.dark,
      surface: const Color(0xFF121820),
      primary: AppColors.primary,
    ),
    scaffoldBackgroundColor: const Color(0xFF0A0E14),
    textTheme: GoogleFonts.poppinsTextTheme(ThemeData.dark().textTheme),
    appBarTheme: AppBarTheme(
      backgroundColor: const Color(0xFF0A0E14),
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
      titleTextStyle: AppTextStyles.headingSm.copyWith(
        color: const Color(0xFFF1F4F8),
      ),
      iconTheme: const IconThemeData(color: Color(0xFFF1F4F8)),
    ),
    elevatedButtonTheme: _elevatedButtonTheme,
    outlinedButtonTheme: _outlinedButtonTheme,
    textButtonTheme: _textButtonTheme,
    snackBarTheme: _snackBarTheme(Brightness.dark),
    progressIndicatorTheme: const ProgressIndicatorThemeData(
      color: AppColors.primary,
    ),
  );

  // ── Shared button themes ──
  static final _elevatedButtonTheme = ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: AppColors.secondaryCyan,
      foregroundColor: Colors.white,
      textStyle: AppTextStyles.buttonText,
      shape: RoundedRectangleBorder(borderRadius: AppRadius.pillAll),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.xxl,
        vertical: AppSpacing.lg,
      ),
      elevation: 4,
      shadowColor: AppColors.primary.withAlpha(102),
    ),
  );

  static final _outlinedButtonTheme = OutlinedButtonThemeData(
    style: OutlinedButton.styleFrom(
      foregroundColor: AppColors.secondaryCyan,
      textStyle: AppTextStyles.buttonText,
      side: BorderSide(color: AppColors.primary.withAlpha(51)),
      shape: RoundedRectangleBorder(borderRadius: AppRadius.pillAll),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.xxl,
        vertical: AppSpacing.lg,
      ),
    ),
  );

  static final _textButtonTheme = TextButtonThemeData(
    style: TextButton.styleFrom(
      foregroundColor: AppColors.secondaryCyan,
      textStyle: AppTextStyles.buttonText,
    ),
  );

  static SnackBarThemeData _snackBarTheme(Brightness b) => SnackBarThemeData(
    backgroundColor: b == Brightness.dark
        ? const Color(0xFF1E2A36)
        : const Color(0xFF0F172A),
    contentTextStyle: AppTextStyles.bodySm.copyWith(color: Colors.white),
    shape: RoundedRectangleBorder(borderRadius: AppRadius.mdAll),
    behavior: SnackBarBehavior.floating,
  );
}
