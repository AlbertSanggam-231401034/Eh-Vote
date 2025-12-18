import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:suara_kita/core/constants/faculty_constants.dart';
import 'package:suara_kita/presentation/providers/signup_provider.dart';

class UserSignupDataPage extends StatefulWidget {
  const UserSignupDataPage({super.key});

  @override
  State<UserSignupDataPage> createState() => _UserSignupDataPageState();
}

class _UserSignupDataPageState extends State<UserSignupDataPage> {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  final _nameController = TextEditingController();
  final _nimController = TextEditingController();
  final _phoneController = TextEditingController();
  final _placeOfBirthController = TextEditingController();

  // Focus Nodes
  final _nameFocusNode = FocusNode();
  final _nimFocusNode = FocusNode();
  final _phoneFocusNode = FocusNode();
  final _placeOfBirthFocusNode = FocusNode();

  String _selectedGender = 'Laki-laki';
  DateTime? _selectedDate;
  String? _selectedFaculty;
  String? _selectedProgram;
  List<String> _availablePrograms = [];

  @override
  void dispose() {
    _nameController.dispose();
    _nimController.dispose();
    _phoneController.dispose();
    _placeOfBirthController.dispose();
    _nameFocusNode.dispose();
    _nimFocusNode.dispose();
    _phoneFocusNode.dispose();
    _placeOfBirthFocusNode.dispose();
    super.dispose();
  }

