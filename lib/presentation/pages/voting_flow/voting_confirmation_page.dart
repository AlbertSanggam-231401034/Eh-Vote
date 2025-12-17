import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:suara_kita/core/constants/colors.dart';
import 'package:suara_kita/data/models/candidate_model.dart'; // Pastikan import ini ada
import 'package:suara_kita/presentation/providers/voting_provider.dart';
import 'package:suara_kita/presentation/widgets/common/primary_button.dart';

class VotingConfirmationPage extends StatefulWidget {
  const VotingConfirmationPage({super.key});

  @override
  State<VotingConfirmationPage> createState() => _VotingConfirmationPageState();
}

class _VotingConfirmationPageState extends State<VotingConfirmationPage> {
  bool _isSubmitting = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: _buildBody(),
      bottomNavigationBar: _buildBottomBar(),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      title: const Text(
        'KONFIRMASI SUARA',
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: AppColors.darkGreen,
          fontSize: 18,
        ),
      ),
      centerTitle: true,
      backgroundColor: Colors.white,
      elevation: 1,
      iconTheme: const IconThemeData(color: AppColors.darkGreen),
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(4.0),
        child: Container(
          color: AppColors.primaryGreen,
          height: 4.0,
        ),
      ),
    );
  }

  Widget _buildBody() {
    return Consumer<VotingProvider>(
      builder: (context, provider, child) {
        final candidate = provider.selectedCandidate;

        if (candidate == null) {
          return _buildNoCandidateSelected();
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              const Text(
                'Harap periksa kembali pilihan Anda',
                style: TextStyle(
                  fontSize: 16,
                  color: AppColors.darkGreen,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Setelah dikirim, suara tidak dapat diubah atau dibatalkan.',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 24),

              // Voter Information Card
              _buildVoterInfoCard(provider),
              const SizedBox(height: 24),

              // Candidate Selection Card
              _buildCandidateCard(candidate),
              const SizedBox(height: 24),

              // Security Notice
              _buildSecurityNotice(),
              const SizedBox(height: 32),

              // Verification Status
              _buildVerificationStatus(provider),
            ],
          ),
        );
      },
    );
  }

  Widget _buildVoterInfoCard(VotingProvider provider) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.lightGreen,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primaryGreen.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(Icons.person_outline, color: AppColors.primaryGreen, size: 20),
              SizedBox(width: 8),
              Text(
                'IDENTITAS PEMILIH',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppColors.darkGreen,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Nama Lengkap',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                    SizedBox(height: 4),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'NIM',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      provider.voterNim ?? 'Tidak tersedia',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppColors.darkGreen,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          // Tambahan logic nama jika provider punya voterName, kalau tidak skip
          // (Optional: Bisa ditambahkan manual jika getter voterName ada)
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.verified, color: AppColors.primaryGreen, size: 16),
              const SizedBox(width: 4),
              Text(
                'Terverifikasi ${provider.isFaceVerified ? 'Wajah' : ''}${provider.isFaceVerified && provider.isKtmVerified ? ' & ' : ''}${provider.isKtmVerified ? 'KTM' : ''}',
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.primaryGreen,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCandidateCard(CandidateModel candidate) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primaryGreen, width: 2),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryGreen.withOpacity(0.1),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'KANDIDAT PILIHAN ANDA',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: AppColors.darkGreen,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Candidate Photo
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: candidate.photoUrl.isNotEmpty
                      ? Image.network(
                    candidate.photoUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: Colors.grey.shade200,
                        child: const Icon(
                          Icons.person,
                          size: 40,
                          color: Colors.grey,
                        ),
                      );
                    },
                  )
                      : Container(
                    color: Colors.grey.shade200,
                    child: const Icon(
                      Icons.person,
                      size: 40,
                      color: Colors.grey,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              // Candidate Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.primaryGreen,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        'No. ${candidate.candidateNumber}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      candidate.name,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.darkGreen,
                      ),
                    ),
                    if (candidate.major.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        candidate.major,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                    const SizedBox(height: 8),
                    if (candidate.vision.isNotEmpty)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Visi:',
                            style: TextStyle(
                              fontWeight: FontWeight.w500,
                              color: Colors.grey,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            candidate.vision.length > 100
                                ? '${candidate.vision.substring(0, 100)}...'
                                : candidate.vision,
                            style: const TextStyle(
                              fontSize: 13,
                              color: Colors.black87,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSecurityNotice() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.orange.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.orange.shade200),
      ),
      child: Row(
        children: [
          Icon(Icons.security, color: Colors.orange.shade700, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Catatan Keamanan',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.orange.shade800,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Suara Anda akan direkam secara digital dengan audit trail lengkap '
                      '(skor wajah, waktu, perangkat) dan tidak dapat diubah setelah dikirim.',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.orange.shade700,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVerificationStatus(VotingProvider provider) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Status Verifikasi',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: AppColors.darkGreen,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(
                provider.isFaceVerified ? Icons.check_circle : Icons.error,
                color: provider.isFaceVerified ? AppColors.primaryGreen : Colors.grey,
              ),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'Verifikasi Wajah',
                  style: TextStyle(fontSize: 13),
                ),
              ),
              Text(
                provider.isFaceVerified ? 'Berhasil' : 'Dibutuhkan',
                style: TextStyle(
                  color: provider.isFaceVerified ? AppColors.primaryGreen : Colors.grey,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(
                provider.isKtmVerified ? Icons.check_circle : Icons.error,
                color: provider.isKtmVerified ? AppColors.primaryGreen : Colors.grey,
              ),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'Verifikasi KTM',
                  style: TextStyle(fontSize: 13),
                ),
              ),
              Text(
                provider.isKtmVerified ? 'Berhasil' : 'Dibutuhkan',
                style: TextStyle(
                  color: provider.isKtmVerified ? AppColors.primaryGreen : Colors.grey,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.access_time, color: Colors.grey),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'Waktu Pemilihan',
                  style: TextStyle(fontSize: 13),
                ),
              ),
              Text(
                _formatTime(),
                style: const TextStyle(
                  color: AppColors.darkGreen,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNoCandidateSelected() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.warning_amber, size: 80, color: Colors.amber),
          const SizedBox(height: 16),
          const Text(
            'Belum ada kandidat terpilih',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Silakan kembali ke halaman pemilihan kandidat',
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          PrimaryButton(
            text: 'PILIH KANDIDAT',
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar() {
    return Consumer<VotingProvider>(
      builder: (context, provider, child) {
        if (_isSubmitting) {
          return Container(
            padding: const EdgeInsets.all(16),
            color: Colors.white,
            child: const Center(
              child: CircularProgressIndicator(color: AppColors.primaryGreen),
            ),
          );
        }

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border(top: BorderSide(color: Colors.grey.shade300)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          side: const BorderSide(color: AppColors.primaryGreen),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'UBAH PILIHAN',
                          style: TextStyle(
                            color: AppColors.primaryGreen,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: PrimaryButton(
                        text: 'KIRIM SUARA SAYA',
                        onPressed: () => _submitVote(provider, context),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Pastikan pilihan sudah benar',
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey.shade500,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _submitVote(VotingProvider provider, BuildContext context) async {
    // Validation checks
    if (!provider.isFaceVerified || !provider.isKtmVerified) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Verifikasi wajah dan KTM belum lengkap'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (provider.selectedCandidate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Silakan pilih kandidat terlebih dahulu'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    final success = await provider.submitVote();

    setState(() => _isSubmitting = false);

    if (success) {
      // Navigate to success page with replacement
      if (mounted) {
        // Ganti halaman ini dengan Success Page
        Navigator.pushReplacementNamed(context, '/voting-success');
      }
    } else {
      // Show error message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(provider.errorMessage ?? 'Gagal mengirimkan suara'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  String _formatTime() {
    final now = DateTime.now();
    return '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
  }
}