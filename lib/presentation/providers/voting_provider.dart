import 'dart:io';
import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

import 'package:suara_kita/data/models/candidate_model.dart';
import 'package:suara_kita/data/models/election_model.dart';
import 'package:suara_kita/data/models/vote_model.dart';
import 'package:suara_kita/services/face_recognition_service.dart';
import 'package:suara_kita/services/firebase_service.dart';
import 'package:suara_kita/services/ktm_scanner_service.dart';

class VotingProvider extends ChangeNotifier {
  // === VOTING FLOW CONSTANTS ===
  static const int TOTAL_STEPS = 6;

  // ✅ UPDATED: Threshold Euclidean (0.75).
  // Jarak <= 0.75 berarti Cocok. Jarak > 0.75 berarti Beda Orang.
  static const double FACE_DISTANCE_THRESHOLD = 0.75;

  static const int MAX_RETRY_ATTEMPTS = 3;
  static const Duration SESSION_TIMEOUT = Duration(minutes: 15);

  // === STATE ===
  int _currentStep = 0;
  bool _isLoading = false;
  String? _errorMessage;
  DateTime? _sessionStartTime;
  int _faceRetryCount = 0;
  bool _isSessionValid = true;
  bool _hasAlreadyVoted = false;

  // === DATA ===
  ElectionModel? _selectedElection;
  List<CandidateModel> _candidates = [];

  // === USER DATA ===
  String? _voterNim;
  String? _voterName;
  String? _storedFaceImageUrl;
  List<double>? _referenceFaceEmbedding;

  // === VERIFICATION ===
  File? _liveFaceImage;
  double? _faceSimilarityScore; // Sekarang isinya Jarak (Distance)
  bool _isFaceVerified = false;
  String? _scannedKtmData;
  bool _isKtmVerified = false;
  bool _agreementAccepted = false;

  // === SELECTION & RECORD ===
  CandidateModel? _selectedCandidate;
  VoteRecord? _voteRecord;
  Map<String, dynamic> _deviceInfo = {};

  // === GETTERS ===
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get hasAlreadyVoted => _hasAlreadyVoted;
  int get currentStep => _currentStep;
  ElectionModel? get selectedElection => _selectedElection;
  List<CandidateModel> get candidates => _candidates;
  String? get voterNim => _voterNim;
  bool get isFaceVerified => _isFaceVerified;
  bool get isKtmVerified => _isKtmVerified;
  bool get agreementAccepted => _agreementAccepted;
  CandidateModel? get selectedCandidate => _selectedCandidate;
  VoteRecord? get voteRecord => _voteRecord;

  // === ELECTION SETUP ===
  Future<void> setElection(ElectionModel election, String userNim) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      _hasAlreadyVoted = false;
      notifyListeners();

      _selectedElection = election;

      final user = await FirebaseService.getUserByNim(userNim);
      if (user == null) throw Exception('Data user tidak ditemukan.');

      _voterNim = user.nim;
      _voterName = user.fullName;
      _storedFaceImageUrl = user.faceImageUrl;

      _hasAlreadyVoted = await FirebaseService.hasUserVoted(userNim, election.id);

