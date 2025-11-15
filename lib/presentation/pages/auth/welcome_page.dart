import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:suara_kita/presentation/widgets/auth/auth_tab_switcher.dart';
import 'package:suara_kita/presentation/widgets/auth/admin_icon_button.dart';

class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Main Content
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Main Logo/Icon
                const Icon(
                  Icons.how_to_vote_outlined,
                  size: 80,
                  color: Colors.blue,
                ),
                const SizedBox(height: 24),

                // App Title with Unbounded font
                Text(
                  'Suara Kita',
                  style: GoogleFonts.unbounded(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
                const SizedBox(height: 16),

                // Description with Almarai font
                Text(
                  'Partisipasi Pemilihan Kampus Jadi Lebih Mudah',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.almarai(
                    fontSize: 16,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 40),

                // Sign Up & Login Buttons
                const AuthTabSwitcher(),
              ],
            ),
          ),

          // Admin Icon Button at top right
          const Positioned(
            top: 40,
            right: 16,
            child: AdminIconButton(),
          ),
        ],
      ),
    );
  }
}