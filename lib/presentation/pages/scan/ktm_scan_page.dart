// lib/presentation/pages/scan/ktm_scan_page.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:suara_kita/services/storage_service.dart';
import 'package:suara_kita/presentation/pages/scan/camera_page.dart'; // Pastikan import CameraPage

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

  Future<void> _scanKTM() async {
    setState(() {
      _isScanning = true;
    });

    try {
      // Buka in-app camera
      final File? imageFile = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => CameraPage(
            title: 'Scan KTM',
            description: 'Pastikan KTM dalam kondisi baik dan barcode terbaca jelas',
            isFaceScan: false,
          ),
        ),
      );

      if (imageFile != null) {
        // Upload ke Supabase
        final String imageUrl = await StorageService.uploadKtmImage(imageFile, widget.nim);

        // Scan barcode (simulated for now)
        final String? barcodeData = await StorageService.scanBarcode();

        setState(() {
          _isScanning = false;
          _isSuccess = true;
          _imageUrl = imageUrl;
          _barcodeData = barcodeData;
        });

        // Call callback dengan kedua data
        if (barcodeData != null) {
          widget.onKtmScanned(imageUrl, barcodeData);
        }
      } else {
        setState(() {
          _isScanning = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Tidak ada foto yang diambil'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } catch (e) {
      setState(() {
        _isScanning = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _retryScan() {
    setState(() {
      _isSuccess = false;
      _imageUrl = null;
      _barcodeData = null;
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
                      value: _isSuccess ? 1.0 : 0.5,
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
                  // Title
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
                    'Ambil foto KTM dan scan barcode',
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
                    child: _isScanning
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
                        ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.badge_rounded,
                              size: 80, color: Colors.white),
                          const SizedBox(height: 8),
                          const Text(
                            'KTM Terverifikasi',
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 4),
                          if (_barcodeData != null)
                            Text(
                              'Barcode: $_barcodeData',
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 10,
                              ),
                            ),
                        ],
                      ),
                    )
                        : const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.badge_outlined,
                              size: 80, color: Colors.white),
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

                  // Instructions
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.white.withOpacity(0.3)),
                    ),
                    child: Column(
                      children: [
                        const Icon(Icons.info_rounded,
                            color: Colors.white, size: 16),
                        const SizedBox(height: 8),
                        Text(
                          'Pastikan KTM dalam kondisi baik dan barcode terbaca jelas',
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

                  if (_isSuccess)
                    Column(
                      children: [
                        const Icon(Icons.check_circle_rounded,
                            color: Colors.white, size: 50),
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
                        if (_barcodeData != null)
                          Text(
                            'Data Barcode: $_barcodeData',
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
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
                                  padding:
                                  const EdgeInsets.symmetric(vertical: 15),
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
                                onPressed: () {
                                  if (_imageUrl != null && _barcodeData != null) {
                                    Navigator.pop(context, {
                                      'imageUrl': _imageUrl,
                                      'barcodeData': _barcodeData,
                                    });
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.white,
                                  foregroundColor: kPrimaryGreen,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  padding:
                                  const EdgeInsets.symmetric(vertical: 15),
                                ),
                                child: Text(
                                  'SIMPAN',
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