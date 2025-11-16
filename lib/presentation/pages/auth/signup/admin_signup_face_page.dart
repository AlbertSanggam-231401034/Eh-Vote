import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AdminSignupFacePage extends StatefulWidget {
  final Map<String, dynamic> userData;

  const AdminSignupFacePage({super.key, required this.userData});

  @override
  State<AdminSignupFacePage> createState() => _AdminSignupFacePageState();
}

class _AdminSignupFacePageState extends State<AdminSignupFacePage> {
  bool _isScanning = false;
  bool _isSuccess = false;

  void _simulateFaceScan() async {
    setState(() {
      _isScanning = true;
    });

    // Simulasi proses scan wajah
    await Future.delayed(const Duration(seconds: 3));

    setState(() {
      _isScanning = false;
      _isSuccess = true;
    });
  }

  void _nextStep() {
    if (_isSuccess) {
      Navigator.pushNamed(
        context,
        '/admin-signup-ktm',
        arguments: {
          ...widget.userData,
          'faceData': 'face_embedding_simulated', // Data wajah simulasi
        },
      );
    }
  }

  void _retryScan() {
    setState(() {
      _isSuccess = false;
    });
  }

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
        child: SafeArea(
          child: Stack(
            children: [
              // Header dengan progress indicator
              Positioned(
                top: 10,
                left: 20,
                right: 20,
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                    ),
                    Expanded(
                      child: LinearProgressIndicator(
                        value: 0.75, // Step 3 dari 4
                        backgroundColor: Colors.white.withOpacity(0.3),
                        valueColor:
                        const AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    ),
                    const SizedBox(width: 48),
                  ],
                ),
              ),
              // Konten utama
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32.0),
                child: SingleChildScrollView( // Tambahkan SingleChildScrollView
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: MediaQuery.of(context).size.height - kToolbarHeight,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const SizedBox(height: 80),
                        // Judul
                        Text(
                          'Scan Wajah',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.unbounded(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Step 3 of 4 - Scan wajah untuk keamanan',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.almarai(
                            fontSize: 14,
                            color: Colors.white.withOpacity(0.8),
                          ),
                        ),
                        const SizedBox(height: 32),

                        // Area scan wajah
                        Container(
                          height: 200,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                            border:
                            Border.all(color: Colors.white.withOpacity(0.3)),
                          ),
                          child: _isScanning
                          // --- PERBAIKAN 1: HAPUS 'const' ---
                              ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const CircularProgressIndicator(
                                    color: Colors.white),
                                const SizedBox(height: 16),
                                Text(
                                  'Memindai wajah...',
                                  style: GoogleFonts.almarai(color: Colors.white), // Ganti ke GoogleFonts
                                ),
                              ],
                            ),
                          )
                              : _isSuccess
                          // --- PERBAIKAN 2: HAPUS 'const' DAN GANTI ICON ---
                              ? Center(
                            child: Column(
                              mainAxisAlignment:
                              MainAxisAlignment.center,
                              children: [
                                const Icon(
                                    Icons.check_circle_outline_rounded, // ICON YANG BENAR
                                    size: 80,
                                    color: Colors.white
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Wajah Terdaftar',
                                  style: GoogleFonts.almarai( // Ganti ke GoogleFonts
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          )
                          // --- PERBAIKAN 3: HAPUS 'const' ---
                              : Center(
                            child: Column(
                              mainAxisAlignment:
                              MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.face_rounded,
                                    size: 80, color: Colors.white),
                                const SizedBox(height: 8),
                                Text(
                                  'Siap memindai wajah',
                                  style: GoogleFonts.almarai(color: Colors.white), // Ganti ke GoogleFonts
                                ),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(height: 32),

                        // Tombol aksi
                        if (!_isSuccess && !_isScanning)
                          SizedBox(
                            width: double.infinity,
                            height: 50,
                            child: ElevatedButton(
                              onPressed: _simulateFaceScan,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                foregroundColor: kPrimaryGreen,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              child: Text(
                                'SCAN WAJAH',
                                style: GoogleFonts.almarai(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),

                        if (_isSuccess)
                          Column(
                            children: [
                              // Hapus Icon check_circle di sini (sudah ada di box atas)
                              Text(
                                'Scan Wajah Berhasil!',
                                textAlign: TextAlign.center,
                                style: GoogleFonts.almarai(
                                  fontSize: 18,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 24),
                              Row(
                                children: [
                                  Expanded(
                                    child: OutlinedButton(
                                      onPressed: _retryScan,
                                      style: OutlinedButton.styleFrom(
                                        foregroundColor: Colors.white,
                                        side: const BorderSide(color: Colors.white),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                          BorderRadius.circular(10),
                                        ),
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 15),
                                      ),
                                      child: Text(
                                        'ULANGI',
                                        style: GoogleFonts.almarai(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: ElevatedButton(
                                      onPressed: _nextStep,
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.white,
                                        foregroundColor: kPrimaryGreen,
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                          BorderRadius.circular(10),
                                        ),
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 15),
                                      ),
                                      child: Text(
                                        'LANJUT',
                                        style: GoogleFonts.almarai(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),

                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}