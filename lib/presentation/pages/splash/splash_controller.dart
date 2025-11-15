// lib/presentation/pages/splash/splash_controller.dart
import 'package:flutter/material.dart';

class SplashController {
  static Future<void> initializeApp() async {
    // Inisialisasi data yang diperlukan sebelum app dimulai
    await Future.delayed(const Duration(milliseconds: 500));

    // Contoh: Initialize preferences, database, dll
    // await SharedPreferences.getInstance();
    // await DatabaseHelper.initialize();
  }
}