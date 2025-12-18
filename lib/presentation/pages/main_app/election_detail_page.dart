import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:suara_kita/core/constants/colors.dart';
import 'package:suara_kita/data/models/election_model.dart';
import 'package:suara_kita/data/models/candidate_model.dart';
import 'package:suara_kita/data/models/user_model.dart';
import 'package:suara_kita/services/firebase_service.dart';
import 'package:suara_kita/presentation/pages/voting_flow/voting_welcome_page.dart';
import 'package:suara_kita/core/utils/ktm_scanner_utils.dart';

class ElectionDetailPage extends StatefulWidget {
  final ElectionModel election;
  final User currentUser;

  const ElectionDetailPage({
    super.key,
    required this.election,
    required this.currentUser,
  });

  @override
  State<ElectionDetailPage> createState() => _ElectionDetailPageState();
}

class _ElectionDetailPageState extends State<ElectionDetailPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoadingStatus = true;
  bool _hasAlreadyVoted = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _checkVotingStatus();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _checkVotingStatus() async {
    try {
      final hasVoted = await FirebaseService.hasUserVoted(
          widget.currentUser.nim,
          widget.election.id
      );
      if (mounted) {
        setState(() {
          _hasAlreadyVoted = hasVoted;
          _isLoadingStatus = false;
        });
      }
    } catch (e) {
      print("Error checking vote status: $e");
      if (mounted) setState(() => _isLoadingStatus = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // --- LOGIKA WAKTU ---
    final now = DateTime.now();
    final isUpcoming = now.isBefore(widget.election.startDate);
    final isEnded = now.isAfter(widget.election.endDate);

    // Logika Tombol
    String buttonText = "VOTE SEKARANG";
    Color buttonColor = AppColors.primaryGreen;
    VoidCallback? onPressedAction;

    if (_isLoadingStatus) {
      // Loading state handled in UI
    } else if (_hasAlreadyVoted) {
      buttonText = "ANDA SUDAH MEMILIH";
      buttonColor = Colors.grey;
      onPressedAction = null;
    } else if (isUpcoming) {
      buttonText = "PEMILIHAN BELUM DIMULAI";
      buttonColor = Colors.orange;
      onPressedAction = null;
    } else if (isEnded) {
      buttonText = "PEMILIHAN SELESAI";
      buttonColor = Colors.redAccent;
      onPressedAction = null;
    } else {
      buttonText = "VOTE SEKARANG";
      buttonColor = AppColors.primaryGreen;
      onPressedAction = () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => VotingWelcomePage(election: widget.election),
          ),
        );
      };
    }

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: NestedScrollView(
        headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
          return <Widget>[
            SliverAppBar(
              expandedHeight: 240.0,
              pinned: true,
              elevation: 0,
              backgroundColor: Colors.white,
              // Tombol Back
              leading: IconButton(
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: innerBoxIsScrolled ? Colors.transparent : Colors.black26,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.arrow_back, color: innerBoxIsScrolled ? Colors.black : Colors.white, size: 20),
                ),
                onPressed: () => Navigator.pop(context),
              ),
              flexibleSpace: FlexibleSpaceBar(
                collapseMode: CollapseMode.pin,
                background: Stack(
                  fit: StackFit.expand,
                  children: [
                    // --- BANNER IMAGE (KEMBALI KE IMAGE.NETWORK) ---
                    // Menggunakan loadingBuilder agar tidak blank saat loading
                    widget.election.bannerUrl != null && widget.election.bannerUrl!.isNotEmpty
                        ? Image.network(
                      widget.election.bannerUrl!,
                      fit: BoxFit.cover,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Container(
                          color: Colors.grey[300],
                          child: Center(
                            child: CircularProgressIndicator(
                              value: loadingProgress.expectedTotalBytes != null
                                  ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                                  : null,
                              color: AppColors.primaryGreen,
                            ),
                          ),
                        );
                      },
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: AppColors.darkGreen,
                          child: const Icon(Icons.broken_image, size: 50, color: Colors.white54),
                        );
                      },
                    )
                        : Container(
                      color: AppColors.darkGreen,
                      child: const Icon(Icons.how_to_vote, size: 60, color: Colors.white),
                    ),

                    // Gradient Overlay (Agar tulisan/icon di atas gambar terlihat)
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.black.withOpacity(0.5),
                            Colors.transparent,
                          ],
                          stops: const [0.0, 0.6],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // --- UI TAB BAR (Style Baru) ---
              bottom: PreferredSize(
                preferredSize: const Size.fromHeight(48.0),
                child: Container(
                  color: Colors.white, // Background Solid Putih
                  child: TabBar(
                    controller: _tabController,
                    labelColor: AppColors.primaryGreen,
                    unselectedLabelColor: Colors.grey,
                    indicatorColor: AppColors.primaryGreen,
                    indicatorWeight: 3,
                    labelStyle: GoogleFonts.unbounded(fontWeight: FontWeight.bold, fontSize: 12),
                    tabs: const [
                      Tab(text: "KANDIDAT"),
                      Tab(text: "QUICK COUNT"),
                    ],
                  ),
                ),
              ),
            ),
          ];
        },
        body: TabBarView(
          controller: _tabController,
          children: [
            _buildCandidatesTab(),
            _buildQuickCountTab(),
          ],
        ),
      ),

      // --- TOMBOL VOTE ---
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -5))
          ],
        ),
        child: SizedBox(
          width: double.infinity,
          height: 50,
          child: _isLoadingStatus
              ? const Center(child: CircularProgressIndicator())
              : ElevatedButton(
            onPressed: onPressedAction,
            style: ElevatedButton.styleFrom(
              backgroundColor: buttonColor,
              disabledBackgroundColor: buttonColor.withOpacity(0.7),
              disabledForegroundColor: Colors.white,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: Text(
              buttonText,
              style: GoogleFonts.unbounded(fontSize: 14, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ),
    );
  }

  // ==========================================================
  // ISI TAB (CONTENT)
  // ==========================================================

  Widget _buildCandidatesTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Deskripsi", style: GoogleFonts.unbounded(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.darkGreen)),
          const SizedBox(height: 8),
          Text(widget.election.description, style: GoogleFonts.almarai(height: 1.5, color: Colors.grey[800])),
          const SizedBox(height: 24),

          StreamBuilder<List<CandidateModel>>(
            stream: FirebaseService.getCandidatesStream(widget.election.id),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
              if (!snapshot.hasData || snapshot.data!.isEmpty) return const Center(child: Text("Belum ada kandidat."));

              final candidates = snapshot.data!;
              return GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.70,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16
                ),
                itemCount: candidates.length,
                itemBuilder: (context, index) => _buildCandidateCard(candidates[index]),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildQuickCountTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.bar_chart_rounded, color: AppColors.darkGreen),
              const SizedBox(width: 8),
              Text("Real Count", style: GoogleFonts.unbounded(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.darkGreen)),
            ],
          ),
          const SizedBox(height: 4),
          const Text("Data diperbarui secara real-time dari server.", style: TextStyle(color: Colors.grey, fontSize: 12)),
          const SizedBox(height: 24),

          StreamBuilder<List<CandidateModel>>(
            stream: FirebaseService.getCandidatesStream(widget.election.id),
            builder: (context, candSnapshot) {
              if (!candSnapshot.hasData) return const Center(child: CircularProgressIndicator());

              final candidates = candSnapshot.data!;
              final totalVotes = candidates.fold(0, (sum, item) => sum + item.voteCount);

              return Column(
                children: [
                  // Total Votes Card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      gradient: AppColors.primaryGradient,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(color: AppColors.primaryGreen.withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 4)),
                      ],
                    ),
                    child: Column(
                      children: [
                        const Text("Total Suara Masuk", style: TextStyle(color: Colors.white70, fontSize: 14)),
                        const SizedBox(height: 4),
                        Text("$totalVotes", style: GoogleFonts.unbounded(fontSize: 48, color: Colors.white, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),

                  _buildSectionHeader("Perolehan Suara"),
                  ...candidates.map((c) {
                    final percentage = totalVotes == 0 ? 0.0 : (c.voteCount / totalVotes);
                    return _buildBarChartItem(c.name, c.voteCount, percentage, AppColors.primaryGreen);
                  }).toList(),

                  const SizedBox(height: 32),

                  _buildStambukAnalysis(widget.election.id, totalVotes),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildStambukAnalysis(String electionId, int totalVotes) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseService.getElectionVotes(electionId),
      builder: (context, voteSnapshot) {
        if (!voteSnapshot.hasData || voteSnapshot.data!.docs.isEmpty) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionHeader("Demografi Pemilih (Stambuk)"),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 10),
                child: Text("Menunggu data masuk...", style: TextStyle(color: Colors.grey)),
              ),
            ],
          );
        }

        final votes = voteSnapshot.data!.docs;
        Map<String, int> stambukCounts = {};
        for (var v in votes) {
          final data = v.data() as Map<String, dynamic>;
          final nim = data['voterNim']?.toString() ?? '';
          if (nim.isNotEmpty) {
            final stambuk = KTMScannerUtils.getAngkatanFromNIM(nim);
            stambukCounts[stambuk] = (stambukCounts[stambuk] ?? 0) + 1;
          }
        }

        final sortedStambuk = stambukCounts.keys.toList()..sort();

        return Column(
          children: [
            _buildSectionHeader("Demografi Pemilih (Stambuk)"),
            ...sortedStambuk.map((stambuk) {
              final count = stambukCounts[stambuk]!;
              final percentage = totalVotes == 0 ? 0.0 : (count / totalVotes);
              return _buildBarChartItem("Angkatan 20$stambuk", count, percentage, Colors.blueAccent);
            }).toList(),
          ],
        );
      },
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(width: 4, height: 24, decoration: BoxDecoration(color: AppColors.darkGreen, borderRadius: BorderRadius.circular(2))),
          const SizedBox(width: 12),
          Text(title, style: GoogleFonts.unbounded(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.darkGreen)),
        ],
      ),
    );
  }

  Widget _buildBarChartItem(String label, int value, double percentage, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label, style: GoogleFonts.almarai(fontWeight: FontWeight.bold, fontSize: 13)),
              Text("$value (${(percentage * 100).toStringAsFixed(1)}%)", style: GoogleFonts.almarai(fontWeight: FontWeight.bold, color: color, fontSize: 13)),
            ],
          ),
          const SizedBox(height: 8),
          Stack(
            children: [
              Container(height: 12, width: double.infinity, decoration: BoxDecoration(color: Colors.grey[200], borderRadius: BorderRadius.circular(6))),
              FractionallySizedBox(
                widthFactor: percentage == 0 ? 0.01 : percentage,
                child: Container(height: 12, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(6))),
              ),
            ],
          )
        ],
      ),
    );
  }

  // --- KARTU KANDIDAT JUGA KEMBALI MENGGUNAKAN IMAGE.NETWORK ---
  Widget _buildCandidateCard(CandidateModel candidate) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 4))],
        border: Border.all(color: Colors.grey[100]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
              child: candidate.photoUrl.isNotEmpty
                  ? Image.network(
                candidate.photoUrl,
                fit: BoxFit.cover,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Center(
                    child: CircularProgressIndicator(
                      value: loadingProgress.expectedTotalBytes != null
                          ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                          : null,
                      color: AppColors.primaryGreen,
                    ),
                  );
                },
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: Colors.grey[200],
                    child: const Icon(Icons.person_off, color: Colors.grey),
                  );
                },
              )
                  : Container(color: Colors.grey[100], child: const Icon(Icons.person, size: 40, color: Colors.grey)),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Column(
              children: [
                CircleAvatar(
                  radius: 12, backgroundColor: AppColors.primaryGreen,
                  child: Text(candidate.candidateNumber, style: const TextStyle(fontSize: 10, color: Colors.white, fontWeight: FontWeight.bold)),
                ),
                const SizedBox(height: 6),
                Text(
                    candidate.name,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.almarai(fontWeight: FontWeight.bold, fontSize: 12, height: 1.2)
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}