import 'dart:io';
import 'package:flutter/material.dart';
import 'package:suara_kita/data/models/user_model.dart';
import 'package:suara_kita/services/face_recognition_service.dart';
import 'package:suara_kita/services/firebase_service.dart';
import 'package:suara_kita/services/storage_service.dart';

class SignupProvider extends ChangeNotifier {
  // === STATE ===
  bool _isLoading = false;
  String? _errorMessage;

  // === USER DATA ===
  String? _nim;
  String? _fullName;
  String? _placeOfBirth;
  DateTime? _dateOfBirth;
  String? _phoneNumber;
  String? _faculty;
  String? _major;
  String? _gender;
  String? _password;

  // === FACE DATA ===
  List<double>? _faceEmbedding;
  File? _faceImageFile;
  String? _faceImageUrl;
  String? _faceValidationError;

  // === KTM DATA ===
  String? _ktmData;
  File? _ktmImageFile;
  String? _ktmImageUrl;

  // === GETTERS ===
  String? get nim => _nim;
  String? get password => _password;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  List<double>? get faceEmbedding => _faceEmbedding;
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

  // SINKRONISASI DENGAN FaceScanPage
  void updateFaceData(File imageFile, String imageUrl, List<double> embedding) {
    _faceImageFile = imageFile;
    _faceImageUrl = imageUrl;
    _faceEmbedding = embedding;
    notifyListeners();
  }

  void setKtmData(String ktmData, File ktmImageFile) {
    _ktmData = ktmData;
    _ktmImageFile = ktmImageFile;
    notifyListeners();
  }

  // === FACE METHODS UNTUK SignupFacePage ===
  Future<void> captureFaceFromCamera() async {
    try {
      _isLoading = true;
      _faceValidationError = null;
      notifyListeners();
      final faceService = FaceRecognitionService();
      final imageFile = await faceService.captureFaceImage();
      if (imageFile == null) throw Exception('Gagal mengambil foto.');
      final embedding = await faceService.extractFaceEmbedding(imageFile);
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
      notifyListeners();
      final faceService = FaceRecognitionService();
      final imageFile = await faceService.pickFaceImage();
      if (imageFile == null) return;
      final embedding = await faceService.extractFaceEmbedding(imageFile);
      _faceEmbedding = embedding;
      _faceImageFile = imageFile;
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      rethrow;
    }
  }

  // === FINAL SIGNUP ===
  Future<bool> completeSignup() async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      if (_nim == null) throw Exception("NIM tidak ditemukan.");

      // Upload KTM jika belum ada URL
      if (_ktmImageFile != null && (_ktmImageUrl == null || _ktmImageUrl!.isEmpty)) {
        _ktmImageUrl = await StorageService.uploadKtmImage(_ktmImageFile!, _nim!);
      }

      final user = User(
        nim: _nim!,
        password: _password ?? '',
        fullName: _fullName ?? '',
        placeOfBirth: _placeOfBirth ?? '',
        dateOfBirth: _dateOfBirth ?? DateTime.now(),
        phoneNumber: _phoneNumber ?? '',
        faculty: _faculty ?? '',
        major: _major ?? '',
        gender: _gender ?? '',
        ktmData: _ktmData ?? 'VERIFIED',
        faceData: _faceImageUrl ?? '',
        role: UserRole.voter,
        hasVoted: false,
        createdAt: DateTime.now(),
        faceImageUrl: _faceImageUrl ?? '',
        ktmImageUrl: _ktmImageUrl ?? '',
        faceEmbedding: _faceEmbedding ?? [],
      );

      await FirebaseService.saveUser(user);
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
}