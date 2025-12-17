import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:suara_kita/services/firebase_service.dart';
import 'package:suara_kita/presentation/pages/admin/admin_scan_flow.dart';
import 'package:suara_kita/data/models/user_model.dart';

class AdminDashboard extends StatefulWidget {
  final User currentUser;

  const AdminDashboard({super.key, required this.currentUser});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  late User _currentUser;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _currentUser = widget.currentUser;
    // Delay refresh slightly to ensure widget is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _refreshUserData();
    });
  }

  Future<void> _refreshUserData() async {
    if (!mounted) return;
    setState(() => _isLoading = true);

    try {
      final updatedUser = await FirebaseService.getUserByNim(widget.currentUser.nim);
      if (updatedUser != null && mounted) {
        setState(() {
          _currentUser = updatedUser;
        });
        print("Admin Data Refreshed: Face URL=${_currentUser.faceImageUrl} KTM URL=${_currentUser.ktmImageUrl}");
      }
    } catch (e) {
      print("Error refreshing user data: $e");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // ✅ FIX LOGIC: Cek faceImageUrl dan ktmImageUrl (String), BUKAN faceEmbedding (List)
    bool isFaceMissing = _currentUser.faceImageUrl.isEmpty; // Cek URL gambar wajah
    bool isKtmMissing = _currentUser.ktmImageUrl.isEmpty;   // Cek URL gambar KTM

    // Alternatif: cek faceData jika ingin lebih spesifik
    // bool isFaceMissing = _currentUser.faceData == null ||
    //                      _currentUser.faceData.isEmpty ||
    //                      _currentUser.faceData == 'ADMIN_SCAN_REQUIRED';

    bool needsScan = isFaceMissing || isKtmMissing;

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
              color: Colors.orangeAccent,
            ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshUserData,
            tooltip: 'Refresh Data',
          ),
          IconButton(
            icon: const Icon(Icons.logout_rounded),
            onPressed: () => _logout(context),
            tooltip: 'Logout',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refreshUserData,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Padding(
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
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Flexible(
                            child: Text(
                              'Selamat Datang, ${_currentUser.fullName}!',
                              style: GoogleFonts.unbounded(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          if (_isLoading)
                            const SizedBox(
                              width: 20, height: 20,
                              child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                            ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        needsScan
                            ? 'Lengkapi profil Anda untuk dapat voting'
                            : 'Profil lengkap. Anda siap mengelola sistem.',
                        style: GoogleFonts.almarai(
                          fontSize: 14,
                          color: Colors.white.withOpacity(0.9),
                        ),
                      ),

                      // Menampilkan detail status data admin
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(
                            _currentUser.faceImageUrl.isNotEmpty
                                ? Icons.check_circle
                                : Icons.cancel,
                            // ✅ FIX: Gunakan Color langsung bukan Colors.green[200] yang nullable
                            color: _currentUser.faceImageUrl.isNotEmpty
                                ? const Color(0xFFA5D6A7) // Hijau muda
                                : const Color(0xFFEF9A9A), // Merah muda
                            size: 16,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Foto Wajah: ${_currentUser.faceImageUrl.isNotEmpty ? 'Ada' : 'Belum'}',
                            style: GoogleFonts.almarai(
                              fontSize: 12,
                              color: Colors.white.withOpacity(0.8),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Icon(
                            _currentUser.ktmImageUrl.isNotEmpty
                                ? Icons.check_circle
                                : Icons.cancel,
                            // ✅ FIX: Gunakan Color langsung bukan Colors.red[200] yang nullable
                            color: _currentUser.ktmImageUrl.isNotEmpty
                                ? const Color(0xFFA5D6A7) // Hijau muda
                                : const Color(0xFFEF9A9A), // Merah muda
                            size: 16,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Foto KTM: ${_currentUser.ktmImageUrl.isNotEmpty ? 'Ada' : 'Belum'}',
                            style: GoogleFonts.almarai(
                              fontSize: 12,
                              color: Colors.white.withOpacity(0.8),
                            ),
                          ),
                        ],
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
                      onTap: () {},
                    ),
                    _ActionCard(
                      title: 'Kelola User',
                      icon: Icons.people_rounded,
                      color: const Color(0xFF2196F3),
                      onTap: () {},
                    ),
                    _ActionCard(
                      title: 'Hasil Voting',
                      icon: Icons.bar_chart_rounded,
                      color: const Color(0xFF9C27B0),
                      onTap: () {},
                    ),
                    _ActionCard(
                      title: 'Pengaturan',
                      icon: Icons.settings_rounded,
                      color: const Color(0xFFFF9800),
                      onTap: () {},
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

                // Placeholder Statistik
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

                // Debug Info (Hanya untuk development)
                if (_currentUser.faceImageUrl.isNotEmpty || _currentUser.ktmImageUrl.isNotEmpty)
                  Container(
                    margin: const EdgeInsets.only(top: 20),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey[300]!),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Info Data Admin:',
                          style: GoogleFonts.almarai(
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                            color: Colors.grey[700],
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Face URL: ${_currentUser.faceImageUrl.isNotEmpty ? '${_currentUser.faceImageUrl.substring(0, _currentUser.faceImageUrl.length > 30 ? 30 : _currentUser.faceImageUrl.length)}...' : 'Tidak ada'}',
                          style: GoogleFonts.almarai(
                            fontSize: 10,
                            color: Colors.grey[600],
                          ),
                        ),
                        Text(
                          'KTM URL: ${_currentUser.ktmImageUrl.isNotEmpty ? '${_currentUser.ktmImageUrl.substring(0, _currentUser.ktmImageUrl.length > 30 ? 30 : _currentUser.ktmImageUrl.length)}...' : 'Tidak ada'}',
                          style: GoogleFonts.almarai(
                            fontSize: 10,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),

                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showScanReminder(BuildContext context) {
    final isFaceMissing = _currentUser.faceImageUrl.isEmpty;
    final isKtmMissing = _currentUser.ktmImageUrl.isEmpty;

    String message = '';
    if (isFaceMissing && isKtmMissing) {
      message = 'Anda perlu melengkapi scan wajah dan KTM.';
    } else if (isFaceMissing) {
      message = 'Anda perlu melengkapi scan wajah.';
    } else {
      message = 'Anda perlu melengkapi scan KTM.';
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Lengkapi Profil Admin'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('NANTI'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _startScanFlow(context);
            },
            child: const Text('LENGKAPI'),
          ),
        ],
      ),
    );
  }

  Future<void> _startScanFlow(BuildContext context) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AdminScanFlow(adminNim: _currentUser.nim),
      ),
    );
    _refreshUserData();
  }

  void _logout(BuildContext context) async {
    await FirebaseService.signOut();
    if (!context.mounted) return;
    Navigator.pushReplacementNamed(context, '/welcome');
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
                textAlign: TextAlign.center,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ),
    );
  }
}