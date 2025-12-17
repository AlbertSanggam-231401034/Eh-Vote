import '../core/constants/faculty_constants.dart'; // Pastikan path import ini sesuai

class KTMScannerUtils {

  // Validasi Logika NIM (Mengecek Struktur dan Kode Fakultas)
  static bool isValidNIMLogic(String nim) {
    // 1. Cek Panjang: Harus 9 Digit sesuai contoh (221401034)
    if (nim.length != 9) return false;

    // 2. Ambil Kode Fakultas (Digit ke-3 dan ke-4)
    // Contoh: 22[14]01034 -> '14'
    String facultyCode = nim.substring(2, 4);

    // 3. Cek apakah kode fakultas tersebut ada di FacultyConstants
    bool isFacultyValid = FacultyConstants.faculties.any(
            (element) => element['id'] == facultyCode
    );

    return isFacultyValid;
  }

  // Mendapatkan Nama Fakultas secara otomatis dari NIM
  static String getFacultyNameFromNIM(String nim) {
    if (!isValidNIMLogic(nim)) return 'Fakultas Tidak Diketahui';

    String facultyCode = nim.substring(2, 4);
    try {
      final faculty = FacultyConstants.faculties.firstWhere(
              (element) => element['id'] == facultyCode
      );
      return faculty['name'] as String;
    } catch (e) {
      return 'Fakultas Tidak Valid';
    }
  }

  // Mendapatkan Tahun Angkatan (Stambuk) dari NIM
  static String getAngkatanFromNIM(String nim) {
    if (nim.length < 2) return '-';
    // Contoh: 22 -> 2022
    return '20${nim.substring(0, 2)}';
  }

  // Helper untuk format tampilan NIM agar mudah dibaca
  // Input: 221401034 -> Output: 22.14.01.034
  static String formatNIMDisplay(String nim) {
    if (nim.length == 9) {
      return '${nim.substring(0, 2)}.${nim.substring(2, 4)}.${nim.substring(4, 6)}.${nim.substring(6)}';
    }
    return nim;
  }
}