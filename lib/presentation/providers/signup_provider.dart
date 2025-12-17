import 'dart:io';
import 'package:flutter/material.dart';
import 'package:suara_kita/data/models/user_model.dart';
import 'package:suara_kita/services/face_recognition_service.dart';
import 'package:suara_kita/services/firebase_service.dart';
import 'package:suara_kita/services/storage_service.dart';

class SignupProvider extends ChangeNotifier {
  // === SIGNUP FLOW STATE ===
  int _currentStep = 0;
  bool _isLoading = false;
  String? _errorMessage;

  // === USER DATA FROM PREVIOUS STEPS ===
  String? _nim;
  String? _fullName;
  String? _placeOfBirth;
  DateTime? _dateOfBirth;
  String? _phoneNumber;
  String? _faculty;
  String? _major;
  String? _gender;
  String? _password;

  // === FACE DATA (STEP 3) ===
  List<double>? _faceEmbedding;
  File? _faceImageFile;
  String? _faceImageUrl;
  String? _faceValidationError;

  // === KTM DATA (STEP 4) ===
  String? _ktmData;
  File? _ktmImageFile;
  String? _ktmImageUrl;

  // === GETTERS ===
  int get currentStep => _currentStep;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  List<double>? get faceEmbedding => _faceEmbedding;
  File? get faceImageFile => _faceImageFile;
  String? get faceImageUrl => _faceImageUrl;
  String? get faceValidationError => _faceValidationError;

  // === SETTERS ===
  void setPersonalData({
    required String nim,
    required String fullName,
    required String placeOfBirth,
    required DateTime dateOfBirth,
    required String phoneNumber,
    required String faculty,
    required String major,
    required String gender,
  }) {
    _nim = nim;
    _fullName = fullName;
    _placeOfBirth = placeOfBirth;
    _dateOfBirth = dateOfBirth;
    _phoneNumber = phoneNumber;
    _faculty = faculty;
    _major = major;
    _gender = gender;
    notifyListeners();
  }

  void setPassword(String password) {
    _password = password;
    notifyListeners();
  }

  void setKtmData(String ktmData, File ktmImageFile) {
    _ktmData = ktmData;
    _ktmImageFile = ktmImageFile;
    notifyListeners();
  }

