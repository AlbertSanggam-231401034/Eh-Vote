import 'dart:io';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:camera/camera.dart';
import 'package:suara_kita/presentation/providers/voting_provider.dart';
import 'package:suara_kita/core/constants/colors.dart';

class VotingFaceVerifyPage extends StatefulWidget {
  static const routeName = '/voting-face-verify';

  const VotingFaceVerifyPage({super.key});

  @override
  State<VotingFaceVerifyPage> createState() => _VotingFaceVerifyPageState();
}

class _VotingFaceVerifyPageState extends State<VotingFaceVerifyPage> with WidgetsBindingObserver {
  CameraController? _cameraController;
  bool _isCameraInitialized = false;
  File? _capturedImage;
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializeCamera();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _cameraController?.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (_cameraController == null || !_cameraController!.value.isInitialized) return;
    if (state == AppLifecycleState.inactive) {
      _cameraController?.dispose();
    } else if (state == AppLifecycleState.resumed) {
      _initializeCamera();
    }
  }

  Future<void> _initializeCamera() async {
    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) return;

      final frontCamera = cameras.firstWhere(
            (camera) => camera.lensDirection == CameraLensDirection.front,
        orElse: () => cameras.first,
      );

      // Dispose controller lama biar bersih
      if (_cameraController != null) {
        await _cameraController!.dispose();
      }

      _cameraController = CameraController(
        frontCamera,
        ResolutionPreset.medium,
        enableAudio: false,
        imageFormatGroup: Platform.isAndroid ? ImageFormatGroup.yuv420 : ImageFormatGroup.bgra8888,
      );

      await _cameraController!.initialize();
      if (mounted) setState(() => _isCameraInitialized = true);
    } catch (e) {
      print('Camera Error: $e');
    }
  }

  Future<void> _captureFace() async {
    if (_cameraController == null || _isProcessing) return;

    try {
      setState(() => _isProcessing = true);

      // 1. Pause preview dulu biar buffer lega
      await _cameraController!.pausePreview();

      // 2. Jeda dikit
      await Future.delayed(const Duration(milliseconds: 200));

      // 3. Ambil gambar
      final XFile image = await _cameraController!.takePicture();

      if (mounted) {
        setState(() {
          _capturedImage = File(image.path);
          _isProcessing = false;
        });
      }
    } catch (e) {
      print("Capture Error: $e");
      if (mounted) {
        setState(() => _isProcessing = false);
        // Kalau error, resume lagi previewnya
        _cameraController?.resumePreview();
      }
    }
  }

  Future<void> _processCapturedFace() async {
    if (_capturedImage == null) return;
    final provider = context.read<VotingProvider>();

    try {
      setState(() => _isProcessing = true);

      // Kirim ke Provider (Logic ML)
      final isVerified = await provider.verifyFace(_capturedImage!);

      if (isVerified && mounted) {
        Navigator.pushNamed(context, '/voting-ktm-scan');
      } else if (mounted) {
        setState(() => _isProcessing = false);
        // Kalau gagal, kasih tau user
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Wajah tidak cocok. Coba lagi.'), backgroundColor: Colors.red),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isProcessing = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  void _retryCapture() {
    setState(() {
      _capturedImage = null;
      _isProcessing = false;
    });
    _cameraController?.resumePreview();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Verifikasi Wajah'),
        centerTitle: true,
        backgroundColor: Colors.white,
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
            // Progress Indicator (jika ada)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(6, (index) {
                  final step = index + 1;
                  final isActive = step <= 1; // Step 1 untuk verifikasi wajah

                  return Container(
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
                          color: isActive ? Colors.white : AppColors.grey,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ),

            Expanded(
              child: Container(
                margin: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: _capturedImage != null
                      ? Stack(
                    children: [
                      Image.file(_capturedImage!,
                        fit: BoxFit.cover,
                        width: double.infinity,
                        height: double.infinity,
                      ),
                      Container(
                        color: Colors.black.withOpacity(0.4),
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.face_rounded, size: 80, color: Colors.white),
                              const SizedBox(height: 16),
                              const Text(
                                'Foto Wajah Diambil',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Sedang memverifikasi identitas Anda...',
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.9),
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 24),
                              if (_isProcessing)
                                const CircularProgressIndicator(color: Colors.white),
                            ],
                          ),
                        ),
                      ),
                    ],
                  )
                      : (_isCameraInitialized && _cameraController != null
                      ? Stack(
                    children: [
                      CameraPreview(_cameraController!),
                      Center(
                        child: Container(
                          width: 280,
                          height: 380,
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: Colors.white.withOpacity(0.8),
                              width: 3,
                            ),
                            borderRadius: BorderRadius.circular(150),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.face_retouching_natural_rounded,
                                color: Colors.white.withOpacity(0.9),
                                size: 80,
                              ),
                              const SizedBox(height: 16),
                              const Text(
                                'Posisikan Wajah Anda\nDalam Area Oval',
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
                    ],
                  )
                      : const Center(child: CircularProgressIndicator(color: AppColors.primaryGreen))),
                ),
              ),
            ),

            // Control Panel - FIXED
            Container(
              padding: const EdgeInsets.all(24),
              child: _capturedImage != null
                  ? Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (!_isProcessing)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ConstrainedBox(
                          constraints: const BoxConstraints(
                            minWidth: 140,
                            maxWidth: 160,
                          ),
                          child: ElevatedButton(
                            onPressed: _retryCapture,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.grey[300],
                              foregroundColor: Colors.black,
                              minimumSize: const Size.fromHeight(50),
                            ),
                            child: const Text("Ulangi"),
                          ),
                        ),
                        const SizedBox(width: 20),
                        ConstrainedBox(
                          constraints: const BoxConstraints(
                            minWidth: 140,
                            maxWidth: 160,
                          ),
                          child: ElevatedButton(
                            onPressed: _isProcessing ? null : _processCapturedFace,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primaryGreen,
                              foregroundColor: Colors.white,
                              minimumSize: const Size.fromHeight(50),
                            ),
                            child: _isProcessing
                                ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                                : const Text("Verifikasi"),
                          ),
                        ),
                      ],
                    ),
                  if (_isProcessing)
                    const SizedBox(height: 20),
                  if (_isProcessing)
                    const Text(
                      'Sedang memverifikasi...',
                      style: TextStyle(color: AppColors.grey),
                    ),
                ],
              )
                  : Center(
                child: FloatingActionButton(
                  onPressed: _isProcessing ? null : _captureFace,
                  backgroundColor: AppColors.primaryGreen,
                  child: _isProcessing
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Icon(Icons.camera_alt),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}