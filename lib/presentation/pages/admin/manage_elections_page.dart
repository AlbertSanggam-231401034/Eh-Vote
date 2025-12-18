import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:suara_kita/core/constants/colors.dart';
import 'package:suara_kita/data/models/election_model.dart';
import 'package:suara_kita/services/firebase_service.dart';
import 'package:suara_kita/presentation/pages/admin/add_election_page.dart';
import 'package:suara_kita/presentation/pages/admin/manage_candidates_page.dart';

class ManageElectionsPage extends StatefulWidget {
  const ManageElectionsPage({super.key});

  @override
  State<ManageElectionsPage> createState() => _ManageElectionsPageState();
}

class _ManageElectionsPageState extends State<ManageElectionsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: Text(
          'Kelola Pemilihan',
          style: GoogleFonts.unbounded(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: AppColors.primaryGreen,
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      // ✅ GUNAKAN getElectionsForAdminStream jika ada (tanpa filter apapun)
      // Jika tidak, getElectionsStream juga oke asalkan tidak ada 'where' clause di service.
      body: StreamBuilder<List<ElectionModel>>(
        stream: FirebaseService.getElectionsStream(),
        builder: (context, snapshot) {
          // --- DEBUG LOGS (Cek Console!) ---
          if (snapshot.connectionState == ConnectionState.active) {
            print("ADMIN STREAM ACTIVE. Data Count: ${snapshot.data?.length ?? 0}");
            if (snapshot.data != null) {
              for (var e in snapshot.data!) {
                print(" - Election: ${e.title} (ID: ${e.id})");
              }
            }
          }
          // --------------------------------

          // 1. Loading State
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          // 2. Error State
          if (snapshot.hasError) {
            print("❌ Error Stream Admin: ${snapshot.error}");
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Text('Terjadi kesalahan: ${snapshot.error}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.red),
                ),
              ),
            );
          }

          // 3. Empty State
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.ballot_outlined, size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  Text(
                    'Belum ada pemilihan dibuat',
                    style: GoogleFonts.almarai(color: Colors.grey),
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const AddElectionPage()),
                      );
                    },
                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryGreen),
                    child: const Text("Buat Sekarang", style: TextStyle(color: Colors.white)),
                  )
                ],
              ),
            );
          }

          // 4. Data Exists
          final elections = snapshot.data!;
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: elections.length,
            itemBuilder: (context, index) {
              final election = elections[index];
              return _buildElectionCard(election);
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddElectionPage()),
          );
        },
        backgroundColor: AppColors.primaryGreen,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildElectionCard(ElectionModel election) {
    bool isExpired = DateTime.now().isAfter(election.endDate);

    return Card(
      elevation: 3,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          // Navigasi ke Kelola Kandidat
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ManageCandidatesPage(electionId: election.id),
            ),
          );
        },
        child: Column(
          children: [
            // Banner Kecil
            if (election.bannerUrl != null && election.bannerUrl!.isNotEmpty)
              Container(
                height: 120,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                  image: DecorationImage(
                    image: NetworkImage(election.bannerUrl!),
                    fit: BoxFit.cover,
                  ),
                ),
              )
            else
              Container(
                height: 80,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                ),
                child: const Center(child: Icon(Icons.image_not_supported, color: Colors.grey)),
              ),

            ListTile(
              contentPadding: const EdgeInsets.all(16),
              title: Row(
                children: [
                  Expanded(
                    child: Text(
                      election.title,
                      style: GoogleFonts.unbounded(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.darkGreen,
                      ),
                    ),
                  ),
                  if (isExpired)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                          color: Colors.grey,
                          borderRadius: BorderRadius.circular(4)
                      ),
                      child: const Text("Selesai", style: TextStyle(color: Colors.white, fontSize: 10)),
                    )
                ],
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 4),
                  Text(election.description, maxLines: 2, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.calendar_today, size: 12, color: Colors.grey),
                      const SizedBox(width: 4),
                      Text(
                        "${election.startDate.day}/${election.startDate.month}/${election.startDate.year}",
                        style: const TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ],
                  ),
                ],
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => _confirmDelete(context, election),
                  ),
                  const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context, ElectionModel election) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Pemilihan?'),
        content: Text('Anda yakin ingin menghapus "${election.title}"? \n\nSemua data kandidat dan suara yang terkait akan ikut terhapus!'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Batal')
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
            onPressed: () async {
              await FirebaseService.deleteElection(election.id);
              if (context.mounted) Navigator.pop(context);
            },
            child: const Text('Hapus Permanen'),
          ),
        ],
      ),
    );
  }
}