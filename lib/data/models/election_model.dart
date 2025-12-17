import 'package:cloud_firestore/cloud_firestore.dart';

class ElectionModel {
  final String id;
  final String title;
  final String description;
  final String bannerUrl;
  final DateTime startDate;
  final DateTime endDate;
  final List<String> candidateIds;
  final DateTime createdAt;
  final bool isPublished;
  final String? facultyFilter; // Untuk pemilihan fakultas tertentu

  const ElectionModel({
    required this.id,
    required this.title,
    required this.description,
    required this.bannerUrl,
    required this.startDate,
    required this.endDate,
    this.candidateIds = const [],
    required this.createdAt,
    this.isPublished = true,
    this.facultyFilter,
  });

  // Helper methods untuk status otomatis
  bool get isOngoing {
    final now = DateTime.now();
    return now.isAfter(startDate) && now.isBefore(endDate);
  }

  bool get isUpcoming {
    final now = DateTime.now();
    return now.isBefore(startDate);
  }

  bool get isCompleted {
    final now = DateTime.now();
    return now.isAfter(endDate);
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'bannerUrl': bannerUrl,
      'startDate': Timestamp.fromDate(startDate),
      'endDate': Timestamp.fromDate(endDate),
      'candidateIds': candidateIds,
      'createdAt': Timestamp.fromDate(createdAt),
      'isPublished': isPublished,
      'facultyFilter': facultyFilter,
    };
  }

  factory ElectionModel.fromMap(Map<String, dynamic> map) {
    return ElectionModel(
      id: map['id'] as String,
      title: map['title'] as String,
      description: map['description'] as String,
      bannerUrl: map['bannerUrl'] as String,
      startDate: (map['startDate'] as Timestamp).toDate(),
      endDate: (map['endDate'] as Timestamp).toDate(),
      candidateIds: List<String>.from(map['candidateIds'] as List<dynamic>? ?? []),
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      isPublished: map['isPublished'] as bool? ?? true,
      facultyFilter: map['facultyFilter'] as String?,
    );
  }

  ElectionModel copyWith({
    String? id,
    String? title,
    String? description,
    String? bannerUrl,
    DateTime? startDate,
    DateTime? endDate,
    List<String>? candidateIds,
    DateTime? createdAt,
    bool? isPublished,
    String? facultyFilter,
  }) {
    return ElectionModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      bannerUrl: bannerUrl ?? this.bannerUrl,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      candidateIds: candidateIds ?? this.candidateIds,
      createdAt: createdAt ?? this.createdAt,
      isPublished: isPublished ?? this.isPublished,
      facultyFilter: facultyFilter ?? this.facultyFilter,
    );
  }

  @override
  String toString() {
    return 'ElectionModel(id: $id, title: $title, status: ${isOngoing ? "Ongoing" : isUpcoming ? "Upcoming" : "Completed"})';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ElectionModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}