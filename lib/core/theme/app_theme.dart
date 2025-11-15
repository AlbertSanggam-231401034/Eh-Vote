import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const Color primaryGreen = Color(0xFF00C64F);
  static const Color darkGreen = Color(0xFF002D12);
  static const Color white = Colors.white;

  // 1. LIGHT THEME (Sudah ada sebelumnya)
  static ThemeData get lightTheme {
    return ThemeData(
      primaryColor: primaryGreen,
      colorScheme: ColorScheme.fromSeed(seedColor: primaryGreen),
      useMaterial3: true,
      scaffoldBackgroundColor: white, // Default background

      textTheme: GoogleFonts.almaraiTextTheme(
        ThemeData.light().textTheme,
      ),

      appBarTheme: AppBarTheme(
        backgroundColor: primaryGreen,
        titleTextStyle: GoogleFonts.almarai(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: white,
        ),
        iconTheme: const IconThemeData(color: white),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryGreen,
          foregroundColor: white,
          textStyle: GoogleFonts.almarai(fontWeight: FontWeight.bold),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          minimumSize: const Size(double.infinity, 50),
        ),
      ),
    );
  }

  // 2. DARK THEME (INI YANG TADINYA HILANG/ERROR)
  static ThemeData get darkTheme {
    return ThemeData(
      primaryColor: primaryGreen,
      colorScheme: ColorScheme.fromSeed(
          seedColor: primaryGreen,
          brightness: Brightness.dark
      ),
      useMaterial3: true,
      scaffoldBackgroundColor: const Color(0xFF121212), // Hitam untuk dark mode

      textTheme: GoogleFonts.almaraiTextTheme(
        ThemeData.dark().textTheme,
      ),

      // Kita samakan styling tombol agar konsisten
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryGreen,
          foregroundColor: white,
          textStyle: GoogleFonts.almarai(fontWeight: FontWeight.bold),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          minimumSize: const Size(double.infinity, 50),
        ),
      ),
    );
  }
}