class AdminConstants {
  static const List<Map<String, String>> predefinedAdmins = [
    {
      'adminId': 'ADMIN001',
      'password': 'admin123', // Dalam production, gunakan hash password
      'fullName': 'System Administrator',
      'email': 'admin@suarakita.com',
      'role': 'super_admin',
    },
    {
      'adminId': 'ADMIN002',
      'password': 'admin456',
      'fullName': 'Election Manager',
      'email': 'election@suarakita.com',
      'role': 'election_manager',
    },
    // Tambahkan admin lain sesuai kebutuhan
  ];

  static bool isValidAdmin(String adminId, String password) {
    return predefinedAdmins.any((admin) =>
    admin['adminId'] == adminId && admin['password'] == password
    );
  }

  static Map<String, String>? getAdminData(String adminId) {
    try {
      return predefinedAdmins.firstWhere((admin) => admin['adminId'] == adminId);
    } catch (e) {
      return null;
    }
  }
}