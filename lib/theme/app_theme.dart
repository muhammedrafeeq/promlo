import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors extends ThemeExtension<AppColors> {
  final Color background;
  final Color surface;
  final Color surfaceContainer;
  final Color surfaceContainerLow;
  final Color surfaceContainerHigh;
  final Color primary;
  final Color primaryContainer;
  final Color onPrimary;
  final Color secondary;
  final Color secondaryContainer;
  final Color onSecondaryContainer;
  final Color tertiary;
  final Color tertiaryContainer;
  final Color onTertiaryContainer;
  final Color onSurface;
  final Color onSurfaceVariant;
  final Color outline;
  final Color outlineVariant;
  final Color cardGlassBg;
  final Color cardGlassBorder;
  final Color cardGlassHoverBorder;

  const AppColors({
    required this.background,
    required this.surface,
    required this.surfaceContainer,
    required this.surfaceContainerLow,
    required this.surfaceContainerHigh,
    required this.primary,
    required this.primaryContainer,
    required this.onPrimary,
    required this.secondary,
    required this.secondaryContainer,
    required this.onSecondaryContainer,
    required this.tertiary,
    required this.tertiaryContainer,
    required this.onTertiaryContainer,
    required this.onSurface,
    required this.onSurfaceVariant,
    required this.outline,
    required this.outlineVariant,
    required this.cardGlassBg,
    required this.cardGlassBorder,
    required this.cardGlassHoverBorder,
  });

  static AppColors of(BuildContext context) =>
      Theme.of(context).extension<AppColors>() ??
      (Theme.of(context).brightness == Brightness.dark ? AppColors.dark : AppColors.light);

  static const AppColors dark = AppColors(
    background: Color(0xFF0B1326),
    surface: Color(0xFF0B1326),
    surfaceContainer: Color(0xFF171F33),
    surfaceContainerLow: Color(0xFF131B2E),
    surfaceContainerHigh: Color(0xFF222A3D),
    primary: Color(0xFFD0BCFF),
    primaryContainer: Color(0xFFA078FF),
    onPrimary: Color(0xFF3C0091),
    secondary: Color(0xFF4CD7F6),
    secondaryContainer: Color(0xFF03B5D3),
    onSecondaryContainer: Color(0xFF00424E),
    tertiary: Color(0xFFFFAFD3),
    tertiaryContainer: Color(0xFFE364A7),
    onTertiaryContainer: Color(0xFF560038),
    onSurface: Color(0xFFDAE2FD),
    onSurfaceVariant: Color(0xFFCBC3D7),
    outline: Color(0xFF494454),
    outlineVariant: Color(0xFF494454),
    cardGlassBg: Color(0x660F172A),
    cardGlassBorder: Color(0x1AFFFFFF),
    cardGlassHoverBorder: Color(0x4DD0BCFF),
  );

  static const AppColors light = AppColors(
    background: Color(0xFFF5F4FF),
    surface: Color(0xFFFFFFFF),
    surfaceContainer: Color(0xFFEFECFF),
    surfaceContainerLow: Color(0xFFF8F6FF),
    surfaceContainerHigh: Color(0xFFE6E1FF),
    primary: Color(0xFF6750A4),
    primaryContainer: Color(0xFFEADDFF),
    onPrimary: Color(0xFFFFFFFF),
    secondary: Color(0xFF0277BD),
    secondaryContainer: Color(0xFFB3E5FC),
    onSecondaryContainer: Color(0xFF01579B),
    tertiary: Color(0xFFB5004A),
    tertiaryContainer: Color(0xFFFFD8E4),
    onTertiaryContainer: Color(0xFF3E001F),
    onSurface: Color(0xFF1C1B1F),
    onSurfaceVariant: Color(0xFF49454F),
    outline: Color(0xFF79747E),
    outlineVariant: Color(0xFFCAC4D0),
    cardGlassBg: Color(0xCCFFFFFF),
    cardGlassBorder: Color(0x336750A4),
    cardGlassHoverBorder: Color(0x806750A4),
  );

  @override
  AppColors copyWith({
    Color? background,
    Color? surface,
    Color? surfaceContainer,
    Color? surfaceContainerLow,
    Color? surfaceContainerHigh,
    Color? primary,
    Color? primaryContainer,
    Color? onPrimary,
    Color? secondary,
    Color? secondaryContainer,
    Color? onSecondaryContainer,
    Color? tertiary,
    Color? tertiaryContainer,
    Color? onTertiaryContainer,
    Color? onSurface,
    Color? onSurfaceVariant,
    Color? outline,
    Color? outlineVariant,
    Color? cardGlassBg,
    Color? cardGlassBorder,
    Color? cardGlassHoverBorder,
  }) =>
      AppColors(
        background: background ?? this.background,
        surface: surface ?? this.surface,
        surfaceContainer: surfaceContainer ?? this.surfaceContainer,
        surfaceContainerLow: surfaceContainerLow ?? this.surfaceContainerLow,
        surfaceContainerHigh: surfaceContainerHigh ?? this.surfaceContainerHigh,
        primary: primary ?? this.primary,
        primaryContainer: primaryContainer ?? this.primaryContainer,
        onPrimary: onPrimary ?? this.onPrimary,
        secondary: secondary ?? this.secondary,
        secondaryContainer: secondaryContainer ?? this.secondaryContainer,
        onSecondaryContainer: onSecondaryContainer ?? this.onSecondaryContainer,
        tertiary: tertiary ?? this.tertiary,
        tertiaryContainer: tertiaryContainer ?? this.tertiaryContainer,
        onTertiaryContainer: onTertiaryContainer ?? this.onTertiaryContainer,
        onSurface: onSurface ?? this.onSurface,
        onSurfaceVariant: onSurfaceVariant ?? this.onSurfaceVariant,
        outline: outline ?? this.outline,
        outlineVariant: outlineVariant ?? this.outlineVariant,
        cardGlassBg: cardGlassBg ?? this.cardGlassBg,
        cardGlassBorder: cardGlassBorder ?? this.cardGlassBorder,
        cardGlassHoverBorder: cardGlassHoverBorder ?? this.cardGlassHoverBorder,
      );

  @override
  AppColors lerp(AppColors? other, double t) {
    if (other == null) return this;
    return AppColors(
      background: Color.lerp(background, other.background, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      surfaceContainer: Color.lerp(surfaceContainer, other.surfaceContainer, t)!,
      surfaceContainerLow: Color.lerp(surfaceContainerLow, other.surfaceContainerLow, t)!,
      surfaceContainerHigh: Color.lerp(surfaceContainerHigh, other.surfaceContainerHigh, t)!,
      primary: Color.lerp(primary, other.primary, t)!,
      primaryContainer: Color.lerp(primaryContainer, other.primaryContainer, t)!,
      onPrimary: Color.lerp(onPrimary, other.onPrimary, t)!,
      secondary: Color.lerp(secondary, other.secondary, t)!,
      secondaryContainer: Color.lerp(secondaryContainer, other.secondaryContainer, t)!,
      onSecondaryContainer: Color.lerp(onSecondaryContainer, other.onSecondaryContainer, t)!,
      tertiary: Color.lerp(tertiary, other.tertiary, t)!,
      tertiaryContainer: Color.lerp(tertiaryContainer, other.tertiaryContainer, t)!,
      onTertiaryContainer: Color.lerp(onTertiaryContainer, other.onTertiaryContainer, t)!,
      onSurface: Color.lerp(onSurface, other.onSurface, t)!,
      onSurfaceVariant: Color.lerp(onSurfaceVariant, other.onSurfaceVariant, t)!,
      outline: Color.lerp(outline, other.outline, t)!,
      outlineVariant: Color.lerp(outlineVariant, other.outlineVariant, t)!,
      cardGlassBg: Color.lerp(cardGlassBg, other.cardGlassBg, t)!,
      cardGlassBorder: Color.lerp(cardGlassBorder, other.cardGlassBorder, t)!,
      cardGlassHoverBorder: Color.lerp(cardGlassHoverBorder, other.cardGlassHoverBorder, t)!,
    );
  }
}

/// Responsive font/icon scale helper.
/// Usage: final rs = AppSizes.of(context);  rs.h1  rs.body  rs.icon(24)
class AppSizes {
  final double screenWidth;

  const AppSizes._(this.screenWidth);

  static AppSizes of(BuildContext context) =>
      AppSizes._(MediaQuery.of(context).size.width);

  bool get isSmall => screenWidth < 360;   // e.g. iPhone SE 1st gen, Galaxy A01
  bool get isMedium => screenWidth < 414;  // most phones

  // Heading scale
  double get h1 => isSmall ? 22 : 26;      // page titles
  double get h2 => isSmall ? 18 : 22;      // section headings
  double get h3 => isSmall ? 15 : 18;      // card titles / sub-headings
  double get body => isSmall ? 13 : 14;    // body text
  double get caption => isSmall ? 11 : 12; // captions / badges

  // Icon scale
  double icon(double base) => isSmall ? (base * 0.82).roundToDouble() : base;
}

class AppTheme {
  static ThemeData get darkTheme {
    final baseTextTheme = GoogleFonts.soraTextTheme();
    final bodyTextTheme = GoogleFonts.interTextTheme();

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      extensions: const [AppColors.dark],
      scaffoldBackgroundColor: AppColors.dark.background,
      colorScheme: const ColorScheme.dark(
        primary: Color(0xFFD0BCFF),
        primaryContainer: Color(0xFFA078FF),
        onPrimary: Color(0xFF3C0091),
        secondary: Color(0xFF4CD7F6),
        secondaryContainer: Color(0xFF03B5D3),
        tertiary: Color(0xFFFFAFD3),
        surface: Color(0xFF0B1326),
        onSurface: Color(0xFFDAE2FD),
        onSurfaceVariant: Color(0xFFCBC3D7),
        outline: Color(0xFF494454),
      ),
      textTheme: baseTextTheme.copyWith(
        bodyLarge: bodyTextTheme.bodyLarge?.copyWith(color: AppColors.dark.onSurface),
        bodyMedium: bodyTextTheme.bodyMedium?.copyWith(color: AppColors.dark.onSurface),
        bodySmall: bodyTextTheme.bodySmall?.copyWith(color: AppColors.dark.onSurfaceVariant),
      ).apply(
        bodyColor: AppColors.dark.onSurface,
        displayColor: AppColors.dark.primary,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      cardTheme: CardThemeData(
        color: AppColors.dark.cardGlassBg,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: AppColors.dark.cardGlassBorder, width: 1),
        ),
      ),
    );
  }

  static ThemeData get lightTheme {
    final baseTextTheme = GoogleFonts.soraTextTheme();
    final bodyTextTheme = GoogleFonts.interTextTheme();

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      extensions: const [AppColors.light],
      scaffoldBackgroundColor: AppColors.light.background,
      colorScheme: const ColorScheme.light(
        primary: Color(0xFF6750A4),
        primaryContainer: Color(0xFFEADDFF),
        onPrimary: Color(0xFFFFFFFF),
        secondary: Color(0xFF0277BD),
        secondaryContainer: Color(0xFFB3E5FC),
        tertiary: Color(0xFFB5004A),
        surface: Color(0xFFFFFFFF),
        onSurface: Color(0xFF1C1B1F),
        onSurfaceVariant: Color(0xFF49454F),
        outline: Color(0xFF79747E),
      ),
      textTheme: baseTextTheme.copyWith(
        bodyLarge: bodyTextTheme.bodyLarge?.copyWith(color: AppColors.light.onSurface),
        bodyMedium: bodyTextTheme.bodyMedium?.copyWith(color: AppColors.light.onSurface),
        bodySmall: bodyTextTheme.bodySmall?.copyWith(color: AppColors.light.onSurfaceVariant),
      ).apply(
        bodyColor: AppColors.light.onSurface,
        displayColor: AppColors.light.primary,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      cardTheme: CardThemeData(
        color: AppColors.light.cardGlassBg,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: AppColors.light.cardGlassBorder, width: 1),
        ),
      ),
    );
  }
}
