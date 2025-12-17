import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:suara_kita/presentation/providers/voting_provider.dart';
import 'package:suara_kita/core/constants/colors.dart';
import 'package:suara_kita/presentation/widgets/common/primary_button.dart';
import 'package:suara_kita/utils/ktm_scanner_utils.dart';

class VotingKtmScanPage extends StatefulWidget {
  static const routeName = '/voting-ktm-scan';

  const VotingKtmScanPage({Key? key}) : super(key: key);

  @override
  State<VotingKtmScanPage> createState() => _VotingKtmScanPageState();
}

class _VotingKtmScanPageState extends State<VotingKtmScanPage> {
  MobileScannerController? _scannerController;
  bool _isScanning = true;
  bool _isProcessing = false;
  String? _scannedData;
  String? _validationError;

  @override
  void initState() {
    super.initState();
    _initializeScanner();
  }

  void _initializeScanner() {
    _scannerController = MobileScannerController(
      formats: [BarcodeFormat.qrCode],
      autoStart: true,
      detectionSpeed: DetectionSpeed.normal,
      detectionTimeoutMs: 1000,
    );
  }

  void _onScanResult(BarcodeCapture barcodeCapture) async {
    if (!mounted || !_isScanning || _isProcessing) return;

    final barcodes = barcodeCapture.barcodes;
    if (barcodes.isEmpty) return;

    final barcode = barcodes.first;
    if (barcode.rawValue == null) return;

    final rawData = barcode.rawValue!.trim();

    // Prevent multiple processing
    setState(() {
      _isProcessing = true;
      _isScanning = false;
      _scannedData = rawData;
    });

    _scannerController?.stop();

    try {
      // Validate NIM format
      if (!_isValidNimFormat(rawData)) {
        throw Exception('Format QR Code tidak valid. Pastikan QR berasal dari KTM USU.');
      }

      // Get voting provider
      final votingProvider = context.read<VotingProvider>();

      // Perform KTM verification
      final isVerified = await votingProvider.verifyKtm(rawData);

      if (isVerified && mounted) {
        // Success - auto navigate to next step
        await Future.delayed(const Duration(milliseconds: 500)); // Small delay for UX
        Navigator.pushNamed(context, '/voting-agreement');
      } else if (mounted) {
        // Error will be shown from provider
        _showScanError(votingProvider.errorMessage ?? 'Verifikasi KTM gagal');
      }
    } catch (e) {
      if (mounted) {
        _showScanError(e.toString());
      }
    } finally {
      if (mounted && !_isScanning) {
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }

  bool _isValidNimFormat(String data) {
    // Basic format validation
    if (data.isEmpty) return false;

    // Check if it's a valid USU NIM
    return KTMScannerUtils.isValidNIMLogic(data);
  }

  void _showScanError(String error) {
    setState(() {
      _validationError = error;
      _isProcessing = false;
    });

    // Show error snackbar
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(error),
        backgroundColor: AppColors.error,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _retryScan() {
    setState(() {
      _isScanning = true;
      _scannedData = null;
      _validationError = null;
      _isProcessing = false;
    });
    _scannerController?.start();
  }

  Widget _buildScanner() {
    return Column(
      children: [
        // Scanner Container
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

                // Scanner overlay guide
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
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.qr_code_scanner_rounded,
                          color: Colors.white.withOpacity(0.9),
                          size: 60,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Arahkan ke QR Code\npada KTM Anda',
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
                ),

                // Processing overlay
                if (_isProcessing)
                  Container(
                    color: Colors.black.withOpacity(0.7),
                    child: const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircularProgressIndicator(
                            color: AppColors.primaryGreen,
                          ),
                          SizedBox(height: 16),
                          Text(
                            'Memverifikasi KTM...',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 24),

        // Instructions
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: Column(
            children: [
              Text(
                'Langkah Verifikasi KTM',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.darkGreen,
                ),
              ),
              const SizedBox(height: 12),
              _buildInstructionStep(1, 'Pastikan QR code pada KTM terlihat jelas'),
              _buildInstructionStep(2, 'Tidak terhalang atau silau'),
              _buildInstructionStep(3, 'Scanner akan otomatis membaca QR'),
              _buildInstructionStep(4, 'NIM akan divalidasi dengan akun Anda'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInstructionStep(int number, String text) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: AppColors.primaryGreen,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                '$number',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 13,
                color: AppColors.grey,
              ),
            ),
          ),
        ],
      ),
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
              Icon(
                Icons.check_circle_rounded,
                color: AppColors.success,
                size: 60,
              ),
              const SizedBox(height: 16),
              Text(
                'KTM Terverifikasi!',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
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
              const SizedBox(height: 8),
              Text(
                KTMScannerUtils.getFacultyNameFromNIM(_scannedData!),
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.primaryGreen,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 16),

              if (_isProcessing)
                const Column(
                  children: [
                    CircularProgressIndicator(
                      color: AppColors.primaryGreen,
                    ),
                    SizedBox(height: 12),
                    Text(
                      'Menyiapkan langkah selanjutnya...',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.grey,
                      ),
                    ),
                  ],
                )
              else
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

        // Security Info
        Container(
          padding: const EdgeInsets.all(16),
          margin: const EdgeInsets.symmetric(horizontal: 20),
          decoration: BoxDecoration(
            color: AppColors.primaryGreen.withOpacity(0.05),
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: AppColors.primaryGreen.withOpacity(0.3)),
          ),
          child: Row(
            children: [
              Icon(
                Icons.security_rounded,
                color: AppColors.primaryGreen,
                size: 24,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Verifikasi KTM memastikan hanya pemilik akun yang dapat memberikan suara',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.darkGreen,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildProgressStepper(int currentStep) {
    final steps = ['Wajah', 'KTM', 'Setuju', 'Pilih', 'Konfirm', 'Selesai'];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Column(
        children: [
          // Step indicators
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(6, (index) {
              final stepNumber = index + 1;
              final isCompleted = stepNumber < currentStep;
              final isCurrent = stepNumber == currentStep;

              return Column(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: isCompleted || isCurrent
                          ? AppColors.primaryGreen
                          : AppColors.lightGrey,
                      shape: BoxShape.circle,
                      border: isCurrent
                          ? Border.all(color: Colors.white, width: 3)
                          : null,
                    ),
                    child: Center(
                      child: Text(
                        '$stepNumber',
                        style: TextStyle(
                          color: isCompleted || isCurrent
                              ? Colors.white
                              : AppColors.grey,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    steps[index],
                    style: TextStyle(
                      fontSize: 10,
                      color: isCompleted || isCurrent
                          ? AppColors.primaryGreen
                          : AppColors.grey,
                      fontWeight: isCompleted || isCurrent
                          ? FontWeight.bold
                          : FontWeight.normal,
                    ),
                  ),
                ],
              );
            }),
          ),

          // Progress line
          Container(
            margin: const EdgeInsets.only(top: 18),
            height: 3,
            child: Row(
              children: List.generate(5, (index) {
                final isActive = (index + 1) < currentStep;
                return Expanded(
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 2),
                    height: 3,
                    decoration: BoxDecoration(
                      color: isActive
                          ? AppColors.primaryGreen
                          : AppColors.lightGrey,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _scannerController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final votingProvider = context.watch<VotingProvider>();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Verifikasi KTM'),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: AppColors.darkGreen,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () {
            if (_isProcessing) return;
            Navigator.pop(context);
          },
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Progress stepper
            _buildProgressStepper(2),

            // Title and instructions
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Column(
                children: [
                  Text(
                    'Scan QR Code KTM Anda',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: AppColors.darkGreen,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Verifikasi fisik KTM untuk memastikan keabsahan identitas Anda',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.grey,
                    ),
                  ),
                ],
              ),
            ),

            // Error message from provider
            if (votingProvider.errorMessage != null && !_isProcessing)
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.error.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.error),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.error_outline,
                      color: AppColors.error,
                      size: 20,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        votingProvider.errorMessage!,
                        style: const TextStyle(
                          color: AppColors.error,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

            // Validation error from scanner
            if (_validationError != null && !_isProcessing)
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.error.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.error),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.qr_code_2_rounded,
                      color: AppColors.error,
                      size: 20,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        _validationError!,
                        style: const TextStyle(
                          color: AppColors.error,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

            // Scanner or Result area
            Expanded(
              child: SingleChildScrollView(
                child: _scannedData == null || _validationError != null
                    ? _buildScanner()
                    : _buildScanResult(),
              ),
            ),

            // Navigation buttons
            Container(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  // Manual input fallback (optional)
                  if (_scannedData == null)
                    TextButton(
                      onPressed: () {
                        // Optional: Implement manual NIM input
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Input NIM Manual'),
                            content: const Text(
                              'Jika QR code tidak dapat discan, '
                                  'silahkan input NIM manual dari KTM Anda.',
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text('Batal'),
                              ),
                              ElevatedButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                  // TODO: Implement manual NIM input
                                },
                                child: const Text('Input Manual'),
                              ),
                            ],
                          ),
                        );
                      },
                      child: Text(
                        'QR tidak terbaca? Input NIM manual',
                        style: TextStyle(
                          color: AppColors.primaryGreen,
                          fontSize: 14,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  const SizedBox(height: 16),

                  // Action buttons
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: _isProcessing
                              ? null
                              : () {
                            if (_scannedData != null) {
                              _retryScan();
                            } else {
                              Navigator.pop(context);
                            }
                          },
                          style: OutlinedButton.styleFrom(
                            minimumSize: const Size(0, 50),
                            side: const BorderSide(color: AppColors.grey),
                            foregroundColor: AppColors.grey,
                          ),
                          child: Text(
                            _scannedData != null ? 'Scan Ulang' : 'Kembali',
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: PrimaryButton(
                          onPressed: votingProvider.isKtmVerified
                              ? () {
                            Navigator.pushNamed(context, '/voting-agreement');
                          }
                              : null,
                          text: 'Lanjutkan',
                          isLoading: votingProvider.isLoading || _isProcessing,
                        ),
                      ),
                    ],
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