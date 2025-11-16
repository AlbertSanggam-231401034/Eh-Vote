import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AdminRegistrationSuccessPage extends StatelessWidget {
  const AdminRegistrationSuccessPage({super.key});

  @override
  Widget build(BuildContext context) {
    const Color kPrimaryGreen = Color(0xFF00C64F);
    const Color kDarkGreen = Color(0xFF002D12);

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [kPrimaryGreen, kDarkGreen],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(flex: 2),
              const Icon(
                Icons.check_circle_rounded,
                size: 100,
                color: Colors.white,
              ),
              const SizedBox(height: 24),
              Text(
                'Registrasi Berhasil!',
                textAlign: TextAlign.center,
                style: GoogleFonts.unbounded(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Akun admin telah berhasil didaftarkan. Sekarang Anda dapat login menggunakan NIM dan password yang telah dibuat.',
                textAlign: TextAlign.center,
                style: GoogleFonts.almarai(
                  fontSize: 16,
                  color: Colors.white.withOpacity(0.9),
                  height: 1.5,
                ),
              ),
              const Spacer(flex: 2),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pushNamedAndRemoveUntil(
                      context,
                      '/admin-login',
                          (route) => false,
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: kPrimaryGreen,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Text(
                    'LOGIN SEKARANG',
                    style: GoogleFonts.almarai(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () {
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    '/welcome',
                        (route) => false,
                  );
                },
                child: Text(
                  'Kembali ke Beranda',
                  style: GoogleFonts.almarai(
                    color: Colors.white,
                    fontSize: 14,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
              const Spacer(flex: 1),
            ],
          ),
        ),
      ),
    );
  }
}