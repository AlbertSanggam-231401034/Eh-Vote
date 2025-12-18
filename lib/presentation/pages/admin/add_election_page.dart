import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:suara_kita/core/constants/colors.dart';
import 'package:suara_kita/data/models/election_model.dart';
import 'package:suara_kita/services/firebase_service.dart';
import 'package:suara_kita/services/supabase_storage_service.dart';

class AddElectionPage extends StatefulWidget {
  const AddElectionPage({super.key});

  @override
  State<AddElectionPage> createState() => _AddElectionPageState();
}

class _AddElectionPageState extends State<AddElectionPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _idCtrl = TextEditingController();

  DateTime _startDate = DateTime.now();
  DateTime _endDate = DateTime.now().add(const Duration(days: 1));

  File? _bannerFile;
  bool _isSubmitting = false;

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80
    );
    if (pickedFile != null) {
      setState(() => _bannerFile = File(pickedFile.path));
    }
  }

  Future<void> _selectDate(BuildContext context, bool isStart) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: isStart ? _startDate : _endDate,
      firstDate: DateTime.now().subtract(const Duration(days: 30)),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      setState(() {
        if (isStart) {
          _startDate = picked;
        } else {
          _endDate = picked;
        }
      });
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    // Validasi Gambar
    if (_bannerFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Wajib upload Banner Acara!"))
      );
      return;
    }

    // Validasi tanggal
    if (_endDate.isBefore(_startDate)) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Tanggal selesai harus setelah tanggal mulai!"))
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      // 1. Upload Banner ke Supabase (Folder: election_banners)
      final fileName = 'banner_${_idCtrl.text}_${DateTime.now().millisecondsSinceEpoch}.jpg';

      final bannerUrl = await SupabaseStorageService.uploadFile(
          _bannerFile!,
          'election_banners/$fileName' // ✅ Path folder rapi
      );

      if (bannerUrl == null) throw Exception("Gagal upload banner");

      // 2. Simpan ke Firebase
      final newElection = ElectionModel(
        id: _idCtrl.text.trim().replaceAll(' ', '_').toLowerCase(),
        title: _titleCtrl.text,
        description: _descCtrl.text,
        startDate: _startDate,
        endDate: _endDate,
        bannerUrl: bannerUrl,
        createdAt: DateTime.now(),
        candidateIds: [],
        facultyFilter: null,
      );

      await FirebaseService.addElection(newElection);

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Berhasil membuat pemilihan!"))
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Gagal: $e"))
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    _idCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
            'Buat Pemilihan Baru',
            style: GoogleFonts.unbounded(fontSize: 16)
        ),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.darkGreen,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            // --- BANNER UPLOAD AREA ---
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Banner Acara *",
                  style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[700],
                      fontWeight: FontWeight.w500
                  ),
                ),
                const SizedBox(height: 8),
                GestureDetector(
                  onTap: _pickImage,
                  child: Container(
                    height: 180,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                          color: _bannerFile == null
                              ? Colors.grey[300]!
                              : AppColors.primaryGreen,
                          width: _bannerFile == null ? 1 : 2
                      ),
                      image: _bannerFile != null
                          ? DecorationImage(
                          image: FileImage(_bannerFile!),
                          fit: BoxFit.cover
                      )
                          : null,
                    ),
                    child: _bannerFile == null
                        ? Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                            Icons.add_photo_alternate,
                            size: 40,
                            color: Colors.grey[400]
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "Upload Banner Acara",
                          style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 14
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "Rekomendasi: 1200x600 px",
                          style: TextStyle(
                              color: Colors.grey[400],
                              fontSize: 12
                          ),
                        ),
                      ],
                    )
                        : Stack(
                      children: [
                        Positioned(
                          top: 8,
                          right: 8,
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                                color: Colors.black54,
                                borderRadius: BorderRadius.circular(20)
                            ),
                            child: const Icon(
                              Icons.edit,
                              color: Colors.white,
                              size: 16,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                if (_bannerFile != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    "Klik untuk mengganti gambar",
                    style: TextStyle(
                        color: Colors.grey[500],
                        fontSize: 12
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 24),

            // --- ID PEMILIHAN ---
            TextFormField(
              controller: _idCtrl,
              decoration: InputDecoration(
                labelText: 'ID Pemilihan (Unik) *',
                hintText: 'contoh: pemira_usu_2025',
                border: const OutlineInputBorder(),
                prefixIcon: const Icon(Icons.tag, size: 20),
                helperText: 'ID akan digunakan dalam URL dan tidak bisa diubah',
                helperStyle: const TextStyle(fontSize: 12),
              ),
              validator: (v) {
                if (v == null || v.isEmpty) return 'Wajib diisi';
                if (v.contains(' ')) return 'ID tidak boleh mengandung spasi';
                return null;
              },
            ),
            const SizedBox(height: 16),

            // --- JUDUL ACARA ---
            TextFormField(
              controller: _titleCtrl,
              decoration: const InputDecoration(
                labelText: 'Judul Acara *',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.title, size: 20),
              ),
              validator: (v) => v == null || v.isEmpty ? 'Wajib diisi' : null,
            ),
            const SizedBox(height: 16),

            // --- DESKRIPSI ---
            TextFormField(
              controller: _descCtrl,
              maxLines: 4,
              decoration: const InputDecoration(
                labelText: 'Deskripsi Lengkap *',
                border: OutlineInputBorder(),
                alignLabelWithHint: true,
              ),
              validator: (v) => v == null || v.isEmpty ? 'Wajib diisi' : null,
            ),
            const SizedBox(height: 20),

            // --- TANGGAL MULAI & SELESAI ---
            Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: () => _selectDate(context, true),
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey[300]!),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.calendar_today,
                                size: 18,
                                color: AppColors.primaryGreen,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                "Mulai",
                                style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[600]
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            "${_startDate.day}/${_startDate.month}/${_startDate.year}",
                            style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: InkWell(
                    onTap: () => _selectDate(context, false),
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey[300]!),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.event_busy,
                                size: 18,
                                color: Colors.red[400],
                              ),
                              const SizedBox(width: 8),
                              Text(
                                "Selesai",
                                style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[600]
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            "${_endDate.day}/${_endDate.month}/${_endDate.year}",
                            style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              "Durasi: ${_endDate.difference(_startDate).inDays + 1} hari",
              style: TextStyle(
                color: _endDate.isBefore(_startDate) ? Colors.red : Colors.grey[600],
                fontSize: 12,
                fontStyle: FontStyle.italic,
              ),
            ),
            const SizedBox(height: 30),

            // --- TOMBOL SUBMIT ---
            ElevatedButton(
              onPressed: _isSubmitting ? null : _submit,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryGreen,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.all(16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                elevation: 2,
              ),
              child: _isSubmitting
                  ? const SizedBox(
                height: 24,
                width: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 3,
                  color: Colors.white,
                ),
              )
                  : const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.add_circle_outline, size: 20),
                  SizedBox(width: 8),
                  Text(
                    "BUAT PEMILIHAN",
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // --- CATATAN ---
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey[200]!),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        size: 16,
                        color: Colors.grey[600],
                      ),
                      const SizedBox(width: 6),
                      Text(
                        "Catatan:",
                        style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: Colors.grey[700],
                            fontSize: 13
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    "• ID pemilihan bersifat unik dan tidak bisa diubah\n"
                        "• Banner akan ditampilkan di halaman detail pemilihan\n"
                        "• Tanggal mulai harus sebelum tanggal selesai",
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 12,
                      height: 1.5,
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