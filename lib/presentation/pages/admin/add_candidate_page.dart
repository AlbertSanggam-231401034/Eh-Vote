import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:suara_kita/core/constants/colors.dart';
import 'package:suara_kita/core/constants/faculty_constants.dart';
import 'package:suara_kita/data/models/candidate_model.dart';
import 'package:suara_kita/services/firebase_service.dart';
import 'package:suara_kita/services/supabase_storage_service.dart';

class AddCandidatePage extends StatefulWidget {
  final String electionId;

  const AddCandidatePage({super.key, required this.electionId});

  @override
  State<AddCandidatePage> createState() => _AddCandidatePageState();
}

class _AddCandidatePageState extends State<AddCandidatePage> {
  final _formKey = GlobalKey<FormState>();

  // --- Controllers ---
  final _nameCtrl = TextEditingController();
  final _nimCtrl = TextEditingController();
  final _numberCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _birthPlaceCtrl = TextEditingController();
  final _visionCtrl = TextEditingController();
  final _missionCtrl = TextEditingController();
  final _bioCtrl = TextEditingController();

  // Socials
  final _igCtrl = TextEditingController();
  final _fbCtrl = TextEditingController();
  final _xCtrl = TextEditingController();
  final _weiboCtrl = TextEditingController();

  // --- Dropdown State ---
  String _selectedGender = 'Laki-laki';
  DateTime _selectedDate = DateTime(2000, 1, 1);

  // Fakultas & Prodi
  String? _selectedFaculty;
  String? _selectedMajor;
  List<String> _availableMajors = [];

