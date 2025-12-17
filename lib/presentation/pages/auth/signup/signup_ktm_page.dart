import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import 'package:suara_kita/presentation/providers/signup_provider.dart';
import 'package:suara_kita/core/constants/colors.dart';
import 'package:suara_kita/presentation/widgets/common/primary_button.dart';
import 'package:suara_kita/services/storage_service.dart';

class SignupKtmPage extends StatefulWidget {
  static const routeName = '/signup-ktm';

  const SignupKtmPage({super.key});

  @override
  State<SignupKtmPage> createState() => _SignupKtmPageState();
}

class _SignupKtmPageState extends State<SignupKtmPage> {
  MobileScannerController? _scannerController;
  bool _isScanning = true;
  String? _scannedData;
  File? _ktmImageFile;

  @override
  void initState() {
    super.initState();
    _initializeScanner();
  }

  void _initializeScanner() {
    _scannerController = MobileScannerController(
      formats: [BarcodeFormat.qrCode],
      autoStart: true,
    );
  }

  // --- LOGIC METHODS ---

  void _onScanResult(BarcodeCapture barcodeCapture) {
    if (!mounted || !_isScanning) return;

    final barcodes = barcodeCapture.barcodes;
    if (barcodes.isNotEmpty) {
      final barcode = barcodes.first;
      if (barcode.rawValue != null) {
        setState(() {
          _scannedData = barcode.rawValue;
          _isScanning = false;
        });

        _scannerController?.stop();

        if (_isValidNimFormat(_scannedData!)) {
          _showScanSuccess();
        } else {
          _showInvalidQRDialog();
        }
      }
    }
  }

  bool _isValidNimFormat(String data) {
    // Validasi format NIM (Angka, 9-15 digit)
    final nimRegex = RegExp(r'^\d{9,15}$');
    return nimRegex.hasMatch(data);
  }

