import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:suara_kita/presentation/providers/voting_provider.dart';
import 'package:suara_kita/core/constants/colors.dart';
import 'package:suara_kita/presentation/widgets/common/primary_button.dart';
import 'package:suara_kita/core/constants/app_constants.dart';

class VotingAgreementPage extends StatefulWidget {
  static const routeName = '/voting-agreement';

  const VotingAgreementPage({Key? key}) : super(key: key);

  @override
  State<VotingAgreementPage> createState() => _VotingAgreementPageState();
}

class _VotingAgreementPageState extends State<VotingAgreementPage> {
  bool _isAgreed = false;
  bool _hasReadTerms = false;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_checkScrollPosition);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_checkScrollPosition);
    _scrollController.dispose();
    super.dispose();
  }

  void _checkScrollPosition() {
    if (!_hasReadTerms &&
        _scrollController.offset >= _scrollController.position.maxScrollExtent - 50) {
      setState(() {
        _hasReadTerms = true;
      });
    }
  }

  Widget _buildProgressStepper(int currentStep) {
    final steps = ['Wajah', 'KTM', 'Setuju', 'Pilih', 'Konfirm', 'Selesai'];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Column(
        children: [
          // Step indicators
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(6, (index) {
              final stepNumber = index + 1;
              final isCompleted = stepNumber < currentStep;
              final isCurrent = stepNumber == currentStep;

              return Column(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: isCompleted || isCurrent
                          ? AppColors.primaryGreen
                          : AppColors.lightGrey,
                      shape: BoxShape.circle,
                      border: isCurrent
                          ? Border.all(color: Colors.white, width: 3)
                          : null,
                    ),
                    child: Center(
                      child: Text(
                        '$stepNumber',
                        style: TextStyle(
                          color: isCompleted || isCurrent
                              ? Colors.white
                              : AppColors.grey,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    steps[index],
                    style: TextStyle(
                      fontSize: 10,
                      color: isCompleted || isCurrent
                          ? AppColors.primaryGreen
                          : AppColors.grey,
                      fontWeight: isCompleted || isCurrent
                          ? FontWeight.bold
                          : FontWeight.normal,
                    ),
                  ),
                ],
              );
            }),
          ),

          // Progress line
          Container(
            margin: const EdgeInsets.only(top: 18),
            height: 3,
            child: Row(
              children: List.generate(5, (index) {
                final isActive = (index + 1) < currentStep;
                return Expanded(
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 2),
                    height: 3,
                    decoration: BoxDecoration(
                      color: isActive
                          ? AppColors.primaryGreen
                          : AppColors.lightGrey,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTermsContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Container(
          padding: const EdgeInsets.symmetric(vertical: 20),
          decoration: BoxDecoration(
            color: AppColors.primaryGreen.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: Column(
              children: [
                Icon(
                  Icons.gavel_rounded,
                  size: 48,
                  color: AppColors.darkGreen,
                ),
                const SizedBox(height: 12),
                Text(
                  'SYARAT DAN KETENTUAN VOTING',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.darkGreen,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'PEMILIHAN MAHASISWA UNIVERSITAS SUMATERA UTARA',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.grey,
                  ),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 24),

        // Important Notice
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.warning.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.warning),
          ),
          child: Row(
            children: [
              Icon(
                Icons.warning_amber_rounded,
                color: AppColors.warning,
                size: 24,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Dengan melanjutkan, Anda menyetujui semua ketentuan di bawah ini. '
                      'Pastikan Anda membacanya dengan saksama.',
                  style: TextStyle(
                    color: AppColors.darkGreen,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 24),

        // Terms Sections
        _buildTermSection(
          number: 1,
          title: 'KEABSAHAN SUARA',
          content: 'Suara yang diberikan melalui sistem e-voting "Suara Kita" '
              'dianggap sah dan mengikat secara hukum. Suara tidak dapat diubah, '
              'dibatalkan, atau ditarik kembali setelah dikirimkan.',
        ),

        _buildTermSection(
          number: 2,
          title: 'VERIFIKASI IDENTITAS',
          content: 'Setiap suara diverifikasi melalui dua faktor: '
              '1) Pengenalan wajah biometrik, dan 2) Scan QR Code KTM fisik. '
              'Sistem akan mencatat similarity score wajah untuk audit trail.',
        ),

        _buildTermSection(
          number: 3,
          title: 'SATU SUARA SATU MAHASISWA',
          content: 'Setiap mahasiswa USU yang terdaftar hanya berhak memberikan '
              'satu suara per pemilihan. Sistem akan mendeteksi dan mencegah '
              'upaya voting ganda.',
        ),

        _buildTermSection(
          number: 4,
          title: 'KERAHASIAAN SUARA',
          content: 'Suara Anda dijamin kerahasiaannya. Sistem tidak mencatat '
              'pilihan kandidat yang terhubung dengan identitas Anda setelah '
              'proses penghitungan suara.',
        ),

        _buildTermSection(
          number: 5,
          title: 'PERIODE VOTING',
          content: 'Voting hanya dapat dilakukan dalam periode yang ditentukan. '
              'Waktu server adalah patokan utama. Voting di luar periode yang '
              'ditentukan tidak akan diproses.',
        ),

        _buildTermSection(
          number: 6,
          title: 'SANKSI PELANGGARAN',
          content: 'Setiap upaya kecurangan, termasuk namun tidak terbatas pada: '
              '1) Penggunaan identitas orang lain, 2) Upaya manipulasi sistem, '
              '3) Voting ganda, akan dikenai sanksi sesuai peraturan universitas.',
        ),

        _buildTermSection(
          number: 7,
          title: 'DATA DAN PRIVASI',
          content: 'Data pribadi Anda dilindungi sesuai UU PDP. Data wajah '
              'hanya digunakan untuk verifikasi voting dan tidak akan dibagikan '
              'kepada pihak ketiga tanpa persetujuan, kecuali diminta oleh hukum.',
        ),

        _buildTermSection(
          number: 8,
          title: 'PENGAKUAN DAN PERSETUJUAN',
          content: 'Dengan mencentang kotak persetujuan, Anda mengakui bahwa: '
              '1) Anda adalah mahasiswa USU yang sah, '
              '2) Anda memberikan suara secara sukarela, '
              '3) Anda memahami semua ketentuan di atas.',
        ),

        const SizedBox(height: 32),

        // Legal Info
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[200]!),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Informasi Hukum:',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppColors.darkGreen,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Syarat dan ketentuan ini mengikat secara hukum sesuai '
                    'Peraturan Rektor USU No. 12/2023 tentang Pemilihan Online '
                    'dan peraturan perundang-undangan yang berlaku.',
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.grey,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Tanggal berlaku: 1 Januari 2024',
                style: TextStyle(
                  fontSize: 12,
                  fontStyle: FontStyle.italic,
                  color: AppColors.grey,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 40),
      ],
    );
  }

  Widget _buildTermSection({required int number, required String title, required String content}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: AppColors.primaryGreen.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    '$number',
                    style: TextStyle(
                      color: AppColors.primaryGreen,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppColors.darkGreen,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      content,
                      style: TextStyle(
                        color: Colors.grey[700],
                        fontSize: 14,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(height: 1, color: Colors.grey),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final votingProvider = context.watch<VotingProvider>();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Persetujuan Voting'),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: AppColors.darkGreen,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Progress stepper
            _buildProgressStepper(3),

            // Title
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Column(
                children: [
                  Text(
                    'Syarat dan Ketentuan',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: AppColors.darkGreen,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Baca dengan saksama sebelum melanjutkan',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.grey,
                    ),
                  ),
                ],
              ),
            ),

            // Scrollable terms
            Expanded(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(15),
                  child: Stack(
                    children: [
                      // Terms content
                      SingleChildScrollView(
                        controller: _scrollController,
                        padding: const EdgeInsets.all(20),
                        child: _buildTermsContent(),
                      ),

                      // Bottom gradient overlay (for scroll indicator)
                      if (!_hasReadTerms)
                        Positioned(
                          bottom: 0,
                          left: 0,
                          right: 0,
                          child: Container(
                            height: 60,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Colors.white.withOpacity(0.1),
                                  Colors.white.withOpacity(0.9),
                                  Colors.white,
                                ],
                              ),
                            ),
                            child: Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.arrow_downward_rounded,
                                    color: AppColors.grey,
                                    size: 20,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Gulir ke bawah untuk membaca semua',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: AppColors.grey,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),

            // Agreement checkbox
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: _isAgreed
                    ? AppColors.success.withOpacity(0.1)
                    : Colors.grey[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _isAgreed ? AppColors.success : Colors.grey[300]!,
                  width: _isAgreed ? 2 : 1,
                ),
              ),
              child: Row(
                children: [
                  // Checkbox
                  SizedBox(
                    width: 24,
                    height: 24,
                    child: Checkbox(
                      value: _isAgreed,
                      onChanged: (value) {
                        if (!_hasReadTerms && value == true) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: const Text(
                                'Harap baca semua syarat dan ketentuan terlebih dahulu',
                              ),
                              backgroundColor: AppColors.warning,
                            ),
                          );
                          return;
                        }

                        setState(() {
                          _isAgreed = value ?? false;
                        });

                        // Update provider
                        if (value != null) {
                          votingProvider.setAgreement(value);
                        }
                      },
                      activeColor: AppColors.primaryGreen,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                  ),

                  const SizedBox(width: 16),

                  // Agreement text
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Saya Setuju dengan Semua Syarat dan Ketentuan',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: AppColors.darkGreen,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Dengan mencentang, Anda menyatakan telah membaca '
                              'dan memahami semua ketentuan di atas',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Error message
            if (votingProvider.errorMessage != null)
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.error.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.error),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.error_outline,
                      color: AppColors.error,
                      size: 20,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        votingProvider.errorMessage!,
                        style: const TextStyle(
                          color: AppColors.error,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

            // Action buttons
            Container(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  // Read confirmation
                  if (!_hasReadTerms)
                    Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.warning.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: AppColors.warning),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.info_outline_rounded,
                            color: AppColors.warning,
                            size: 20,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'Harap gulir ke bawah untuk membaca semua syarat '
                                  'sebelum menyetujui',
                              style: TextStyle(
                                color: AppColors.darkGreen,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(context),
                          style: OutlinedButton.styleFrom(
                            minimumSize: const Size(0, 50),
                            side: const BorderSide(color: AppColors.grey),
                            foregroundColor: AppColors.grey,
                          ),
                          child: const Text('Kembali'),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: PrimaryButton(
                          onPressed: (_isAgreed && _hasReadTerms)
                              ? () {
                            // Navigate to candidate selection
                            Navigator.pushNamed(context, '/candidate-selection');
                          }
                              : null,
                          text: 'Lanjutkan',
                          isLoading: votingProvider.isLoading,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 8),

                  // Help text
                  Text(
                    'Step 3 dari 6 - Persetujuan',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.grey,
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
}