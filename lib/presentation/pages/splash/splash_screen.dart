// lib/presentation/pages/splash/splash_screen.dart
import 'package:flutter/material.dart';
import 'package:suara_kita/core/theme/text_styles.dart';
import 'package:google_fonts/google_fonts.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateToNext();
  }

  _navigateToNext() async {
    // Delay untuk menampilkan splash screen selama 2 detik
    await Future.delayed(const Duration(milliseconds: 2000), () {
      // Setelah 2 detik, pindah ke welcome page
      Navigator.pushReplacementNamed(context, '/welcome');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Icon dari Google Fonts (Material Icons)
            const Icon(
              Icons.how_to_vote_rounded,
              size: 100,
              color: Colors.white,
            ),
            const SizedBox(height: 20),
            // Teks dengan font Almarai
            Text(
              'Suara Kita',
              style: GoogleFonts.almarai(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'E-Voting USU',
              style: GoogleFonts.almarai(
                fontSize: 16,
                fontWeight: FontWeight.normal,
                color: Colors.white70,
              ),
            ),
          ],
        ),
      ),
    );
  }
}