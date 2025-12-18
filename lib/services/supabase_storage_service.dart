import 'dart:io';
import 'dart:typed_data';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../core/config/supabase_config.dart'; // Pastikan import ini ada jika config dipisah

class SupabaseStorageService {
  // Instance client Supabase
  static final SupabaseClient _supabase = Supabase.instance.client;

  // ========== CONFIGURATION ==========

  // ✅ PENTING: Gunakan satu bucket utama agar permission lebih mudah diatur
  // Pastikan bucket 'ktm-images' sudah Public di Supabase Console
  static const String mainBucket = 'ktm-images';

  // ========== INITIALIZATION ==========

  static Future<void> initialize() async {
    // Inisialisasi biasanya sudah di main.dart, tapi method ini disimpan untuk jaga-jaga
    await Supabase.initialize(
      url: SupabaseConfig.supabaseUrl,
      anonKey: SupabaseConfig.supabaseAnonKey,
    );
  }

  // ========== GENERIC UPLOAD METHODS (FIXED) ==========

  /// ✅ Upload file Generic (Positional Arguments - Sesuai yang diminta Page)
  /// [file] : File yang akan diupload
  /// [path] : Path lengkap termasuk folder (contoh: 'candidates/foto.jpg')
  static Future<String?> uploadFile(File file, String path) async {
    try {
      // 1. Validasi file
      if (!await file.exists()) {
        print('❌ File tidak ditemukan: ${file.path}');
        return null;
      }

      // 2. Opsi Upload (Cache & Upsert/Overwrite)
      const FileOptions fileOptions = FileOptions(
        cacheControl: '3600',
        upsert: true,
      );

      // 3. Upload ke Supabase
      // Kita upload ke mainBucket, tapi path-nya mengandung folder
      await _supabase.storage.from(mainBucket).upload(
        path,
        file,
        fileOptions: fileOptions,
      );

      // 4. Ambil Public URL
      final String publicUrl = _supabase.storage.from(mainBucket).getPublicUrl(path);

      print('✅ Upload Sukses ke: $path');
      print('🔗 URL: $publicUrl');

      return publicUrl;
    } catch (e) {
      print('❌ Error uploading file to Supabase: $e');
      return null;
    }
  }

  /// Upload binary data
  static Future<String?> uploadBinary(Uint8List data, String path) async {
    try {
      await _supabase.storage.from(mainBucket).uploadBinary(
        path,
        data,
        fileOptions: const FileOptions(cacheControl: '3600', upsert: true),
      );

      final String publicUrl = _supabase.storage.from(mainBucket).getPublicUrl(path);
      return publicUrl;
    } catch (e) {
      print('❌ Error uploading binary: $e');
      return null;
    }
  }

  // ========== HELPER WRAPPERS (Untuk Kompatibilitas Kode Lama) ==========

  /// Upload KTM (Folder: ktm_scans)
  static Future<String?> uploadKtmImage(File imageFile, String nim) async {
    final fileName = 'ktm_${nim}_${DateTime.now().millisecondsSinceEpoch}.jpg';
    return uploadFile(imageFile, 'ktm_scans/$fileName');
  }

  /// Upload Wajah (Folder: face_scans)
  static Future<String?> uploadFaceImage(File imageFile, String nim) async {
    final fileName = 'face_${nim}_${DateTime.now().millisecondsSinceEpoch}.jpg';
    return uploadFile(imageFile, 'face_scans/$fileName');
  }

  /// Upload Candidate Photo (Wrapper opsional jika kode lama masih pakai ini)
  static Future<String?> uploadCandidatePhoto(File imageFile, String candidateId) async {
    final fileName = 'candidate_${candidateId}_${DateTime.now().millisecondsSinceEpoch}.jpg';
    return uploadFile(imageFile, 'candidates/$fileName');
  }

  // ========== DELETE METHODS ==========

  /// Delete file berdasarkan URL
  static Future<bool> deleteFile(String fileUrl) async {
    try {
      final Uri uri = Uri.parse(fileUrl);
      final List<String> segments = uri.pathSegments;

      // Cari index bucket di URL
      final int bucketIndex = segments.indexOf(mainBucket);

      if (bucketIndex == -1 || bucketIndex + 1 >= segments.length) {
        print('❌ Invalid URL format for deletion');
        return false;
      }

      // Gabungkan sisa segment menjadi path
      final String filePath = segments.sublist(bucketIndex + 1).join('/');

      print('🗑️ Deleting: $filePath');
      await _supabase.storage.from(mainBucket).remove([filePath]);

      return true;
    } catch (e) {
      print('❌ Error deleting file: $e');
      return false;
    }
  }
}