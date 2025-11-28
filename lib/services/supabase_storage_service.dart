// lib/services/supabase_storage_service.dart
import 'dart:io';
import 'dart:typed_data'; // Penting: Untuk tipe data Uint8List
import 'package:supabase_flutter/supabase_flutter.dart';
import '../core/config/supabase_config.dart';

class SupabaseStorageService {
  // Instance client Supabase
  static final SupabaseClient _supabase = SupabaseClient(
    SupabaseConfig.supabaseUrl,
    SupabaseConfig.supabaseAnonKey,
  );

  // Initialize Supabase (biasanya dipanggil di main.dart)
  static Future<void> initialize() async {
    await Supabase.initialize(
      url: SupabaseConfig.supabaseUrl,
      anonKey: SupabaseConfig.supabaseAnonKey,
    );
  }

  // Upload image to Supabase Storage
  static Future<String> uploadImage({
    required File imageFile,
    required String bucketName,
    required String fileName,
  }) async {
    try {
      // Read file bytes as Uint8List (Perbaikan utama disini)
      Uint8List imageBytes = await imageFile.readAsBytes();

      // Upload to Supabase Storage using uploadBinary
      await _supabase.storage
          .from(bucketName)
          .uploadBinary(fileName, imageBytes);

      // Get public URL after upload
      final String publicUrl = _supabase.storage
          .from(bucketName)
          .getPublicUrl(fileName);

      print('✅ Image uploaded to Supabase: $publicUrl');
      return publicUrl;
    } catch (e) {
      print('❌ Error uploading to Supabase: $e');
      throw Exception('Gagal mengupload gambar ke Supabase: $e');
    }
  }

  // Helper: Upload face image
  static Future<String> uploadFaceImage(File imageFile, String nim) async {
    final String fileName = 'face_${nim}_${DateTime.now().millisecondsSinceEpoch}.jpg';
    return uploadImage(
      imageFile: imageFile,
      bucketName: SupabaseConfig.faceImagesBucket,
      fileName: fileName,
    );
  }

  // Helper: Upload KTM image
  static Future<String> uploadKtmImage(File imageFile, String nim) async {
    final String fileName = 'ktm_${nim}_${DateTime.now().millisecondsSinceEpoch}.jpg';
    return uploadImage(
      imageFile: imageFile,
      bucketName: SupabaseConfig.ktmImagesBucket,
      fileName: fileName,
    );
  }

  // Delete image from Supabase Storage
  static Future<void> deleteImage(String imageUrl) async {
    try {
      // Extract file name from URL
      final Uri uri = Uri.parse(imageUrl);
      final String filePath = uri.pathSegments.last;

      // Determine bucket from URL logic
      final String bucketName = uri.pathSegments.contains(SupabaseConfig.faceImagesBucket)
          ? SupabaseConfig.faceImagesBucket
          : SupabaseConfig.ktmImagesBucket;

      await _supabase.storage
          .from(bucketName)
          .remove([filePath]);

      print('✅ Image deleted from Supabase: $imageUrl');
    } catch (e) {
      print('❌ Error deleting from Supabase: $e');
      throw Exception('Gagal menghapus gambar dari Supabase: $e');
    }
  }

  // Utility: Check if URL is from Supabase Storage
  static bool isSupabaseUrl(String url) {
    return url.contains(SupabaseConfig.supabaseUrl);
  }
}