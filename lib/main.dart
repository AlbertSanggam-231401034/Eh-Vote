import 'package:flutter/material.dart';
// Kita import langsung WelcomePage yang sudah kamu buat
import 'package:suara_kita/presentation/pages/auth/welcome_page.dart';
// Kita import google_fonts karena WelcomePage memakainya
import 'package:google_fonts/google_fonts.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Suara Kita',
      debugShowCheckedModeBanner: false,

      // Kita set tema dasarnya di sini untuk sementara
      // Font 'Almarai' akan jadi default
      theme: ThemeData(
        primarySwatch: Colors.blue,
        textTheme: GoogleFonts.almaraiTextTheme(
          Theme.of(context).textTheme,
        ),
        scaffoldBackgroundColor: Colors.white,
      ),

      // Kita langsung arahkan ke WelcomePage
      home: const WelcomePage(),
    );
  }
}