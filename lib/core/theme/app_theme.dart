import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'design_tokens.dart';

final class AppTheme {
  const AppTheme._();

  static ThemeData get dark => ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorScheme: const ColorScheme.dark(
          primary: AppColors.primary,
          secondary: AppColors.secondary,
          error: AppColors.error,
          surface: AppColors.surface,
          onPrimary: Colors.white,
          onSecondary: Colors.white,
          onSurface: AppColors.onSurface,
        ),
        scaffoldBackgroundColor: AppColors.background,
        cardTheme: CardThemeData(
          color: AppColors.surface,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: Radii.cardLg),
          margin: EdgeInsets.zero,
        ),
        // Nunito includes full Latin Extended — covers all Polish diacritics:
        // ą ę ó ś ź ż ć ń ł
        textTheme: GoogleFonts.nunitoTextTheme(
          ThemeData.dark().textTheme,
        ).copyWith(
          displayLarge: GoogleFonts.nunito(
            fontSize: 32,
            fontWeight: FontWeight.w800,
            color: AppColors.onSurface,
          ),
          headlineMedium: GoogleFonts.nunito(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: AppColors.onSurface,
          ),
          titleLarge: GoogleFonts.nunito(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: AppColors.onSurface,
          ),
          titleMedium: GoogleFonts.nunito(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.onSurface,
          ),
          bodyLarge: GoogleFonts.nunito(
            fontSize: 16,
            fontWeight: FontWeight.w400,
            color: AppColors.onSurface,
          ),
          bodyMedium: GoogleFonts.nunito(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: AppColors.onSurfaceVariant,
          ),
          labelLarge: GoogleFonts.nunito(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            minimumSize: const Size(double.infinity, MinTapTarget.size),
            shape: RoundedRectangleBorder(borderRadius: Radii.cardLg),
            textStyle: GoogleFonts.nunito(
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.primary,
            minimumSize: const Size(double.infinity, MinTapTarget.size),
            side: const BorderSide(color: AppColors.primary),
            shape: RoundedRectangleBorder(borderRadius: Radii.cardLg),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: AppColors.surfaceVariant,
          border: OutlineInputBorder(
            borderRadius: Radii.cardMd,
            borderSide: BorderSide.none,
          ),
          hintStyle: GoogleFonts.nunito(color: AppColors.onSurfaceVariant),
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: AppColors.surface,
          selectedItemColor: AppColors.primary,
          unselectedItemColor: AppColors.onSurfaceVariant,
          type: BottomNavigationBarType.fixed,
        ),
        progressIndicatorTheme: const ProgressIndicatorThemeData(
          color: AppColors.primary,
          linearTrackColor: AppColors.surfaceVariant,
        ),
        chipTheme: ChipThemeData(
          backgroundColor: AppColors.surfaceVariant,
          labelStyle: GoogleFonts.nunito(
            color: AppColors.onSurface,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
          shape: const StadiumBorder(),
        ),
        dividerTheme: const DividerThemeData(
          color: AppColors.surfaceVariant,
          thickness: 1,
          space: 1,
        ),
      );
}
