// lib/utils/admin_setup.dart
import 'package:suara_kita/data/models/user_model.dart';
import 'package:suara_kita/services/firebase_service.dart';

class AdminSetup {
  // Admin utama - gunakan data yang sudah ada
  static final User mainAdmin = User(
    nim: '231401034',
    password: 'albertto22',
    fullName: 'Albert Sanggam Nalom Sinurat',
    placeOfBirth: 'Lubuk Pakam',
    dateOfBirth: DateTime(2005, 9, 22),
    phoneNumber: '081278093204',
    faculty: 'Fakultas Ilmu Komputer dan Teknologi Informasi (Fasilkom-TI)',
    major: 'Ilmu Komputer',
    gender: 'Laki-laki',
    ktmData: 'ADMIN_SCAN_REQUIRED',
    faceData: 'ADMIN_SCAN_REQUIRED',
    role: UserRole.superAdmin,
    hasVoted: false,
    createdAt: DateTime(2025, 11, 17, 6, 42, 54),
    faceImageUrl: '',
    ktmImageUrl: '',
  );

  static Future<void> setupAdmins() async {
    try {
      print('🚀 Setting up admin accounts...');

      // 1. Cek apakah Admin Utama sudah ada
      final existingMainAdmin = await FirebaseService.getUserByNim(mainAdmin.nim);

      if (existingMainAdmin != null) {
        // 🔥 LOGIKA BARU: Cek apakah admin sudah pernah scan?
        bool hasScanned = existingMainAdmin.faceEmbedding != null &&
            existingMainAdmin.faceEmbedding!.isNotEmpty;

        if (hasScanned) {
          // JIKA SUDAH SCAN: Jangan timpa data scan-nya!
          // Cuma update role atau data statis lain yang mungkin berubah
          print('✅ Admin ${mainAdmin.nim} sudah scan. Skip reset data.');
          await FirebaseService.updateUser(mainAdmin.nim, {
            'role': 'superAdmin', // Pastikan role tetap superAdmin
            // JANGAN update faceImageUrl atau ktmImageUrl di sini
          });
        } else {
          // JIKA BELUM SCAN: Boleh update data dasar (reset)
          await FirebaseService.updateUser(mainAdmin.nim, {
            'fullName': mainAdmin.fullName,
            'password': mainAdmin.password,
            // Biarkan field scan tetap apa adanya (kosong/isi sebagian)
          });
          print('🔄 Admin ${mainAdmin.nim} data updated (Belum Scan).');
        }
      } else {
        // Jika admin belum ada sama sekali, buat baru (fresh)
        await FirebaseService.saveUser(mainAdmin);
        print('✅ Main admin ${mainAdmin.nim} berhasil dibuat baru');
      }

      print('🎉 Admin setup completed!');
    } catch (e) {
      print('❌ Error setting up admins: $e');
    }
  }

  // Method helper (Optional, tapi lebih baik cek manual di Dashboard)
  static bool needsScan(User admin) {
    // Admin dianggap butuh scan jika embedding-nya belum ada
    return admin.faceEmbedding == null || admin.faceEmbedding!.isEmpty;
  }
}