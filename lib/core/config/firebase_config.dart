import 'package:firebase_core/firebase_core.dart';
import '../../firebase_options.dart';

class FirebaseConfig {
  static Future<void> initialize() async {
    try {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      print('✅ Firebase initialized successfully');
    } catch (e) {
      print('❌ Error initializing Firebase: $e');
      rethrow;
    }
  }
}