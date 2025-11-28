// lib/main.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:suara_kita/core/theme/app_theme.dart';
import 'package:suara_kita/presentation/pages/splash/splash_page.dart';
import 'package:suara_kita/presentation/pages/auth/welcome_page.dart';
import 'package:suara_kita/presentation/pages/auth/login_page.dart';
import 'package:suara_kita/presentation/pages/auth/admin_login_page.dart';
import 'package:suara_kita/presentation/pages/auth/signup/user_signup_data_page.dart';
import 'package:suara_kita/presentation/pages/auth/signup/user_signup_password_page.dart';
import 'package:suara_kita/presentation/pages/scan/face_scan_page.dart';
import 'package:suara_kita/presentation/pages/scan/ktm_scan_page.dart';
import 'package:suara_kita/presentation/pages/admin/admin_dashboard.dart';
import 'package:suara_kita/presentation/pages/admin/admin_scan_flow.dart';
import 'package:suara_kita/utils/admin_setup.dart';
import 'package:suara_kita/services/supabase_storage_service.dart';
import 'package:suara_kita/services/firebase_service.dart';
import 'package:suara_kita/data/models/user_model.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // Initialize Firebase
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    print('✅ Firebase initialized successfully');

    // Initialize Supabase
    await SupabaseStorageService.initialize();
    print('✅ Supabase initialized successfully');

    // Setup predefined admins
    await AdminSetup.setupAdmins();

  } catch (e) {
    print('❌ Error initializing services: $e');
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Suara Kita - E-Voting USU',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.light,
      debugShowCheckedModeBanner: false,
      initialRoute: '/splash',

      routes: {
        '/splash': (context) => const SplashPage(),
        '/welcome': (context) => const WelcomePage(),
        '/login': (context) => const LoginPage(),
        '/admin-login': (context) => const AdminLoginPage(),
        '/signup': (context) => const UserSignupDataPage(),
        '/home': (context) => const PlaceholderPage(title: 'Home Page'),
        '/admin-dashboard': (context) => const PlaceholderPage(title: 'Admin Dashboard'), // Temporary fallback
      },

      onGenerateRoute: (settings) {
        switch (settings.name) {
          case '/user-signup-password':
            final args = settings.arguments as Map<String, dynamic>;
            return MaterialPageRoute(
              builder: (context) => UserSignupPasswordPage(userData: args),
            );
          case '/user-signup-face':
            final args = settings.arguments as Map<String, dynamic>;
            return MaterialPageRoute(
              builder: (context) => FaceScanPage(
                nim: args['nim'],
                onFaceScanned: (imageUrl) {
                  print('Face image URL: $imageUrl');
                  Navigator.pushNamed(
                      context,
                      '/user-signup-ktm',
                      arguments: {...args, 'faceImageUrl': imageUrl}
                  );
                },
              ),
            );
          case '/user-signup-ktm':
            final args = settings.arguments as Map<String, dynamic>;
            return MaterialPageRoute(
              builder: (context) => KtmScanPage(
                nim: args['nim'],
                onKtmScanned: (imageUrl, barcodeData) async {
                  print('KTM image URL: $imageUrl');
                  print('Barcode data: $barcodeData');

                  try {
                    // BUAT USER OBJECT DENGAN SEMUA DATA
                    final User newUser = User(
                      nim: args['nim'],
                      password: args['password'],
                      fullName: args['fullName'],
                      placeOfBirth: args['placeOfBirth'],
                      dateOfBirth: args['dateOfBirth'],
                      phoneNumber: args['phoneNumber'],
                      faculty: args['faculty'],
                      major: args['major'],
                      gender: args['gender'],
                      ktmData: barcodeData,
                      faceData: 'face_embedding_${args['nim']}',
                      role: UserRole.voter,
                      hasVoted: false,
                      createdAt: DateTime.now(),
                      faceImageUrl: args['faceImageUrl'],
                      ktmImageUrl: imageUrl,
                    );

                    // SIMPAN KE FIREBASE
                    await FirebaseService.saveUser(newUser);

                    // Tampilkan success dialog
                    await showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        backgroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                        title: Text(
                          'Registrasi Berhasil!',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.almarai(
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF002D12),
                          ),
                        ),
                        content: Text(
                          'Akun Anda berhasil dibuat. Silakan login untuk melanjutkan.',
                          style: GoogleFonts.almarai(),
                          textAlign: TextAlign.center,
                        ),
                        actions: [
                          Center(
                            child: SizedBox(
                              width: 120,
                              child: ElevatedButton(
                                onPressed: () {
                                  Navigator.pushReplacementNamed(context, '/welcome');
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF00C64F),
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                child: Text(
                                  'OK',
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

                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Error menyimpan data: $e'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                },
              ),
            );
          case '/admin-dashboard':
            final args = settings.arguments as User?;
            if (args == null) {
              // Fallback ke welcome page jika tidak ada user data
              return MaterialPageRoute(builder: (context) => const WelcomePage());
            }
            return MaterialPageRoute(
              builder: (context) => AdminDashboard(currentUser: args),
            );
          case '/admin-scan-flow':
            final args = settings.arguments as Map<String, dynamic>;
            return MaterialPageRoute(
              builder: (context) => AdminScanFlow(adminNim: args['adminNim']),
            );
          default:
            return MaterialPageRoute(builder: (context) => const SplashPage());
        }
      },
    );
  }
}

// Temporary placeholder page (tetap sama)
class PlaceholderPage extends StatelessWidget {
  final String title;

  const PlaceholderPage({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        backgroundColor: const Color(0xFF00C64F),
        foregroundColor: Colors.white,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF00C64F), Color(0xFF002D12)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                title,
                style: GoogleFonts.unbounded(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Halaman dalam pengembangan',
                style: GoogleFonts.almarai(
                  fontSize: 16,
                  color: Colors.white.withOpacity(0.8),
                ),
              ),
              const SizedBox(height: 30),
              SizedBox(
                width: 200,
                child: ElevatedButton(
                  onPressed: () => Navigator.pushReplacementNamed(context, '/welcome'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: const Color(0xFF00C64F),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 15),
                  ),
                  child: Text(
                    'KEMBALI',
                    style: GoogleFonts.almarai(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
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