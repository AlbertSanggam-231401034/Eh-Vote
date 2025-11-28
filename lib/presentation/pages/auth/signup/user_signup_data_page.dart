import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:suara_kita/core/constants/faculty_constants.dart';

class UserSignupDataPage extends StatefulWidget {
  const UserSignupDataPage({super.key});

  @override
  State<UserSignupDataPage> createState() => _UserSignupDataPageState();
}

class _UserSignupDataPageState extends State<UserSignupDataPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _nimController = TextEditingController();
  final _phoneController = TextEditingController();
  final _placeOfBirthController = TextEditingController();

  // TAMBAHKAN FOCUS NODE
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
    // HAPUS FOCUS NODE SAAT WIDGET DI-DISPOSE
    _nameFocusNode.dispose();
    _nimFocusNode.dispose();
    _phoneFocusNode.dispose();
    _placeOfBirthFocusNode.dispose();
    super.dispose();
  }

  void _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
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
    if (value == null || value.isEmpty) {
      return 'Harap masukkan NIM';
    }
    if (!RegExp(r'^[0-9]+$').hasMatch(value)) {
      return 'NIM harus berupa angka';
    }
    if (value.length < 8 || value.length > 10) {
      return 'NIM harus 8-10 digit';
    }
    return null;
  }

  void _nextStep() {
    if (_formKey.currentState!.validate()) {
      if (_selectedDate == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Harap pilih tanggal lahir')),
        );
        return;
      }

      if (_selectedFaculty == null || _selectedProgram == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Harap pilih fakultas dan program studi')),
        );
        return;
      }

      Navigator.pushNamed(
        context,
        '/user-signup-password',
        arguments: {
          'fullName': _nameController.text,
          'nim': _nimController.text,
          'gender': _selectedGender,
          'dateOfBirth': _selectedDate!,
          'placeOfBirth': _placeOfBirthController.text,
          'phoneNumber': _phoneController.text,
          'faculty': _selectedFaculty!,
          'major': _selectedProgram!,
        },
      );
    }
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
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Spacer(flex: 1),
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
                    'Step 1 of 4 - Isi data pribadi',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.almarai(
                      fontSize: 14,
                      color: Colors.white.withOpacity(0.8),
                    ),
                  ),
                  const Spacer(flex: 1),
                  Expanded(
                    flex: 4,
                    child: SingleChildScrollView(
                      child: Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            _buildTextField(
                              'Nama Lengkap',
                              Icons.person_rounded,
                              _nameController,
                              _nameFocusNode,
                            ),
                            const SizedBox(height: 12),
                            _buildNimField(),
                            const SizedBox(height: 12),
                            _buildGenderSelection(),
                            const SizedBox(height: 12),
                            _buildPlaceOfBirthField(),
                            const SizedBox(height: 12),
                            _buildDateField(),
                            const SizedBox(height: 12),
                            _buildTextField(
                                'No Handphone',
                                Icons.phone_rounded,
                                _phoneController,
                                _phoneFocusNode,
                                TextInputType.phone
                            ),
                            const SizedBox(height: 12),
                            _buildFacultyDropdown(),
                            const SizedBox(height: 12),
                            _buildProgramDropdown(),
                            const SizedBox(height: 20),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _nextStep,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: kPrimaryGreen,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: Text(
                        'LANJUT',
                        style: GoogleFonts.almarai(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const Spacer(flex: 1),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // UPDATE METHOD: Tambah parameter focusNode
  Widget _buildTextField(
      String label,
      IconData icon,
      TextEditingController controller,
      FocusNode focusNode,
      [TextInputType keyboardType = TextInputType.text]
      ) {
    return TextFormField(
      controller: controller,
      focusNode: focusNode, // TAMBAHKAN FOCUS NODE
      keyboardType: keyboardType,
      style: GoogleFonts.almarai(color: Colors.white, fontSize: 14),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: GoogleFonts.almarai(color: Colors.white.withOpacity(0.8), fontSize: 14),
        prefixIcon: Icon(icon, color: Colors.white, size: 20),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.white),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.white.withOpacity(0.5)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.white),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Harap isi $label';
        }
        return null;
      },
    );
  }

  Widget _buildNimField() {
    return TextFormField(
      controller: _nimController,
      focusNode: _nimFocusNode, // TAMBAHKAN FOCUS NODE
      keyboardType: TextInputType.number,
      style: GoogleFonts.almarai(color: Colors.white, fontSize: 14),
      decoration: InputDecoration(
        labelText: 'NIM',
        labelStyle: GoogleFonts.almarai(color: Colors.white.withOpacity(0.8), fontSize: 14),
        prefixIcon: const Icon(Icons.badge_rounded, color: Colors.white, size: 20),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.white),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.white.withOpacity(0.5)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.white),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      ),
      validator: _nimValidator,
    );
  }

  // TAMBAHKAN METHOD _buildGenderSelection YANG HILANG
  Widget _buildGenderSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Jenis Kelamin',
          style: GoogleFonts.almarai(
            color: Colors.white.withOpacity(0.8),
            fontSize: 13,
          ),
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            Expanded(
              child: _buildGenderOption('Laki-laki', Icons.male_rounded),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildGenderOption('Perempuan', Icons.female_rounded),
            ),
          ],
        ),
      ],
    );
  }

  // TAMBAHKAN METHOD _buildGenderOption
  Widget _buildGenderOption(String gender, IconData icon) {
    bool isSelected = _selectedGender == gender;
    return GestureDetector(
      onTap: () => setState(() => _selectedGender = gender),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          border: Border.all(
            color: isSelected ? Colors.white : Colors.white.withOpacity(0.5),
            width: 1.5,
          ),
          borderRadius: BorderRadius.circular(6),
          color: isSelected ? Colors.white.withOpacity(0.2) : Colors.transparent,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon,
                color: isSelected ? Colors.white : Colors.white.withOpacity(0.7),
                size: 18),
            const SizedBox(width: 6),
            Text(
              gender,
              style: GoogleFonts.almarai(
                color: Colors.white,
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceOfBirthField() {
    return TextFormField(
      controller: _placeOfBirthController,
      focusNode: _placeOfBirthFocusNode, // TAMBAHKAN FOCUS NODE
      style: GoogleFonts.almarai(color: Colors.white, fontSize: 14),
      decoration: InputDecoration(
        labelText: 'Tempat Lahir',
        labelStyle: GoogleFonts.almarai(color: Colors.white.withOpacity(0.8), fontSize: 14),
        prefixIcon: const Icon(Icons.place_rounded, color: Colors.white, size: 20),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.white),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.white.withOpacity(0.5)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.white),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Harap isi tempat lahir';
        }
        return null;
      },
    );
  }

  Widget _buildDateField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Tanggal Lahir',
          style: GoogleFonts.almarai(
            color: Colors.white.withOpacity(0.8),
            fontSize: 13,
          ),
        ),
        const SizedBox(height: 6),
        GestureDetector(
          onTap: _selectDate,
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              border: Border.all(
                color: Colors.white.withOpacity(0.5),
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                const Icon(Icons.calendar_today_rounded, color: Colors.white, size: 18),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    _selectedDate != null
                        ? '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}'
                        : 'Pilih Tanggal Lahir',
                    style: GoogleFonts.almarai(
                      color: _selectedDate != null ? Colors.white : Colors.white.withOpacity(0.6),
                      fontSize: 14,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFacultyDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Fakultas',
          style: GoogleFonts.almarai(
            color: Colors.white.withOpacity(0.8),
            fontSize: 13,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          decoration: BoxDecoration(
            border: Border.all(
              color: Colors.white.withOpacity(0.5),
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: DropdownButtonFormField<String>(
              value: _selectedFaculty,
              onChanged: _onFacultyChanged,
              items: FacultyConstants.getFacultyNames().map((String faculty) {
                return DropdownMenuItem<String>(
                  value: faculty,
                  child: Text(
                    faculty,
                    style: GoogleFonts.almarai(
                      color: Colors.black,
                      fontSize: 13,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                );
              }).toList(),
              decoration: const InputDecoration(
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(horizontal: 6, vertical: 8),
              ),
              style: GoogleFonts.almarai(color: Colors.black, fontSize: 13),
              dropdownColor: Colors.white,
              icon: const Icon(Icons.arrow_drop_down_rounded, color: Colors.white, size: 20),
              hint: Text(
                'Pilih Fakultas',
                style: GoogleFonts.almarai(
                  color: Colors.white.withOpacity(0.6),
                  fontSize: 14,
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Harap pilih fakultas';
                }
                return null;
              },
              isExpanded: true,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProgramDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Program Studi',
          style: GoogleFonts.almarai(
            color: Colors.white.withOpacity(0.8),
            fontSize: 13,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          decoration: BoxDecoration(
            border: Border.all(
              color: Colors.white.withOpacity(0.5),
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: DropdownButtonFormField<String>(
              value: _selectedProgram,
              onChanged: _selectedFaculty != null ? (String? newValue) {
                setState(() {
                  _selectedProgram = newValue;
                });
              } : null,
              items: _availablePrograms.map((String program) {
                return DropdownMenuItem<String>(
                  value: program,
                  child: Text(
                    program,
                    style: GoogleFonts.almarai(
                      color: Colors.black,
                      fontSize: 13,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                );
              }).toList(),
              decoration: const InputDecoration(
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(horizontal: 6, vertical: 8),
              ),
              style: GoogleFonts.almarai(color: Colors.black, fontSize: 13),
              dropdownColor: Colors.white,
              icon: const Icon(Icons.arrow_drop_down_rounded, color: Colors.white, size: 20),
              hint: Text(
                _selectedFaculty != null ? 'Pilih Program Studi' : 'Pilih fakultas terlebih dahulu',
                style: GoogleFonts.almarai(
                  color: Colors.white.withOpacity(0.6),
                  fontSize: 14,
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Harap pilih program studi';
                }
                return null;
              },
              disabledHint: Text(
                'Pilih fakultas terlebih dahulu',
                style: GoogleFonts.almarai(
                  color: Colors.white.withOpacity(0.4),
                  fontSize: 14,
                ),
              ),
              isExpanded: true,
            ),
          ),
        ),
      ],
    );
  }
}