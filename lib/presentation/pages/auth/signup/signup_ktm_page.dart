import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:suara_kita/presentation/providers/signup_provider.dart';
import 'package:suara_kita/presentation/pages/scan/camera_page.dart';
import 'package:suara_kita/core/constants/colors.dart';

class SignupKtmPage extends StatefulWidget {
  static const routeName = '/signup-ktm';
  const SignupKtmPage({super.key});

  @override
  State<SignupKtmPage> createState() => _SignupKtmPageState();
}

class _SignupKtmPageState extends State<SignupKtmPage> {
  File? _localKtmImage;
  bool _localIsScanning = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<SignupProvider>();

      // Cek apakah data dari step sebelumnya masih ada
      if (provider.nim == null || provider.faceEmbedding == null) {
        _showDataMissingDialog();
      }
    });
  }

  void _showDataMissingDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text("Data Tidak Lengkap"),
        content: const Text("State data pendaftaran hilang (reset). Silakan ulangi proses dari awal."),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).popUntil((route) => route.isFirst);
            },
            child: const Text("ULANGI"),
          )
        ],
      ),
    );
  }

  Future<void> _scanKTM() async {
    setState(() => _localIsScanning = true);
    try {
      final File? imageFile = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const CameraPage(
            title: 'Scan KTM',
            description: 'Foto KTM fisik Anda dengan jelas',
            isFaceScan: false,
          ),
        ),
      );

      if (imageFile != null) {
        setState(() => _localKtmImage = imageFile);
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Kamera Error: $e')));
    } finally {
      if (mounted) setState(() => _localIsScanning = false);
    }
  }

  Future<void> _finishSignup() async {
    final provider = context.read<SignupProvider>();

    // Proteksi sebelum kirim
    if (provider.nim == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Error: NIM Kosong. Silakan restart app.")));
      return;
    }

    if (_localKtmImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Silakan ambil foto KTM dulu")));
      return;
    }

    // Masukkan ke provider
    provider.setKtmData("VERIFIED_PHOTO", _localKtmImage!);

    final success = await provider.completeSignup();

    if (success && mounted) {
      Navigator.pushNamedAndRemoveUntil(context, '/signup-success', (route) => false);
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(provider.errorMessage ?? "Gagal mendaftar."),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    const Color kPrimaryGreen = Color(0xFF00C64F);
    const Color kDarkGreen = Color(0xFF002D12);

    final provider = context.watch<SignupProvider>();
    final isSuccess = _localKtmImage != null;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Verifikasi Terakhir"),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: kDarkGreen,
        elevation: 0,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                "Step 4: Ambil Foto KTM",
                style: GoogleFonts.unbounded(fontSize: 18, fontWeight: FontWeight.bold, color: kPrimaryGreen),
              ),
            ),
            const Spacer(),

            // Preview
            Container(
              height: 250,
              width: double.infinity,
              margin: const EdgeInsets.symmetric(horizontal: 24),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: isSuccess ? kPrimaryGreen : Colors.grey.shade300, width: 2),
              ),
              child: isSuccess
                  ? ClipRRect(
                borderRadius: BorderRadius.circular(18),
                child: Image.file(_localKtmImage!, fit: BoxFit.cover),
              )
                  : const Center(child: Icon(Icons.credit_card, size: 100, color: Colors.grey)),
            ),

            const Spacer(),

            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: OutlinedButton.icon(
                      onPressed: provider.isLoading ? null : _scanKTM,
                      icon: const Icon(Icons.camera_alt),
                      label: Text(isSuccess ? "FOTO ULANG" : "AMBIL FOTO"),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: kPrimaryGreen,
                        side: const BorderSide(color: kPrimaryGreen, width: 1.5),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton(
                      onPressed: (isSuccess && !provider.isLoading) ? _finishSignup : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: kPrimaryGreen,
                        foregroundColor: Colors.white,
                        disabledBackgroundColor: Colors.grey[300],
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        elevation: 0,
                      ),
                      child: provider.isLoading
                          ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                          : const Text("SELESAI & DAFTAR", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}