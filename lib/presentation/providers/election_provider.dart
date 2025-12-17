import 'package:flutter/foundation.dart';
import 'package:suara_kita/data/models/election_model.dart';
import 'package:suara_kita/data/models/candidate_model.dart';
import 'package:suara_kita/services/firebase_service.dart';

class ElectionProvider with ChangeNotifier {
  List<ElectionModel> _elections = [];
  List<ElectionModel> _ongoingElections = [];
  List<ElectionModel> _upcomingElections = [];
  List<ElectionModel> _completedElections = [];

  ElectionModel? _currentElection;
  List<CandidateModel> _currentCandidates = [];

  bool _isLoading = false;
  String? _error;

  // Getters
  List<ElectionModel> get elections => _elections;
  List<ElectionModel> get ongoingElections => _ongoingElections;
  List<ElectionModel> get upcomingElections => _upcomingElections;
  List<ElectionModel> get completedElections => _completedElections;
  ElectionModel? get currentElection => _currentElection;
  List<CandidateModel> get currentCandidates => _currentCandidates;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Load all elections from Firebase
  Future<void> loadElections() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final querySnapshot = await FirebaseService.electionsCollection.get();

      _elections = querySnapshot.docs.map((doc) {
        // FIXED: fromMap hanya menerima 1 parameter Map, bukan 2 parameter
        // Gabungkan id ke dalam map data
        final data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id; // Tambahkan id ke dalam data
        return ElectionModel.fromMap(data);
      }).toList();

      _categorizeElections();

    } catch (e) {
      _error = 'Failed to load elections: $e';
      print('❌ Error loading elections: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Load candidates for specific election
  Future<void> loadCandidatesForElection(String electionId) async {
    _isLoading = true;
    notifyListeners();

    try {
      final querySnapshot = await FirebaseService.candidatesCollection
          .where('electionId', isEqualTo: electionId)
          .get();

      _currentCandidates = querySnapshot.docs.map((doc) {
        // FIXED: fromMap hanya menerima 1 parameter Map, bukan 2 parameter
        // Gabungkan id ke dalam map data
        final data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id; // Tambahkan id ke dalam data
        return CandidateModel.fromMap(data);
      }).toList();

    } catch (e) {
      _error = 'Failed to load candidates: $e';
      print('❌ Error loading candidates: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Set current election
  void setCurrentElection(ElectionModel election) {
    _currentElection = election;
    loadCandidatesForElection(election.id);
    notifyListeners(); // Jangan lupa tambahkan ini
  }

  // Submit vote
  Future<bool> submitVote(String candidateId, String voterNim, String voterName) async {
    if (_currentElection == null) return false;

    try {
      _isLoading = true;
      notifyListeners();

      await FirebaseService.submitVote(
        electionId: _currentElection!.id,
        candidateId: candidateId,
        voterNim: voterNim,
        voterName: voterName,
      );

      _isLoading = false;
      notifyListeners();
      return true;

    } catch (e) {
      _error = 'Voting failed: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Check if user has voted in current election
  Future<bool> hasUserVoted(String nim) async {
    if (_currentElection == null) return false;

    return await FirebaseService.hasUserVoted(nim, _currentElection!.id);
  }

  // Private methods
  void _categorizeElections() {
    // Variabel 'now' tidak digunakan, bisa dihapus atau digunakan
    final now = DateTime.now(); // Masih tetap dideklarasikan tapi tidak digunakan

    _ongoingElections = _elections.where((election) => election.isOngoing).toList();
    _upcomingElections = _elections.where((election) => election.isUpcoming).toList();
    _completedElections = _elections.where((election) => election.isCompleted).toList();
  }

  // Optional: Tambahkan method untuk clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }
}