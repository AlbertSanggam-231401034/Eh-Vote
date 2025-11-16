import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:suara_kita/services/firebase_service.dart';
import 'package:suara_kita/data/models/user_model.dart';

class AdminLoginPage extends StatelessWidget {
  const AdminLoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Warna yang sama dengan halaman lainnya
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
                      'Masuk sebagai administrator sistem',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.almarai(
                        fontSize: 16,
                        color: Colors.white.withOpacity(0.9),
                      ),
                    ),
                    const Spacer(flex: 1),
                    // Form login admin
                    _AdminLoginForm(),
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

class _AdminLoginForm extends StatefulWidget {
  @override
  State<_AdminLoginForm> createState() => __AdminLoginFormState();
}

class __AdminLoginFormState extends State<_AdminLoginForm> {
  final _formKey = GlobalKey<FormState>();
  final _adminIdController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isPasswordVisible = false;
  bool _isLoading = false;

  void _adminLogin() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        // Verifikasi login dengan Firebase
        final user = await FirebaseService.verifyLogin(
          _adminIdController.text.trim(),
          _passwordController.text,
        );

        setState(() {
          _isLoading = false;
        });

        if (user != null && (user.role == UserRole.admin || user.role == UserRole.superAdmin)) {
          // Login berhasil dan user adalah admin
          _handleSuccessfulAdminLogin(user, context);
        } else {
          // Login gagal atau user bukan admin
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Admin ID atau password salah, atau akun bukan admin'),
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

  void _handleSuccessfulAdminLogin(User user, BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: Text(
          'Admin Login Berhasil',
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
            const SizedBox(height: 8),
            Text(
              'NIM: ${user.nim}',
              style: GoogleFonts.almarai(fontSize: 12),
            ),
          ],
        ),
        actions: [
          Center(
            child: SizedBox(
              width: 160,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pushReplacementNamed(context, '/admin-dashboard');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00C64F),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text(
                  'MASUK DASHBOARD',
                  style: GoogleFonts.almarai(
                    fontSize: 14,
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
    return Form(
      key: _formKey,
      child: Column(
        children: [
          // Input Admin ID (sebenarnya adalah NIM)
          TextFormField(
            controller: _adminIdController,
            decoration: InputDecoration(
              labelText: 'Admin ID (NIM)',
              labelStyle: GoogleFonts.almarai(
                color: Colors.white.withOpacity(0.8),
              ),
              prefixIcon: const Icon(
                Icons.admin_panel_settings_rounded,
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
                return 'Harap masukkan Admin ID (NIM)';
              }
              if (!RegExp(r'^[0-9]+$').hasMatch(value)) {
                return 'Admin ID harus berupa angka (NIM)';
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
          const SizedBox(height: 24),
          // Tombol Login Admin
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _adminLogin,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: const Color(0xFF00C64F),
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
                'LOGIN AS ADMIN',
                style: GoogleFonts.almarai(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Informasi tambahan
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.white.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.info_rounded,
                  color: Colors.white,
                  size: 16,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Hanya untuk administrator sistem yang terdaftar',
                    style: GoogleFonts.almarai(
                      color: Colors.white,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Link registrasi admin baru
          const SizedBox(height: 16),
          TextButton(
            onPressed: () {
              Navigator.pushNamed(context, '/admin-registration');
            },
            child: Text(
              'Registrasi Admin Baru',
              style: GoogleFonts.almarai(
                color: Colors.white,
                fontSize: 14,
                decoration: TextDecoration.underline,
              ),
            ),
          ),
        ],
      ),
    );
  }
}