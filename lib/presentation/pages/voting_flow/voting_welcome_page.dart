import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:suara_kita/presentation/providers/voting_provider.dart';
import 'package:suara_kita/core/constants/colors.dart';
import 'package:suara_kita/presentation/widgets/common/primary_button.dart';
import 'package:suara_kita/data/models/election_model.dart';

class VotingWelcomePage extends StatefulWidget {
  static const routeName = '/voting-welcome';
  final ElectionModel election;

  const VotingWelcomePage({
    super.key,
    required this.election,
  });

  @override
  State<VotingWelcomePage> createState() => _VotingWelcomePageState();
}

class _VotingWelcomePageState extends State<VotingWelcomePage> {

  @override
  void initState() {
    super.initState();
    // ✅ PANGGIL SET ELECTION SAAT HALAMAN DIBUKA
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<VotingProvider>();

      // Menggunakan NIM Testing '231401034' (Sesuai Data Supabase Albert)
      // Nanti jika sudah production, ambil dari AuthProvider.user.nim
      print("DEBUG: Menginisialisasi Voting Session untuk NIM 231401034...");
      provider.setElection(widget.election, '231401034');
    });
  }

  @override
  Widget build(BuildContext context) {
    final votingProvider = context.watch<VotingProvider>();
    final hasVoted = votingProvider.hasAlreadyVoted;

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
        child: votingProvider.isLoading
            ? const Center(child: CircularProgressIndicator(color: AppColors.primaryGreen))
            : Column(
          children: [
            // Election Info Card
            Container(
              margin: const EdgeInsets.all(20),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: hasVoted
                    ? const LinearGradient(colors: [Colors.grey, Colors.black54])
                    : AppColors.primaryGradient,
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
                    widget.election.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  if (hasVoted)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.check_circle, color: AppColors.primaryGreen, size: 20),
                          SizedBox(width: 8),
                          Text(
                            "ANDA SUDAH MEMILIH",
                            style: TextStyle(
                              color: AppColors.primaryGreen,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    )
                  else
                    Text(
                      widget.election.description,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 14,
                      ),
                      textAlign: TextAlign.center,
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
                      const SizedBox(height: 30),

                      _buildStepCard(1, Icons.face_retouching_natural_rounded, 'Verifikasi Wajah', 'Face recognition', AppColors.primaryGreen, hasVoted),
                      _buildStepCard(2, Icons.qr_code_scanner_rounded, 'Scan KTM', 'Validasi QR Code', AppColors.darkGreen, hasVoted),
                      _buildStepCard(3, Icons.gavel_rounded, 'Persetujuan', 'Syarat ketentuan', const Color(0xFF4CAF50), hasVoted),
                      _buildStepCard(4, Icons.how_to_vote_rounded, 'Pilih Kandidat', 'Tentukan pilihan', const Color(0xFF2196F3), hasVoted),
                      _buildStepCard(5, Icons.check_circle_rounded, 'Konfirmasi', 'Review pilihan', const Color(0xFFFF9800), hasVoted),
                      _buildStepCard(6, Icons.celebration_rounded, 'Selesai', 'Vote terkirim', const Color(0xFF9C27B0), hasVoted),

                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ),

            // Start Button
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -5)),
                ],
              ),
              child: Column(
                children: [
                  PrimaryButton(
                    onPressed: hasVoted
                        ? null // ⛔ DISABLE TOMBOL
                        : () {
                      votingProvider.startVotingSession();
                      Navigator.pushNamed(context, '/voting-face-verify');
                    },
                    text: hasVoted ? 'SUDAH MEMBERIKAN SUARA' : 'MULAI VOTING',
                    isLoading: votingProvider.isLoading,
                  ),
                  const SizedBox(height: 10),
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text(
                      'Kembali',
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

  // ... (Widget _buildStepCard sama persis, tidak perlu diubah)
  Widget _buildStepCard(int number, IconData icon, String title, String desc, Color color, bool isDisabled) {
    final displayColor = isDisabled ? Colors.grey : color;

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
        border: Border.all(color: displayColor.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Container(
            width: 50, height: 50,
            decoration: BoxDecoration(color: displayColor.withOpacity(0.1), shape: BoxShape.circle),
            child: Center(child: Text('$number', style: TextStyle(color: displayColor, fontSize: 20, fontWeight: FontWeight.bold))),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [Icon(icon, color: displayColor, size: 18), const SizedBox(width: 8), Text(title, style: TextStyle(color: isDisabled ? Colors.grey : AppColors.darkGreen, fontSize: 16, fontWeight: FontWeight.w600))]),
                const SizedBox(height: 4),
                Text(desc, style: TextStyle(color: AppColors.grey, fontSize: 12)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}