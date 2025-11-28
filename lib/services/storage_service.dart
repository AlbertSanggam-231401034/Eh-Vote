// lib/services/storage_service.dart
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import './supabase_storage_service.dart';

class StorageService {
  static final ImagePicker _imagePicker = ImagePicker();

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

  // Upload face image to Supabase - METHOD BARU
  static Future<String> uploadFaceImage(File imageFile, String nim) async {
    return SupabaseStorageService.uploadFaceImage(imageFile, nim);
  }

  // Upload KTM image to Supabase - METHOD BARU
  static Future<String> uploadKtmImage(File imageFile, String nim) async {
    return SupabaseStorageService.uploadKtmImage(imageFile, nim);
  }

  // Delete image from storage
  static Future<void> deleteImage(String imageUrl) async {
    if (SupabaseStorageService.isSupabaseUrl(imageUrl)) {
      await SupabaseStorageService.deleteImage(imageUrl);
    } else {
      print('⚠️ URL bukan dari Supabase, skip deletion');
    }
  }

  // Scan barcode (simulated)
  static Future<String?> scanBarcode() async {
    try {
      // TODO: Implement actual barcode scanning
      await Future.delayed(const Duration(seconds: 2));
      return 'KTM_${DateTime.now().millisecondsSinceEpoch}';
    } catch (e) {
      print('❌ Error scanning barcode: $e');
      throw Exception('Gagal memindai barcode: $e');
    }
  }
}