import 'package:flutter/material.dart';
import 'dart:async';
import 'package:google_fonts/google_fonts.dart';
import 'package:suara_kita/utils/firebase_test.dart';
import 'package:suara_kita/services/firebase_service.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  String _loadingStatus = 'Menginisialisasi aplikasi...';
  double _progressValue = 0.0;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _initializeApp();
  }

  void _initializeAnimations() {
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.elasticOut),
    );

    _controller.forward();
  }

  void _initializeApp() async {
    try {
      _updateStatus('Memeriksa koneksi...', 0.2);
      await Future.delayed(const Duration(milliseconds: 500));

      // Test Firebase connection
      _updateStatus('Menghubungkan ke Firebase...', 0.4);
      await FirebaseTest.testConnection();

      // Check if user is already logged in
      _updateStatus('Memeriksa status login...', 0.6);
      await Future.delayed(const Duration(milliseconds: 500));

      final currentUser = FirebaseService.currentUser;
      final bool isUserLoggedIn = currentUser != null;

      _updateStatus('Menyiapkan antarmuka...', 0.8);
      await Future.delayed(const Duration(milliseconds: 500));

      _updateStatus('Selesai!', 1.0);
      await Future.delayed(const Duration(milliseconds: 500));

      if (mounted) {
        _navigateToNextScreen(isUserLoggedIn);
      }
    } catch (e) {
      print('❌ App initialization failed: $e');
      _updateStatus('Terjadi kesalahan, melanjutkan...', 1.0);

      // Tetap lanjut ke welcome page meskipun ada error
      if (mounted) {
        await Future.delayed(const Duration(milliseconds: 1000));
        Navigator.pushReplacementNamed(context, '/welcome');
      }
    }
  }

  void _updateStatus(String status, double progress) {
    if (mounted) {
      setState(() {
        _loadingStatus = status;
        _progressValue = progress;
      });
    }
  }

  void _navigateToNextScreen(bool isUserLoggedIn) {
    // TODO: Add logic to navigate based on user authentication status
    // For now, always go to welcome page
    Navigator.pushReplacementNamed(context, '/welcome');

    // Future implementation:
    // if (isUserLoggedIn) {
    //   // Check user role and navigate accordingly
    //   Navigator.pushReplacementNamed(context, '/home');
    // } else {
    //   Navigator.pushReplacementNamed(context, '/welcome');
    // }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
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
        child: Center(
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return Opacity(
                opacity: _fadeAnimation.value,
                child: Transform.scale(
                  scale: _scaleAnimation.value,
                  child: child,
                ),
              );
            },
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // App Icon
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.9),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.how_to_vote,
                    size: 60,
                    color: kPrimaryGreen,
                  ),
                ),

                const SizedBox(height: 30),

                // App Name
                Text(
                  'Suara Kita',
                  style: GoogleFonts.unbounded(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 1.2,
                  ),
                ),

                const SizedBox(height: 8),

                // App Tagline
                Text(
                  'E-Voting USU',
                  style: GoogleFonts.almarai(
                    fontSize: 16,
                    color: Colors.white70,
                    letterSpacing: 1.0,
                  ),
                ),

                const SizedBox(height: 40),

                // Progress Bar
                Container(
                  width: 200,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                  child: FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor: _progressValue,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // Loading Status
                Text(
                  _loadingStatus,
                  style: GoogleFonts.almarai(
                    fontSize: 14,
                    color: Colors.white60,
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 30),

                // Animated Loading Indicator
                SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Colors.white.withOpacity(0.8),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}