  void _showScanSuccess() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('QR Code berhasil dipindai!'),
        backgroundColor: AppColors.success,
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _showInvalidQRDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Format QR Tidak Valid'),
        content: const Text('QR Code yang dipindai bukan format NIM USU yang valid.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _retryScan();
            },
            child: const Text('Scan Ulang'),
          ),
        ],
      ),
    );
  }

  Future<void> _captureKtmPhoto() async {
    try {
      final imageFile = await StorageService.takePhoto();
      if (imageFile != null) {
        setState(() {
          _ktmImageFile = imageFile;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal mengambil foto: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Future<void> _uploadKtmFromGallery() async {
    try {
      final imageFile = await StorageService.pickImage();
      if (imageFile != null) {
        setState(() {
          _ktmImageFile = imageFile;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal memilih gambar: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  void _retryScan() {
    setState(() {
      _scannedData = null;
      _isScanning = true;
      _ktmImageFile = null;
    });
    _scannerController?.start();
  }

  // --- WIDGET BUILDERS ---

  Widget _buildScanner() {
    return Column(
      children: [
        Container(
          height: 300,
          margin: const EdgeInsets.symmetric(horizontal: 20),
          decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 10,
                spreadRadius: 2,
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Stack(
              children: [
                MobileScanner(
                  controller: _scannerController,
                  onDetect: _onScanResult,
                ),
                Center(
                  child: Container(
                    width: 250,
                    height: 250,
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: AppColors.primaryGreen,
                        width: 3,
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 20,
                  left: 0,
                  right: 0,
                  child: Column(
                    children: [
                      Icon(
                        Icons.qr_code_scanner_rounded,
                        color: Colors.white.withOpacity(0.9),
                        size: 40,
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        'Arahkan kamera ke QR Code pada KTM',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 20),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: OutlinedButton.icon(
            onPressed: () { _uploadKtmFromGallery(); },
            icon: const Icon(Icons.photo_library_rounded),
            label: const Text('Upload Gambar KTM dari Galeri'),
            style: OutlinedButton.styleFrom(
              minimumSize: const Size(double.infinity, 50),
              side: const BorderSide(color: AppColors.primaryGreen),
              foregroundColor: AppColors.primaryGreen,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildScanResult() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          margin: const EdgeInsets.symmetric(horizontal: 20),
          decoration: BoxDecoration(
            color: AppColors.success.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.success),
          ),
          child: Column(
            children: [
              const Icon(
                Icons.check_circle_rounded,
                color: AppColors.success,
                size: 60,
              ),
              const SizedBox(height: 16),
              const Text(
                'QR Code Berhasil Dipindai',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.darkGreen,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'NIM: ${_scannedData ?? ""}',
                style: const TextStyle(
                  fontSize: 16,
                  color: AppColors.grey,
                ),
              ),
              const SizedBox(height: 16),
              OutlinedButton(
                onPressed: _retryScan,
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primaryGreen,
                  side: const BorderSide(color: AppColors.primaryGreen),
                ),
                child: const Text('Scan Ulang'),
              ),
            ],
          ),
        ),
        const SizedBox(height: 30),
        if (_ktmImageFile == null)
          Column(
            children: [
              const Text(
                'Ambil Foto KTM untuk Verifikasi',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.darkGreen,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Foto KTM Anda untuk melengkapi verifikasi identitas',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.grey,
                ),
              ),
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: ElevatedButton.icon(
                  onPressed: () { _captureKtmPhoto(); },
                  icon: const Icon(Icons.camera_alt_rounded),
                  label: const Text('Ambil Foto KTM'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryGreen,
                    foregroundColor: AppColors.white,
                    minimumSize: const Size(double.infinity, 50),
                  ),
                ),
              ),
            ],
          )
        else
          Column(
            children: [
              Container(
                height: 200,
                width: double.infinity,
                margin: const EdgeInsets.symmetric(horizontal: 20),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  image: DecorationImage(
                    image: FileImage(_ktmImageFile!),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  OutlinedButton.icon(
                    onPressed: () {
                      setState(() {
                        _ktmImageFile = null;
                      });
                    },
                    icon: const Icon(Icons.replay_rounded),
                    label: const Text('Ganti Foto'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.error,
                      side: const BorderSide(color: AppColors.error),
                    ),
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton.icon(
                    onPressed: () {
                      // Simpan data ke provider
                      final provider = context.read<SignupProvider>();
                      provider.setKtmData(_scannedData!, _ktmImageFile!);

                      // Lanjut ke Success Page
                      Navigator.pushNamed(context, '/signup-success');
                    },
                    icon: const Icon(Icons.check_rounded),
                    label: const Text('Gunakan'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryGreen,
                      foregroundColor: AppColors.white,
                    ),
                  ),
                ],
              ),
            ],
          ),
      ],
    );
  }

  Widget _buildStepIndicator(int step, String label, bool isActive) {
    return Column(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: isActive ? AppColors.primaryGreen : AppColors.lightGrey,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              '$step',
              style: TextStyle(
                color: isActive ? AppColors.white : AppColors.grey,
                fontWeight: FontWeight.w700,
                fontSize: 14,
              ),
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: isActive ? AppColors.primaryGreen : AppColors.grey,
            fontWeight: isActive ? FontWeight.w700 : FontWeight.w400,
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _scannerController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<SignupProvider>();

    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        title: const Text('Verifikasi KTM'),
        centerTitle: true,
        backgroundColor: AppColors.white,
        foregroundColor: AppColors.darkGreen,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Progress Indicator
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildStepIndicator(1, 'Data', true),
                  _buildStepIndicator(2, 'Pass', true),
                  _buildStepIndicator(3, 'Wajah', true),
                  _buildStepIndicator(4, 'KTM', true), // Active
                  _buildStepIndicator(5, 'Selesai', false),
                ],
              ),
            ),

            // Instructions
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Column(
                children: [
                  Text(
                    'Scan QR Code KTM Anda',
                    style: Theme.of(context).textTheme.displaySmall,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Pastikan QR code pada KTM terlihat jelas dan tidak terhalang.',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),

            // Scanner Area
            Expanded(
              child: SingleChildScrollView(
                child: _scannedData == null ? _buildScanner() : _buildScanResult(),
              ),
            ),

            // Error Message
            if (provider.errorMessage != null)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: Text(
                  provider.errorMessage!,
                  style: const TextStyle(color: AppColors.error, fontSize: 14),
                  textAlign: TextAlign.center,
                ),
              ),

            // Bottom Actions
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size(0, 50),
                        side: const BorderSide(color: AppColors.grey),
                        foregroundColor: AppColors.grey,
                      ),
                      child: const Text('Kembali'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    // TOMBOL LANJUTKAN (Sekarang Aman)
                    child: PrimaryButton(
                      // Logika: Hanya aktif jika QR terscan DAN foto KTM ada
                      onPressed: (_scannedData != null && _ktmImageFile != null)
                          ? () {
                        provider.setKtmData(_scannedData!, _ktmImageFile!);
                        Navigator.pushNamed(context, '/signup-success');
                      }
                          : null, // Null akan membuat tombol disabled (abu-abu)
                      text: 'Lanjutkan',
                      isLoading: false,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}