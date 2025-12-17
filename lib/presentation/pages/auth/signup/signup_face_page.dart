import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:camera/camera.dart';

// --- CORRECT IMPORTS ---
import 'package:suara_kita/presentation/providers/signup_provider.dart';
import 'package:suara_kita/core/constants/colors.dart'; // Ensure this file exists
import 'package:suara_kita/presentation/widgets/common/primary_button.dart';

class SignupFacePage extends StatefulWidget {
  static const routeName = '/signup-face';

  const SignupFacePage({super.key}); // Use super.key for cleaner syntax

  @override
  State<SignupFacePage> createState() => _SignupFacePageState();
}

class _SignupFacePageState extends State<SignupFacePage> {
  late CameraController _cameraController;
  List<CameraDescription>? _cameras;
  bool _isCameraInitialized = false;
  bool _showCapturePreview = false;
  File? _capturedImage;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    try {
      _cameras = await availableCameras();

      // Safety check if cameras are available
      if (_cameras == null || _cameras!.isEmpty) {
        if (mounted) _showCameraError();
        return;
      }

      final frontCamera = _cameras!.firstWhere(
            (camera) => camera.lensDirection == CameraLensDirection.front,
        orElse: () => _cameras!.first, // Fallback to first camera if no front camera
      );

      _cameraController = CameraController(
        frontCamera,
        ResolutionPreset.medium,
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.jpeg,
      );

      await _cameraController.initialize();

      if (mounted) {
        setState(() {
          _isCameraInitialized = true;
        });
      }
    } catch (e) {
      print('Error initializing camera: $e');
      if (mounted) {
        _showCameraError();
      }
    }
  }

  void _showCameraError() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Kamera Tidak Tersedia'),
        content: const Text(
          'Tidak dapat mengakses kamera depan. '
              'Silakan gunakan opsi upload dari galeri atau berikan izin kamera.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Future<void> _captureFace() async {
    if (!_isCameraInitialized) return;

    try {
      final image = await _cameraController.takePicture();
      final imageFile = File(image.path);

      if (mounted) {
        setState(() {
          _showCapturePreview = true;
          _capturedImage = imageFile;
        });
      }
    } catch (e) {
      print('Error capturing image: $e');
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

  Future<void> _processCapturedFace() async {
    if (_capturedImage == null) return;

    // Use read instead of watch for actions inside methods
    final provider = context.read<SignupProvider>();

    try {
      await provider.captureFaceFromCamera();

      if (provider.faceEmbedding != null && mounted) {
        // Success - navigate to next step
        Navigator.pushNamed(context, '/signup-ktm');
      }
    } catch (e) {
      // Error already handled in provider, reset preview to try again
      if (mounted) {
        setState(() {
          _showCapturePreview = false;
          _capturedImage = null;
        });
      }
    }
  }

  Future<void> _uploadFromGallery() async {
    final provider = context.read<SignupProvider>();

    try {
      await provider.uploadFaceFromGallery();

      if (provider.faceEmbedding != null && mounted) {
        Navigator.pushNamed(context, '/signup-ktm');
      }
    } catch (e) {
      // Error handled in provider (UI updates via Consumer/Watch)
    }
  }

  void _retryCapture() {
    setState(() {
      _showCapturePreview = false;
      _capturedImage = null;
    });
  }

  // --- WIDGET BUILDERS ---

  Widget _buildCameraPreview() {
    if (!_isCameraInitialized) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primaryGreen),
      );
    }

    return Stack(
      children: [
        // 1. Camera Feed
        SizedBox(
          width: double.infinity,
          height: double.infinity,
          child: CameraPreview(_cameraController),
        ),

        // 2. Face Detection Overlay (Guidelines)
        Center(
          child: Container(
            width: 280,
            height: 350,
            decoration: BoxDecoration(
              border: Border.all(
                color: Colors.white.withOpacity(0.8),
                width: 3,
              ),
              borderRadius: BorderRadius.circular(150), // Oval shape for face
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.face_retouching_natural_rounded,
                  color: Colors.white.withOpacity(0.7),
                  size: 80,
                ),
                const SizedBox(height: 16),
                Text(
                  'Posisikan Wajah\ndi Area Ini',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    shadows: const [
                      Shadow(
                        blurRadius: 4,
                        color: Colors.black,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),

        // 3. Capture Button
        Positioned(
          bottom: 30,
          left: 0,
          right: 0,
          child: Center(
            child: GestureDetector(
              onTap: _captureFace,
              child: Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  color: AppColors.white,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.primaryGreen,
                    width: 4,
                  ),
                ),
                child: const Icon(
                  Icons.camera_alt_rounded,
                  size: 30,
                  color: AppColors.primaryGreen,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCapturePreview() {
    if (_capturedImage == null) return Container();

    return Stack(
      children: [
        Image.file(
          _capturedImage!,
          fit: BoxFit.cover,
          width: double.infinity,
          height: double.infinity,
        ),

        // Overlay Action Buttons
        Positioned(
          bottom: 30,
          left: 20,
          right: 20,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // Tombol Ulangi
              ElevatedButton.icon(
                onPressed: _retryCapture,
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('Ulangi'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.white,
                  foregroundColor: AppColors.error,
                  elevation: 4,
                ),
              ),

              // Tombol Gunakan Foto
              ElevatedButton.icon(
                onPressed: _processCapturedFace,
                icon: const Icon(Icons.check_circle_rounded),
                label: const Text('Gunakan'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryGreen,
                  foregroundColor: AppColors.white,
                  elevation: 4,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    // Dispose controller only if initialized
    if (_isCameraInitialized) {
      _cameraController.dispose();
    }
    super.dispose();
  }

  Widget _buildStepIndicator(int step, String label, bool isActive) {
    return Column(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: isActive ? AppColors.primaryGreen : AppColors.lightGrey,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              '$step',
              style: TextStyle(
                color: isActive ? AppColors.white : AppColors.grey,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: isActive ? AppColors.primaryGreen : AppColors.grey,
            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    // Watch provider for UI updates (loading, errors)
    final provider = context.watch<SignupProvider>();

    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        title: const Text('Registrasi Wajah'),
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
            // 1. Step Indicator
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildStepIndicator(1, 'Data', true),
                  _buildStepIndicator(2, 'Pass', true),
                  _buildStepIndicator(3, 'Wajah', true), // Current Step
                  _buildStepIndicator(4, 'KTM', false),
                  _buildStepIndicator(5, 'Selesai', false),
                ],
              ),
            ),

            const SizedBox(height: 10),

            // 2. Title & Description
            Text(
              'Ambil Foto Wajah',
              style: Theme.of(context).textTheme.displaySmall,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 8),
              child: Text(
                'Pastikan wajah terlihat jelas, tanpa masker/kacamata, dan pencahayaan cukup.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.grey,
                ),
              ),
            ),

            // 3. Camera Viewport
            Expanded(
              child: Container(
                margin: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: _showCapturePreview
                      ? _buildCapturePreview()
                      : _buildCameraPreview(),
                ),
              ),
            ),

            // 4. Error Message (if any)
            if (provider.faceValidationError != null)
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.error.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.error_outline, color: AppColors.error),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        provider.faceValidationError!,
                        style: const TextStyle(color: AppColors.error, fontSize: 13),
                      ),
                    ),
                  ],
                ),
              ),

            // 5. Bottom Actions
            Container(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  // Upload from Gallery Button
                  OutlinedButton.icon(
                    // FIXED: Correctly reference the function, handling the Future<void> return type
                    onPressed: provider.isLoading ? null : _uploadFromGallery,
                    icon: const Icon(Icons.photo_library_rounded),
                    label: const Text('Upload dari Galeri'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primaryGreen,
                      side: const BorderSide(color: AppColors.primaryGreen),
                      minimumSize: const Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),

                  const SizedBox(height: 10),

                  // Loading Indicator (if needed)
                  if (provider.isLoading)
                    const Center(
                      child: CircularProgressIndicator(color: AppColors.primaryGreen),
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