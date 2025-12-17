import 'package:flutter/material.dart';

class AppColors {
  // Warna Utama (USU Modern Green Theme)
  static const Color primaryGreen = Color(0xFF00C64F);
  static const Color darkGreen = Color(0xFF002D12);

  // ✅ TAMBAHKAN INI (Untuk background tint/highlight lembut)
  static const Color lightGreen = Color(0xFFE8F5E9);

  // Gradient Utama
  static const Gradient primaryGradient = LinearGradient(
    colors: [primaryGreen, darkGreen],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  // Warna Netral
  static const Color white = Colors.white;
  static const Color black = Color(0xFF1A1A1A);
  static const Color grey = Color(0xFF9E9E9E);
  static const Color lightGrey = Color(0xFFF5F5F5);

  // Warna Feedback
  static const Color error = Color(0xFFD32F2F);
  static const Color success = Color(0xFF388E3C);
  static const Color warning = Color(0xFFFBC02D);

  // Background Colors
  static const Color scaffoldBackground = Color(0xFFF8F9FA);
  static const Color cardBackground = Colors.white;
}