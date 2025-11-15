import 'package:flutter/material.dart';

// Ini hanya halaman placeholder sementara
class SignupDataPage extends StatelessWidget {
  const SignupDataPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sign Up - Step 1')),
      body: const Center(
        child: Text('Halaman Sign Up Data Diri'),
      ),
    );
  }
}