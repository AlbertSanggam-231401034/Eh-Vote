import 'package:cloud_firestore/cloud_firestore.dart';

class ElectionModel {
  final String id;
  final String title;
  final String description;
  final DateTime startDate;
  final DateTime endDate;
  final String? bannerUrl; // Bisa null
  final DateTime createdAt;
  final List<String> candidateIds;
  final String? facultyFilter;
  final bool isPublished;

  const ElectionModel({
    required this.id,
    required this.title,
    required this.description,
    required this.startDate,
    required this.endDate,
    this.bannerUrl,
    required this.createdAt,
    this.candidateIds = const [],
    this.facultyFilter,
    this.isPublished = true,
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

  // Status untuk UI display
  String get statusText {
    if (isOngoing) return 'Aktif';
    if (isUpcoming) return 'Akan Datang';
    return 'Selesai';
  }

  // Warna untuk status badge
  Map<String, dynamic> get statusInfo {
    if (isOngoing) {
      return {
        'text': 'Aktif',
        'color': 0xFF4CAF50, // Green
        'bgColor': 0xFFE8F5E9, // Light Green
      };
    } else if (isUpcoming) {
      return {
        'text': 'Akan Datang',
        'color': 0xFF2196F3, // Blue
        'bgColor': 0xFFE3F2FD, // Light Blue
      };
    } else {
      return {
        'text': 'Selesai',
        'color': 0xFF9E9E9E, // Grey
        'bgColor': 0xFFFAFAFA, // Light Grey
      };
    }
  }

  // Format tanggal untuk display
  String get formattedDateRange {
    final start = '${startDate.day}/${startDate.month}/${startDate.year}';
    final end = '${endDate.day}/${endDate.month}/${endDate.year}';
    return '$start - $end';
  }

  // Cek apakah user bisa vote (untuk logic frontend)
  bool get canVote {
    final now = DateTime.now();
    return now.isAfter(startDate) && now.isBefore(endDate) && isPublished;
  }

  // Durasi pemilihan dalam hari
  int get durationInDays {
    return endDate.difference(startDate).inDays;
  }

  // Progress percentage (0-100)
  double get progressPercentage {
    if (isCompleted) return 100.0;
    if (isUpcoming) return 0.0;

    final totalDuration = endDate.difference(startDate).inMilliseconds;
    final elapsedDuration = DateTime.now().difference(startDate).inMilliseconds;

    if (totalDuration == 0) return 0.0;
    return (elapsedDuration / totalDuration * 100).clamp(0.0, 100.0);
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'startDate': Timestamp.fromDate(startDate),
      'endDate': Timestamp.fromDate(endDate),
      'bannerUrl': bannerUrl ?? '',
      'createdAt': Timestamp.fromDate(createdAt),
      'candidateIds': candidateIds,
      'facultyFilter': facultyFilter,
      'isPublished': isPublished,
      // Tambahan field untuk analytics
      'totalVotes': 0, // Akan diupdate oleh sistem
      'lastUpdated': FieldValue.serverTimestamp(),
    };
  }

  factory ElectionModel.fromMap(Map<String, dynamic> map) {
    // Helper untuk konversi Timestamp Firestore ke DateTime
    DateTime parseDate(dynamic val) {
      if (val is Timestamp) return val.toDate();
      if (val is DateTime) return val;
      if (val is String) {
        try {
          return DateTime.parse(val);
        } catch (e) {
          return DateTime.now();
        }
      }
      return DateTime.now(); // Fallback
    }

    // Helper untuk konversi bannerUrl
    String? parseBannerUrl(dynamic val) {
      if (val == null) return null;
      if (val is String && val.isEmpty) return null;
      return val.toString();
    }

    return ElectionModel(
      id: map['id'] as String? ?? '',
      title: map['title'] as String? ?? 'Tanpa Judul',
      description: map['description'] as String? ?? '',
      startDate: parseDate(map['startDate']),
      endDate: parseDate(map['endDate']),
      bannerUrl: parseBannerUrl(map['bannerUrl']),
      createdAt: parseDate(map['createdAt'] ?? map['created_at']),
      candidateIds: (map['candidateIds'] as List<dynamic>?)
          ?.map((e) => e.toString())
          .where((e) => e.isNotEmpty)
          .toList() ??
          [],
      facultyFilter: map['facultyFilter'] as String?,
      isPublished: map['isPublished'] as bool? ?? true,
    );
  }

  // Copy with untuk update
  ElectionModel copyWith({
    String? id,
    String? title,
    String? description,
    DateTime? startDate,
    DateTime? endDate,
    String? bannerUrl,
    DateTime? createdAt,
    List<String>? candidateIds,
    String? facultyFilter,
    bool? isPublished,
  }) {
    return ElectionModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      bannerUrl: bannerUrl ?? this.bannerUrl,
      createdAt: createdAt ?? this.createdAt,
      candidateIds: candidateIds ?? this.candidateIds,
      facultyFilter: facultyFilter ?? this.facultyFilter,
      isPublished: isPublished ?? this.isPublished,
    );
  }

