import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:suara_kita/core/constants/colors.dart';
import 'package:suara_kita/data/models/user_model.dart'; // ✅ Import User Model
import 'package:suara_kita/presentation/providers/voting_provider.dart';
import 'package:suara_kita/presentation/widgets/common/primary_button.dart';
import 'package:suara_kita/services/firebase_service.dart'; // ✅ Import Firebase Service

class VotingSuccessPage extends StatefulWidget {
  const VotingSuccessPage({super.key});

  @override
  State<VotingSuccessPage> createState() => _VotingSuccessPageState();
}

class _VotingSuccessPageState extends State<VotingSuccessPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    // Setup animation for checkmark
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 0.5,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.elasticOut,
      ),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false, // Mencegah user kembali ke halaman sebelumnya
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Consumer<VotingProvider>(
            builder: (context, provider, child) {
              final voteRecord = provider.voteRecord;

              return Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Animated Checkmark
                    ScaleTransition(
                      scale: _scaleAnimation,
                      child: Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.primaryGreen.withOpacity(0.1),
                          border: Border.all(
                            color: AppColors.primaryGreen,
                            width: 3,
                          ),
                        ),
                        child: const Icon(
                          Icons.check_circle,
                          size: 80,
                          color: AppColors.primaryGreen,
                        ),
                      ),
                    ),

                    const SizedBox(height: 32),

                    // Success Header
                    const Text(
                      'Suara Berhasil Direkam!',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: AppColors.darkGreen,
                      ),
                      textAlign: TextAlign.center,
                    ),

                    const SizedBox(height: 12),

                    // Subheader
                    Text(
                      'Terima kasih telah berpartisipasi dalam demokrasi kampus',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey.shade700,
                        height: 1.4,
                      ),
                      textAlign: TextAlign.center,
                    ),

                    const SizedBox(height: 32),

                    // Vote Receipt Card
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppColors.lightGreen,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: AppColors.primaryGreen.withOpacity(0.3),
                          width: 1.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          // Receipt Header
                          Row(
                            children: const [
                              Icon(
                                Icons.receipt_long,
                                color: AppColors.primaryGreen,
                                size: 20,
                              ),
                              SizedBox(width: 8),
                              Text(
                                'BUKTI PEMILIHAN',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.darkGreen,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 16),

                          // Vote ID
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.grey.shade300),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'ID Suara',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  voteRecord?.voteId ?? 'VOTE_${DateTime.now().millisecondsSinceEpoch}',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.darkGreen,
                                    fontFamily: 'monospace',
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 12),

                          // Time Stamp
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.grey.shade300),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Waktu Voting',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey,
                                  ),
                                ),
                                Text(
                                  _formatTime(voteRecord?.votedAt ?? DateTime.now()),
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.darkGreen,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 16),

                          // Security Note
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppColors.primaryGreen.withOpacity(0.05),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: AppColors.primaryGreen.withOpacity(0.2),
                              ),
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.security,
                                  color: AppColors.primaryGreen,
                                  size: 16,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    'ID ini dicatat dalam sistem audit trail',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: AppColors.darkGreen.withOpacity(0.8),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Instruction Text
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Text(
                        'Simpan ID di atas sebagai bukti partisipasi Anda dalam pemilihan',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade600,
                          fontStyle: FontStyle.italic,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),

                    const Spacer(),

                    // Home Button
                    SizedBox(
                      width: double.infinity,
                      child: PrimaryButton(
                        text: 'KEMBALI KE BERANDA',
                        onPressed: () => _returnToHome(provider, context),
                      ),
                    ),

                    const SizedBox(height: 16),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Future<void> _returnToHome(VotingProvider provider, BuildContext context) async {
    // 1. Simpan NIM sebelum di-reset
    final nim = provider.voterNim;

    // 2. Reset provider
    provider.reset();

    // 3. Ambil data user terbaru dari Firebase (agar status hasVoted terupdate di Home)
    User? updatedUser;
    if (nim != null) {
      try {
        updatedUser = await FirebaseService.getUserByNim(nim);
      } catch (e) {
        print("Error fetching updated user: $e");
      }
    }

    // 4. Navigasi ke Home dengan membawa Data User
    if (updatedUser != null && context.mounted) {
      Navigator.pushNamedAndRemoveUntil(
        context,
        '/home',
            (route) => false,
        arguments: updatedUser, // ✅ KIRIM DATA USER KE HOME
      );
    } else if (context.mounted) {
      // Fallback jika gagal ambil user (sangat jarang terjadi), kembalikan ke Login biar aman
      Navigator.pushNamedAndRemoveUntil(
        context,
        '/login',
            (route) => false,
      );
    }
  }

  String _formatTime(DateTime dateTime) {
    return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}