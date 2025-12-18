import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:suara_kita/data/models/user_model.dart';
import 'package:suara_kita/data/models/candidate_model.dart';
import 'package:suara_kita/data/models/election_model.dart';
import 'dart:convert';
import 'dart:typed_data';

class FirebaseService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final auth.FirebaseAuth _auth = auth.FirebaseAuth.instance;

  // Collection references
  static CollectionReference get usersCollection => _firestore.collection('users');
  static CollectionReference get electionsCollection => _firestore.collection('elections');
  static CollectionReference get candidatesCollection => _firestore.collection('candidates');
  static CollectionReference get votesCollection => _firestore.collection('votes');
  static CollectionReference get adminCollection => _firestore.collection('admins');
  static CollectionReference get votingActivitiesCollection => _firestore.collection('voting_activities');

  // ========== USER OPERATIONS ==========

  // Save user to Firestore
  static Future<void> saveUser(User user) async {
    try {
      await usersCollection.doc(user.nim).set(user.toMap());
      print('✅ User ${user.nim} saved successfully');
    } catch (e) {
      print('❌ Error saving user: $e');
      throw Exception('Gagal menyimpan user: $e');
    }
  }

  // Get user by NIM
  static Future<User?> getUserByNim(String nim) async {
    try {
      final doc = await usersCollection.doc(nim).get();
      if (doc.exists) {
        return User.fromMap(doc.data() as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      print('❌ Error getting user: $e');
      throw Exception('Gagal mengambil data user: $e');
    }
  }

  // Check if NIM already exists
  static Future<bool> isNimExists(String nim) async {
    try {
      final doc = await usersCollection.doc(nim).get();
      return doc.exists;
    } catch (e) {
      print('❌ Error checking NIM: $e');
      throw Exception('Gagal memeriksa NIM: $e');
    }
  }

  // Verify login (NIM + Password)
  static Future<User?> verifyLogin(String nim, String password) async {
    try {
      final user = await getUserByNim(nim);
      if (user != null && user.password == password) {
        print('✅ Login successful for NIM: $nim');
        return user;
      }
      print('❌ Login failed for NIM: $nim');
      return null;
    } catch (e) {
      print('❌ Error verifying login: $e');
      throw Exception('Gagal verifikasi login: $e');
    }
  }

  // Update user data
  static Future<void> updateUser(String nim, Map<String, dynamic> updates) async {
    try {
      await usersCollection.doc(nim).update(updates);
      print('✅ User $nim updated successfully');
    } catch (e) {
      print('❌ Error updating user: $e');
      throw Exception('Gagal mengupdate user: $e');
    }
  }

  // Update user's face embedding
  static Future<void> updateFaceEmbedding(String nim, List<double> embedding) async {
    try {
      // Convert embedding to Base64 string
      final base64String = _convertEmbeddingToBase64(embedding);

      await usersCollection.doc(nim).update({
        'face_embedding': base64String,
        'face_registered_at': FieldValue.serverTimestamp(),
        'is_face_registered': true,
      });
      print('✅ Face embedding updated for NIM: $nim');
    } catch (e) {
      print('❌ Error updating face embedding: $e');
      throw Exception('Gagal mengupdate embedding wajah: $e');
    }
  }

  // Check if user has face embedding
  static Future<bool> hasFaceEmbedding(String nim) async {
    try {
      final user = await getUserByNim(nim);
      return user?.faceEmbedding != null && user!.faceEmbedding!.isNotEmpty;
    } catch (e) {
      print('❌ Error checking face embedding: $e');
      return false;
    }
  }

  // ========== AUTH OPERATIONS ==========

  // Get current user
  static auth.User? get currentUser => _auth.currentUser;

  // Sign out
  static Future<void> signOut() async {
    try {
      await _auth.signOut();
      print('✅ User signed out successfully');
    } catch (e) {
      print('❌ Error signing out: $e');
      throw Exception('Gagal sign out: $e');
    }
  }

  // ========== ELECTION OPERATIONS ==========

  // Get all elections (old version - returns QuerySnapshot)
  static Stream<QuerySnapshot> getElections() {
    try {
      return electionsCollection
          .orderBy('startDate', descending: true)
          .snapshots();
    } catch (e) {
      print('❌ Error getting elections: $e');
      throw Exception('Gagal mengambil data pemilihan: $e');
    }
  }

  // Get all elections (new version - returns List<ElectionModel>)
  static Stream<List<ElectionModel>> getElectionsStream() {
    return electionsCollection
        .orderBy('startDate', descending: true) // Yang terbaru di atas
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        // Tambahkan print ini untuk debugging di console!
        print("Data Firestore: ${data['title']} - ID: ${doc.id}");
        return ElectionModel.fromMap(data);
      }).toList();
    });
  }

  // Get active elections (old version)
  static Stream<QuerySnapshot> getActiveElections() {
    try {
      final now = DateTime.now();
      return electionsCollection
          .where('status', isEqualTo: 'ONGOING')
          .where('endDate', isGreaterThan: now)
          .orderBy('endDate')
          .snapshots();
    } catch (e) {
      print('❌ Error getting active elections: $e');
      throw Exception('Gagal mengambil pemilihan aktif: $e');
    }
  }

  // Get active elections (new version)
  static Stream<List<ElectionModel>> getActiveElectionsStream() {
    final now = DateTime.now();
    return electionsCollection
        .where('status', isEqualTo: 'ONGOING')
        .where('endDate', isGreaterThan: now)
        .orderBy('endDate')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return ElectionModel.fromMap(data);
      }).toList();
    });
  }

  // Get election by ID (old version)
  static Future<DocumentSnapshot> getElectionById(String electionId) async {
    try {
      return await electionsCollection.doc(electionId).get();
    } catch (e) {
      print('❌ Error getting election: $e');
      throw Exception('Gagal mengambil data pemilihan: $e');
    }
  }

  // Get election by ID returning ElectionModel
  static Future<ElectionModel?> getElectionModelById(String electionId) async {
    try {
      final doc = await electionsCollection.doc(electionId).get();
      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return ElectionModel.fromMap(data);
      }
      return null;
    } catch (e) {
      print('❌ Error getting election model: $e');
      return null;
    }
  }

  // Add new election
  static Future<void> addElection(ElectionModel election) async {
    try {
      await electionsCollection.doc(election.id).set(election.toMap());
      print('✅ Election added successfully with ID: ${election.id}');
    } catch (e) {
      print('❌ Error adding election: $e');
      throw Exception('Gagal menambah pemilihan: $e');
    }
  }

  // Update election
  static Future<void> updateElection(String electionId, ElectionModel election) async {
    try {
      await electionsCollection.doc(electionId).update(election.toMap());
      print('✅ Election $electionId updated successfully');
    } catch (e) {
      print('❌ Error updating election: $e');
      throw Exception('Gagal mengupdate pemilihan: $e');
    }
  }