  void _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime(2000),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF00C64F),
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDate) {
      setState(() => _selectedDate = picked);
    }
  }

  void _onFacultyChanged(String? newValue) {
    setState(() {
      _selectedFaculty = newValue;
      _selectedProgram = null;
      _availablePrograms = newValue != null
          ? FacultyConstants.getProgramsByFaculty(newValue)
          : [];
    });
  }

  String? _nimValidator(String? value) {
    if (value == null || value.isEmpty) return 'Harap masukkan NIM';
    if (!RegExp(r'^[0-9]+$').hasMatch(value)) return 'NIM harus berupa angka';
    if (value.length < 8 || value.length > 10) return 'NIM harus 8-10 digit';
    return null;
  }

  void _nextStep() {
    if (_formKey.currentState!.validate()) {
      if (_selectedDate == null) {
        _showError('Harap pilih tanggal lahir');
        return;
      }
      if (_selectedFaculty == null || _selectedProgram == null) {
        _showError('Harap pilih fakultas dan program studi');
        return;
      }

      // --- PERBAIKAN: SIMPAN KE PROVIDER AGAR DATA TIDAK HILANG ---
      context.read<SignupProvider>().setPersonalData(
        nim: _nimController.text.trim(),
        fullName: _nameController.text.trim(),
        placeOfBirth: _placeOfBirthController.text.trim(),
        dateOfBirth: _selectedDate!,
        phoneNumber: _phoneController.text.trim(),
        faculty: _selectedFaculty!,
        major: _selectedProgram!,
        gender: _selectedGender,
      );

      Navigator.pushNamed(
        context,
        '/user-signup-password',
        arguments: {
          'fullName': _nameController.text,
          'nim': _nimController.text,
        },
      );
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.redAccent),
    );
  }

  @override
  Widget build(BuildContext context) {
    const Color kPrimaryGreen = Color(0xFF00C64F);
    const Color kDarkGreen = Color(0xFF002D12);

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [kPrimaryGreen, kDarkGreen],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Stack(
          children: [
            // AppBar & Progress
            Positioned(
              top: 50,
              left: 20,
              right: 20,
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                  ),
                  Expanded(
                    child: LinearProgressIndicator(
                      value: 0.25,
                      backgroundColor: Colors.white.withOpacity(0.3),
                      valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  ),
                  const SizedBox(width: 48),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                children: [
                  const SizedBox(height: 120),
                  Text(
                    'Data Diri',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.unbounded(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Langkah 1 dari 4 - Isi data pribadi Anda',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.almarai(
                      fontSize: 14,
                      color: Colors.white.withOpacity(0.8),
                    ),
                  ),
                  const SizedBox(height: 32),

                  Expanded(
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            _buildTextField('Nama Lengkap', Icons.person_rounded, _nameController, _nameFocusNode),
                            const SizedBox(height: 16),
                            _buildNimField(),
                            const SizedBox(height: 16),
                            _buildGenderSelection(),
                            const SizedBox(height: 16),
                            _buildPlaceOfBirthField(),
                            const SizedBox(height: 16),
                            _buildDateField(),
                            const SizedBox(height: 16),
                            _buildTextField('No Handphone', Icons.phone_rounded, _phoneController, _phoneFocusNode, TextInputType.phone),
                            const SizedBox(height: 16),
                            _buildFacultyDropdown(),
                            const SizedBox(height: 16),
                            _buildProgramDropdown(),
                            const SizedBox(height: 32),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // Bottom Button
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 24),
                    child: SizedBox(
                      width: double.infinity,
                      height: 55,
                      child: ElevatedButton(
                        onPressed: _nextStep,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: kPrimaryGreen,
                          elevation: 0,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: Text(
                          'LANJUTKAN',
                          style: GoogleFonts.unbounded(fontSize: 14, fontWeight: FontWeight.bold),
                        ),
                      ),
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

  Widget _buildTextField(String label, IconData icon, TextEditingController controller, FocusNode focusNode, [TextInputType keyboardType = TextInputType.text]) {
    return TextFormField(
      controller: controller,
      focusNode: focusNode,
      keyboardType: keyboardType,
      style: GoogleFonts.almarai(color: Colors.white, fontSize: 14),
      decoration: _inputDecoration(label, icon),
      validator: (value) => (value == null || value.isEmpty) ? 'Harap isi $label' : null,
    );
  }

  Widget _buildNimField() {
    return TextFormField(
      controller: _nimController,
      focusNode: _nimFocusNode,
      keyboardType: TextInputType.number,
      style: GoogleFonts.almarai(color: Colors.white, fontSize: 14),
      decoration: _inputDecoration('NIM', Icons.badge_rounded),
      validator: _nimValidator,
    );
  }

  Widget _buildPlaceOfBirthField() {
    return TextFormField(
      controller: _placeOfBirthController,
      focusNode: _placeOfBirthFocusNode,
      style: GoogleFonts.almarai(color: Colors.white, fontSize: 14),
      decoration: _inputDecoration('Tempat Lahir', Icons.place_rounded),
      validator: (value) => (value == null || value.isEmpty) ? 'Harap isi tempat lahir' : null,
    );
  }

  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      labelStyle: GoogleFonts.almarai(color: Colors.white.withOpacity(0.7), fontSize: 14),
      prefixIcon: Icon(icon, color: Colors.white, size: 20),
      filled: true,
      fillColor: Colors.white.withOpacity(0.1),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.white.withOpacity(0.2))),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Colors.white, width: 1.5)),
      errorStyle: const TextStyle(color: Colors.yellowAccent),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
    );
  }

  Widget _buildGenderSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Jenis Kelamin', style: GoogleFonts.almarai(color: Colors.white.withOpacity(0.8), fontSize: 13)),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(child: _buildGenderOption('Laki-laki', Icons.male_rounded)),
            const SizedBox(width: 12),
            Expanded(child: _buildGenderOption('Perempuan', Icons.female_rounded)),
          ],
        ),
      ],
    );
  }

  Widget _buildGenderOption(String gender, IconData icon) {
    bool isSelected = _selectedGender == gender;
    return InkWell(
      onTap: () => setState(() => _selectedGender = gender),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: isSelected ? Colors.white : Colors.white.withOpacity(0.2)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: isSelected ? const Color(0xFF002D12) : Colors.white, size: 18),
            const SizedBox(width: 8),
            Text(
              gender,
              style: GoogleFonts.almarai(
                color: isSelected ? const Color(0xFF002D12) : Colors.white,
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDateField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Tanggal Lahir', style: GoogleFonts.almarai(color: Colors.white.withOpacity(0.8), fontSize: 13)),
        const SizedBox(height: 8),
        InkWell(
          onTap: _selectDate,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white.withOpacity(0.2)),
            ),
            child: Row(
              children: [
                const Icon(Icons.calendar_today_rounded, color: Colors.white, size: 18),
                const SizedBox(width: 12),
                Text(
                  _selectedDate != null
                      ? '${_selectedDate!.day.toString().padLeft(2, '0')}/${_selectedDate!.month.toString().padLeft(2, '0')}/${_selectedDate!.year}'
                      : 'Pilih Tanggal Lahir',
                  style: GoogleFonts.almarai(color: Colors.white, fontSize: 14),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFacultyDropdown() {
    return _buildDropdownContainer(
      label: 'Fakultas',
      child: DropdownButtonFormField<String>(
        value: _selectedFaculty,
        dropdownColor: const Color(0xFF002D12),
        onChanged: _onFacultyChanged,
        items: FacultyConstants.getFacultyNames().map((f) => DropdownMenuItem(value: f, child: Text(f))).toList(),
        style: GoogleFonts.almarai(color: Colors.white, fontSize: 13),
        decoration: const InputDecoration(border: InputBorder.none),
        hint: Text('Pilih Fakultas', style: TextStyle(color: Colors.white.withOpacity(0.5))),
        validator: (v) => v == null ? 'Pilih fakultas' : null,
      ),
    );
  }

  Widget _buildProgramDropdown() {
    return _buildDropdownContainer(
      label: 'Program Studi',
      child: DropdownButtonFormField<String>(
        value: _selectedProgram,
        dropdownColor: const Color(0xFF002D12),
        onChanged: (v) => setState(() => _selectedProgram = v),
        items: _availablePrograms.map((p) => DropdownMenuItem(value: p, child: Text(p))).toList(),
        style: GoogleFonts.almarai(color: Colors.white, fontSize: 13),
        decoration: const InputDecoration(border: InputBorder.none),
        hint: Text(_selectedFaculty != null ? 'Pilih Program Studi' : 'Pilih fakultas dahulu',
            style: TextStyle(color: Colors.white.withOpacity(0.5))),
        validator: (v) => v == null ? 'Pilih program studi' : null,
      ),
    );
  }

  Widget _buildDropdownContainer({required String label, required Widget child}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: GoogleFonts.almarai(color: Colors.white.withOpacity(0.8), fontSize: 13)),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white.withOpacity(0.2)),
          ),
          child: child,
        ),
      ],
    );
  }
}