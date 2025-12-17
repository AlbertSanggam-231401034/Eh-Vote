import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/colors.dart';
import '../constants/app_constants.dart';

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      primaryColor: AppColors.primaryGreen,
      scaffoldBackgroundColor: AppColors.scaffoldBackground,

      // Fix Kursor: Biar kelihatan hijau (bukan putih)
      textSelectionTheme: TextSelectionThemeData(
        cursorColor: AppColors.primaryGreen,
        selectionColor: AppColors.primaryGreen.withOpacity(0.3),
        selectionHandleColor: AppColors.primaryGreen,
      ),

      // Skema Warna
      colorScheme: const ColorScheme.light(
        primary: AppColors.primaryGreen,
        secondary: AppColors.darkGreen,
        background: AppColors.scaffoldBackground,
        surface: AppColors.cardBackground,
        error: AppColors.error,
        onSurface: AppColors.black, // Teks default hitam
      ),

      // Typography (Font Global)
      fontFamily: AppConstants.fontAlmarai,
      textTheme: TextTheme(
        displayLarge: GoogleFonts.unbounded(
          fontSize: 32,
          fontWeight: FontWeight.w800,
          color: AppColors.white,
          height: 1.2,
        ),
        displayMedium: GoogleFonts.unbounded(
          fontSize: 24,
          fontWeight: FontWeight.w700,
          color: AppColors.darkGreen,
        ),
        displaySmall: GoogleFonts.unbounded(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: AppColors.darkGreen,
        ),
        bodyLarge: GoogleFonts.almarai(
          fontSize: 16,
          fontWeight: FontWeight.w400,
          color: AppColors.black,
        ),
        bodyMedium: GoogleFonts.almarai(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: AppColors.black,
        ),
        bodySmall: GoogleFonts.almarai(
          fontSize: 12,
          fontWeight: FontWeight.w400,
          color: AppColors.grey,
        ),
      ),

      // Tombol Utama (Elevated) - Style Global
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryGreen,
          foregroundColor: AppColors.white,
          minimumSize: const Size(double.infinity, AppConstants.buttonHeight),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppConstants.buttonBorderRadius),
          ),
          textStyle: GoogleFonts.almarai(
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
          elevation: 0,
        ),
      ),

      // ⚠️ PENTING: SAYA HAPUS 'inputDecorationTheme' DARI SINI
      // Supaya codingan di AdminLoginPage & UserSignupDataPage (yang transparan)
      // tidak tertimpa oleh settingan global background putih.
      // Biarkan masing-masing halaman mengatur style input-nya sendiri.

      // App Bar Theme Global
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.white,
        foregroundColor: AppColors.darkGreen,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: GoogleFonts.unbounded(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: AppColors.darkGreen,
        ),
        iconTheme: const IconThemeData(
          color: AppColors.darkGreen,
          size: 24,
        ),
      ),
    );
  }

  static BoxDecoration get gradientBackground {
    return const BoxDecoration(
      gradient: AppColors.primaryGradient,
    );
  }
}