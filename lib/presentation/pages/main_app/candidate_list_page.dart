import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:suara_kita/presentation/providers/election_provider.dart';
import 'package:suara_kita/presentation/widgets/candidate/candidate_card.dart';

import '../../../data/models/candidate_model.dart';

class CandidateListPage extends StatefulWidget {
  const CandidateListPage({Key? key}) : super(key: key);

  @override
  State<CandidateListPage> createState() => _CandidateListPageState();
}

class _CandidateListPageState extends State<CandidateListPage> {
  @override
  void initState() {
    super.initState();
    _loadCandidates();
  }

  void _loadCandidates() {
    final provider = Provider.of<ElectionProvider>(context, listen: false);
    if (provider.currentElection != null) {
      provider.loadCandidatesForElection(provider.currentElection!.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    final electionProvider = Provider.of<ElectionProvider>(context);
    final currentElection = electionProvider.currentElection;
    final candidates = electionProvider.currentCandidates;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          currentElection?.title ?? 'Daftar Kandidat',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: Color(0xFF00C64F),
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: _buildBody(electionProvider, candidates),
    );
  }

  Widget _buildBody(ElectionProvider provider, List<CandidateModel> candidates) {
    if (provider.isLoading) {
      return Center(child: CircularProgressIndicator());
    }

    if (provider.error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Error: ${provider.error}'),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadCandidates,
              child: Text('Coba Lagi'),
            ),
          ],
        ),
      );
    }

    if (candidates.isEmpty) {
      return Center(
        child: Text(
          'Belum ada kandidat untuk pemilihan ini.',
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
      );
    }

    // Sort candidates by candidateNumber
    candidates.sort((a, b) => a.candidateNumber.compareTo(b.candidateNumber));

    return ListView.builder(
      padding: EdgeInsets.all(16),
      itemCount: candidates.length,
      itemBuilder: (context, index) {
        final candidate = candidates[index];
        return CandidateCard(
          candidate: candidate,
          onTap: () {
            // Navigate to voting flow
            Navigator.pushNamed(context, '/voting_face_verify', arguments: candidate.id);
          },
        );
      },
    );
  }
}