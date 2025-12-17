import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:suara_kita/presentation/providers/voting_provider.dart';
import 'package:suara_kita/core/constants/colors.dart';
import 'package:suara_kita/presentation/widgets/common/primary_button.dart';
import 'package:suara_kita/data/models/election_model.dart'; // Import Model

class VotingWelcomePage extends StatefulWidget {
  static const routeName = '/voting-welcome';
  final ElectionModel election; // ✅ Data diterima dari constructor

  const VotingWelcomePage({
    super.key,
    required this.election, // ✅ Wajib diisi
  });

  @override
  State<VotingWelcomePage> createState() => _VotingWelcomePageState();
}

class _VotingWelcomePageState extends State<VotingWelcomePage> {
  // Tidak perlu initState untuk setElection di sini
  // Kita setElection saat tombol ditekan saja (Lazy Loading)

  @override
  Widget build(BuildContext context) {
    // ✅ FIX: HANYA panggil VotingProvider. ElectionProvider DIHAPUS.
    final votingProvider = context.watch<VotingProvider>();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Mulai Voting'),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: AppColors.darkGreen,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Election Info Card
            Container(
              margin: const EdgeInsets.all(20),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Column(
                children: [
                  Text(
                    widget.election.title, // ✅ Pakai widget.election
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.election.description,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 14,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildStatusChip(
                        'Dimulai',
                        widget.election.startDate,
                      ),
                      const SizedBox(width: 12),
                      _buildStatusChip(
                        'Berakhir',
                        widget.election.endDate,
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Steps Guide
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 20),
                      const Text(
                        '6 Langkah Voting Aman',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppColors.darkGreen,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Ikuti langkah-langkah berikut untuk memberikan suara Anda dengan aman dan terverifikasi.',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.grey,
                        ),
                      ),
                      const SizedBox(height: 30),

                      _buildStepCard(1, Icons.face_retouching_natural_rounded, 'Verifikasi Wajah', 'Face recognition', AppColors.primaryGreen),
                      _buildStepCard(2, Icons.qr_code_scanner_rounded, 'Scan KTM', 'Validasi QR Code', AppColors.darkGreen),
                      _buildStepCard(3, Icons.gavel_rounded, 'Persetujuan', 'Syarat ketentuan', const Color(0xFF4CAF50)),
                      _buildStepCard(4, Icons.how_to_vote_rounded, 'Pilih Kandidat', 'Tentukan pilihan', const Color(0xFF2196F3)),
                      _buildStepCard(5, Icons.check_circle_rounded, 'Konfirmasi', 'Review pilihan', const Color(0xFFFF9800)),
                      _buildStepCard(6, Icons.celebration_rounded, 'Selesai', 'Vote terkirim', const Color(0xFF9C27B0)),

                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ),

            // Start Button
            Container(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  PrimaryButton(
                    onPressed: () async {
                      // Init Session di Provider
                      final userNim = context.read<VotingProvider>().voterNim ?? '231401034';

                      // ✅ Set Election Data ke Provider saat tombol ditekan
                      await votingProvider.setElection(widget.election, userNim);

                      votingProvider.startVotingSession();
                      if (context.mounted) {
                        Navigator.pushNamed(context, '/voting-face-verify');
                      }
                    },
                    text: 'MULAI VOTING',
                    isLoading: votingProvider.isLoading,
                  ),
                  const SizedBox(height: 10),
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text(
                      'Kembali ke Daftar Pemilihan',
                      style: TextStyle(color: AppColors.grey),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStepCard(int number, IconData icon, String title, String desc, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            spreadRadius: 1,
          ),
        ],
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Container(
            width: 50, height: 50,
            decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle),
            child: Center(child: Text('$number', style: TextStyle(color: color, fontSize: 20, fontWeight: FontWeight.bold))),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [Icon(icon, color: color, size: 18), const SizedBox(width: 8), Text(title, style: TextStyle(color: AppColors.darkGreen, fontSize: 16, fontWeight: FontWeight.w600))]),
                const SizedBox(height: 4),
                Text(desc, style: TextStyle(color: AppColors.grey, fontSize: 12)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusChip(String label, DateTime date) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(20)),
      child: Row(
        children: [
          Text(label, style: const TextStyle(color: Colors.white, fontSize: 12)),
          const SizedBox(width: 6),
          Text('${date.day}/${date.month}/${date.year}', style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 11)),
        ],
      ),
    );
  }
}