import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  AppTheme._();

  static const Color primaryColor = Color(0xFF3D2C8D);

  static ThemeData get light => FlexThemeData.light(
        colorScheme: ColorScheme.fromSeed(
          seedColor: primaryColor,
          primary: primaryColor,
          secondary: const Color(0xFF1D9E75),
          error: const Color(0xFFE05C5C),
        ),
        surfaceMode: FlexSurfaceMode.levelSurfacesLowScaffold,
        blendLevel: 7,
        subThemesData: const FlexSubThemesData(
          blendOnLevel: 10,
          useM2StyleDividerInM3: true,
          defaultRadius: 16.0,
          thinBorderWidth: 1.0,
          inputDecoratorRadius: 12.0,
          inputDecoratorSchemeColor: SchemeColor.primary,
          inputDecoratorIsFilled: true,
          inputDecoratorFillColor: Colors.transparent,
          fabRadius: 16.0,
          fabSchemeColor: SchemeColor.primary,
          snackBarRadius: 12.0,
          snackBarBackgroundSchemeColor: SchemeColor.onSurface,
          bottomSheetRadius: 24.0,
          navigationBarElevation: 0,
          navigationBarIndicatorSchemeColor: SchemeColor.primaryContainer,
        ),
        visualDensity: FlexColorScheme.comfortablePlatformDensity,
        fontFamily: GoogleFonts.inter().fontFamily,
        textTheme: GoogleFonts.interTextTheme(),
      );

  static ThemeData get dark => FlexThemeData.dark(
        colorScheme: ColorScheme.fromSeed(
          seedColor: primaryColor,
          primary: primaryColor,
          secondary: const Color(0xFF1D9E75),
          error: const Color(0xFFE05C5C),
          brightness: Brightness.dark,
        ),
        surfaceMode: FlexSurfaceMode.levelSurfacesLowScaffold,
        blendLevel: 13,
        subThemesData: const FlexSubThemesData(
          blendOnLevel: 20,
          useM2StyleDividerInM3: true,
          defaultRadius: 16.0,
          thinBorderWidth: 1.0,
          inputDecoratorRadius: 12.0,
          inputDecoratorSchemeColor: SchemeColor.primary,
          inputDecoratorIsFilled: true,
          inputDecoratorFillColor: Colors.transparent,
          fabRadius: 16.0,
          fabSchemeColor: SchemeColor.primary,
          snackBarRadius: 12.0,
          snackBarBackgroundSchemeColor: SchemeColor.onSurface,
          bottomSheetRadius: 24.0,
          navigationBarElevation: 0,
          navigationBarIndicatorSchemeColor: SchemeColor.primaryContainer,
        ),
        visualDensity: FlexColorScheme.comfortablePlatformDensity,
        fontFamily: GoogleFonts.inter().fontFamily,
        textTheme: GoogleFonts.interTextTheme(),
      );
}
