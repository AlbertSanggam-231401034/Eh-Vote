import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:suara_kita/data/models/user_model.dart';
import 'package:suara_kita/services/firebase_service.dart';

class AdminSignupKtmPage extends StatefulWidget {
  final Map<String, dynamic> userData;

  const AdminSignupKtmPage({super.key, required this.userData});

  @override
  State<AdminSignupKtmPage> createState() => _AdminSignupKtmPageState();
}

class _AdminSignupKtmPageState extends State<AdminSignupKtmPage> {
  bool _isScanning = false;
  bool _isSuccess = false;
  bool _isSaving = false;

  void _simulateKtmScan() async {
    setState(() {
      _isScanning = true;
    });

    // Simulasi proses scan KTM
    await Future.delayed(const Duration(seconds: 2));

    setState(() {
      _isScanning = false;
      _isSuccess = true;
    });
  }

  void _completeRegistration() async {
    if (_isSuccess) {
      setState(() {
        _isSaving = true;
      });

      try {
        // Cek apakah NIM sudah terdaftar
        final isNimExists = await FirebaseService.isNimExists(widget.userData['nim']);
        if (isNimExists) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('NIM ${widget.userData['nim']} sudah terdaftar'),
              backgroundColor: Colors.red,
            ),
          );
          setState(() {
            _isSaving = false;
          });
          return;
        }

        // Buat objek User dari data yang terkumpul
        final user = User(
          nim: widget.userData['nim'],
          password: widget.userData['password'],
          fullName: widget.userData['fullName'],
          placeOfBirth: widget.userData['placeOfBirth'],
          dateOfBirth: widget.userData['dateOfBirth'],
          phoneNumber: widget.userData['phoneNumber'],
          faculty: widget.userData['faculty'],
          major: widget.userData['major'],
          ktmData: 'ktm_barcode_${widget.userData['nim']}', // Data KTM simulasi
          faceData: widget.userData['faceData'],
          role: UserRole.admin, // Tandai sebagai admin
          hasVoted: false,
          createdAt: DateTime.now(),
        );

        // Simpan ke Firebase
        await FirebaseService.saveUser(user);

        setState(() {
          _isSaving = false;
        });

        // Navigasi ke halaman sukses
        Navigator.pushNamedAndRemoveUntil(
          context,
          '/admin-registration-success',
              (route) => false,
        );

      } catch (e) {
        setState(() {
          _isSaving = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
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
                        value: 1.0, // Step 4 dari 4
                        backgroundColor: Colors.white.withOpacity(0.3),
                        valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    ),
                    const SizedBox(width: 48),
                  ],
                ),
              ),
              // Konten utama
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32.0),
                child: SingleChildScrollView(
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
                          'Scan KTM',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.unbounded(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Step 4 of 4 - Scan KTM untuk verifikasi',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.almarai(
                            fontSize: 14,
                            color: Colors.white.withOpacity(0.8),
                          ),
                        ),
                        const SizedBox(height: 32),

                        // Area scan KTM
                        Container(
                          height: 200,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: Colors.white.withOpacity(0.3)),
                          ),
                          child: _isSaving
                              ? const Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                CircularProgressIndicator(color: Colors.white),
                                SizedBox(height: 16),
                                Text(
                                  'Menyimpan data...',
                                  style: TextStyle(color: Colors.white),
                                ),
                              ],
                            ),
                          )
                              : _isScanning
                              ? const Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                CircularProgressIndicator(color: Colors.white),
                                SizedBox(height: 16),
                                Text(
                                  'Memindai KTM...',
                                  style: TextStyle(color: Colors.white),
                                ),
                              ],
                            ),
                          )
                              : _isSuccess
                              ? const Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.badge_rounded, size: 80, color: Colors.white),
                                SizedBox(height: 8),
                                Text(
                                  'KTM Terverifikasi',
                                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          )
                              : const Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.badge_outlined, size: 80, color: Colors.white),
                                SizedBox(height: 8),
                                Text(
                                  'Siap memindai KTM',
                                  style: TextStyle(color: Colors.white),
                                ),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(height: 24),

                        // Informasi KTM
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.white.withOpacity(0.3)),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.info_rounded, color: Colors.white, size: 16),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Pastikan KTM dalam kondisi baik dan barcode terbaca jelas',
                                  style: GoogleFonts.almarai(
                                    color: Colors.white,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 32),

                        // Tombol aksi
                        if (!_isSuccess && !_isScanning && !_isSaving)
                          SizedBox(
                            width: double.infinity,
                            height: 50,
                            child: ElevatedButton(
                              onPressed: _simulateKtmScan,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                foregroundColor: kPrimaryGreen,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              child: Text(
                                'SCAN KTM',
                                style: GoogleFonts.almarai(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),

                        if (_isSuccess && !_isSaving)
                          Column(
                            children: [
                              const Icon(Icons.check_circle_rounded, color: Colors.white, size: 50),
                              const SizedBox(height: 16),
                              Text(
                                'Scan KTM Berhasil!',
                                textAlign: TextAlign.center,
                                style: GoogleFonts.almarai(
                                  fontSize: 18,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'NIM: ${widget.userData['nim']}',
                                textAlign: TextAlign.center,
                                style: GoogleFonts.almarai(
                                  fontSize: 14,
                                  color: Colors.white.withOpacity(0.8),
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
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                        padding: const EdgeInsets.symmetric(vertical: 15),
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
                                      onPressed: _completeRegistration,
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.white,
                                        foregroundColor: kPrimaryGreen,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                        padding: const EdgeInsets.symmetric(vertical: 15),
                                      ),
                                      child: Text(
                                        'SIMPAN DATA',
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