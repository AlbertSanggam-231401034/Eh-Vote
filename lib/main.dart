import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:suara_kita/core/theme/app_theme.dart';
import 'package:suara_kita/presentation/pages/splash/splash_page.dart';
import 'package:suara_kita/presentation/pages/auth/welcome_page.dart';
import 'package:suara_kita/presentation/pages/auth/login_page.dart';
import 'package:suara_kita/presentation/pages/auth/signup/signup_data_page.dart';
import 'package:suara_kita/presentation/pages/auth/signup/admin_signup_data_page.dart';
import 'package:suara_kita/presentation/pages/auth/signup/admin_signup_password_page.dart';
import 'package:suara_kita/presentation/pages/auth/signup/admin_signup_face_page.dart';
import 'package:suara_kita/presentation/pages/auth/signup/admin_signup_ktm_page.dart';
import 'package:suara_kita/presentation/pages/auth/admin_login_page.dart';
import 'package:suara_kita/presentation/pages/auth/admin_registration_page.dart';
import 'package:suara_kita/presentation/pages/auth/admin_registration_success_page.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // Initialize Firebase dengan error handling
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    print('Firebase initialized successfully');
  } catch (e) {
    print('Error initializing Firebase: $e');
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
        '/admin-registration': (context) => const AdminRegistrationPage(),
        '/admin-registration-success': (context) => const AdminRegistrationSuccessPage(),
        '/signup': (context) => const SignupDataPage(),
        '/admin-signup-data': (context) => const AdminSignupDataPage(),
        '/home': (context) => const PlaceholderPage(title: 'Home Page'),
        '/admin-dashboard': (context) => const PlaceholderPage(title: 'Admin Dashboard'),
      },

      onGenerateRoute: (settings) {
        // Handle routes dengan arguments
        switch (settings.name) {
          case '/admin-signup-password':
            final args = settings.arguments as Map<String, dynamic>;
            return MaterialPageRoute(
              builder: (context) => AdminSignupPasswordPage(userData: args),
            );
          case '/admin-signup-face':
            final args = settings.arguments as Map<String, dynamic>;
            return MaterialPageRoute(
              builder: (context) => AdminSignupFacePage(userData: args),
            );
          case '/admin-signup-ktm':
            final args = settings.arguments as Map<String, dynamic>;
            return MaterialPageRoute(
              builder: (context) => AdminSignupKtmPage(userData: args),
            );
          default:
          // Fallback untuk route yang tidak dikenal
            return MaterialPageRoute(builder: (context) => const SplashPage());
        }
      },

      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(
            textScaleFactor: 1.0, // Mencegah text scaling
          ),
          child: child!,
        );
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