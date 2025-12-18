// lib/presentation/pages/scan/face_scan_page.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:suara_kita/services/storage_service.dart';
import 'package:suara_kita/services/face_recognition_service.dart';
import 'package:suara_kita/presentation/pages/scan/camera_page.dart';
import 'package:suara_kita/presentation/providers/signup_provider.dart';

class FaceScanPage extends StatefulWidget {
  final String nim;
  final Function(String) onFaceScanned;

  const FaceScanPage({
    super.key,
    required this.nim,
    required this.onFaceScanned,
  });

  @override
  State<FaceScanPage> createState() => _FaceScanPageState();
}

class _FaceScanPageState extends State<FaceScanPage> {
  bool _isScanning = false;
  bool _isSuccess = false;
  String? _imageUrl;

  Future<void> _scanFace() async {
    setState(() => _isScanning = true);

    try {
      // 1. Buka In-App Camera
      final File? imageFile = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const CameraPage(
            title: 'Scan Wajah',
            description: 'Posisikan wajah di tengah dan pencahayaan cukup',
            isFaceScan: true,
          ),
        ),
      );

      if (imageFile != null) {
        // 2. Upload ke Supabase/Firebase
        final String? imageUrl = await StorageService.uploadFaceImage(imageFile, widget.nim);

        if (imageUrl == null) throw Exception("Gagal upload gambar ke server");

        // 3. Extract Embedding (ML Logic)
        final faceService = FaceRecognitionService();
        final embedding = await faceService.extractFaceEmbedding(imageFile);

        if (mounted) {
          // --- PERBAIKAN: UPDATE PROVIDER AGAR DATA TIDAK RESET ---
          // Kita masukkan data ke SignupProvider agar NIM, Password, dan Face Data terjaga.
          context.read<SignupProvider>().updateFaceData(
              imageFile,
              imageUrl,
              embedding ?? []
          );

          setState(() {
            _isScanning = false;
            _isSuccess = true;
            _imageUrl = imageUrl;
          });

          // Panggil callback untuk integrasi dengan flow navigasi luar
          widget.onFaceScanned(imageUrl);
        }
      } else {
        if (mounted) setState(() => _isScanning = false);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isScanning = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Error: $e'),
              backgroundColor: Colors.red
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    const Color kPrimaryGreen = Color(0xFF00C64F);
    const Color kDarkGreen = Color(0xFF002D12);

    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [kPrimaryGreen, kDarkGreen],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 20),
              Text(
                'Scan Wajah',
                style: GoogleFonts.unbounded(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white
                ),
              ),
              const Spacer(),

              // Frame Scan Visual
              Container(
                width: 250,
                height: 250,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 4),
                  color: Colors.white10,
                ),
                child: _isScanning
                    ? const Center(child: CircularProgressIndicator(color: Colors.white))
                    : _isSuccess
                    ? const Icon(Icons.check_circle, color: Colors.white, size: 100)
                    : const Icon(Icons.face_unlock_rounded, color: Colors.white, size: 100),
              ),

              const Spacer(),

              Padding(
                padding: const EdgeInsets.all(32.0),
                child: _isSuccess
                    ? ElevatedButton(
                  onPressed: () {
                    // Navigasi ke tahap verifikasi KTM
                    Navigator.pushNamed(context, '/signup-ktm');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: kPrimaryGreen,
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)
                    ),
                  ),
                  child: const Text(
                      "LANJUT KE SCAN KTM",
                      style: TextStyle(fontWeight: FontWeight.bold)
                  ),
                )
                    : ElevatedButton(
                  onPressed: _scanFace,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: kPrimaryGreen,
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)
                    ),
                  ),
                  child: const Text(
                      "MULAI SCAN",
                      style: TextStyle(fontWeight: FontWeight.bold)
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