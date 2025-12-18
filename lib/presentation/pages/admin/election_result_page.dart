import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:suara_kita/core/constants/colors.dart';
import 'package:suara_kita/data/models/election_model.dart';
import 'package:suara_kita/data/models/candidate_model.dart';
import 'package:suara_kita/services/firebase_service.dart';

class ElectionResultPage extends StatelessWidget {
  final ElectionModel election;

  const ElectionResultPage({super.key, required this.election});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Hasil Real Count', style: GoogleFonts.unbounded(fontSize: 16, color: Colors.white)),
        backgroundColor: AppColors.primaryGreen,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: StreamBuilder<List<CandidateModel>>(
        stream: FirebaseService.getCandidatesStream(election.id),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

          final candidates = snapshot.data!;
          // Hitung total suara masuk
          int totalVotes = candidates.fold(0, (sum, item) => sum + item.voteCount);

          return Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: [
                // Header Info
                Text(
                  election.title,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.unbounded(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text("Total Suara Masuk: $totalVotes", style: const TextStyle(fontSize: 16, color: Colors.grey)),
                const SizedBox(height: 30),

                // List Grafik Batang
                Expanded(
                  child: ListView.builder(
                    itemCount: candidates.length,
                    itemBuilder: (context, index) {
                      final candidate = candidates[index];
                      // Hitung persentase
                      double percentage = totalVotes == 0 ? 0 : (candidate.voteCount / totalVotes);

                      return Container(
                        margin: const EdgeInsets.only(bottom: 24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "No. ${candidate.candidateNumber} - ${candidate.name}",
                                  style: const TextStyle(fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  "${(percentage * 100).toStringAsFixed(1)}% (${candidate.voteCount})",
                                  style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.primaryGreen),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            // Custom Bar Chart
                            Stack(
                              children: [
                                Container(
                                  height: 20,
                                  width: double.infinity,
                                  decoration: BoxDecoration(
                                    color: Colors.grey[200],
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                FractionallySizedBox(
                                  widthFactor: percentage == 0 ? 0.01 : percentage, // Minimal width dikit biar kelihatan
                                  child: Container(
                                    height: 20,
                                    decoration: BoxDecoration(
                                      color: AppColors.primaryGreen,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}