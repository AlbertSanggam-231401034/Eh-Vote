import 'package:flutter/material.dart';

class AdminIconButton extends StatelessWidget {
  const AdminIconButton({super.key});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: () {
        // TODO: Implement admin login navigation
        print('Admin icon pressed');
      },
      icon: const Icon(
        Icons.admin_panel_settings_rounded,
        size: 28,
        color: Colors.blue,
      ),
      tooltip: 'Login sebagai Admin',
    );
  }
}