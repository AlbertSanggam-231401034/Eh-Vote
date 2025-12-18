// lib/services/storage_service.dart
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import './supabase_storage_service.dart';

class StorageService {
  static final ImagePicker _imagePicker = ImagePicker();

  // --- CAMERA & GALLERY OPERATIONS ---

  // Take photo using camera
  static Future<File?> takePhoto() async {
    try {
      final XFile? photo = await _imagePicker.pickImage(
        source: ImageSource.camera,
        preferredCameraDevice: CameraDevice.front,
        imageQuality: 80,
        maxWidth: 720,
      );

      if (photo != null) {
        return File(photo.path);
      }
      return null;
    } catch (e) {
      print('❌ Error taking photo: $e');
      throw Exception('Gagal mengambil foto: $e');
    }
  }

  // Pick image from gallery
  static Future<File?> pickImage() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
        maxWidth: 720,
      );

      if (image != null) {
        return File(image.path);
      }
      return null;
    } catch (e) {
      print('❌ Error picking image: $e');
      throw Exception('Gagal memilih gambar: $e');
    }
  }

  // --- UPLOAD OPERATIONS (Updated to match SupabaseStorageService) ---

  // Upload face image
  static Future<String?> uploadFaceImage(File imageFile, String nim) async {
    try {
      // Panggil wrapper yang sudah kita buat di SupabaseStorageService
      final String? imageUrl = await SupabaseStorageService.uploadFaceImage(imageFile, nim);

      if (imageUrl == null) {
        throw Exception('Gagal mengupload foto wajah');
      }
      return imageUrl;
    } catch (e) {
      print('❌ Error uploading face image: $e');
      rethrow;
    }
  }

  // Upload KTM image
  static Future<String?> uploadKtmImage(File imageFile, String nim) async {
    try {
      final String? imageUrl = await SupabaseStorageService.uploadKtmImage(imageFile, nim);

      if (imageUrl == null) {
        throw Exception('Gagal mengupload foto KTM');
      }
      return imageUrl;
    } catch (e) {
      print('❌ Error uploading KTM image: $e');
      rethrow;
    }
  }

  // Upload candidate photo
  static Future<String?> uploadCandidatePhoto(File imageFile, String candidateId) async {
    try {
      // Manual path construction karena wrapper khusus candidate mungkin sudah dihapus di SupabaseService
      // untuk penyederhanaan. Kita pakai uploadFile generic.
      final fileName = 'cand_${candidateId}_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final String? imageUrl = await SupabaseStorageService.uploadFile(
          imageFile,
          'candidates/$fileName'
      );

      if (imageUrl == null) {
        throw Exception('Gagal mengupload foto kandidat');
      }
      return imageUrl;
    } catch (e) {
      print('❌ Error uploading candidate photo: $e');
      rethrow;
    }
  }

  // Upload election banner
  static Future<String?> uploadElectionBanner(File imageFile, String electionId) async {
    try {
      final fileName = 'banner_${electionId}_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final String? imageUrl = await SupabaseStorageService.uploadFile(
          imageFile,
          'election_banners/$fileName'
      );

      if (imageUrl == null) {
        throw Exception('Gagal mengupload banner pemilihan');
      }
      return imageUrl;
    } catch (e) {
      print('❌ Error uploading election banner: $e');
      rethrow;
    }
  }

  // Upload user avatar
  static Future<String?> uploadUserAvatar(File imageFile, String userId) async {
    try {
      final fileName = 'avatar_${userId}_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final String? imageUrl = await SupabaseStorageService.uploadFile(
          imageFile,
          'avatars/$fileName'
      );

      if (imageUrl == null) {
        throw Exception('Gagal mengupload avatar user');
      }
      return imageUrl;
    } catch (e) {
      print('❌ Error uploading user avatar: $e');
      rethrow;
    }
  }

  // Generic file upload (Updated params)
  static Future<String?> uploadFile({
    required File file,
    String folder = 'uploads', // Default folder
    String? fileName,
  }) async {
    try {
      final finalFileName = fileName ?? 'file_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final path = '$folder/$finalFileName';

      final String? imageUrl = await SupabaseStorageService.uploadFile(
          file,
          path
      );

      if (imageUrl == null) {
        throw Exception('Gagal mengupload file');
      }
      return imageUrl;
    } catch (e) {
      print('❌ Error uploading file: $e');
      rethrow;
    }
  }

  // --- DELETE & UTILITY ---

  // Delete image
  static Future<bool> deleteImage(String imageUrl) async {
    try {
      return await SupabaseStorageService.deleteFile(imageUrl);
    } catch (e) {
      print('❌ Error deleting image: $e');
      return false;
    }
  }

  // Scan barcode (Simulation)
  static Future<String?> scanBarcode() async {
    try {
      await Future.delayed(const Duration(seconds: 2));
      return 'KTM_${DateTime.now().millisecondsSinceEpoch}';
    } catch (e) {
      print('❌ Error scanning barcode: $e');
      throw Exception('Gagal memindai barcode: $e');
    }
  }
}