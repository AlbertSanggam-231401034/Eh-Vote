import 'package:mobile_scanner/mobile_scanner.dart';
import '../utils/ktm_scanner_utils.dart'; // Import utils yang baru dibuat

class KTMScannerService {
  final MobileScannerController controller = MobileScannerController();

  // Function to validate NIM format (USU standard 9 Digits)
  bool isValidNIM(String nim) {
    // 1. Regex Check: Pastikan hanya angka dan berjumlah 9 digit
    // ^[0-9]{9}$ -> Menerima angka 0-9 sebanyak tepat 9 kali
    final RegExp nimRegex = RegExp(r'^[0-9]{9}$');

    if (!nimRegex.hasMatch(nim)) {
      return false;
    }

    // 2. Logic Check: Pastikan kode fakultas (digit 3-4) valid sesuai data USU
    return KTMScannerUtils.isValidNIMLogic(nim);
  }

  // Extract and validate NIM from barcode
  String? extractAndValidateNIM(Barcode barcode) {
    final String? rawNIM = barcode.rawValue;

    if (rawNIM == null) return null;

    // Clean the NIM (hapus spasi atau karakter aneh jika ada)
    final String cleanNIM = rawNIM.trim().replaceAll(' ', '');

    if (isValidNIM(cleanNIM)) {
      return cleanNIM;
    }

    return null;
  }

  void dispose() {
    controller.dispose();
  }
}