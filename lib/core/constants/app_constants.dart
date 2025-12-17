class AppConstants {
  // App Info
  static const String appName = 'Suara Kita';
  static const String appTagline = 'Partisipasi Pemilihan\nKampus Jadi Lebih Mudah';
  static const String appVersion = '1.0.0';
  static const String appBuildNumber = '1';

  // Fonts (sesuai pubspec.yaml)
  static const String fontUnbounded = 'Unbounded';
  static const String fontAlmarai = 'Almarai';

  // Face Recognition
  static const double faceSimilarityThreshold = 0.6;
  static const int faceEmbeddingDimensions = 192;
  static const int minFaceImageWidth = 112;
  static const int minFaceImageHeight = 112;

  // Voting
  static const int maxVoteAttempts = 3;
  static const Duration votingSessionTimeout = Duration(minutes: 15);

  // Dimensions
  static const double defaultPadding = 20.0;
  static const double cardBorderRadius = 15.0;
  static const double buttonBorderRadius = 30.0;
  static const double inputBorderRadius = 10.0;
  static const double buttonHeight = 55.0;
}