  // Untuk debug
  @override
  String toString() {
    return 'ElectionModel(id: $id, title: $title, status: $statusText, dates: $formattedDateRange)';
  }

  // Equals operator
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ElectionModel &&
        other.id == id &&
        other.title == title &&
        other.startDate == startDate;
  }

  // Hash code
  @override
  int get hashCode => Object.hash(id, title, startDate);

  // JSON serialization (untuk API atau local storage)
  Map<String, dynamic> toJson() => toMap();

  factory ElectionModel.fromJson(Map<String, dynamic> json) => ElectionModel.fromMap(json);

  // Validasi data
  bool get isValid {
    if (id.isEmpty || title.isEmpty || description.isEmpty) return false;
    if (startDate.isAfter(endDate)) return false;
    if (createdAt.isAfter(DateTime.now())) return false;
    return true;
  }

  // Static factory untuk create new election
  static ElectionModel createNew({
    required String title,
    required String description,
    required DateTime startDate,
    required DateTime endDate,
    String? bannerUrl,
    String? facultyFilter,
  }) {
    final now = DateTime.now();
    final id = 'election_${title.toLowerCase().replaceAll(' ', '_')}_${now.millisecondsSinceEpoch}';

    return ElectionModel(
      id: id,
      title: title,
      description: description,
      startDate: startDate,
      endDate: endDate,
      bannerUrl: bannerUrl,
      createdAt: now,
      facultyFilter: facultyFilter,
      isPublished: false, // Default belum publish
    );
  }

  // Static factory untuk sample/dummy data (development only)
  static ElectionModel sample() {
    final now = DateTime.now();
    return ElectionModel(
      id: 'pemira_2025',
      title: 'Pemira Universitas 2025',
      description: 'Pemilihan Rektor Universitas untuk periode 2025-2029',
      startDate: now,
      endDate: now.add(const Duration(days: 30)),
      bannerUrl: 'https://example.com/banner.jpg',
      createdAt: now.subtract(const Duration(days: 7)),
      candidateIds: ['candidate_1', 'candidate_2', 'candidate_3'],
      facultyFilter: null,
      isPublished: true,
    );
  }

  // Method untuk mendapatkan waktu tersisa
  Duration get remainingTime {
    final now = DateTime.now();
    if (isCompleted) return Duration.zero;
    if (isUpcoming) return startDate.difference(now);
    return endDate.difference(now);
  }

  // Format waktu tersisa untuk UI
  String get remainingTimeText {
    final duration = remainingTime;
    if (duration.inDays > 0) {
      return '${duration.inDays} hari lagi';
    } else if (duration.inHours > 0) {
      return '${duration.inHours} jam lagi';
    } else if (duration.inMinutes > 0) {
      return '${duration.inMinutes} menit lagi';
    }
    return 'Segera berakhir';
  }

  // Cek apakah election ini untuk fakultas tertentu
  bool isForFaculty(String faculty) {
    if (facultyFilter == null) return true; // Untuk semua fakultas
    return facultyFilter == faculty;
  }

  // Tambah candidate
  ElectionModel addCandidate(String candidateId) {
    final newCandidateIds = List<String>.from(candidateIds);
    if (!newCandidateIds.contains(candidateId)) {
      newCandidateIds.add(candidateId);
    }
    return copyWith(candidateIds: newCandidateIds);
  }

  // Hapus candidate
  ElectionModel removeCandidate(String candidateId) {
    final newCandidateIds = List<String>.from(candidateIds);
    newCandidateIds.remove(candidateId);
    return copyWith(candidateIds: newCandidateIds);
  }

  // Update banner
  ElectionModel updateBanner(String newBannerUrl) {
    return copyWith(bannerUrl: newBannerUrl);
  }

  // Publish election
  ElectionModel publish() {
    return copyWith(isPublished: true);
  }

  // Unpublish election
  ElectionModel unpublish() {
    return copyWith(isPublished: false);
  }

  // Update dates
  ElectionModel updateDates(DateTime newStartDate, DateTime newEndDate) {
    return copyWith(startDate: newStartDate, endDate: newEndDate);
  }
}