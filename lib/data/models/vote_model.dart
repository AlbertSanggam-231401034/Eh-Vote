import 'package:cloud_firestore/cloud_firestore.dart';

class VoteRecord {
  final String voteId;       // ID Unik Vote (electionId-voterNim)
  final String electionId;   // ID Pemilihan yang diikuti
  final String candidateId;  // ID Kandidat yang dipilih
  final String voterNim;     // NIM Pemilih (Primary Key User)
  final DateTime votedAt;    // Kapan vote dilakukan

  // Metadata tambahan untuk keamanan
  final bool isFaceVerified; // Bukti lolos verifikasi wajah
  final String deviceInfo;   // Untuk audit trail

  const VoteRecord({
    required this.voteId,
    required this.electionId,
    required this.candidateId,
    required this.voterNim,
    required this.votedAt,
    this.isFaceVerified = true,
    this.deviceInfo = '',
  });

  // --- LOGIC EKSTRAKSI (Tidak masuk DB, hanya Logic Aplikasi) ---

  // Mengambil Stambuk dari NIM (Digit 1-2)
  String get stambuk {
    if (voterNim.length >= 2) {
      return "20${voterNim.substring(0, 2)}";
    }
    return "Unknown";
  }

  // Mengambil Kode Fakultas dari NIM (Digit 3-4)
  String get facultyCode {
    if (voterNim.length >= 4) {
      return voterNim.substring(2, 4);
    }
    return "Unknown";
  }

  // --- DATABASE MAPPING ---

  Map<String, dynamic> toMap() {
    return {
      'voteId': voteId,
      'electionId': electionId,
      'candidateId': candidateId,
      'voterNim': voterNim,
      'votedAt': Timestamp.fromDate(votedAt),
      'isFaceVerified': isFaceVerified,
      'deviceInfo': deviceInfo,
    };
  }

  factory VoteRecord.fromMap(Map<String, dynamic> map) {
    return VoteRecord(
      voteId: map['voteId'] as String,
      electionId: map['electionId'] as String,
      candidateId: map['candidateId'] as String,
      voterNim: map['voterNim'] as String,
      votedAt: (map['votedAt'] as Timestamp).toDate(),
      isFaceVerified: map['isFaceVerified'] as bool? ?? false,
      deviceInfo: map['deviceInfo'] as String? ?? '',
    );
  }

  @override
  String toString() {
    return 'VoteRecord(voteId: $voteId, voterNim: $voterNim, candidateId: $candidateId)';
  }
}