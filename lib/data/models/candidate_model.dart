import 'package:cloud_firestore/cloud_firestore.dart';

class CandidateModel {
  final String id;
  final String name;
  final String nim;
  final String faculty;
  final String major;
  final String phoneNumber;
  final String instagramUrl;
  final String facebookUrl;
  final String xUrl;
  final String weiboUrl; // ✅ Tambahan dari gambar UI
  final String photoUrl;
  final String vision;
  final String mission;
  final String shortBiography; // ✅ Tambahan: "SHORT BIOGRAPHY" dari UI
  final String electionId;
  final DateTime createdAt;
  final int voteCount;
  final String candidateNumber; // ✅ Tambahan: Urutan kandidat (01, 02, 03)
  final String gender; // ✅ Tambahan: Dari form Admin
  final String placeOfBirth; // ✅ Tambahan: Dari form Admin
  final DateTime dateOfBirth; // ✅ Tambahan: Dari form Admin
  final Map<String, int> votesByStambuk; // ✅ Tambahan: Untuk grafik quick count

  const CandidateModel({
    required this.id,
    required this.name,
    required this.nim,
    required this.faculty,
    required this.major,
    required this.phoneNumber,
    this.instagramUrl = '',
    this.facebookUrl = '',
    this.xUrl = '',
    this.weiboUrl = '', // ✅ Inisialisasi default
    required this.photoUrl,
    required this.vision,
    required this.mission,
    this.shortBiography = '', // ✅ Inisialisasi default
    required this.electionId,
    required this.createdAt,
    this.voteCount = 0,
    required this.candidateNumber, // ✅ Required field
    required this.gender, // ✅ Required field
    required this.placeOfBirth, // ✅ Required field
    required this.dateOfBirth, // ✅ Required field
    this.votesByStambuk = const {}, // ✅ Inisialisasi default map kosong
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'nim': nim,
      'faculty': faculty,
      'major': major,
      'phoneNumber': phoneNumber,
      'instagramUrl': instagramUrl,
      'facebookUrl': facebookUrl,
      'xUrl': xUrl,
      'weiboUrl': weiboUrl, // ✅ Tambah ke Firestore
      'photoUrl': photoUrl,
      'vision': vision,
      'mission': mission,
      'shortBiography': shortBiography, // ✅ Tambah ke Firestore
      'electionId': electionId,
      'createdAt': Timestamp.fromDate(createdAt),
      'voteCount': voteCount,
      'candidateNumber': candidateNumber, // ✅ Tambah ke Firestore
      'gender': gender, // ✅ Tambah ke Firestore
      'placeOfBirth': placeOfBirth, // ✅ Tambah ke Firestore
      'dateOfBirth': Timestamp.fromDate(dateOfBirth), // ✅ Tambah ke Firestore
      'votesByStambuk': votesByStambuk, // ✅ Map langsung bisa disimpan di Firestore
    };
  }

  factory CandidateModel.fromMap(Map<String, dynamic> map) {
    // Handle votesByStambuk conversion
    Map<String, int> votesByStambukMap = {};
    if (map['votesByStambuk'] != null) {
      final Map<dynamic, dynamic> rawMap = map['votesByStambuk'];
      rawMap.forEach((key, value) {
        votesByStambukMap[key.toString()] = (value as num).toInt();
      });
    }

    return CandidateModel(
      id: map['id'] as String,
      name: map['name'] as String,
      nim: map['nim'] as String,
      faculty: map['faculty'] as String,
      major: map['major'] as String,
      phoneNumber: map['phoneNumber'] as String,
      instagramUrl: map['instagramUrl'] as String? ?? '',
      facebookUrl: map['facebookUrl'] as String? ?? '',
      xUrl: map['xUrl'] as String? ?? '',
      weiboUrl: map['weiboUrl'] as String? ?? '',
      photoUrl: map['photoUrl'] as String,
      vision: map['vision'] as String,
      mission: map['mission'] as String,
      shortBiography: map['shortBiography'] as String? ?? '',
      electionId: map['electionId'] as String,
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      voteCount: map['voteCount'] as int? ?? 0,
      candidateNumber: map['candidateNumber'] as String? ?? '01',
      gender: map['gender'] as String? ?? 'Laki-laki',
      placeOfBirth: map['placeOfBirth'] as String? ?? '',
      dateOfBirth: (map['dateOfBirth'] as Timestamp?)?.toDate() ?? DateTime.now(),
      votesByStambuk: votesByStambukMap,
    );
  }

  // CopyWith method dengan field baru
  CandidateModel copyWith({
    String? id,
    String? name,
    String? nim,
    String? faculty,
    String? major,
    String? phoneNumber,
    String? instagramUrl,
    String? facebookUrl,
    String? xUrl,
    String? weiboUrl,
    String? photoUrl,
    String? vision,
    String? mission,
    String? shortBiography,
    String? electionId,
    DateTime? createdAt,
    int? voteCount,
    String? candidateNumber,
    String? gender,
    String? placeOfBirth,
    DateTime? dateOfBirth,
    Map<String, int>? votesByStambuk,
  }) {
    return CandidateModel(
      id: id ?? this.id,
      name: name ?? this.name,
      nim: nim ?? this.nim,
      faculty: faculty ?? this.faculty,
      major: major ?? this.major,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      instagramUrl: instagramUrl ?? this.instagramUrl,
      facebookUrl: facebookUrl ?? this.facebookUrl,
      xUrl: xUrl ?? this.xUrl,
      weiboUrl: weiboUrl ?? this.weiboUrl,
      photoUrl: photoUrl ?? this.photoUrl,
      vision: vision ?? this.vision,
      mission: mission ?? this.mission,
      shortBiography: shortBiography ?? this.shortBiography,
      electionId: electionId ?? this.electionId,
      createdAt: createdAt ?? this.createdAt,
      voteCount: voteCount ?? this.voteCount,
      candidateNumber: candidateNumber ?? this.candidateNumber,
      gender: gender ?? this.gender,
      placeOfBirth: placeOfBirth ?? this.placeOfBirth,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      votesByStambuk: votesByStambuk ?? this.votesByStambuk,
    );
  }

  // Helper method untuk mendapatkan angkatan dari NIM kandidat
  String get angkatan {
    if (nim.length >= 2) {
      return '20${nim.substring(0, 2)}';
    }
    return 'Unknown';
  }

  @override
  String toString() {
    return 'CandidateModel(id: $id, name: $name, candidateNumber: $candidateNumber, votes: $voteCount)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CandidateModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}