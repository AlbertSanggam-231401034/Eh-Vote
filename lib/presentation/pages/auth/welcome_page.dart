import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
// Import widget ikon admin yang sudah kita perbaiki
import 'package:suara_kita/presentation/widgets/auth/admin_icon_button.dart';

class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  @override
  Widget build(BuildContext context) {
    // Warna hijau utama (titik awal gradasi)
    const Color kPrimaryGreen = Color(0xFF00C64F);
    // Warna hijau sangat gelap (titik akhir gradasi)
    const Color kDarkGreen = Color(0xFF002D12);

    return Scaffold(
      // 1. HAPUS 'backgroundColor' DARI SCAFFOLD

      // 2. BUNGKUS 'Stack' DENGAN 'Container' UNTUK GRADASI
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              kPrimaryGreen, // Mulai dari Hijau Cerah
              kDarkGreen,    // Berakhir di Hijau Sangat Gelap
            ],
            begin: Alignment.topCenter, // Mulai dari atas
            end: Alignment.bottomCenter,  // Selesai di bawah
          ),
        ),
        child: Stack(
          children: [
            // Konten Utama (Tidak berubah sama sekali)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Spacer(flex: 2),
                  const Icon(
                    Icons.how_to_vote_outlined,
                    size: 100,
                    color: Colors.white,
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Suara Kita',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.unbounded(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Partisipasi Pemilihan\nKampus Jadi Lebih Mudah',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.almarai(
                      fontSize: 18,
                      color: Colors.white.withOpacity(0.9),
                      height: 1.4,
                    ),
                  ),
                  const Spacer(flex: 2),
                  ElevatedButton(
                    onPressed: () {
                      // TODO: Navigasi ke Halaman Sign Up
                      print('Sign Up pressed');
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: kPrimaryGreen, // Teks Hijau
                      minimumSize: const Size(double.infinity, 55),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: Text(
                      'SIGN UP',
                      style: GoogleFonts.almarai(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  OutlinedButton(
                    onPressed: () {
                      // TODO: Navigasi ke Halaman Login
                      print('Log In pressed');
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 55),
                      side: const BorderSide(color: Colors.white, width: 2),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: Text(
                      'LOG IN',
                      style: GoogleFonts.almarai(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const Spacer(flex: 1),
                ],
              ),
            ),

            // Ikon Admin (Tidak berubah)
            const Positioned(
              top: 50,
              right: 20,
              child: AdminIconButton(),
            ),
          ],
        ),
      ),
    );
  }
}