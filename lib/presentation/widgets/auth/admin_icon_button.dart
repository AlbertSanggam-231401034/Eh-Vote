import 'package:flutter/material.dart';

class AdminIconButton extends StatelessWidget {
  const AdminIconButton({super.key});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: () {
        Navigator.pushNamed(context, '/admin-login');
      },
      icon: const Icon(
        Icons.admin_panel_settings,
        size: 32,
        color: Colors.white,
      ),
      tooltip: 'Login sebagai Admin',
    );
  }
}