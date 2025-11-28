import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:suara_kita/services/firebase_service.dart';
import 'package:suara_kita/presentation/pages/admin/admin_scan_flow.dart';
import 'package:suara_kita/utils/admin_setup.dart';
import 'package:suara_kita/data/models/user_model.dart';

class AdminDashboard extends StatelessWidget {
  final User currentUser;


  const AdminDashboard({super.key, required this.currentUser});
  @override
  Widget build(BuildContext context) {
    bool needsScan = AdminSetup.needsScan(currentUser);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: Text(
          'Admin Dashboard',
          style: GoogleFonts.unbounded(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color(0xFF00C64F),
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          if (needsScan)
            IconButton(
              icon: const Icon(Icons.warning_amber_rounded),
              onPressed: () => _showScanReminder(context),
              tooltip: 'Lengkapi Profil',
              color: Colors.orange,
            ),
          IconButton(
            icon: const Icon(Icons.logout_rounded),
            onPressed: () => _logout(context),
            tooltip: 'Logout',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF00C64F), Color(0xFF002D12)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Selamat Datang, ${currentUser.fullName}!',
                    style: GoogleFonts.unbounded(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    needsScan
                        ? 'Lengkapi profil Anda untuk dapat voting'
                        : 'Kelola sistem e-voting dengan mudah',
                    style: GoogleFonts.almarai(
                      fontSize: 14,
                      color: Colors.white.withOpacity(0.9),
                    ),
                  ),
                  if (needsScan) ...[
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () => _startScanFlow(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: const Color(0xFF00C64F),
                        ),
                        child: Text(
                          'LENGKAPI PROFIL SEKARANG',
                          style: GoogleFonts.almarai(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Quick Actions
            Text(
              'Aksi Cepat',
              style: GoogleFonts.unbounded(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF002D12),
              ),
            ),
            const SizedBox(height: 16),

            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              children: [
                _ActionCard(
                  title: 'Lihat Pemilihan',
                  icon: Icons.how_to_vote_rounded,
                  color: const Color(0xFF00C64F),
                  onTap: () {
                    // TODO: Navigate to elections
                  },
                ),
                _ActionCard(
                  title: 'Kelola User',
                  icon: Icons.people_rounded,
                  color: const Color(0xFF2196F3),
                  onTap: () {
                    // TODO: Navigate to user management
                  },
                ),
                _ActionCard(
                  title: 'Hasil Voting',
                  icon: Icons.bar_chart_rounded,
                  color: const Color(0xFF9C27B0),
                  onTap: () {
                    // TODO: Navigate to results
                  },
                ),
                _ActionCard(
                  title: 'Pengaturan',
                  icon: Icons.settings_rounded,
                  color: const Color(0xFFFF9800),
                  onTap: () {
                    // TODO: Navigate to settings
                  },
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Statistics
            Text(
              'Statistik',
              style: GoogleFonts.unbounded(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF002D12),
              ),
            ),
            const SizedBox(height: 16),

            // Placeholder untuk statistik
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  const Icon(Icons.analytics_rounded, size: 50, color: Colors.grey),
                  const SizedBox(height: 8),
                  Text(
                    'Fitur statistik dalam pengembangan',
                    style: GoogleFonts.almarai(
                      color: Colors.grey,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showScanReminder(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: Text(
          'Lengkapi Profil Admin',
          textAlign: TextAlign.center,
          style: GoogleFonts.almarai(
            fontWeight: FontWeight.bold,
            color: const Color(0xFF002D12),
          ),
        ),
        content: Text(
          'Anda perlu melengkapi scan wajah dan KTM untuk dapat mengakses semua fitur admin.',
          style: GoogleFonts.almarai(),
          textAlign: TextAlign.center,
        ),
        actions: [
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF00C64F),
                    side: const BorderSide(color: Color(0xFF00C64F)),
                  ),
                  child: Text(
                    'NANTI',
                    style: GoogleFonts.almarai(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    _startScanFlow(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00C64F),
                    foregroundColor: Colors.white,
                  ),
                  child: Text(
                    'LENGKAPI',
                    style: GoogleFonts.almarai(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _startScanFlow(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AdminScanFlow(adminNim: currentUser.nim),
      ),
    );
  }

  void _logout(BuildContext context) async {
    try {
      await FirebaseService.signOut();
      // ignore: use_build_context_synchronously
      Navigator.pushReplacementNamed(context, '/welcome');
    } catch (e) {
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error logging out: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}

class _ActionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _ActionCard({
    required this.title,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(height: 8),
              Text(
                title,
                style: GoogleFonts.almarai(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF002D12),
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}