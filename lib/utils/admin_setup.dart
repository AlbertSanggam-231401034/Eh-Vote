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
    ktmData: 'ADMIN_SCAN_REQUIRED', // Tanda bahwa admin perlu scan
    faceData: 'ADMIN_SCAN_REQUIRED', // Tanda bahwa admin perlu scan
    role: UserRole.superAdmin,
    hasVoted: false,
    createdAt: DateTime(2025, 11, 17, 6, 42, 54),
    faceImageUrl: '', // Akan diisi saat admin melakukan scan
    ktmImageUrl: '', // Akan diisi saat admin melakukan scan
  );

  // Backup admin (untuk emergency)
  static final List<User> backupAdmins = [
    User(
      nim: 'ADMIN001',
      password: 'admin123',
      fullName: 'System Administrator',
      placeOfBirth: 'Medan',
      dateOfBirth: DateTime(1990, 1, 1),
      phoneNumber: '081234567890',
      faculty: 'Fakultas Ilmu Komputer dan Teknologi Informasi',
      major: 'Teknologi Informasi',
      gender: 'Laki-laki',
      ktmData: 'ADMIN_SCAN_REQUIRED',
      faceData: 'ADMIN_SCAN_REQUIRED',
      role: UserRole.admin,
      hasVoted: false,
      createdAt: DateTime.now(),
      faceImageUrl: '',
      ktmImageUrl: '',
    ),
  ];

  static Future<void> setupAdmins() async {
    try {
      print('🚀 Setting up admin accounts...');

      // 1. Update main admin jika diperlukan
      final existingMainAdmin = await FirebaseService.getUserByNim(mainAdmin.nim);
      if (existingMainAdmin != null) {
        // Update data admin dengan field yang mungkin missing
        await FirebaseService.updateUser(mainAdmin.nim, {
          'gender': mainAdmin.gender,
          'faceImageUrl': existingMainAdmin.faceImageUrl.isNotEmpty
              ? existingMainAdmin.faceImageUrl
              : mainAdmin.faceImageUrl,
          'ktmImageUrl': existingMainAdmin.ktmImageUrl.isNotEmpty
              ? existingMainAdmin.ktmImageUrl
              : mainAdmin.ktmImageUrl,
          'faceData': existingMainAdmin.faceData,
          'ktmData': existingMainAdmin.ktmData,
          'role': 'superAdmin',
        });
        print('🔄 Admin ${mainAdmin.nim} data updated');
      } else {
        // Jika admin belum ada, buat baru
        await FirebaseService.saveUser(mainAdmin);
        print('✅ Main admin ${mainAdmin.nim} berhasil dibuat');
      }

      // 2. Setup backup admins
      for (final admin in backupAdmins) {
        final existingAdmin = await FirebaseService.getUserByNim(admin.nim);
        if (existingAdmin == null) {
          await FirebaseService.saveUser(admin);
          print('✅ Backup admin ${admin.nim} berhasil ditambahkan');
        } else {
          // Update backup admin data
          await FirebaseService.updateUser(admin.nim, {
            'gender': admin.gender,
            'faceImageUrl': existingAdmin.faceImageUrl,
            'ktmImageUrl': existingAdmin.ktmImageUrl,
          });
          print('🔄 Backup admin ${admin.nim} data updated');
        }
      }

      print('🎉 Admin setup completed!');
    } catch (e) {
      print('❌ Error setting up admins: $e');
    }
  }

  // Method untuk check jika admin perlu melengkapi scan
  static bool needsScan(User admin) {
    return admin.faceImageUrl.isEmpty || admin.ktmImageUrl.isEmpty;
  }
}