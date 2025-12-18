import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:suara_kita/core/constants/colors.dart';
import 'package:suara_kita/data/models/candidate_model.dart';
import 'package:suara_kita/services/firebase_service.dart';
import 'package:suara_kita/presentation/pages/admin/add_candidate_page.dart'; // Import halaman add

class ManageCandidatesPage extends StatefulWidget {
  final String electionId; // ID Pemilihan (misal: 'pemira_2025')

  const ManageCandidatesPage({super.key, required this.electionId});

  @override
  State<ManageCandidatesPage> createState() => _ManageCandidatesPageState();
}

class _ManageCandidatesPageState extends State<ManageCandidatesPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: Text(
          'Kelola Kandidat',
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
      body: StreamBuilder<List<CandidateModel>>(
        stream: FirebaseService.getCandidatesStream(widget.electionId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.person_add_disabled_rounded, size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  Text(
                    'Belum ada kandidat terdaftar',
                    style: GoogleFonts.almarai(color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          final candidates = snapshot.data!;
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: candidates.length,
            itemBuilder: (context, index) {
              final candidate = candidates[index];
              return _buildCandidateCard(candidate);
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // Navigasi ke halaman AddCandidatePage
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddCandidatePage(electionId: widget.electionId),
            ),
          );
        },
        backgroundColor: AppColors.primaryGreen,
        label: const Text('Tambah', style: TextStyle(color: Colors.white)),
        icon: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildCandidateCard(CandidateModel candidate) {
    return Card(
      elevation: 3,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ExpansionTile(
        leading: CircleAvatar(
          radius: 25,
          backgroundColor: Colors.grey[200],
          backgroundImage: candidate.photoUrl.isNotEmpty
              ? NetworkImage(candidate.photoUrl)
              : null,
          child: candidate.photoUrl.isEmpty ? const Icon(Icons.person) : null,
        ),
        title: Text(
          'No. ${candidate.candidateNumber} - ${candidate.name}',
          style: GoogleFonts.unbounded(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: AppColors.darkGreen,
          ),
        ),
        subtitle: Text(
          '${candidate.major} - ${candidate.faculty}',
          style: GoogleFonts.almarai(fontSize: 12),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildDetailRow(Icons.badge, 'NIM', candidate.nim),
                _buildDetailRow(Icons.phone, 'HP', candidate.phoneNumber),
                _buildDetailRow(Icons.visibility, 'Visi', candidate.vision),
                if (candidate.instagramUrl.isNotEmpty)
                  _buildDetailRow(Icons.camera_alt, 'IG', candidate.instagramUrl),

                const SizedBox(height: 10),
                const Divider(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton.icon(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      label: const Text('Hapus Kandidat', style: TextStyle(color: Colors.red)),
                      onPressed: () => _confirmDelete(candidate),
                    ),
                  ],
                )
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: Colors.grey),
          const SizedBox(width: 8),
          SizedBox(
            width: 70,
            child: Text('$label:', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
          ),
          Expanded(child: Text(value, style: const TextStyle(fontSize: 12))),
        ],
      ),
    );
  }

  void _confirmDelete(CandidateModel candidate) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Kandidat?'),
        content: Text('Anda yakin ingin menghapus ${candidate.name}? Data tidak dapat dikembalikan.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Batal')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
            onPressed: () async {
              await FirebaseService.deleteCandidate(candidate.id);
              if (mounted) Navigator.pop(context);
            },
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }
}