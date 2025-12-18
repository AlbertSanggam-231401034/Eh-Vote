import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image/image.dart' as img;
import 'package:tflite_flutter/tflite_flutter.dart';

class FaceRecognitionService {
  // === SINGLETON PATTERN ===
  static final FaceRecognitionService _instance = FaceRecognitionService._internal();
  factory FaceRecognitionService() => _instance;
  FaceRecognitionService._internal();

  // === VARIABLES ===
  final ImagePicker _imagePicker = ImagePicker();
  final FaceDetector _faceDetector = FaceDetector(
    options: FaceDetectorOptions(
      enableContours: true,
      enableLandmarks: true,
      enableClassification: true,
      performanceMode: FaceDetectorMode.accurate,
    ),
  );

  Interpreter? _interpreter;
  bool _isModelLoaded = false;

  // === CONSTANTS ===
  static const String _modelPath = 'assets/models/mobilefacenet.tflite';
  static const int _inputSize = 112;
  static const double _threshold = 0.6;

  // === PUBLIC METHODS ===

  // Initialize TFLite model
  Future<void> initialize() async {
    try {
      print('🔄 Loading TensorFlow Lite model...');
      _interpreter = await Interpreter.fromAsset(_modelPath);
      print('✅ Model loaded successfully!');
      _isModelLoaded = true;
    } catch (e) {
      print('❌ Failed to load model: $e');
      rethrow;
    }
  }

  bool isModelLoaded() => _isModelLoaded;

