// test_supabase.dart
import 'package:suara_kita/services/storage_service.dart';
import 'dart:io';

void testSupabaseUpload() async {
  try {
    // Test dengan gambar dummy atau ambil dari camera
    // Test di Flutter
    final File? testImage = await StorageService.takePhoto();
    if (testImage != null) {
      final String url = await StorageService.uploadFaceImage(testImage, 'test_nim');
      print('Uploaded to: $url');
    }
  } catch (e) {
    print('❌ Supabase upload failed: $e');
  }
}