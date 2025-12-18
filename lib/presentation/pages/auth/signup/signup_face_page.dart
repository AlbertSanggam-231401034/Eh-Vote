import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:camera/camera.dart';
import 'package:suara_kita/presentation/providers/signup_provider.dart';
import 'package:suara_kita/core/constants/colors.dart';

class SignupFacePage extends StatefulWidget {
  static const routeName = '/signup-face';
  const SignupFacePage({super.key});

  @override
  State<SignupFacePage> createState() => _SignupFacePageState();
}

class _SignupFacePageState extends State<SignupFacePage> {
  late CameraController _cameraController;
  bool _isCameraInitialized = false;
  bool _showCapturePreview = false;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) return;

      final front = cameras.firstWhere(
            (c) => c.lensDirection == CameraLensDirection.front,
        orElse: () => cameras.first,
      );

      _cameraController = CameraController(front, ResolutionPreset.medium, enableAudio: false);
      await _cameraController.initialize();
      if (mounted) setState(() => _isCameraInitialized = true);
    } catch (e) {
      debugPrint("Camera Error: $e");
    }
  }

  Future<void> _processCapturedFace() async {
    final provider = context.read<SignupProvider>();
    try {
      // Fungsi ini sekarang sudah ada di Provider yang baru di atas
      await provider.captureFaceFromCamera();

      if (provider.faceEmbedding != null && mounted) {
        Navigator.pushNamed(context, '/signup-ktm');
      }
    } catch (e) {
      if (mounted) {
        setState(() => _showCapturePreview = false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
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
      debugPrint("Gallery Error: $e");
    }
  }

  @override
  void dispose() {
    if (_isCameraInitialized) _cameraController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<SignupProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text("Registrasi Wajah")),
      body: Column(
        children: [
          Expanded(
            child: _isCameraInitialized
                ? CameraPreview(_cameraController)
                : const Center(child: CircularProgressIndicator()),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                if (provider.isLoading)
                  const CircularProgressIndicator()
                else ...[
                  ElevatedButton(
                      onPressed: _processCapturedFace,
                      child: const Text("AMBIL FOTO WAJAH")
                  ),
                  TextButton(
                      onPressed: _uploadFromGallery,
                      child: const Text("Upload dari Galeri")
                  ),
                ],
                if (provider.faceValidationError != null)
                  Text(provider.faceValidationError!, style: const TextStyle(color: Colors.red)),
              ],
            ),
          )
        ],
      ),
    );
  }
}