import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:suara_kita/core/constants/colors.dart';
import 'package:suara_kita/data/models/election_model.dart';
import 'package:suara_kita/services/firebase_service.dart';
import 'package:suara_kita/presentation/pages/admin/election_result_page.dart'; // Import Halaman Grafik

class ManageResultsPage extends StatelessWidget {
  const ManageResultsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Pilih Pemilihan', style: GoogleFonts.unbounded(color: Colors.white, fontSize: 18)),
        backgroundColor: AppColors.primaryGreen,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: StreamBuilder<List<ElectionModel>>(
        stream: FirebaseService.getElectionsStream(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          final elections = snapshot.data!;

          if (elections.isEmpty) {
            return const Center(child: Text("Belum ada data pemilihan"));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: elections.length,
            itemBuilder: (context, index) {
              final election = elections[index];
              return Card(
                elevation: 2,
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: AppColors.primaryGreen.withOpacity(0.1),
                    child: const Icon(Icons.bar_chart, color: AppColors.primaryGreen),
                  ),
                  title: Text(election.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text("Lihat hasil real count"),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ElectionResultPage(election: election),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}