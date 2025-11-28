import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:suara_kita/services/firebase_service.dart';
import 'package:suara_kita/presentation/pages/scan/face_scan_page.dart';
import 'package:suara_kita/presentation/pages/scan/ktm_scan_page.dart';

class AdminScanFlow extends StatefulWidget {
  final String adminNim;

  const AdminScanFlow({super.key, required this.adminNim});

  @override
  State<AdminScanFlow> createState() => _AdminScanFlowState();
}

class _AdminScanFlowState extends State<AdminScanFlow> {
  int _currentStep = 0;
  String? _faceImageUrl;
  String? _ktmImageUrl;
  String? _barcodeData;

  void _onFaceScanned(String imageUrl) {
    setState(() {
      _faceImageUrl = imageUrl;
      _currentStep = 1;
    });
  }

  void _onKtmScanned(String imageUrl, String barcodeData) {
    setState(() {
      _ktmImageUrl = imageUrl;
      _barcodeData = barcodeData;
      _currentStep = 2;
    });
  }

  Future<void> _completeScan() async {
    try {
      // Update admin data dengan hasil scan
      await FirebaseService.updateUser(widget.adminNim, {
        'faceImageUrl': _faceImageUrl!,
        'ktmImageUrl': _ktmImageUrl!,
        'faceData': 'face_embedding_${widget.adminNim}',
        'ktmData': _barcodeData!,
      });

      // Kembali ke admin dashboard
      Navigator.pushReplacementNamed(context, '/admin-dashboard');

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Scan berhasil! Profil admin telah dilengkapi.'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
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
          child: Column(
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                    ),
                    Expanded(
                      child: Text(
                        'Lengkapi Profil Admin',
                        style: GoogleFonts.unbounded(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Progress Steps
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildStep(1, 'Scan Wajah', _currentStep >= 0),
                    _buildStep(2, 'Scan KTM', _currentStep >= 1),
                    _buildStep(3, 'Selesai', _currentStep >= 2),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Content
              Expanded(
                child: _currentStep == 0
                    ? FaceScanPage(
                  nim: widget.adminNim,
                  onFaceScanned: _onFaceScanned,
                )
                    : _currentStep == 1
                    ? KtmScanPage(
                  nim: widget.adminNim,
                  onKtmScanned: _onKtmScanned,
                )
                    : _buildCompletionStep(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStep(int stepNumber, String title, bool isActive) {
    return Column(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: isActive ? Colors.white : Colors.white.withOpacity(0.3),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              '$stepNumber',
              style: GoogleFonts.almarai(
                color: isActive ? const Color(0xFF00C64F) : Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          title,
          style: GoogleFonts.almarai(
            color: Colors.white,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildCompletionStep() {
    return Padding(
      padding: const EdgeInsets.all(32.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.check_circle_rounded, size: 80, color: Colors.white),
          const SizedBox(height: 24),
          Text(
            'Scan Berhasil!',
            style: GoogleFonts.unbounded(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Profil admin Anda telah dilengkapi dengan data scan wajah dan KTM.',
            style: GoogleFonts.almarai(
              fontSize: 16,
              color: Colors.white.withOpacity(0.9),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: _completeScan,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: const Color(0xFF00C64F),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Text(
                'SIMPAN & LANJUTKAN',
                style: GoogleFonts.almarai(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}