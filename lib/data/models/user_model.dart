import 'package:cloud_firestore/cloud_firestore.dart';

class User {
  final String nim; // Primary Key
  final String password;
  final String fullName;
  final String placeOfBirth;
  final DateTime dateOfBirth;
  final String phoneNumber;
  final String faculty;
  final String major;
  final String ktmData;
  final String faceData;
  final UserRole role;
  final bool hasVoted;
  final DateTime createdAt;

  const User({
    required this.nim,
    required this.password,
    required this.fullName,
    required this.placeOfBirth,
    required this.dateOfBirth,
    required this.phoneNumber,
    required this.faculty,
    required this.major,
    required this.ktmData,
    required this.faceData,
    this.role = UserRole.voter,
    this.hasVoted = false,
    required this.createdAt,
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
      'ktmData': ktmData,
      'faceData': faceData,
      'role': role.toString().split('.').last,
      'hasVoted': hasVoted,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  // Create from Map dari Firebase
  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      nim: map['nim'],
      password: map['password'],
      fullName: map['fullName'],
      placeOfBirth: map['placeOfBirth'],
      dateOfBirth: (map['dateOfBirth'] as Timestamp).toDate(),
      phoneNumber: map['phoneNumber'],
      faculty: map['faculty'],
      major: map['major'],
      ktmData: map['ktmData'],
      faceData: map['faceData'],
      role: UserRole.values.firstWhere(
            (e) => e.toString().split('.').last == map['role'],
        orElse: () => UserRole.voter,
      ),
      hasVoted: map['hasVoted'] ?? false,
      createdAt: (map['createdAt'] as Timestamp).toDate(),
    );
  }

  // Copy with method untuk update
  User copyWith({
    String? password,
    String? fullName,
    String? phoneNumber,
    bool? hasVoted,
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
      ktmData: ktmData,
      faceData: faceData,
      role: role,
      hasVoted: hasVoted ?? this.hasVoted,
      createdAt: createdAt,
    );
  }
}

enum UserRole {
  voter,
  admin,
  superAdmin,
}