  // === FACE CAPTURE METHODS ===
  Future<void> captureFaceFromCamera() async {
    try {
      _isLoading = true;
      _faceValidationError = null;
      notifyListeners();

      final faceService = FaceRecognitionService();

      // 1. Capture face image
      final imageFile = await faceService.captureFaceImage();
      if (imageFile == null) {
        throw Exception('Gagal mengambil foto wajah. Pastikan wajah terlihat jelas.');
      }

      // 2. Extract embedding
      final embedding = await faceService.extractFaceEmbedding(imageFile);
      if (embedding == null) {
        throw Exception('Gagal mengekstrak fitur wajah. Coba dengan pencahayaan lebih baik.');
      }

      // 3. Validate embedding quality
      final faceVerified = await _validateFaceEmbedding(embedding, imageFile);
      if (!faceVerified) {
        throw Exception('Kualitas wajah tidak memenuhi standar. Silakan coba lagi.');
      }

      // 4. Store data
      _faceEmbedding = embedding;
      _faceImageFile = imageFile;

      _isLoading = false;
      notifyListeners();

    } catch (e) {
      _isLoading = false;
      _faceValidationError = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  Future<void> uploadFaceFromGallery() async {
    try {
      _isLoading = true;
      _faceValidationError = null;
      notifyListeners();

      final faceService = FaceRecognitionService();

      // 1. Pick image from gallery
      final imageFile = await faceService.pickFaceImage();
      if (imageFile == null) {
        throw Exception('Tidak ada gambar yang dipilih.');
      }

      // 2. Extract embedding
      final embedding = await faceService.extractFaceEmbedding(imageFile);
      if (embedding == null) {
        throw Exception('Gagal mengekstrak fitur wajah dari gambar.');
      }

      // 3. Validate
      final faceVerified = await _validateFaceEmbedding(embedding, imageFile);
      if (!faceVerified) {
        throw Exception('Gambar tidak memenuhi kualitas wajah yang dibutuhkan.');
      }

      // 4. Store data
      _faceEmbedding = embedding;
      _faceImageFile = imageFile;

      _isLoading = false;
      notifyListeners();

    } catch (e) {
      _isLoading = false;
      _faceValidationError = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  // === UPLOAD METHODS ===
  Future<void> uploadFaceImageToServer() async {
    try {
      if (_faceImageFile == null || _nim == null) {
        throw Exception('Data gambar atau NIM tidak tersedia.');
      }

      final url = await StorageService.uploadFaceImage(_faceImageFile!, _nim!);
      _faceImageUrl = url;

      // FIX: Use null-aware check before accessing isEmpty
      if (_faceImageUrl == null || _faceImageUrl!.isEmpty) {
        throw Exception('Gagal mengupload gambar wajah ke server.');
      }

      notifyListeners();

    } catch (e) {
      throw Exception('Upload gambar wajah gagal: $e');
    }
  }

  Future<void> uploadKtmImageToServer() async {
    try {
      if (_ktmImageFile == null || _nim == null) {
        throw Exception('Data KTM atau NIM tidak tersedia.');
      }

      final url = await StorageService.uploadKtmImage(_ktmImageFile!, _nim!);
      _ktmImageUrl = url;

      // FIX: Use null-aware check before accessing isEmpty
      if (_ktmImageUrl == null || _ktmImageUrl!.isEmpty) {
        throw Exception('Gagal mengupload gambar KTM ke server.');
      }

      notifyListeners();

    } catch (e) {
      throw Exception('Upload gambar KTM gagal: $e');
    }
  }

  // === COMPLETE SIGNUP ===
  Future<bool> completeSignup() async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      // Validate all data is present
      if (_nim == null || _password == null || _faceEmbedding == null) {
        throw Exception('Data pendaftaran tidak lengkap.');
      }

      // Upload images to server if not already uploaded
      if (_faceImageFile != null && _faceImageUrl == null) {
        await uploadFaceImageToServer();
      }

      if (_ktmImageFile != null && _ktmImageUrl == null) {
        await uploadKtmImageToServer();
      }

      // Final check for image URLs
      if (_faceImageUrl == null || _ktmImageUrl == null) {
        throw Exception('Gagal mendapatkan URL gambar setelah upload.');
      }

      // Create user object
      final user = User(
        nim: _nim!,
        password: _password!,
        fullName: _fullName!,
        placeOfBirth: _placeOfBirth!,
        dateOfBirth: _dateOfBirth!,
        phoneNumber: _phoneNumber!,
        faculty: _faculty!,
        major: _major!,
        gender: _gender!,
        ktmData: _ktmData ?? '',
        faceData: _faceImageUrl!, // Using non-null assertion as we checked above
        role: UserRole.voter,
        hasVoted: false,
        createdAt: DateTime.now(),
        faceImageUrl: _faceImageUrl!,
        ktmImageUrl: _ktmImageUrl!,
        faceEmbedding: _faceEmbedding!,
      );

      // Save to Firebase
      await FirebaseService.saveUser(user);

      // Update face embedding in Firebase
      await FirebaseService.updateFaceEmbedding(_nim!, _faceEmbedding!);

      _isLoading = false;
      notifyListeners();
      return true;

    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  // === HELPER METHODS ===
  Future<bool> _validateFaceEmbedding(List<double> embedding, File imageFile) async {
    try {
      // Check embedding length
      if (embedding.length != 192) {
        return false;
      }

      // Calculate norm (should be close to 1 after L2 normalization)
      double sum = 0.0;
      for (final value in embedding) {
        sum += value * value;
      }
      final norm = sum; // L2 norm squared

      // Acceptable range: 0.8 to 1.2 (after normalization should be ~1.0)
      return norm >= 0.8 && norm <= 1.2;
    } catch (e) {
      return false;
    }
  }

  bool get isFaceDataComplete => _faceEmbedding != null && _faceImageFile != null;
  bool get isKtmDataComplete => _ktmData != null && _ktmImageFile != null;

  void goToStep(int step) {
    _currentStep = step;
    notifyListeners();
  }

  void clearErrors() {
    _errorMessage = null;
    _faceValidationError = null;
    notifyListeners();
  }

  void reset() {
    _currentStep = 0;
    _isLoading = false;
    _errorMessage = null;
    _faceEmbedding = null;
    _faceImageFile = null;
    _faceImageUrl = null;
    _faceValidationError = null;
    _ktmData = null;
    _ktmImageFile = null;
    _ktmImageUrl = null;
    notifyListeners();
  }

  // Get user data for review
  Map<String, dynamic> getUserDataForReview() {
    return {
      'nim': _nim,
      'fullName': _fullName,
      'faculty': _faculty,
      'major': _major,
      'hasFaceData': _faceEmbedding != null,
      'hasKtmData': _ktmData != null,
      'faceImageUrl': _faceImageUrl,
      'ktmImageUrl': _ktmImageUrl,
    };
  }
}