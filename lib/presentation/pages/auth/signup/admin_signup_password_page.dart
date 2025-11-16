import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AdminSignupPasswordPage extends StatefulWidget {
  final Map<String, dynamic> userData;

  const AdminSignupPasswordPage({super.key, required this.userData});

  @override
  State<AdminSignupPasswordPage> createState() => _AdminSignupPasswordPageState();
}

class _AdminSignupPasswordPageState extends State<AdminSignupPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;

  void _nextStep() {
    if (_formKey.currentState!.validate()) {
      // Validasi konfirmasi password
      if (_passwordController.text != _confirmPasswordController.text) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Password dan konfirmasi password tidak sama')),
        );
        return;
      }

      // Navigasi ke step 3 dengan membawa data dari step 1 + password
      Navigator.pushNamed(
        context,
        '/admin-signup-face',
        arguments: {
          ...widget.userData,
          'password': _passwordController.text,
        },
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
          child: Stack(
            children: [
              // Header dengan progress indicator
              Positioned(
                top: 10,
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
                        value: 0.5, // Step 2 dari 4
                        backgroundColor: Colors.white.withOpacity(0.3),
                        valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    ),
                    const SizedBox(width: 48),
                  ],
                ),
              ),
              // Konten utama
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32.0),
                child: SingleChildScrollView(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: MediaQuery.of(context).size.height - kToolbarHeight,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const SizedBox(height: 80),
                        // Judul
                        Text(
                          'Buat Password',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.unbounded(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Step 2 of 4 - Buat password untuk akun Anda',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.almarai(
                            fontSize: 14,
                            color: Colors.white.withOpacity(0.8),
                          ),
                        ),
                        const SizedBox(height: 32),
                        // Form
                        Form(
                          key: _formKey,
                          child: Column(
                            children: [
                              // Password
                              TextFormField(
                                controller: _passwordController,
                                obscureText: !_isPasswordVisible,
                                style: GoogleFonts.almarai(color: Colors.white),
                                decoration: InputDecoration(
                                  labelText: 'Password',
                                  labelStyle: GoogleFonts.almarai(color: Colors.white.withOpacity(0.8)),
                                  prefixIcon: const Icon(Icons.lock_rounded, color: Colors.white),
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
                              const SizedBox(height: 16),
                              // Konfirmasi Password
                              TextFormField(
                                controller: _confirmPasswordController,
                                obscureText: !_isConfirmPasswordVisible,
                                style: GoogleFonts.almarai(color: Colors.white),
                                decoration: InputDecoration(
                                  labelText: 'Konfirmasi Password',
                                  labelStyle: GoogleFonts.almarai(color: Colors.white.withOpacity(0.8)),
                                  prefixIcon: const Icon(Icons.lock_outline_rounded, color: Colors.white),
                                  suffixIcon: IconButton(
                                    onPressed: () {
                                      setState(() {
                                        _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
                                      });
                                    },
                                    icon: Icon(
                                      _isConfirmPasswordVisible ? Icons.visibility_rounded : Icons.visibility_off_rounded,
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
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Harap konfirmasi password';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 24),
                              // Informasi keamanan password
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: Colors.white.withOpacity(0.3)),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(Icons.info_rounded, color: Colors.white, size: 16),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        'Gunakan password yang kuat dan mudah diingat',
                                        style: GoogleFonts.almarai(
                                          color: Colors.white,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 32),
                        // Tombol lanjut
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            onPressed: _nextStep,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: kPrimaryGreen,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: Text(
                              'LANJUT',
                              style: GoogleFonts.almarai(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}