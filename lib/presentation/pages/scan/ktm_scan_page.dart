// lib/presentation/pages/scan/ktm_scan_page.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:suara_kita/services/storage_service.dart';
import 'package:suara_kita/presentation/pages/scan/camera_page.dart';
import 'package:suara_kita/presentation/providers/signup_provider.dart';
import 'package:suara_kita/core/constants/colors.dart';

class KtmScanPage extends StatefulWidget {
  final String nim;
  final Function(String, String) onKtmScanned;

  const KtmScanPage({
    super.key,
    required this.nim,
    required this.onKtmScanned,
  });

  @override
  State<KtmScanPage> createState() => _KtmScanPageState();
}

class _KtmScanPageState extends State<KtmScanPage> {
  bool _isScanning = false;
  bool _isSuccess = false;
  String? _imageUrl;
  String? _barcodeData;
  File? _ktmFile; // Menyimpan file lokal untuk dikirim ke provider

  Future<void> _scanKTM() async {
    setState(() {
      _isScanning = true;
    });

    try {
      // 1. Buka in-app camera
      final File? imageFile = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const CameraPage(
            title: 'Scan KTM',
            description: 'Pastikan KTM dalam kondisi baik dan barcode terbaca jelas',
            isFaceScan: false,
          ),
        ),
      );

      if (imageFile != null) {
        // 2. Upload foto KTM
        final String? imageUrl = await StorageService.uploadKtmImage(imageFile, widget.nim);

        if (imageUrl == null) {
          if (mounted) setState(() => _isScanning = false);
          _showSnackBar('Gagal mengupload foto KTM', Colors.red);
          return;
        }

        // 3. Scan barcode (Simulasi data barcode)
        final String? barcodeData = await StorageService.scanBarcode();

        setState(() {
          _isScanning = false;
          _isSuccess = true;
          _imageUrl = imageUrl;
          _barcodeData = barcodeData;
          _ktmFile = imageFile;
        });

        // Tetap jalankan callback bawaan jika diperlukan
        if (barcodeData != null) {
          widget.onKtmScanned(imageUrl, barcodeData);
        }
      } else {
        if (mounted) setState(() => _isScanning = false);
        _showSnackBar('Tidak ada foto yang diambil', Colors.orange);
      }
    } catch (e) {
      if (mounted) setState(() => _isScanning = false);
      _showSnackBar('Error: $e', Colors.red);
    }
  }

  // --- FUNGSI PENDAFTARAN FINAL ---
  Future<void> _finishSignup() async {
    final provider = context.read<SignupProvider>();

    if (_ktmFile == null || _barcodeData == null) {
      _showSnackBar('Data KTM tidak lengkap', Colors.orange);
      return;
    }

    try {
      // 1. Isi data KTM ke provider
      provider.setKtmData(_barcodeData!, _ktmFile!);

      // 2. Eksekusi pendaftaran final ke Firebase/Database
      final success = await provider.completeSignup();

      if (success && mounted) {
        // Pindah ke halaman sukses dan bersihkan semua stack navigasi
        Navigator.pushNamedAndRemoveUntil(context, '/signup-success', (route) => false);
      } else if (mounted) {
        _showSnackBar(provider.errorMessage ?? 'Gagal menyimpan data pendaftaran', Colors.red);
      }
    } catch (e) {
      _showSnackBar('Terjadi kesalahan fatal: $e', Colors.red);
    }
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: color),
    );
  }

  void _retryScan() {
    setState(() {
      _isSuccess = false;
      _imageUrl = null;
      _barcodeData = null;
      _ktmFile = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    const Color kPrimaryGreen = Color(0xFF00C64F);
    const Color kDarkGreen = Color(0xFF002D12);
    final isFinalLoading = context.watch<SignupProvider>().isLoading;

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
            // Header
            Positioned(
              top: 50,
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
                      value: _isSuccess ? 1.0 : 0.75,
                      backgroundColor: Colors.white.withOpacity(0.3),
                      valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  ),
                  const SizedBox(width: 48),
                ],
              ),
            ),
            // Main Content
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Spacer(flex: 1),
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
                    'Langkah terakhir: Verifikasi identitas mahasiswa',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.almarai(
                      fontSize: 14,
                      color: Colors.white.withOpacity(0.8),
                    ),
                  ),
                  const Spacer(flex: 1),

                  // Scan Area
                  Container(
                    height: 200,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.white.withOpacity(0.3)),
                    ),
                    child: _isScanning || isFinalLoading
                        ? const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircularProgressIndicator(color: Colors.white),
                          SizedBox(height: 16),
                          Text(
                            'Memproses data...',
                            style: TextStyle(color: Colors.white),
                          ),
                        ],
                      ),
                    )
                        : _isSuccess
                        ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.badge_rounded, size: 80, color: Colors.white),
                          const SizedBox(height: 8),
                          const Text(
                            'KTM Terdeteksi',
                            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Barcode: $_barcodeData',
                            style: const TextStyle(color: Colors.white70, fontSize: 10),
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

                  // Action Buttons
                  if (!_isSuccess && !_isScanning)
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _scanKTM,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: kPrimaryGreen,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        child: Text(
                          'AMBIL FOTO KTM',
                          style: GoogleFonts.almarai(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),

                  if (_isSuccess)
                    Column(
                      children: [
                        const Icon(Icons.check_circle_rounded, color: Colors.white, size: 50),
                        const SizedBox(height: 16),
                        Text(
                          'KTM Siap Diverifikasi',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.almarai(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 24),
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                onPressed: isFinalLoading ? null : _retryScan,
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: Colors.white,
                                  side: const BorderSide(color: Colors.white),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                  padding: const EdgeInsets.symmetric(vertical: 15),
                                ),
                                child: const Text('ULANGI'),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: ElevatedButton(
                                onPressed: isFinalLoading ? null : _finishSignup,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.white,
                                  foregroundColor: kPrimaryGreen,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                  padding: const EdgeInsets.symmetric(vertical: 15),
                                ),
                                child: isFinalLoading
                                    ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(strokeWidth: 2, color: kPrimaryGreen)
                                )
                                    : const Text('SIMPAN & DAFTAR'),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  const Spacer(flex: 2),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}