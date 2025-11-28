import 'package:cloud_firestore/cloud_firestore.dart';

enum UserRole {
  voter,
  admin,
  superAdmin,
}

class User {
  final String nim; // Primary Key
  final String password;
  final String fullName;
  final String placeOfBirth;
  final DateTime dateOfBirth;
  final String phoneNumber;
  final String faculty;
  final String major;
  final String gender;
  final String ktmData;
  final String faceData;
  final UserRole role;
  final bool hasVoted;
  final DateTime createdAt;
  final String faceImageUrl;
  final String ktmImageUrl;

  const User({
    required this.nim,
    required this.password,
    required this.fullName,
    required this.placeOfBirth,
    required this.dateOfBirth,
    required this.phoneNumber,
    required this.faculty,
    required this.major,
    required this.gender,
    required this.ktmData,
    required this.faceData,
    this.role = UserRole.voter,
    this.hasVoted = false,
    required this.createdAt,
    required this.faceImageUrl,
    required this.ktmImageUrl,
  });

  // Convert to Map untuk Firebase
  Map<String, dynamic> toMap() {
    return {
      'nim': nim,
      'password': password,
      'fullName': fullName,
      'placeOfBirth': placeOfBirth,
      'dateOfBirth': Timestamp.fromDate(dateOfBirth),
      'phoneNumber': phoneNumber,
      'faculty': faculty,
      'major': major,
      'gender': gender, // ✅ PERBAIKAN: TAMBAH INI
      'ktmData': ktmData,
      'faceData': faceData,
      'role': role.toString().split('.').last,
      'hasVoted': hasVoted,
      'createdAt': Timestamp.fromDate(createdAt),
      'faceImageUrl': faceImageUrl,
      'ktmImageUrl': ktmImageUrl,
    };
  }

  // Create from Map dari Firebase
  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      nim: map['nim'] as String,
      password: map['password'] as String,
      fullName: map['fullName'] as String,
      placeOfBirth: map['placeOfBirth'] as String,
      dateOfBirth: (map['dateOfBirth'] as Timestamp).toDate(),
      phoneNumber: map['phoneNumber'] as String,
      faculty: map['faculty'] as String,
      major: map['major'] as String,
      gender: map['gender'] as String? ?? 'Laki-laki', // ✅ PERBAIKAN: HANDLE NULL
      ktmData: map['ktmData'] as String,
      faceData: map['faceData'] as String,
      role: UserRole.values.firstWhere(
            (e) => e.toString().split('.').last == map['role'],
        orElse: () => UserRole.voter,
      ),
      hasVoted: map['hasVoted'] as bool? ?? false,
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      faceImageUrl: map['faceImageUrl'] as String? ?? '',
      ktmImageUrl: map['ktmImageUrl'] as String? ?? '',
    );
  }

  // Copy with method untuk update
  User copyWith({
    String? password,
    String? fullName,
    String? phoneNumber,
    bool? hasVoted,
    UserRole? role,
    String? faceImageUrl,
    String? ktmImageUrl,
    String? faceData,
    String? ktmData,
    String? gender,
  }) {
    return User(
      nim: nim,
      password: password ?? this.password,
      fullName: fullName ?? this.fullName,
      placeOfBirth: placeOfBirth,
      dateOfBirth: dateOfBirth,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      faculty: faculty,
      major: major,
      gender: gender ?? this.gender,
      ktmData: ktmData ?? this.ktmData,
      faceData: faceData ?? this.faceData,
      role: role ?? this.role,
      hasVoted: hasVoted ?? this.hasVoted,
      createdAt: createdAt,
      faceImageUrl: faceImageUrl ?? this.faceImageUrl,
      ktmImageUrl: ktmImageUrl ?? this.ktmImageUrl,
    );
  }

  @override
  String toString() {
    return 'User(nim: $nim, fullName: $fullName, role: $role, faculty: $faculty)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is User && other.nim == nim;
  }

  @override
  int get hashCode => nim.hashCode;
}