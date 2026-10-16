import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';

class AppTheme {
  static ThemeData light() {
    final base = ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.red,
        brightness: Brightness.light,
        primary: AppColors.red,
        surface: AppColors.canvas,
      ),
    );

    final text = GoogleFonts.manropeTextTheme(base.textTheme).apply(
      bodyColor: AppColors.text,
      displayColor: AppColors.text,
    );

    return base.copyWith(
      textTheme: text,
      scaffoldBackgroundColor: AppColors.canvas,
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.card,
        foregroundColor: AppColors.text,
        elevation: 0,
        titleTextStyle: text.titleLarge?.copyWith(fontWeight: FontWeight.w800),
      ),
      cardTheme: CardThemeData(
        color: AppColors.card,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      ),
      dividerColor: AppColors.line,
    );
  }

  static ThemeData dark() {
    const canvas = AppColors.ink;
    const card = AppColors.panel;
    const text = AppColors.textDark;
    final base = ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.red,
        brightness: Brightness.dark,
        primary: AppColors.red,
        surface: canvas,
      ),
    );
    final theme = GoogleFonts.manropeTextTheme(base.textTheme).apply(
      bodyColor: text,
      displayColor: text,
    );
    return base.copyWith(
      textTheme: theme,
      scaffoldBackgroundColor: canvas,
      appBarTheme: AppBarTheme(
        backgroundColor: card,
        foregroundColor: text,
        elevation: 0,
        titleTextStyle: theme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
      ),
      cardTheme: CardThemeData(
        color: card,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: AppColors.lineDark),
        ),
      ),
      dividerColor: AppColors.lineDark,
    );
  }
}