// Delete election (with cascade delete for candidates)
  static Future<void> deleteElection(String electionId) async {
    try {
      // Check if election has votes
      final votesSnapshot = await votesCollection
          .where('electionId', isEqualTo: electionId)
          .limit(1)
          .get();

      if (votesSnapshot.docs.isNotEmpty) {
        throw Exception('Pemilihan memiliki vote dan tidak dapat dihapus');
      }

      // Delete all candidates in this election first
      final candidatesSnapshot = await candidatesCollection
          .where('electionId', isEqualTo: electionId)
          .get();

      final batch = _firestore.batch();
      for (final candidateDoc in candidatesSnapshot.docs) {
        batch.delete(candidateDoc.reference);
      }

      // Delete the election
      batch.delete(electionsCollection.doc(electionId));

      await batch.commit();
      print('✅ Election $electionId and its candidates deleted successfully');
    } catch (e) {
      print('❌ Error deleting election: $e');
      throw Exception('Gagal menghapus pemilihan: $e');
    }
  }

  // Toggle election status (Active/Inactive)
  static Future<void> toggleElectionStatus(String electionId, bool isActive) async {
    try {
      final status = isActive ? 'ACTIVE' : 'INACTIVE';
      await electionsCollection.doc(electionId).update({
        'status': status,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      print('✅ Election $electionId status updated to: $status');
    } catch (e) {
      print('❌ Error toggling election status: $e');
      throw Exception('Gagal mengubah status pemilihan: $e');
    }
  }

  // Get upcoming elections
  static Stream<List<ElectionModel>> getUpcomingElectionsStream() {
    final now = DateTime.now();
    return electionsCollection
        .where('startDate', isGreaterThan: now)
        .orderBy('startDate')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return ElectionModel.fromMap(data);
      }).toList();
    });
  }

  // Get completed elections
  static Stream<List<ElectionModel>> getCompletedElectionsStream() {
    final now = DateTime.now();
    return electionsCollection
        .where('endDate', isLessThan: now)
        .orderBy('endDate', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return ElectionModel.fromMap(data);
      }).toList();
    });
  }

  // Get election statistics
  static Future<Map<String, dynamic>> getElectionStats(String electionId) async {
    try {
      final electionDoc = await electionsCollection.doc(electionId).get();
      if (!electionDoc.exists) {
        throw Exception('Pemilihan tidak ditemukan');
      }

      final candidatesSnapshot = await candidatesCollection
          .where('electionId', isEqualTo: electionId)
          .get();

      final votesSnapshot = await votesCollection
          .where('electionId', isEqualTo: electionId)
          .get();

      final totalVotes = votesSnapshot.docs.length;
      final totalCandidates = candidatesSnapshot.docs.length;

      return {
        'electionId': electionId,
        'totalCandidates': totalCandidates,
        'totalVotes': totalVotes,
        'voterTurnout': totalVotes, // TODO: Calculate percentage of registered users
        'lastUpdated': DateTime.now(),
      };
    } catch (e) {
      print('❌ Error getting election stats: $e');
      return {
        'error': e.toString(),
        'lastUpdated': DateTime.now(),
      };
    }
  }

  // ========== CANDIDATE OPERATIONS ==========

  // Get candidates for an election (old version - returns QuerySnapshot)
  static Stream<QuerySnapshot> getCandidates(String electionId) {
    try {
      return candidatesCollection
          .where('electionId', isEqualTo: electionId)
          .orderBy('candidateNumber')
          .snapshots();
    } catch (e) {
      print('❌ Error getting candidates: $e');
      throw Exception('Gagal mengambil data kandidat: $e');
    }
  }

  // Get candidates for an election (new version - returns List<CandidateModel>)
  static Stream<List<CandidateModel>> getCandidatesStream(String electionId) {
    return candidatesCollection
        .where('electionId', isEqualTo: electionId)
        .orderBy('candidateNumber') // String '01', '02', dst
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id; // Inject ID dokumen ke dalam model
        return CandidateModel.fromMap(data);
      }).toList();
    });
  }

  // Get candidate by ID
  static Future<DocumentSnapshot> getCandidateById(String candidateId) async {
    try {
      return await candidatesCollection.doc(candidateId).get();
    } catch (e) {
      print('❌ Error getting candidate: $e');
      throw Exception('Gagal mengambil data kandidat: $e');
    }
  }

  // Get candidate by ID returning CandidateModel
  static Future<CandidateModel?> getCandidateModelById(String candidateId) async {
    try {
      final doc = await candidatesCollection.doc(candidateId).get();
      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return CandidateModel.fromMap(data);
      }
      return null;
    } catch (e) {
      print('❌ Error getting candidate model: $e');
      return null;
    }
  }

  // Get candidate with details
  static Future<Map<String, dynamic>?> getCandidateWithDetails(String candidateId) async {
    try {
      final candidateDoc = await candidatesCollection.doc(candidateId).get();
      if (!candidateDoc.exists) return null;

      final candidateData = candidateDoc.data() as Map<String, dynamic>;

      // Get vote count for this candidate
      final votesSnapshot = await votesCollection
          .where('candidateId', isEqualTo: candidateId)
          .get();

      return {
        ...candidateData,
        'voteCount': votesSnapshot.docs.length,
      };
    } catch (e) {
      print('❌ Error getting candidate details: $e');
      return null;
    }
  }

  // Add new candidate (Updated version with custom ID generation)
  static Future<void> addCandidate(CandidateModel candidate) async {
    try {
      // Generate candidate ID menggunakan electionId dan candidateNumber
      final candidateId = '${candidate.electionId}_${candidate.candidateNumber.padLeft(3, '0')}';

      // Update candidate dengan ID yang sudah dibuat
      final candidateWithId = candidate.copyWith(id: candidateId);

      await candidatesCollection.doc(candidateId).set(candidateWithId.toMap());
      print('✅ Candidate added successfully with ID: $candidateId');
    } catch (e) {
      print('❌ Error adding candidate: $e');
      throw Exception('Gagal menambah kandidat: $e');
    }
  }

  // Update candidate
  static Future<void> updateCandidate(String candidateId, CandidateModel candidate) async {
    try {
      await candidatesCollection.doc(candidateId).update(candidate.toMap());
      print('✅ Candidate $candidateId updated successfully');
    } catch (e) {
      print('❌ Error updating candidate: $e');
      throw Exception('Gagal mengupdate kandidat: $e');
    }
  }

  // Delete candidate
  static Future<void> deleteCandidate(String candidateId) async {
    try {
      // Check if candidate has votes
      final votesSnapshot = await votesCollection
          .where('candidateId', isEqualTo: candidateId)
          .limit(1)
          .get();

      if (votesSnapshot.docs.isNotEmpty) {
        throw Exception('Kandidat memiliki vote dan tidak dapat dihapus');
      }

      await _firestore.collection('candidates').doc(candidateId).delete();
      print('✅ Candidate $candidateId deleted successfully');
    } catch (e) {
      print('❌ Error deleting candidate: $e');
      throw Exception('Gagal menghapus kandidat: $e');
    }
  }

  // Get all candidates (for admin)
  static Stream<List<CandidateModel>> getAllCandidatesStream() {
    return candidatesCollection
        .orderBy('electionId')
        .orderBy('candidateNumber')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return CandidateModel.fromMap(data);
      }).toList();
    });
  }

  // ========== VOTE OPERATIONS ==========

  // Submit vote (versi update dengan similarity score)
  static Future<void> submitVote({
    required String electionId,
    required String candidateId,
    required String voterNim,
    required String voterName,
    double? faceSimilarityScore,
  }) async {
    try {
      // Buat voteId unik
      final String voteId = '$electionId-$voterNim-${DateTime.now().millisecondsSinceEpoch}';

      final voteData = {
        'electionId': electionId,
        'candidateId': candidateId,
        'voterNim': voterNim,
        'voterName': voterName,
        'timestamp': FieldValue.serverTimestamp(),
        'voteId': voteId,
        'faceSimilarityScore': faceSimilarityScore,
        'isVerified': true,
      };

      // Check if user already voted in this election
      final existingVotes = await votesCollection
          .where('voterNim', isEqualTo: voterNim)
          .where('electionId', isEqualTo: electionId)
          .limit(1)
          .get();

      if (existingVotes.docs.isNotEmpty) {
        throw Exception('Anda sudah melakukan voting pada pemilihan ini');
      }

      // Submit vote
      await votesCollection.doc(voteId).set(voteData);

      // Update user's voted elections
      await usersCollection.doc(voterNim).update({
        'votedElections': FieldValue.arrayUnion([electionId]),
        'lastVotedAt': FieldValue.serverTimestamp(),
      });

      // Update candidate vote count
      await _updateCandidateVoteCount(candidateId);

      print('✅ Vote submitted successfully by $voterNim with similarity score: $faceSimilarityScore');
    } catch (e) {
      print('❌ Error submitting vote: $e');
      throw Exception('Gagal submit vote: $e');
    }
  }

  // Check if user has voted in an election
  static Future<bool> hasUserVoted(String nim, String electionId) async {
    try {
      final query = await votesCollection
          .where('voterNim', isEqualTo: nim)
          .where('electionId', isEqualTo: electionId)
          .limit(1)
          .get();

      return query.docs.isNotEmpty;
    } catch (e) {
      print('❌ Error checking vote: $e');
      return false;
    }
  }

  // Get vote count for candidate
  static Future<int> getCandidateVoteCount(String candidateId) async {
    try {
      final query = await votesCollection
          .where('candidateId', isEqualTo: candidateId)
          .get();

      return query.docs.length;
    } catch (e) {
      print('❌ Error getting candidate votes: $e');
      return 0;
    }
  }

  // Get votes for election
  static Stream<QuerySnapshot> getElectionVotes(String electionId) {
    try {
      return votesCollection
          .where('electionId', isEqualTo: electionId)
          // .orderBy('timestamp', descending: true)
          .snapshots();
    } catch (e) {
      print('❌ Error getting election votes: $e');
      throw Exception('Gagal mengambil data vote pemilihan: $e');
    }
  }

  // ========== VOTING ACTIVITY LOGGING ==========

  // Record voting activity for audit trail
  static Future<void> recordVotingActivity({
    required String nim,
    required String electionId,
    required String candidateId,
    String? candidateName,
    required String voterName,
    double? similarityScore,
    DateTime? timestamp,
    String? deviceInfo,
    String? ipAddress,
  }) async {
    try {
      final activityId = '${DateTime.now().millisecondsSinceEpoch}-$nim';

      final activityData = {
        'activityId': activityId,
        'nim': nim,
        'electionId': electionId,
        'candidateId': candidateId,
        'candidateName': candidateName,
        'voterName': voterName,
        'similarityScore': similarityScore,
        'timestamp': timestamp ?? DateTime.now(),
        'deviceInfo': deviceInfo ?? 'Flutter Mobile App',
        'ipAddress': ipAddress ?? 'unknown',
        'status': 'completed',
        'isSuccess': true,
      };

      await votingActivitiesCollection.doc(activityId).set(activityData);
      print('✅ Voting activity recorded for NIM: $nim');
    } catch (e) {
      print('⚠️ Error recording voting activity: $e');
      // Don't throw error since this is just logging
    }
  }

  // Get voting activities for user
  static Stream<QuerySnapshot> getUserVotingActivities(String nim) {
    try {
      return votingActivitiesCollection
          .where('nim', isEqualTo: nim)
          .orderBy('timestamp', descending: true)
          .limit(50)
          .snapshots();
    } catch (e) {
      print('❌ Error getting voting activities: $e');
      throw Exception('Gagal mengambil aktivitas voting: $e');
    }
  }

  // ========== ADMIN OPERATIONS ==========

  // Check if user is admin
  static Future<bool> isUserAdmin(String nim) async {
    try {
      final user = await getUserByNim(nim);
      return user != null && (user.role == UserRole.admin || user.role == UserRole.superAdmin);
    } catch (e) {
      print('❌ Error checking admin status: $e');
      return false;
    }
  }

  // Get all users (for admin)
  static Stream<QuerySnapshot> getAllUsers() {
    try {
      return usersCollection
          .orderBy('nim')
          .snapshots();
    } catch (e) {
      print('❌ Error getting all users: $e');
      throw Exception('Gagal mengambil data semua user: $e');
    }
  }

  // Get election results with statistics
  static Future<Map<String, dynamic>> getElectionResults(String electionId) async {
    try {
      // Get all votes for this election
      final votesSnapshot = await votesCollection
          .where('electionId', isEqualTo: electionId)
          .get();

      // Get all candidates for this election
      final candidatesSnapshot = await candidatesCollection
          .where('electionId', isEqualTo: electionId)
          .get();

      // Calculate statistics
      final totalVotes = votesSnapshot.docs.length;
      final candidateResults = <Map<String, dynamic>>[];

      for (final candidateDoc in candidatesSnapshot.docs) {
        final candidateId = candidateDoc.id;
        final candidateData = candidateDoc.data() as Map<String, dynamic>;

        final candidateVotes = votesSnapshot.docs
            .where((vote) => (vote.data() as Map<String, dynamic>)['candidateId'] == candidateId)
            .length;

        final percentage = totalVotes > 0 ? (candidateVotes / totalVotes * 100) : 0;

        candidateResults.add({
          'candidateId': candidateId,
          'candidateName': candidateData['name'],
          'candidateNumber': candidateData['candidateNumber'],
          'voteCount': candidateVotes,
          'percentage': percentage,
        });
      }

      return {
        'electionId': electionId,
        'totalVotes': totalVotes,
        'candidateResults': candidateResults,
        'timestamp': DateTime.now(),
      };
    } catch (e) {
      print('❌ Error getting election results: $e');
      throw Exception('Gagal mengambil hasil pemilihan: $e');
    }
  }

  // Create new election (legacy version)
  static Future<void> createElection(Map<String, dynamic> electionData) async {
    try {
      final String electionId = electionData['id'] as String;
      await electionsCollection.doc(electionId).set(electionData);
      print('✅ Election created successfully');
    } catch (e) {
      print('❌ Error creating election: $e');
      throw Exception('Gagal membuat pemilihan: $e');
    }
  }

  // Add candidate to election (legacy version)
  static Future<void> addCandidateLegacy(Map<String, dynamic> candidateData) async {
    try {
      final String candidateId = candidateData['id'] as String;
      await candidatesCollection.doc(candidateId).set(candidateData);
      print('✅ Candidate added successfully');
    } catch (e) {
      print('❌ Error adding candidate: $e');
      throw Exception('Gagal menambah kandidat: $e');
    }
  }

  // ========== PRIVATE HELPER METHODS ==========

  // Update candidate vote count
  static Future<void> _updateCandidateVoteCount(String candidateId) async {
    try {
      final voteCount = await getCandidateVoteCount(candidateId);
      await candidatesCollection.doc(candidateId).update({
        'voteCount': voteCount,
        'lastVoteUpdate': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('⚠️ Error updating candidate vote count: $e');
      // Don't throw error, this is non-critical
    }
  }

  // Convert embedding list to Base64
  static String _convertEmbeddingToBase64(List<double> embedding) {
    try {
      // Convert to Float32List
      final float32List = Float32List.fromList(embedding);
      // Convert to bytes
      final bytes = float32List.buffer.asUint8List();
      // Encode to Base64
      return base64Encode(bytes);
    } catch (e) {
      print('❌ Error converting embedding to Base64: $e');
      return '';
    }
  }

  // Convert Base64 to embedding list
  static List<double> _convertBase64ToEmbedding(String base64String) {
    try {
      final bytes = base64Decode(base64String);
      final float32List = Float32List.view(bytes.buffer);
      return float32List.toList();
    } catch (e) {
      print('❌ Error converting Base64 to embedding: $e');
      return [];
    }
  }

  // ========== UTILITY METHODS ==========

  // Get server timestamp
  static DateTime get serverTimestamp {
    return DateTime.now();
  }

  // Batch write operation
  static Future<void> batchWrite(List<Map<String, dynamic>> operations) async {
    try {
      final batch = _firestore.batch();

      for (final operation in operations) {
        final String type = operation['type'] as String;
        final String path = operation['path'] as String;
        final dynamic data = operation['data'];

        switch (type) {
          case 'set':
            batch.set(_firestore.doc(path), data);
            break;
          case 'update':
            batch.update(_firestore.doc(path), data);
            break;
          case 'delete':
            batch.delete(_firestore.doc(path));
            break;
        }
      }

      await batch.commit();
      print('✅ Batch write completed successfully');
    } catch (e) {
      print('❌ Error in batch write: $e');
      throw Exception('Gagal melakukan operasi batch: $e');
    }
  }

  // Clear all collections (for testing only)
  static Future<void> clearAllData() async {
    try {
      final collections = [
        usersCollection,
        electionsCollection,
        candidatesCollection,
        votesCollection,
        votingActivitiesCollection,
      ];

      for (final collection in collections) {
        final snapshot = await collection.get();
        final batch = _firestore.batch();

        for (final doc in snapshot.docs) {
          batch.delete(doc.reference);
        }

        await batch.commit();
      }

      print('✅ All data cleared successfully');
    } catch (e) {
      print('❌ Error clearing data: $e');
      throw Exception('Gagal menghapus data: $e');
    }
  }

  // Get database statistics
  static Future<Map<String, dynamic>> getDatabaseStats() async {
    try {
      final usersCount = (await usersCollection.get()).docs.length;
      final electionsCount = (await electionsCollection.get()).docs.length;
      final candidatesCount = (await candidatesCollection.get()).docs.length;
      final votesCount = (await votesCollection.get()).docs.length;
      final activitiesCount = (await votingActivitiesCollection.get()).docs.length;

      // Get active elections count
      final activeElections = await electionsCollection
          .where('status', isEqualTo: 'ACTIVE')
          .get();

      return {
        'users': usersCount,
        'elections': electionsCount,
        'activeElections': activeElections.docs.length,
        'candidates': candidatesCount,
        'votes': votesCount,
        'activities': activitiesCount,
        'lastUpdated': DateTime.now(),
      };
    } catch (e) {
      print('❌ Error getting database stats: $e');
      return {
        'error': e.toString(),
        'lastUpdated': DateTime.now(),
      };
    }
  }

  // Backup all data (for admin)
  static Future<Map<String, dynamic>> backupAllData() async {
    try {
      final users = await usersCollection.get();
      final elections = await electionsCollection.get();
      final candidates = await candidatesCollection.get();
      final votes = await votesCollection.get();
      final activities = await votingActivitiesCollection.get();

      return {
        'timestamp': DateTime.now(),
        'users': users.docs.map((doc) => doc.data()).toList(),
        'elections': elections.docs.map((doc) => doc.data()).toList(),
        'candidates': candidates.docs.map((doc) => doc.data()).toList(),
        'votes': votes.docs.map((doc) => doc.data()).toList(),
        'activities': activities.docs.map((doc) => doc.data()).toList(),
      };
    } catch (e) {
      print('❌ Error backing up data: $e');
      throw Exception('Gagal membuat backup data: $e');
    }
  }

  // Search elections by title
  static Stream<List<ElectionModel>> searchElections(String query) {
    return electionsCollection
        .where('title', isGreaterThanOrEqualTo: query)
        .where('title', isLessThanOrEqualTo: '$query\uf8ff')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return ElectionModel.fromMap(data);
      }).toList();
    });
  }

  // Get election with candidates
  static Future<Map<String, dynamic>> getElectionWithCandidates(String electionId) async {
    try {
      final election = await getElectionModelById(electionId);
      if (election == null) {
        throw Exception('Pemilihan tidak ditemukan');
      }

      final candidates = await candidatesCollection
          .where('electionId', isEqualTo: electionId)
          .get();

      return {
        'election': election.toMap(),
        'candidates': candidates.docs.map((doc) => doc.data()).toList(),
        'totalCandidates': candidates.docs.length,
      };
    } catch (e) {
      print('❌ Error getting election with candidates: $e');
      throw Exception('Gagal mengambil data pemilihan dengan kandidat: $e');
    }
  }

  // Update election visibility
  static Future<void> updateElectionVisibility(String electionId, bool isPublic) async {
    try {
      await electionsCollection.doc(electionId).update({
        'isPublic': isPublic,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      print('✅ Election $electionId visibility updated to: ${isPublic ? 'Public' : 'Private'}');
    } catch (e) {
      print('❌ Error updating election visibility: $e');
      throw Exception('Gagal mengupdate visibilitas pemilihan: $e');
    }
  }

  // Get election participation rate
  static Future<double> getElectionParticipationRate(String electionId) async {
    try {
      final totalUsers = (await usersCollection.get()).docs.length;
      final totalVotes = await votesCollection
          .where('electionId', isEqualTo: electionId)
          .get()
          .then((snapshot) => snapshot.docs.length);

      if (totalUsers == 0) return 0.0;
      return (totalVotes / totalUsers) * 100;
    } catch (e) {
      print('❌ Error getting participation rate: $e');
      return 0.0;
    }
  }

  // Get elections stream for admin (without any filters)
  static Stream<List<ElectionModel>> getElectionsForAdminStream() {
    return _firestore
        .collection('elections')
        .orderBy('startDate', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        print("Data Firestore Admin View: ${data['title']} - ID: ${doc.id}");
        return ElectionModel.fromMap(data);
      }).toList();
    });
  }

  // Get all elections with pagination
  static Future<List<ElectionModel>> getElectionsWithPagination({
    required int limit,
    DocumentSnapshot? lastDocument,
  }) async {
    try {
      Query query = electionsCollection
          .orderBy('startDate', descending: true)
          .limit(limit);

      if (lastDocument != null) {
        query = query.startAfterDocument(lastDocument);
      }

      final snapshot = await query.get();

      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return ElectionModel.fromMap(data);
      }).toList();
    } catch (e) {
      print('❌ Error getting elections with pagination: $e');
      return [];
    }
  }

  // Get elections by status
  static Stream<List<ElectionModel>> getElectionsByStatus(String status) {
    return electionsCollection
        .where('status', isEqualTo: status)
        .orderBy('startDate', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return ElectionModel.fromMap(data);
      }).toList();
    });
  }

  // Get election by faculty filter
  static Stream<List<ElectionModel>> getElectionsByFaculty(String faculty) {
    return electionsCollection
        .where('facultyFilter', isEqualTo: faculty)
        .where('status', isEqualTo: 'ACTIVE')
        .orderBy('startDate', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return ElectionModel.fromMap(data);
      }).toList();
    });
  }

  // Check if election exists
  static Future<bool> doesElectionExist(String electionId) async {
    try {
      final doc = await electionsCollection.doc(electionId).get();
      return doc.exists;
    } catch (e) {
      print('❌ Error checking election existence: $e');
      return false;
    }
  }

  // Get election count by status
  static Future<Map<String, int>> getElectionCountByStatus() async {
    try {
      final active = await electionsCollection
          .where('status', isEqualTo: 'ACTIVE')
          .get()
          .then((snapshot) => snapshot.docs.length);

      final upcoming = await electionsCollection
          .where('startDate', isGreaterThan: DateTime.now())
          .get()
          .then((snapshot) => snapshot.docs.length);

      final completed = await electionsCollection
          .where('endDate', isLessThan: DateTime.now())
          .get()
          .then((snapshot) => snapshot.docs.length);

      final total = await electionsCollection
          .get()
          .then((snapshot) => snapshot.docs.length);

      return {
        'active': active,
        'upcoming': upcoming,
        'completed': completed,
        'total': total,
      };
    } catch (e) {
      print('❌ Error getting election count by status: $e');
      return {
        'active': 0,
        'upcoming': 0,
        'completed': 0,
        'total': 0,
      };
    }
  }

  // Get recent elections
  static Stream<List<ElectionModel>> getRecentElections({int limit = 5}) {
    return electionsCollection
        .orderBy('createdAt', descending: true)
        .limit(limit)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return ElectionModel.fromMap(data);
      }).toList();
    });
  }
}