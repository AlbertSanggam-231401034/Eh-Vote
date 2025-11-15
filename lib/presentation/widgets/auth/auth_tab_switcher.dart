import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:suara_kita/presentation/widgets/common/primary_button.dart';

class AuthTabSwitcher extends StatefulWidget {
  const AuthTabSwitcher({super.key});

  @override
  State<AuthTabSwitcher> createState() => _AuthTabSwitcherState();
}

class _AuthTabSwitcherState extends State<AuthTabSwitcher> {
  bool _isLogin = true;

  void _switchTab() {
    setState(() {
      _isLogin = !_isLogin;
    });
  }

  void _navigateToLogin() {
    // Akan kita implementasikan nanti
    print('Navigate to Login');
  }

  void _navigateToSignUp() {
    // Akan kita implementasikan nanti
    print('Navigate to Sign Up');
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Tab Indicator
        Container(
          width: double.infinity,
          height: 50,
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(25),
          ),
          child: Stack(
            children: [
              AnimatedPositioned(
                duration: const Duration(milliseconds: 300),
                left: _isLogin ? 0 : MediaQuery.of(context).size.width / 2,
                child: Container(
                  width: MediaQuery.of(context).size.width / 2 - 24,
                  height: 50,
                  decoration: BoxDecoration(
                    color: Colors.blue,
                    borderRadius: BorderRadius.circular(25),
                  ),
                ),
              ),
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: _switchTab,
                      child: Center(
                        child: Text(
                          'LOG IN',
                          style: GoogleFonts.almarai(
                            fontWeight: FontWeight.bold,
                            color: _isLogin ? Colors.white : Colors.grey,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: _switchTab,
                      child: Center(
                        child: Text(
                          'SIGN UP',
                          style: GoogleFonts.almarai(
                            fontWeight: FontWeight.bold,
                            color: _isLogin ? Colors.grey : Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 32),
        // Action Button
        PrimaryButton(
          onPressed: _isLogin ? _navigateToLogin : _navigateToSignUp,
          text: _isLogin ? 'LOG IN' : 'SIGN UP',
        ),
      ],
    );
  }
}