      if (!_hasAlreadyVoted) {
        await _loadCandidates(election.id);
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Gagal memuat data pemilihan: ${e.toString()}';
      notifyListeners();
      rethrow;
    }
  }

  Future<void> _loadCandidates(String electionId) async {
    try {
      final candidatesSnapshot = await FirebaseService.candidatesCollection
          .where('electionId', isEqualTo: electionId)
          .orderBy('candidateNumber')
          .get();

      _candidates = candidatesSnapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        if (!data.containsKey('id')) data['id'] = doc.id;
        return CandidateModel.fromMap(data);
      }).toList();
    } catch (e) {
      throw Exception('Gagal memuat data kandidat: $e');
    }
  }

  // === FACE VERIFICATION (REAL EUCLIDEAN LOGIC) ===
  Future<bool> verifyFace(File liveFaceImage) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      print("DEBUG: Memulai verifikasi wajah (EUCLIDEAN)...");

      if (_storedFaceImageUrl == null || _storedFaceImageUrl!.isEmpty) {
        throw Exception("Data foto wajah Anda tidak ditemukan di sistem database.");
      }

      final faceService = FaceRecognitionService();
      if (!faceService.isModelLoaded()) {
        await faceService.initialize();
      }

      if (_referenceFaceEmbedding == null) {
        print("DEBUG: Mendownload foto referensi dari Supabase...");
        File referenceImageFile = await _downloadFile(_storedFaceImageUrl!, "ref_face.jpg");

        print("DEBUG: Mengekstrak fitur wajah dari foto referensi...");
        _referenceFaceEmbedding = await faceService.extractFaceEmbedding(referenceImageFile);

        if (_referenceFaceEmbedding == null) {
          throw Exception("Gagal mengenali wajah pada foto profil database.");
        }
      }

      print("DEBUG: Mengekstrak fitur wajah dari foto selfie...");
      final liveEmbedding = await faceService.extractFaceEmbedding(liveFaceImage);

      if (liveEmbedding == null) {
        throw Exception("Wajah tidak terdeteksi jelas pada kamera.");
      }

      // Hitung Jarak (Distance)
      final distance = await faceService.verifyFace(
        liveFaceImage: liveFaceImage,
        storedEmbedding: _referenceFaceEmbedding!,
      );

      _faceSimilarityScore = distance;
      print("DEBUG: Jarak Wajah: $distance (Batas Aman: $FACE_DISTANCE_THRESHOLD)");

      // ✅ UPDATED LOGIC: Jika Jarak LEBIH KECIL dari Threshold -> COCOK
      if (distance <= FACE_DISTANCE_THRESHOLD) {
        _liveFaceImage = liveFaceImage;
        _isFaceVerified = true;
        _faceRetryCount = 0;
        print("DEBUG: Verifikasi BERHASIL (Wajah Cocok)");

        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _faceRetryCount++;
        final distStr = distance.toStringAsFixed(2);
        throw Exception("Wajah tidak cocok (Skor Jarak: $distStr). Pastikan wajah terlihat jelas.");
      }

    } catch (e) {
      print("DEBUG ERROR: $e");
      _isLoading = false;
      _errorMessage = e.toString().replaceAll("Exception: ", "");
      notifyListeners();
      return false;
    }
  }

  Future<File> _downloadFile(String url, String filename) async {
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final dir = await getTemporaryDirectory();
        final file = File('${dir.path}/$filename');
        await file.writeAsBytes(response.bodyBytes);
        return file;
      } else {
        throw Exception('Gagal mendownload gambar referensi. Kode: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Gagal koneksi internet saat mengambil data wajah.');
    }
  }

  // === KTM VERIFICATION ===
  Future<bool> verifyKtm(String scannedData) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      if (_voterNim == null) throw Exception('Data pengguna error.');

      final ktmService = KTMScannerService();
      if (!ktmService.isValidNIM(scannedData)) {
        throw Exception('Format QR Code tidak valid.');
      }

      if (scannedData != _voterNim) {
        throw Exception('NIM KTM ($scannedData) tidak sesuai akun ($_voterNim).');
      }

      _scannedKtmData = scannedData;
      _isKtmVerified = true;

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  // === CONTROLS ===
  void setAgreement(bool accepted) {
    _agreementAccepted = accepted;
    notifyListeners();
  }

  void selectCandidate(CandidateModel candidate) {
    _selectedCandidate = candidate;
    notifyListeners();
  }

  void startVotingSession() {
    _sessionStartTime = DateTime.now();
    _isSessionValid = true;
    _currentStep = 0;
    _loadDeviceInfo();
    notifyListeners();
  }

  void _checkSessionTimeout() {
    if (_sessionStartTime == null) return;
    final now = DateTime.now();
    if (now.difference(_sessionStartTime!) > SESSION_TIMEOUT) {
      _isSessionValid = false;
      _errorMessage = 'Sesi habis.';
      notifyListeners();
    }
  }

  Future<void> _loadDeviceInfo() async {
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      final deviceInfo = DeviceInfoPlugin();
      if (Platform.isAndroid) {
        final androidInfo = await deviceInfo.androidInfo;
        _deviceInfo = {
          'platform': 'Android',
          'model': androidInfo.model,
          'appVersion': packageInfo.version,
        };
      } else if (Platform.isIOS) {
        final iosInfo = await deviceInfo.iosInfo;
        _deviceInfo = {
          'platform': 'iOS',
          'model': iosInfo.model,
          'appVersion': packageInfo.version,
        };
      }
    } catch (e) {
      _deviceInfo = {'error': e.toString()};
    }
  }

  Future<bool> submitVote() async {
    try {
      if (!_validateVotingData()) throw Exception('Data voting belum lengkap.');
      _checkSessionTimeout();
      if (!_isSessionValid) throw Exception('Sesi habis.');

      _isLoading = true;
      notifyListeners();

      final voteId = '${_selectedElection!.id}-${_voterNim}-${DateTime.now().millisecondsSinceEpoch}';

      _voteRecord = VoteRecord(
        voteId: voteId,
        electionId: _selectedElection!.id,
        candidateId: _selectedCandidate!.id,
        voterNim: _voterNim!,
        votedAt: DateTime.now(),
        isFaceVerified: _isFaceVerified,
        deviceInfo: _deviceInfo.toString(),
      );

      await FirebaseService.submitVote(
        electionId: _selectedElection!.id,
        candidateId: _selectedCandidate!.id,
        voterNim: _voterNim!,
        voterName: _voterName!,
        faceSimilarityScore: _faceSimilarityScore,
      );

      await FirebaseService.recordVotingActivity(
        nim: _voterNim!,
        electionId: _selectedElection!.id,
        candidateId: _selectedCandidate!.id,
        candidateName: _selectedCandidate!.name,
        voterName: _voterName!,
        similarityScore: _faceSimilarityScore,
        deviceInfo: _deviceInfo.toString(),
      );

      await FirebaseService.updateUser(_voterNim!, {
        'hasVoted': true,
        'lastVotedAt': DateTime.now(),
      });

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Gagal vote: $e';
      notifyListeners();
      return false;
    }
  }

  bool _validateVotingData() {
    return _selectedElection != null &&
        _isFaceVerified &&
        _isKtmVerified &&
        _agreementAccepted &&
        _selectedCandidate != null &&
        _voterNim != null;
  }

  void reset() {
    _currentStep = 0;
    _isLoading = false;
    _errorMessage = null;
    _faceRetryCount = 0;
    _isSessionValid = true;
    _hasAlreadyVoted = false;
    _liveFaceImage = null;
    _referenceFaceEmbedding = null;
    _faceSimilarityScore = null;
    _isFaceVerified = false;
    _scannedKtmData = null;
    _isKtmVerified = false;
    _agreementAccepted = false;
    _selectedCandidate = null;
    _voteRecord = null;
    notifyListeners();
  }

  // NAVIGATION CONTROLS
  void nextStep() {
    if (_currentStep < TOTAL_STEPS - 1) {
      _currentStep++;
      notifyListeners();
    }
  }

  void previousStep() {
    if (_currentStep > 0) {
      _currentStep--;
      notifyListeners();
    }
  }

  void goToStep(int step) {
    if (step >= 0 && step < TOTAL_STEPS) {
      _currentStep = step;
      notifyListeners();
    }
  }
}