  // Capture face from camera
  Future<File?> captureFaceImage() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.camera,
        preferredCameraDevice: CameraDevice.front,
        maxWidth: 720,
        maxHeight: 1280,
        imageQuality: 90,
      );

      if (image != null) {
        final file = File(image.path);
        final isFaceValid = await _validateFaceImage(file);
        return isFaceValid ? file : null;
      }
      return null;
    } catch (e) {
      print('❌ Error capturing face: $e');
      return null;
    }
  }

  // Pick face from gallery
  Future<File?> pickFaceImage() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 720,
        maxHeight: 1280,
        imageQuality: 90,
      );

      if (image != null) {
        final file = File(image.path);
        final isFaceValid = await _validateFaceImage(file);
        return isFaceValid ? file : null;
      }
      return null;
    } catch (e) {
      print('❌ Error picking face: $e');
      return null;
    }
  }

  // Extract face embedding (feature vector)
  Future<List<double>?> extractFaceEmbedding(File faceImage) async {
    try {
      if (!_isModelLoaded) await initialize();

      // Preprocess image -> Return List 4D [1, 112, 112, 3]
      final inputData = await _preprocessImage(faceImage);
      if (inputData == null) {
        print('❌ Failed to preprocess image');
        return null;
      }

      // Output buffer: [1, 192]
      var outputBuffer = List.filled(1 * 192, 0.0).reshape([1, 192]);

      // Run inference
      _interpreter!.run(inputData, outputBuffer);

      // Flatten output
      List<double> embedding = List<double>.from(outputBuffer[0]);
      return _normalizeVector(embedding);

    } catch (e) {
      print('❌ Error extracting embedding: $e');
      return null;
    }
  }

  // Extract embedding without validation (for testing)
  Future<List<double>?> extractEmbeddingDirect(File imageFile) async {
    try {
      if (!_isModelLoaded) await initialize();

      // Gunakan _preprocessImage yang sama (sudah diperbaiki)
      final inputData = await _preprocessImage(imageFile);
      if (inputData == null) return null;

      var outputBuffer = List.filled(1 * 192, 0.0).reshape([1, 192]);
      _interpreter!.run(inputData, outputBuffer);

      List<double> embedding = List<double>.from(outputBuffer[0]);
      return _normalizeVector(embedding);
    } catch (e) {
      print('❌ Direct extraction error: $e');
      return null;
    }
  }

  // Verify Face
  Future<double> verifyFace({
    required File liveFaceImage,
    required List<double> storedEmbedding,
  }) async {
    try {
      final liveEmbedding = await extractFaceEmbedding(liveFaceImage);
      if (liveEmbedding == null) return 0.0;
      return _cosineSimilarity(liveEmbedding, storedEmbedding);
    } catch (e) {
      print('❌ Error in face verification: $e');
      return 0.0;
    }
  }

  // Check if face is verified based on threshold
  Future<bool> isFaceVerified({
    required File liveFaceImage,
    required List<double> storedEmbedding,
  }) async {
    final similarity = await verifyFace(
      liveFaceImage: liveFaceImage,
      storedEmbedding: storedEmbedding,
    );
    return similarity >= _threshold;
  }

  // Helper Conversion Methods
  String embeddingToBase64(List<double> embedding) {
    try {
      final float32List = Float32List.fromList(embedding);
      final bytes = float32List.buffer.asUint8List();
      return base64Encode(bytes);
    } catch (e) {
      return '';
    }
  }

  List<double>? base64ToEmbedding(String base64String) {
    try {
      if (base64String.isEmpty) return null;
      final bytes = base64Decode(base64String);
      final float32List = Float32List.view(bytes.buffer);
      return float32List.toList();
    } catch (e) {
      return null;
    }
  }

  String embeddingToJson(List<double> embedding) => jsonEncode(embedding);

  List<double>? jsonToEmbedding(String jsonString) {
    try {
      final decoded = jsonDecode(jsonString);
      if (decoded is List) {
        return decoded.map((e) {
          if (e is int) return e.toDouble();
          if (e is double) return e;
          return 0.0;
        }).toList();
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  // === PRIVATE METHODS ===

  Future<bool> _validateFaceImage(File imageFile) async {
    try {
      final inputImage = InputImage.fromFile(imageFile);
      final faces = await _faceDetector.processImage(inputImage);

      if (faces.isEmpty) {
        print('⚠️  No face detected');
        return false;
      }
      if (faces.length > 1) {
        print('⚠️  Multiple faces detected (${faces.length})');
        return false;
      }

      final face = faces.first;
      final imageBytes = await imageFile.readAsBytes();
      final decodedImage = img.decodeImage(imageBytes);

      if (decodedImage != null) {
        final minFaceWidth = decodedImage.width * 0.2;
        final minFaceHeight = decodedImage.height * 0.2;
        if (face.boundingBox.width < minFaceWidth || face.boundingBox.height < minFaceHeight) {
          print('⚠️  Face too small');
          return false;
        }
      }

      final yaw = face.headEulerAngleY ?? 0;
      final pitch = face.headEulerAngleX ?? 0;

      if (yaw.abs() > 25 || pitch.abs() > 15) {
        print('⚠️  Face angle too large');
        return false;
      }

      final leftEyeOpen = face.leftEyeOpenProbability ?? 0;
      final rightEyeOpen = face.rightEyeOpenProbability ?? 0;
      if (leftEyeOpen < 0.4 || rightEyeOpen < 0.4) {
        print('⚠️  Eyes not fully open');
        return false;
      }

      return true;
    } catch (e) {
      print('❌ Error validating face: $e');
      return false;
    }
  }

  // ✅ PREPROCESS IMAGE FIX (4D ARRAY)
  Future<List<dynamic>?> _preprocessImage(File imageFile) async {
    try {
      final imageBytes = await imageFile.readAsBytes();
      final originalImage = img.decodeImage(imageBytes);
      if (originalImage == null) return null;

      final inputImage = InputImage.fromFile(imageFile);
      final faces = await _faceDetector.processImage(inputImage);

      if (faces.isEmpty) {
        print('❌ No face detected for preprocessing');
        return null;
      }

      final faceRect = faces.first.boundingBox;

      final x = faceRect.left.clamp(0, originalImage.width - 1).toInt();
      final y = faceRect.top.clamp(0, originalImage.height - 1).toInt();
      final width = faceRect.width.clamp(1, originalImage.width - x).toInt();
      final height = faceRect.height.clamp(1, originalImage.height - y).toInt();

      final croppedImage = img.copyCrop(
        originalImage,
        x: x,
        y: y,
        width: width,
        height: height,
      );

      final resizedImage = img.copyResize(
        croppedImage,
        width: _inputSize,
        height: _inputSize,
      );

      // Create 4D array [1, 112, 112, 3]
      var inputBuffer = List.generate(
          1,
              (i) => List.generate(
              _inputSize,
                  (y) => List.generate(
                  _inputSize,
                      (x) {
                    final pixel = resizedImage.getPixel(x, y);
                    // Normalize (value - 128) / 128
                    return [
                      (pixel.r - 128) / 128,
                      (pixel.g - 128) / 128,
                      (pixel.b - 128) / 128
                    ];
                  }
              )
          )
      );

      return inputBuffer;
    } catch (e) {
      print('❌ Error preprocessing image: $e');
      return null;
    }
  }

  List<double> _normalizeVector(List<double> vector) {
    double sum = 0.0;
    for (final value in vector) sum += value * value;
    final norm = sqrt(sum);
    if (norm == 0) return vector;
    return vector.map((value) => value / norm).toList();
  }

  double _cosineSimilarity(List<double> a, List<double> b) {
    if (a.length != b.length) return 0.0;
    double dotProduct = 0.0;
    double normA = 0.0;
    double normB = 0.0;
    for (int i = 0; i < a.length; i++) {
      dotProduct += a[i] * b[i];
      normA += a[i] * a[i];
      normB += b[i] * b[i];
    }
    normA = sqrt(normA);
    normB = sqrt(normB);
    if (normA == 0 || normB == 0) return 0.0;
    return dotProduct / (normA * normB);
  }

  void dispose() {
    _faceDetector.close();
    _interpreter?.close();
  }
}