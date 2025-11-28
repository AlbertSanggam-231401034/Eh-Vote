import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:suara_kita/services/firebase_service.dart';
import 'package:suara_kita/data/models/user_model.dart';

class AdminLoginPage extends StatefulWidget {
  const AdminLoginPage({super.key});

  @override
  State<AdminLoginPage> createState() => _AdminLoginPageState();
}

class _AdminLoginPageState extends State<AdminLoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _nimController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isPasswordVisible = false;
  bool _isLoading = false;

  void _login() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        // Verifikasi login dengan Firebase
        final user = await FirebaseService.verifyLogin(
          _nimController.text.trim(),
          _passwordController.text,
        );

        setState(() {
          _isLoading = false;
        });

        if (user != null) {
          // Login berhasil
          _handleSuccessfulLogin(user, context);
        } else {
          // Login gagal
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('NIM atau password salah'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } catch (e) {
        setState(() {
          _isLoading = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _handleSuccessfulLogin(User user, BuildContext context) {
    // Tampilkan dialog sukses
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: Text(
          'Login Berhasil',
          textAlign: TextAlign.center,
          style: GoogleFonts.almarai(
            fontWeight: FontWeight.bold,
            color: const Color(0xFF002D12),
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Selamat datang, ${user.fullName}!',
                style: GoogleFonts.almarai()),
            const SizedBox(height: 8),
            Text(
              'Role: ${_getRoleDisplayName(user.role)}',
              style: GoogleFonts.almarai(
                fontWeight: FontWeight.bold,
                color: const Color(0xFF00C64F),
              ),
            ),
          ],
        ),
        actions: [
          Center(
            child: SizedBox(
              width: 120,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  _navigateToAdminDashboard(user, context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00C64F),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text(
                  'LANJUT',
                  style: GoogleFonts.almarai(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _navigateToAdminDashboard(User user, BuildContext context) {
    // ✅ PERBAIKAN: Kirim user data sebagai arguments
    Navigator.pushReplacementNamed(
      context,
      '/admin-dashboard',
      arguments: user,
    );
  }

  String _getRoleDisplayName(UserRole role) {
    switch (role) {
      case UserRole.admin:
        return 'Admin';
      case UserRole.superAdmin:
        return 'Super Admin';
      case UserRole.voter:
        return 'Pemilih';
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
          child: Stack(
            children: [
              // Tombol back di kiri atas
              Positioned(
                top: 10,
                left: 20,
                child: IconButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  icon: const Icon(
                    Icons.arrow_back_rounded,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
              ),
              // Konten utama
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Spacer(flex: 2),
                    // Icon admin
                    const Icon(
                      Icons.admin_panel_settings_rounded,
                      size: 80,
                      color: Colors.white,
                    ),
                    const SizedBox(height: 24),
                    // Judul
                    Text(
                      'Admin Login',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.unbounded(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Subjudul
                    Text(
                      'Masuk sebagai administrator',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.almarai(
                        fontSize: 16,
                        color: Colors.white.withOpacity(0.9),
                      ),
                    ),
                    const Spacer(flex: 1),
                    // Form login
                    Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          // Input NIM
                          TextFormField(
                            controller: _nimController,
                            decoration: InputDecoration(
                              labelText: 'NIM Admin',
                              labelStyle: GoogleFonts.almarai(
                                color: Colors.white.withOpacity(0.8),
                              ),
                              prefixIcon: const Icon(
                                Icons.badge_rounded,
                                color: Colors.white,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: const BorderSide(color: Colors.white),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide(color: Colors.white.withOpacity(0.5)),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: const BorderSide(color: Colors.white),
                              ),
                            ),
                            style: GoogleFonts.almarai(color: Colors.white),
                            keyboardType: TextInputType.number,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Harap masukkan NIM';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          // Input Password
                          TextFormField(
                            controller: _passwordController,
                            obscureText: !_isPasswordVisible,
                            decoration: InputDecoration(
                              labelText: 'Password',
                              labelStyle: GoogleFonts.almarai(
                                color: Colors.white.withOpacity(0.8),
                              ),
                              prefixIcon: const Icon(
                                Icons.lock_rounded,
                                color: Colors.white,
                              ),
                              suffixIcon: IconButton(
                                onPressed: () {
                                  setState(() {
                                    _isPasswordVisible = !_isPasswordVisible;
                                  });
                                },
                                icon: Icon(
                                  _isPasswordVisible ? Icons.visibility_rounded : Icons.visibility_off_rounded,
                                  color: Colors.white,
                                ),
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: const BorderSide(color: Colors.white),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide(color: Colors.white.withOpacity(0.5)),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: const BorderSide(color: Colors.white),
                              ),
                            ),
                            style: GoogleFonts.almarai(color: Colors.white),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Harap masukkan password';
                              }
                              if (value.length < 6) {
                                return 'Password minimal 6 karakter';
                              }
                              return null;
                            },
                          ),
                        ],
                      ),
                    ),
                    const Spacer(flex: 2),
                    // Tombol Login
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _login,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: kPrimaryGreen,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: _isLoading
                            ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation(Color(0xFF00C64F)),
                          ),
                        )
                            : Text(
                          'LOGIN ADMIN',
                          style: GoogleFonts.almarai(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const Spacer(flex: 3),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}