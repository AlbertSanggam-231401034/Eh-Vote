import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:suara_kita/data/models/user_model.dart';

class FirebaseService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final auth.FirebaseAuth _auth = auth.FirebaseAuth.instance;

  // Collection references
  static CollectionReference get usersCollection => _firestore.collection('users');
  static CollectionReference get electionsCollection => _firestore.collection('elections');
  static CollectionReference get candidatesCollection => _firestore.collection('candidates');
  static CollectionReference get votesCollection => _firestore.collection('votes');
  static CollectionReference get adminCollection => _firestore.collection('admins');

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

  // ========== VOTE OPERATIONS ==========

  // Submit vote - PERBAIKAN DI SINI
  static Future<void> submitVote({
    required String electionId,
    required String candidateId,
    required String voterNim,
    required String voterName,
  }) async {
    try {
      // Buat voteId terlebih dahulu
      final String voteId = '$electionId-$voterNim';

      final voteData = {
        'electionId': electionId,
        'candidateId': candidateId,
        'voterNim': voterNim,
        'voterName': voterName,
        'timestamp': FieldValue.serverTimestamp(),
        'voteId': voteId, // Gunakan variabel yang sudah dibuat
      };

      // Check if user already voted - PERBAIKAN: gunakan variabel voteId
      final existingVote = await votesCollection.doc(voteId).get();
      if (existingVote.exists) {
        throw Exception('Anda sudah melakukan voting pada pemilihan ini');
      }

      // Submit vote - PERBAIKAN: gunakan variabel voteId
      await votesCollection.doc(voteId).set(voteData);

      // Update user's voted elections
      await usersCollection.doc(voterNim).update({
        'votedElections': FieldValue.arrayUnion([electionId])
      });

      print('✅ Vote submitted successfully by $voterNim');
    } catch (e) {
      print('❌ Error submitting vote: $e');
      throw Exception('Gagal submit vote: $e');
    }
  }

  // Check if user has voted in an election
  static Future<bool> hasUserVoted(String nim, String electionId) async {
    try {
      final String voteId = '$electionId-$nim'; // PERBAIKAN: buat variabel terlebih dahulu
      final doc = await votesCollection.doc(voteId).get();
      return doc.exists;
    } catch (e) {
      print('❌ Error checking vote: $e');
      return false;
    }
  }

  // Get vote count for candidate
  static Stream<QuerySnapshot> getCandidateVotes(String candidateId) {
    try {
      return votesCollection
          .where('candidateId', isEqualTo: candidateId)
          .snapshots();
    } catch (e) {
      print('❌ Error getting candidate votes: $e');
      throw Exception('Gagal mengambil data vote kandidat: $e');
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

  // Get election results
  static Stream<QuerySnapshot> getElectionResults(String electionId) {
    try {
      return votesCollection
          .where('electionId', isEqualTo: electionId)
          .snapshots();
    } catch (e) {
      print('❌ Error getting election results: $e');
      throw Exception('Gagal mengambil hasil pemilihan: $e');
    }
  }

  // Create new election
  static Future<void> createElection(Map<String, dynamic> electionData) async {
    try {
      // Pastikan 'id' ada dan bertipe String
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
      // Pastikan 'id' ada dan bertipe String
      final String candidateId = candidateData['id'] as String;
      await candidatesCollection.doc(candidateId).set(candidateData);
      print('✅ Candidate added successfully');
    } catch (e) {
      print('❌ Error adding candidate: $e');
      throw Exception('Gagal menambah kandidat: $e');
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
        final String type = operation['type'] as String; // PERBAIKAN: type casting
        final String path = operation['path'] as String; // PERBAIKAN: type casting
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
}