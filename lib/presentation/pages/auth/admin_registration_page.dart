import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AdminRegistrationPage extends StatelessWidget {
  const AdminRegistrationPage({super.key});

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
        child: Stack(
          children: [
            // Tombol back di kiri atas
            Positioned(
              top: 50,
              left: 20,
              child: IconButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                icon: const Icon(
                  Icons.arrow_back_rounded,
                  color: Colors.white,
                  size: 28,
                ),
              ),
            ),
            // Konten utama
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Spacer(flex: 2),
                  // Icon admin
                  const Icon(
                    Icons.admin_panel_settings_rounded,
                    size: 80,
                    color: Colors.white,
                  ),
                  const SizedBox(height: 24),
                  // Judul
                  Text(
                    'Registrasi Admin',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.unbounded(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Subjudul
                  Text(
                    'Daftarkan akun administrator baru',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.almarai(
                      fontSize: 16,
                      color: Colors.white.withOpacity(0.9),
                    ),
                  ),
                  const Spacer(flex: 1),
                  // Informasi penting
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.white.withOpacity(0.3)),
                    ),
                    child: Column(
                      children: [
                        const Icon(
                          Icons.security_rounded,
                          color: Colors.white,
                          size: 24,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Pastikan data yang dimasukkan valid. Akun admin akan memiliki akses penuh ke sistem.',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.almarai(
                            color: Colors.white,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Tombol mulai registrasi
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () {
                        // --- INI PERBAIKANNYA ---
                        // Mengarah ke rute Step 1 yang sudah ada di main.dart
                        Navigator.pushNamed(context, '/admin-signup-data');
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: kPrimaryGreen,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: Text(
                        'MULAI REGISTRASI',
                        style: GoogleFonts.almarai(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const Spacer(flex: 3),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}