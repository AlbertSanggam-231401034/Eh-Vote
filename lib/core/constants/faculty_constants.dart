class FacultyConstants {
  static const List<Map<String, dynamic>> faculties = [
    {
      'id': '01',
      'name': 'Fakultas Kedokteran',
      'programs': ['Pendidikan Dokter'],
    },
    {
      'id': '02',
      'name': 'Fakultas Hukum',
      'programs': ['Ilmu Hukum'],
    },
    {
      'id': '03',
      'name': 'Fakultas Pertanian',
      'programs': [
        'Agribisnis',
        'Agroteknologi',
        'Ilmu dan Teknologi Pangan',
        'Manajemen Sumber Daya Perairan',
        'Peternakan',
        'Penyuluhan dan Komunikasi Pertanian',
        'Teknik Pertanian dan Biosistem',
      ],
    },
    {
      'id': '04',
      'name': 'Fakultas Teknik',
      'programs': [
        'Arsitektur',
        'Teknik Elektro',
        'Teknik Industri',
        'Teknik Kimia',
        'Teknik Lingkungan',
        'Teknik Mesin',
        'Teknik Sipil',
      ],
    },
    {
      'id': '05',
      'name': 'Fakultas Kedokteran Gigi',
      'programs': ['Pendidikan Dokter Gigi'],
    },
    {
      'id': '06',
      'name': 'Fakultas Ekonomi dan Bisnis',
      'programs': [
        'Akuntansi',
        'Ekonomi Pembangunan',
        'Ilmu Ekonomi',
        'Manajemen',
      ],
    },
    {
      'id': '07',
      'name': 'Fakultas Ilmu Budaya',
      'programs': [
        'Bahasa Mandarin',
        'Etnomusikologi',
        'Ilmu Sejarah',
        'Perpustakaan dan Sains Informasi',
        'Sastra Arab',
        'Sastra Batak',
        'Sastra Indonesia',
        'Sastra Inggris',
        'Sastra Jepang',
        'Sastra Melayu',
      ],
    },
    {
      'id': '08',
      'name': 'Fakultas Matematika dan IPA (FMIPA)',
      'programs': [
        'Biologi',
        'Fisika',
        'Kimia',
        'Matematika',
        'Statistika',
      ],
    },
    {
      'id': '09',
      'name': 'Fakultas Ilmu Sosial dan Ilmu Politik (FISIP)',
      'programs': [
        'Antropologi Sosial',
        'Ilmu Administrasi Bisnis',
        'Ilmu Administrasi Publik',
        'Ilmu Kesejahteraan Sosial',
        'Ilmu Komunikasi',
        'Ilmu Politik',
        'Sosiologi',
      ],
    },
    {
      'id': '10',
      'name': 'Fakultas Kesehatan Masyarakat (FKM)',
      'programs': [
        'Gizi',
        'Ilmu Kesehatan Masyarakat',
      ],
    },
    {
      'id': '11',
      'name': 'Fakultas Farmasi',
      'programs': ['Farmasi'],
    },
    {
      'id': '12',
      'name': 'Fakultas Psikologi',
      'programs': ['Psikologi'],
    },
    {
      'id': '13',
      'name': 'Fakultas Keperawatan',
      'programs': ['Ilmu Keperawatan'],
    },
    {
      'id': '14',
      'name': 'Fakultas Ilmu Komputer dan Teknologi Informasi (Fasilkom-TI)',
      'programs': [
        'Ilmu Komputer',
        'Teknologi Informasi',
      ],
    },
    {
      'id': '15',
      'name': 'Fakultas Kehutanan',
      'programs': ['Kehutanan'],
    },
    {
      'id': '16',
      'name': 'Fakultas Vokasi',
      'programs': [
        'Administrasi Perkantoran Digital (D4)',
        'Akuntansi Sektor Publik (D4)',
        'Teknologi Rekayasa Instrumentasi (D4)',
        'Administrasi Perpajakan (D3)',
        'Akuntansi (D3)',
        'Analis Farmasi dan Makanan (D3)',
        'Bahasa Inggris (D3)',
        'Bahasa Jepang (D3)',
        'Keuangan (D3)',
        'Kesekretariatan (D3)',
        'Kimia (D3)',
        'Metrologi dan Instrumentasi (D3)',
        'Perjalanan Wisata (D3)',
        'Perpustakaan (D3)',
        'Teknik Informatika (D3)',
      ],
    },
  ];

  // Get faculty by name
  static Map<String, dynamic>? getFacultyByName(String name) {
    try {
      return faculties.firstWhere((faculty) => faculty['name'] == name);
    } catch (e) {
      return null;
    }
  }

  // Get programs by faculty name
  static List<String> getProgramsByFaculty(String facultyName) {
    final faculty = getFacultyByName(facultyName);
    return faculty?['programs'] ?? [];
  }

  // Get all faculty names for dropdown
  static List<String> getFacultyNames() {
    return faculties.map((faculty) => faculty['name'] as String).toList();
  }
}