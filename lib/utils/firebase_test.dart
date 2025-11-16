import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import '../firebase_options.dart';

class FirebaseTest {
  static Future<void> testConnection() async {
    try {
      // Test Firestore connection
      final firestore = FirebaseFirestore.instance;
      await firestore.collection('test').doc('connection').set({
        'timestamp': FieldValue.serverTimestamp(),
        'status': 'connected',
      });

      print('✅ Firebase Firestore connection successful');

      // Clean up test document
      await firestore.collection('test').doc('connection').delete();

    } catch (e) {
      print('❌ Firebase connection test failed: $e');
      rethrow;
    }
  }
}