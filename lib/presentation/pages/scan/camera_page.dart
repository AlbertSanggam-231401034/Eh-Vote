// lib/presentation/pages/scan/camera_page.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:google_fonts/google_fonts.dart';

class CameraPage extends StatefulWidget {
  final String title;
  final String description;
  final bool isFaceScan;

  const CameraPage({
    super.key,
    required this.title,
    required this.description,
    this.isFaceScan = false,
  });

  @override
  State<CameraPage> createState() => _CameraPageState();
}

class _CameraPageState extends State<CameraPage> {
  CameraController? _controller;
  Future<void>? _initializeControllerFuture; // JANGAN PAKAI late
  bool _isFrontCamera = true;
  bool _hasError = false;
  String _errorMessage = '';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    try {
      setState(() {
        _isLoading = true;
        _hasError = false;
      });

      final cameras = await availableCameras();

      if (cameras.isEmpty) {
        setState(() {
          _hasError = true;
          _errorMessage = 'Tidak ada kamera yang tersedia';
          _isLoading = false;
        });
        return;
      }

      // Untuk face scan, default pakai front camera
      CameraDescription selectedCamera;
      if (widget.isFaceScan) {
        selectedCamera = cameras.firstWhere(
              (camera) => camera.lensDirection == CameraLensDirection.front,
          orElse: () => cameras.first,
        );
      } else {
        // Untuk KTM, pakai back camera
        selectedCamera = cameras.firstWhere(
              (camera) => camera.lensDirection == CameraLensDirection.back,
          orElse: () => cameras.first,
        );
      }

      _controller = CameraController(
        selectedCamera,
        ResolutionPreset.medium,
        enableAudio: false, // Nonaktifkan audio
      );

      // Inisialisasi future
      _initializeControllerFuture = _controller!.initialize();

      // Tunggu inisialisasi selesai
      await _initializeControllerFuture;

      setState(() {
        _isLoading = false;
      });

    } catch (e) {
      print('❌ Camera initialization error: $e');
      setState(() {
        _hasError = true;
        _errorMessage = 'Gagal menginisialisasi kamera: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  Future<void> _takePicture() async {
    try {
      if (_controller == null || !_controller!.value.isInitialized) {
        throw Exception('Kamera belum siap');
      }

      // Pastikan future sudah selesai
      if (_initializeControllerFuture != null) {
        await _initializeControllerFuture;
      }

      final XFile image = await _controller!.takePicture();

      if (!mounted) return;

      Navigator.pop(context, File(image.path));
    } catch (e) {
      print('❌ Error taking picture: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error mengambil foto: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _switchCamera() async {
    try {
      setState(() {
        _isLoading = true;
      });

      final cameras = await availableCameras();
      if (cameras.length < 2) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Hanya ada 1 kamera yang tersedia'),
              backgroundColor: Colors.orange,
            ),
          );
        }
        setState(() {
          _isLoading = false;
        });
        return;
      }

      // Dispose controller lama
      await _controller?.dispose();

      setState(() {
        _isFrontCamera = !_isFrontCamera;
      });

      final newCamera = _isFrontCamera
          ? cameras.firstWhere(
            (camera) => camera.lensDirection == CameraLensDirection.front,
        orElse: () => cameras.first,
      )
          : cameras.firstWhere(
            (camera) => camera.lensDirection == CameraLensDirection.back,
        orElse: () => cameras.first,
      );

      _controller = CameraController(
        newCamera,
        ResolutionPreset.medium,
        enableAudio: false,
      );

      _initializeControllerFuture = _controller!.initialize();
      await _initializeControllerFuture;

      setState(() {
        _isLoading = false;
      });

    } catch (e) {
      print('❌ Error switching camera: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error mengganti kamera: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _retryInitialize() {
    _initializeCamera();
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const Color kPrimaryGreen = Color(0xFF00C64F);
    const Color kDarkGreen = Color(0xFF002D12);

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [kPrimaryGreen, kDarkGreen],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close, color: Colors.white, size: 28),
                  ),
                  Expanded(
                    child: Column(
                      children: [
                        Text(
                          widget.title,
                          style: GoogleFonts.unbounded(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          widget.description,
                          style: GoogleFonts.almarai(
                            color: Colors.white.withOpacity(0.9),
                            fontSize: 12,
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 2,
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: _isLoading ? null : _switchCamera,
                    icon: const Icon(Icons.cameraswitch_rounded,
                        color: Colors.white, size: 28),
                  ),
                ],
              ),
            ),

            // Main Content Area
            Expanded(
              child: _isLoading
                  ? const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF00C64F)),
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Menyiapkan kamera...',
                      style: TextStyle(color: Colors.white),
                    ),
                  ],
                ),
              )
                  : _hasError
                  ? _buildErrorWidget()
                  : _buildCameraPreview(),
            ),

            // Capture Button
            if (!_hasError && !_isLoading)
              Container(
                padding: const EdgeInsets.all(32),
                color: Colors.black,
                child: Center(
                  child: FloatingActionButton(
                    onPressed: _takePicture,
                    backgroundColor: const Color(0xFF00C64F),
                    child: const Icon(Icons.camera_alt_rounded,
                        color: Colors.white, size: 30),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorWidget() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline_rounded,
                size: 60, color: Colors.white),
            const SizedBox(height: 16),
            Text(
              _errorMessage,
              style: GoogleFonts.almarai(
                color: Colors.white,
                fontSize: 16,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey,
                    foregroundColor: Colors.white,
                  ),
                  child: Text(
                    'KEMBALI',
                    style: GoogleFonts.almarai(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                ElevatedButton(
                  onPressed: _retryInitialize,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00C64F),
                    foregroundColor: Colors.white,
                  ),
                  child: Text(
                    'COBA LAGI',
                    style: GoogleFonts.almarai(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCameraPreview() {
    return FutureBuilder<void>(
      future: _initializeControllerFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          if (_controller != null && _controller!.value.isInitialized) {
            return Stack(
              children: [
                CameraPreview(_controller!),

                // Overlay untuk face scan (lingkaran)
                if (widget.isFaceScan)
                  Center(
                    child: Container(
                      width: 200,
                      height: 200,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white.withOpacity(0.6),
                          width: 2,
                        ),
                      ),
                    ),
                  ),

                // Overlay untuk KTM scan (persegi panjang)
                if (!widget.isFaceScan)
                  Center(
                    child: Container(
                      width: 280,
                      height: 180,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.6),
                          width: 2,
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          // Corner indicators
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              // Top left corner
                              _buildCornerIndicator(true, true),
                              // Top right corner
                              _buildCornerIndicator(true, false),
                            ],
                          ),
                          const Spacer(),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              // Bottom left corner
                              _buildCornerIndicator(false, true),
                              // Bottom right corner
                              _buildCornerIndicator(false, false),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                // Instructions text
                Positioned(
                  bottom: 100,
                  left: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    child: Text(
                      widget.isFaceScan
                          ? 'Pastikan wajah Anda berada dalam lingkaran'
                          : 'Pastikan KTM berada dalam kotak dan barcode terbaca jelas',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.almarai(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        shadows: [
                          Shadow(
                            color: Colors.black.withOpacity(0.8),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            );
          } else {
            return const Center(
              child: Text(
                'Kamera tidak tersedia',
                style: TextStyle(color: Colors.white),
              ),
            );
          }
        } else {
          return const Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF00C64F)),
            ),
          );
        }
      },
    );
  }

  Widget _buildCornerIndicator(bool isTop, bool isLeft) {
    return Container(
      width: 20,
      height: 20,
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: Colors.white.withOpacity(0.6),
            width: isTop ? 2 : 0,
          ),
          left: BorderSide(
            color: Colors.white.withOpacity(0.6),
            width: isLeft ? 2 : 0,
          ),
          right: BorderSide(
            color: Colors.white.withOpacity(0.6),
            width: !isLeft ? 2 : 0,
          ),
          bottom: BorderSide(
            color: Colors.white.withOpacity(0.6),
            width: !isTop ? 2 : 0,
          ),
        ),
      ),
    );
  }
}