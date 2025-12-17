import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:suara_kita/data/models/user_model.dart';
import 'dart:convert'; // Untuk base64 encode/decode
import 'dart:typed_data'; // Untuk Float32List

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

  // Get all elections
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

  // Get active elections
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

  // Get election by ID
  static Future<DocumentSnapshot> getElectionById(String electionId) async {
    try {
      return await electionsCollection.doc(electionId).get();
    } catch (e) {
      print('❌ Error getting election: $e');
      throw Exception('Gagal mengambil data pemilihan: $e');
    }
  }

  // ========== CANDIDATE OPERATIONS ==========

  // Get candidates for an election
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

  // Get candidate by ID
  static Future<DocumentSnapshot> getCandidateById(String candidateId) async {
    try {
      return await candidatesCollection.doc(candidateId).get();
    } catch (e) {
      print('❌ Error getting candidate: $e');
      throw Exception('Gagal mengambil data kandidat: $e');
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
          .orderBy('timestamp', descending: true)
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

  // Create new election
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

  // Add candidate to election
  static Future<void> addCandidate(Map<String, dynamic> candidateData) async {
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

      return {
        'users': usersCount,
        'elections': electionsCount,
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
}