import 'package:flutter/material.dart';

class AdminIconButton extends StatelessWidget {
  const AdminIconButton({super.key});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: () {
        // TODO: Nanti kita isi navigasi ke Admin Login Page
        print('Admin icon pressed');
      },
      // INI PERBAIKANNYA: Ikon yang benar untuk "Shield Person"
      icon: const Icon(
        Icons.admin_panel_settings, // BUKAN shield_person
        size: 32, // Sedikit lebih besar
        color: Colors.white, // Putih agar terlihat di background hijau
      ),
      tooltip: 'Login sebagai Admin',
    );
  }
}