  File? _imageFile;
  bool _isUploading = false;

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 70
    );
    if (pickedFile != null) {
      setState(() => _imageFile = File(pickedFile.path));
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(1980),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() => _selectedDate = picked);
    }
  }

  void _onFacultyChanged(String? newValue) {
    setState(() {
      _selectedFaculty = newValue;
      _selectedMajor = null;
      _availableMajors = newValue != null
          ? FacultyConstants.getProgramsByFaculty(newValue)
          : [];
    });
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Mohon lengkapi data wajib!'))
      );
      return;
    }

    // Validasi Dropdown
    if (_selectedFaculty == null || _selectedMajor == null) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Wajib pilih Fakultas dan Prodi!'))
      );
      return;
    }

    if (_imageFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Wajib upload foto kandidat!'))
      );
      return;
    }

    setState(() => _isUploading = true);

    try {
      // 1. Upload Foto Kandidat
      final fileName = 'cand_${widget.electionId}_${DateTime.now().millisecondsSinceEpoch}.jpg';

      // ✅ FIX: Gunakan Positional Argument (file, path)
      final photoUrl = await SupabaseStorageService.uploadFile(
          _imageFile!,
          'candidates/$fileName'
      );

      if (photoUrl == null) throw Exception("Gagal upload foto ke Supabase");

      // 2. Generate candidate ID
      final candidateId = '${widget.electionId}_${_numberCtrl.text.trim()}';

      // ✅ FIX: Pastikan semua field String tidak null
      final newCandidate = CandidateModel(
        id: candidateId,
        electionId: widget.electionId,
        candidateNumber: _numberCtrl.text,
        name: _nameCtrl.text,
        nim: _nimCtrl.text,
        faculty: _selectedFaculty!,
        major: _selectedMajor!,
        gender: _selectedGender,
        placeOfBirth: _birthPlaceCtrl.text,
        dateOfBirth: _selectedDate,
        phoneNumber: _phoneCtrl.text,
        vision: _visionCtrl.text,
        mission: _missionCtrl.text,
        shortBiography: _bioCtrl.text,
        photoUrl: photoUrl,
        createdAt: DateTime.now(),
        // Kirim string langsung (default empty string handled by controller)
        instagramUrl: _igCtrl.text,
        facebookUrl: _fbCtrl.text,
        xUrl: _xCtrl.text,
        weiboUrl: _weiboCtrl.text,
        voteCount: 0,
        votesByStambuk: {},
      );

      await FirebaseService.addCandidate(newCandidate);

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Kandidat Berhasil Ditambahkan!'),
              backgroundColor: Colors.green,
            )
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: $e'),
              backgroundColor: Colors.red,
            )
        );
      }
    } finally {
      if (mounted) setState(() => _isUploading = false);
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _nimCtrl.dispose();
    _numberCtrl.dispose();
    _phoneCtrl.dispose();
    _birthPlaceCtrl.dispose();
    _visionCtrl.dispose();
    _missionCtrl.dispose();
    _bioCtrl.dispose();
    _igCtrl.dispose();
    _fbCtrl.dispose();
    _xCtrl.dispose();
    _weiboCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          'Tambah Kandidat Baru',
          style: GoogleFonts.unbounded(
            fontSize: 16,
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: AppColors.primaryGreen,
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
        centerTitle: true,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            // --- FOTO KANDIDAT ---
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  "Foto Profil Kandidat *",
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[700],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 12),
                GestureDetector(
                  onTap: _pickImage,
                  child: Container(
                    width: 140,
                    height: 160,
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: _imageFile == null
                            ? Colors.grey[300]!
                            : AppColors.primaryGreen,
                        width: _imageFile == null ? 1 : 2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey[300]!,
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                      image: _imageFile != null
                          ? DecorationImage(
                        image: FileImage(_imageFile!),
                        fit: BoxFit.cover,
                      )
                          : null,
                    ),
                    child: _imageFile == null
                        ? Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.add_a_photo,
                          size: 40,
                          color: AppColors.primaryGreen,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "Upload Foto",
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "Rekomendasi: 600x800 px",
                          style: TextStyle(
                            color: Colors.grey[400],
                            fontSize: 10,
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
                              borderRadius: BorderRadius.circular(20),
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
                if (_imageFile != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    "Klik untuk mengganti foto",
                    style: TextStyle(
                      color: Colors.grey[500],
                      fontSize: 12,
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 24),

            // --- INFO UTAMA ---
            _buildSectionTitle('Info Utama'),
            Row(
              children: [
                Expanded(
                  flex: 1,
                  child: TextFormField(
                    controller: _numberCtrl,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'No. Urut *',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.numbers, size: 20),
                    ),
                    validator: (v) => v == null || v.isEmpty ? 'Wajib diisi' : null,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 3,
                  child: TextFormField(
                    controller: _nameCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Nama Lengkap *',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.person, size: 20),
                    ),
                    validator: (v) => v == null || v.isEmpty ? 'Wajib diisi' : null,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _nimCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'NIM *',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.badge, size: 20),
                helperText: 'Contoh: 1234567890',
                helperStyle: TextStyle(fontSize: 12),
              ),
              validator: (v) {
                if (v == null || v.isEmpty) return 'Wajib diisi';
                if (v.length < 10) return 'NIM minimal 10 digit';
                return null;
              },
            ),

            // --- DATA PRIBADI ---
            const SizedBox(height: 24),
            _buildSectionTitle('Data Pribadi'),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _birthPlaceCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Tempat Lahir *',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.place, size: 20),
                    ),
                    validator: (v) => v == null || v.isEmpty ? 'Wajib diisi' : null,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: InkWell(
                    onTap: () => _selectDate(context),
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      height: 56,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey[400]!),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.calendar_today,
                            size: 20,
                            color: Colors.grey[600],
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Tanggal Lahir *',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[600],
                                  ),
                                ),
                                Text(
                                  "${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}",
                                  style: const TextStyle(fontSize: 14),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _selectedGender,
              decoration: const InputDecoration(
                labelText: 'Jenis Kelamin *',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.transgender, size: 20),
              ),
              items: ['Laki-laki', 'Perempuan']
                  .map((val) => DropdownMenuItem(
                value: val,
                child: Text(val),
              ))
                  .toList(),
              onChanged: (val) => setState(() => _selectedGender = val!),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _phoneCtrl,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                labelText: 'No. Handphone *',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.phone, size: 20),
                helperText: 'Contoh: 081234567890',
                helperStyle: TextStyle(fontSize: 12),
              ),
              validator: (v) {
                if (v == null || v.isEmpty) return 'Wajib diisi';
                if (v.length < 10) return 'No. HP minimal 10 digit';
                return null;
              },
            ),

            // --- AKADEMIK ---
            const SizedBox(height: 24),
            _buildSectionTitle('Akademik'),
            DropdownButtonFormField<String>(
              value: _selectedFaculty,
              isExpanded: true,
              decoration: const InputDecoration(
                labelText: 'Fakultas *',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.school, size: 20),
              ),
              items: FacultyConstants.getFacultyNames().map((faculty) {
                return DropdownMenuItem(
                  value: faculty,
                  child: Text(faculty),
                );
              }).toList(),
              onChanged: _onFacultyChanged,
              validator: (v) => v == null ? 'Pilih Fakultas' : null,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _selectedMajor,
              isExpanded: true,
              decoration: const InputDecoration(
                labelText: 'Program Studi *',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.menu_book, size: 20),
              ),
              items: _availableMajors.map((major) {
                return DropdownMenuItem(
                  value: major,
                  child: Text(major),
                );
              }).toList(),
              onChanged: _selectedFaculty == null
                  ? null
                  : (val) => setState(() => _selectedMajor = val),
              hint: Text(
                _selectedFaculty == null ? 'Pilih Fakultas terlebih dahulu' : 'Pilih Program Studi',
                style: TextStyle(color: Colors.grey[500]),
              ),
              validator: (v) => v == null ? 'Pilih Program Studi' : null,
              disabledHint: const Text('Pilih Fakultas terlebih dahulu'),
            ),

            // --- PROFIL KAMPANYE ---
            const SizedBox(height: 24),
            _buildSectionTitle('Profil Kampanye'),
            TextFormField(
              controller: _visionCtrl,
              maxLines: 2,
              decoration: const InputDecoration(
                labelText: 'Visi *',
                border: OutlineInputBorder(),
                alignLabelWithHint: true,
                hintText: 'Masukkan visi kandidat...',
              ),
              validator: (v) => v == null || v.isEmpty ? 'Wajib diisi' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _missionCtrl,
              maxLines: 4,
              decoration: const InputDecoration(
                labelText: 'Misi *',
                border: OutlineInputBorder(),
                alignLabelWithHint: true,
                hintText: 'Masukkan misi kandidat...',
              ),
              validator: (v) => v == null || v.isEmpty ? 'Wajib diisi' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _bioCtrl,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Biografi Singkat *',
                border: OutlineInputBorder(),
                alignLabelWithHint: true,
                hintText: 'Masukkan biografi singkat kandidat...',
              ),
              validator: (v) => v == null || v.isEmpty ? 'Wajib diisi' : null,
            ),

            // --- MEDIA SOSIAL ---
            const SizedBox(height: 24),
            _buildSectionTitle('Media Sosial (Opsional)'),
            TextFormField(
              controller: _igCtrl,
              decoration: const InputDecoration(
                labelText: 'Instagram URL',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.photo_camera_back, size: 20),
                hintText: 'https://instagram.com/username',
              ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _fbCtrl,
              decoration: const InputDecoration(
                labelText: 'Facebook URL',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.facebook, size: 20),
                hintText: 'https://facebook.com/username',
              ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _xCtrl,
              decoration: const InputDecoration(
                labelText: 'X (Twitter) URL',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.tag, size: 20),
                hintText: 'https://twitter.com/username',
              ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _weiboCtrl,
              decoration: const InputDecoration(
                labelText: 'Weibo URL',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.language, size: 20),
                hintText: 'https://weibo.com/username',
              ),
            ),

            // --- TOMBOL SIMPAN ---
            const SizedBox(height: 32),
            SizedBox(
              height: 56,
              child: ElevatedButton(
                onPressed: _isUploading ? null : _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryGreen,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  elevation: 2,
                  shadowColor: AppColors.primaryGreen.withOpacity(0.3),
                ),
                child: _isUploading
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
                    Icon(Icons.save, size: 22),
                    SizedBox(width: 10),
                    Text(
                      'SIMPAN KANDIDAT',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // --- INFO PENTING ---
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.grey[200]!),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        size: 18,
                        color: AppColors.primaryGreen,
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'Informasi Penting',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '• Foto akan disimpan di folder "candidates" pada Supabase Storage\n'
                        '• Pastikan semua data yang dimasukkan sudah benar\n'
                        '• Data kandidat tidak dapat diubah setelah disimpan\n'
                        '• No. urut tidak boleh duplikat dalam satu pemilihan',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 12,
                      height: 1.6,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: TextStyle(
          color: AppColors.darkGreen,
          fontWeight: FontWeight.bold,
          fontSize: 15,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController ctrl, {bool isNumber = false, int maxLines = 1, bool isRequired = true}) {
    return TextFormField(
      controller: ctrl,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      ),
      validator: isRequired ? (v) => v!.isEmpty ? 'Wajib diisi' : null : null,
    );
  }
}