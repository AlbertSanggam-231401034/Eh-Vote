import 'package:flutter/material.dart';
import 'package:suara_kita/core/theme/app_theme.dart';
import 'package:suara_kita/presentation/pages/splash/splash_page.dart'; // Ganti nama file
import 'package:suara_kita/presentation/pages/auth/welcome_page.dart';
import 'package:suara_kita/presentation/pages/auth/login_page.dart';
// Impor halaman placeholder baru
import 'package:suara_kita/presentation/pages/auth/signup/signup_data_page.dart';

void main() {
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
      themeMode: ThemeMode.light, // Kita set ke Light Mode saja
      debugShowCheckedModeBanner: false,
      initialRoute: '/splash',
      routes: {
        '/splash': (context) => const SplashPage(), // Ganti nama class
        '/welcome': (context) => const WelcomePage(),
        '/login': (context) => const LoginPage(),
        // TAMBAHKAN INI: Rute untuk Sign Up
        '/signup': (context) => const SignupDataPage(),
      },
      onUnknownRoute: (settings) {
        return MaterialPageRoute(builder: (context) => const SplashPage());
      },

      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(
            textScaleFactor: 1.0, // Memaksa ukuran font tetap
          ),
          child: child!,
        );
      },
    );
  }
}