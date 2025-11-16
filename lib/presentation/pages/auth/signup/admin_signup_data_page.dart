import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:suara_kita/core/constants/faculty_constants.dart';
// IMPORT INI UNTUK MEMPERBAIKI ERROR
import 'package:suara_kita/presentation/pages/auth/signup/admin_signup_password_page.dart';

class AdminSignupDataPage extends StatefulWidget {
  const AdminSignupDataPage({super.key});

  @override
  State<AdminSignupDataPage> createState() => _AdminSignupDataPageState();
}

class _AdminSignupDataPageState extends State<AdminSignupDataPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _nimController = TextEditingController();
  final _phoneController = TextEditingController();
  final _placeOfBirthController = TextEditingController();
  String _selectedGender = 'Laki-laki';
  DateTime? _selectedDate;
  String? _selectedFaculty;
  String? _selectedProgram;

  List<String> _availablePrograms = [];

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

  // --- UPDATE: _nextStep yang sudah diperbaiki ---
  void _nextStep() {
    if (_formKey.currentState!.validate()) {
      // Validasi tambahan
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

      // Navigasi ke step 2 dengan membawa data
      Navigator.pushNamed(
        context,
        '/admin-signup-password',
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

  // --- UPDATE: Tambahkan method untuk field tempat lahir ---
  Widget _buildPlaceOfBirthField() {
    return TextFormField(
      controller: _placeOfBirthController,
      style: GoogleFonts.almarai(color: Colors.white),
      decoration: InputDecoration(
        labelText: 'Tempat Lahir',
        labelStyle: GoogleFonts.almarai(color: Colors.white.withOpacity(0.8)),
        prefixIcon: const Icon(Icons.place_rounded, color: Colors.white),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.white),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.white.withOpacity(0.5)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.white),
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Harap isi tempat lahir';
        }
        return null;
      },
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
        child: SafeArea(
          child: Stack(
            children: [
              Positioned(
                top: 10,
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
                padding: const EdgeInsets.symmetric(horizontal: 32.0),
                child: SingleChildScrollView(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: MediaQuery.of(context).size.height - kToolbarHeight,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const SizedBox(height: 80),
                        Text(
                          'Data Admin',
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
                        const SizedBox(height: 32),
                        Form(
                          key: _formKey,
                          child: Column(
                            children: [
                              _buildTextField('Nama Lengkap', Icons.person_rounded, _nameController),
                              const SizedBox(height: 16),
                              _buildNimField(),
                              const SizedBox(height: 16),
                              _buildGenderSelection(),
                              const SizedBox(height: 16),
                              // UPDATE: Tambahkan field tempat lahir di sini
                              _buildPlaceOfBirthField(),
                              const SizedBox(height: 16),
                              _buildDateField(),
                              const SizedBox(height: 16),
                              _buildTextField('No Handphone', Icons.phone_rounded, _phoneController, TextInputType.phone),
                              const SizedBox(height: 16),
                              _buildFacultyDropdown(),
                              const SizedBox(height: 16),
                              _buildProgramDropdown(),
                            ],
                          ),
                        ),
                        const SizedBox(height: 32),
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
                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- WIDGET BUILDER DENGAN VALIDASI ---
  Widget _buildTextField(String label, IconData icon, TextEditingController controller, [TextInputType keyboardType = TextInputType.text]) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      style: GoogleFonts.almarai(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: GoogleFonts.almarai(color: Colors.white.withOpacity(0.8)),
        prefixIcon: Icon(icon, color: Colors.white),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.white),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.white.withOpacity(0.5)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.white),
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Harap isi $label';
        }
        if (label == 'No Handphone') {
          if (!RegExp(r'^[0-9]+$').hasMatch(value)) {
            return 'No Handphone harus berupa angka';
          }
          if (value.length < 9 || value.length > 15) {
            return 'No Handphone harus 9-15 digit';
          }
        }
        return null;
      },
    );
  }

  Widget _buildNimField() {
    return TextFormField(
      controller: _nimController,
      keyboardType: TextInputType.number,
      style: GoogleFonts.almarai(color: Colors.white),
      decoration: InputDecoration(
        labelText: 'NIM',
        labelStyle: GoogleFonts.almarai(color: Colors.white.withOpacity(0.8)),
        prefixIcon: const Icon(Icons.badge_rounded, color: Colors.white),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.white),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.white.withOpacity(0.5)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.white),
        ),
      ),
      validator: _nimValidator,
    );
  }

  // --- DROPDOWN WIDGETS ---
  Widget _buildFacultyDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Fakultas',
          style: GoogleFonts.almarai(
            color: Colors.white.withOpacity(0.8),
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            border: Border.all(
              color: Colors.white.withOpacity(0.5),
            ),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            child: DropdownButtonFormField<String>(
              isExpanded: true,
              value: _selectedFaculty,
              onChanged: _onFacultyChanged,
              items: FacultyConstants.getFacultyNames().map((String faculty) {
                return DropdownMenuItem<String>(
                  value: faculty,
                  child: Text(
                    faculty,
                    style: GoogleFonts.almarai(
                      color: Colors.black,
                      fontSize: 14,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                );
              }).toList(),
              decoration: const InputDecoration(
                border: InputBorder.none,
                contentPadding: EdgeInsets.zero,
              ),
              style: GoogleFonts.almarai(color: Colors.black),
              dropdownColor: Colors.white,
              icon: const Icon(Icons.arrow_drop_down_rounded, color: Colors.white),
              hint: Text(
                'Pilih Fakultas',
                style: GoogleFonts.almarai(
                  color: Colors.white.withOpacity(0.6),
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Harap pilih fakultas';
                }
                return null;
              },
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
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            border: Border.all(
              color: Colors.white.withOpacity(0.5),
            ),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            child: DropdownButtonFormField<String>(
              isExpanded: true,
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
                      fontSize: 14,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                );
              }).toList(),
              decoration: const InputDecoration(
                border: InputBorder.none,
                contentPadding: EdgeInsets.zero,
              ),
              style: GoogleFonts.almarai(color: Colors.black),
              dropdownColor: Colors.white,
              icon: const Icon(Icons.arrow_drop_down_rounded, color: Colors.white),
              hint: Text(
                _selectedFaculty != null ? 'Pilih Program Studi' : 'Pilih fakultas dahulu',
                style: GoogleFonts.almarai(
                  color: Colors.white.withOpacity(0.6),
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Harap pilih program studi';
                }
                return null;
              },
              disabledHint: Text(
                'Pilih fakultas dahulu',
                style: GoogleFonts.almarai(
                  color: Colors.white.withOpacity(0.4),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // --- WIDGET BUILDER LAINNYA ---
  Widget _buildGenderSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Jenis Kelamin',
          style: GoogleFonts.almarai(
            color: Colors.white.withOpacity(0.8),
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: _buildGenderOption('Laki-laki', Icons.male_rounded),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildGenderOption('Perempuan', Icons.female_rounded),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildGenderOption(String gender, IconData icon) {
    bool isSelected = _selectedGender == gender;
    return GestureDetector(
      onTap: () => setState(() => _selectedGender = gender),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          border: Border.all(
            color: isSelected ? Colors.white : Colors.white.withOpacity(0.5),
            width: 2,
          ),
          borderRadius: BorderRadius.circular(8),
          color: isSelected ? Colors.white.withOpacity(0.2) : Colors.transparent,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: isSelected ? Colors.white : Colors.white.withOpacity(0.7)),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                gender,
                style: GoogleFonts.almarai(
                  color: Colors.white,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
                overflow: TextOverflow.ellipsis,
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
        Text(
          'Tanggal Lahir',
          style: GoogleFonts.almarai(
            color: Colors.white.withOpacity(0.8),
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: _selectDate,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border.all(
                color: Colors.white.withOpacity(0.5),
              ),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                const Icon(Icons.calendar_today_rounded, color: Colors.white),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    _selectedDate != null
                        ? '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}'
                        : 'Pilih Tanggal Lahir',
                    style: GoogleFonts.almarai(
                      color: _selectedDate != null ? Colors.white : Colors.white.withOpacity(0.6),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}