import 'dart:convert'; // Tambahkan import ini
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
  static const int _inputSize = 112; // MobileFaceNet input size: 112x112
  static const double _threshold = 0.6; // Similarity threshold

  // === PUBLIC METHODS ===

  // Initialize TFLite model
  Future<void> initialize() async {
    try {
      print('🔄 Loading TensorFlow Lite model...');

      // Load model
      _interpreter = await Interpreter.fromAsset(_modelPath);

      // Get model info (for debugging)
      final inputShape = _interpreter!.getInputTensor(0).shape;
      final outputShape = _interpreter!.getOutputTensor(0).shape;

      print('✅ Model loaded successfully!');
      print('📊 Input shape: $inputShape');
      print('📊 Output shape: $outputShape');

      _isModelLoaded = true;
    } catch (e) {
      print('❌ Failed to load model: $e');
      rethrow;
    }
  }

  // Check if model is loaded
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

        // Verify face presence and quality
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

        // Verify face presence and quality
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
      if (!_isModelLoaded) {
        await initialize();
      }

      // Preprocess image
      final inputData = await _preprocessImage(faceImage);
      if (inputData == null) {
        print('❌ Failed to preprocess image');
        return null;
      }

      // Run inference
      final output = Float32List(192); // MobileFaceNet output: 192 dimensions
      _interpreter!.run(inputData, output);

      // Convert to List<double> and normalize
      final embedding = output.map((e) => e.toDouble()).toList();
      final normalizedEmbedding = _normalizeVector(embedding);

      print('📊 Embedding extracted: ${normalizedEmbedding.length} dimensions');
      return normalizedEmbedding;
    } catch (e) {
      print('❌ Error extracting embedding: $e');
      return null;
    }
  }

  // Extract embedding without validation (for testing)
  Future<List<double>?> extractEmbeddingDirect(File imageFile) async {
    try {
      if (!_isModelLoaded) {
        await initialize();
      }

      final inputData = await _preprocessImageSimple(imageFile);
      if (inputData == null) return null;

      final output = Float32List(192);
      _interpreter!.run(inputData, output);

      final embedding = output.map((e) => e.toDouble()).toList();
      return _normalizeVector(embedding);
    } catch (e) {
      print('❌ Direct extraction error: $e');
      return null;
    }
  }

  // Compare two embeddings (for verification)
  Future<double> verifyFace({
    required File liveFaceImage,
    required List<double> storedEmbedding,
  }) async {
    try {
      // Extract embedding from live image
      final liveEmbedding = await extractFaceEmbedding(liveFaceImage);
      if (liveEmbedding == null) {
        return 0.0;
      }

      // Calculate similarity score
      final similarity = _cosineSimilarity(liveEmbedding, storedEmbedding);
      print('🔍 Face similarity score: ${similarity.toStringAsFixed(4)}');

      return similarity;
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

  // Convert embedding to Base64 string for storage/transmission
  String embeddingToBase64(List<double> embedding) {
    try {
      // Convert to Float32List first (more compact than Float64List)
      final float32List = Float32List.fromList(embedding);
      final bytes = float32List.buffer.asUint8List();
      return base64Encode(bytes);
    } catch (e) {
      print('❌ Error converting embedding to Base64: $e');
      return '';
    }
  }

  // Convert Base64 string back to embedding
  List<double>? base64ToEmbedding(String base64String) {
    try {
      if (base64String.isEmpty) return null;

      final bytes = base64Decode(base64String);
      final float32List = Float32List.view(bytes.buffer);
      return float32List.toList();
    } catch (e) {
      print('❌ Error converting Base64 to embedding: $e');
      return null;
    }
  }

  // Convert embedding to JSON string
  String embeddingToJson(List<double> embedding) {
    return jsonEncode(embedding);
  }

  // Convert JSON string back to embedding
  List<double>? jsonToEmbedding(String jsonString) {
    try {
      final decoded = jsonDecode(jsonString);

      if (decoded is List) {
        // Konversi dari List<dynamic> ke List<double>
        return decoded.map((e) {
          if (e is int) return e.toDouble();
          if (e is double) return e;
          return 0.0;
        }).toList();
      }

      return null;
    } catch (e) {
      print('❌ Error converting JSON to embedding: $e');
      return null;
    }
  }

  // === PRIVATE METHODS ===

  // Validate face image quality
  Future<bool> _validateFaceImage(File imageFile) async {
    try {
      final inputImage = InputImage.fromFile(imageFile);
      final faces = await _faceDetector.processImage(inputImage);

      // Check if exactly one face is detected
      if (faces.isEmpty) {
        print('⚠️  No face detected');
        return false;
      }

      if (faces.length > 1) {
        print('⚠️  Multiple faces detected (${faces.length})');
        return false;
      }

      final face = faces.first;

      // Check face size (minimum 20% of image dimensions)
      final imageBytes = await imageFile.readAsBytes();
      final decodedImage = img.decodeImage(imageBytes);
      if (decodedImage != null) {
        final imageWidth = decodedImage.width;
        final imageHeight = decodedImage.height;
        final faceWidth = face.boundingBox.width;
        final faceHeight = face.boundingBox.height;

        final minFaceWidth = imageWidth * 0.2;
        final minFaceHeight = imageHeight * 0.2;

        if (faceWidth < minFaceWidth || faceHeight < minFaceHeight) {
          print('⚠️  Face too small in image');
          return false;
        }
      }

      // Check face alignment
      final yaw = face.headEulerAngleY ?? 0;
      final pitch = face.headEulerAngleX ?? 0;
      final roll = face.headEulerAngleZ ?? 0;

      // Allowable angles: ±25 degrees for yaw, ±15 for pitch, ±10 for roll
      if (yaw.abs() > 25) {
        print('⚠️  Face yaw angle too large: ${yaw.toStringAsFixed(1)}°');
        return false;
      }

      if (pitch.abs() > 15) {
        print('⚠️  Face pitch angle too large: ${pitch.toStringAsFixed(1)}°');
        return false;
      }

      if (roll.abs() > 10) {
        print('⚠️  Face roll angle too large: ${roll.toStringAsFixed(1)}°');
        return false;
      }

      // Check if eyes are open
      final leftEyeOpen = face.leftEyeOpenProbability ?? 0;
      final rightEyeOpen = face.rightEyeOpenProbability ?? 0;

      if (leftEyeOpen < 0.4 || rightEyeOpen < 0.4) {
        print('⚠️  Eyes not fully open (L: ${leftEyeOpen.toStringAsFixed(2)}, R: ${rightEyeOpen.toStringAsFixed(2)})');
        return false;
      }

      // Check smile probability (optional, for better quality)
      final smileProb = face.smilingProbability ?? 0;
      if (smileProb > 0.8) {
        print('ℹ️  Subject is smiling (probability: ${smileProb.toStringAsFixed(2)})');
      }

      return true;
    } catch (e) {
      print('❌ Error validating face: $e');
      return false;
    }
  }

  // Preprocess image for MobileFaceNet
  Future<Float32List?> _preprocessImage(File imageFile) async {
    try {
      // Read image bytes
      final imageBytes = await imageFile.readAsBytes();

      // Decode image
      final originalImage = img.decodeImage(imageBytes);
      if (originalImage == null) {
        print('❌ Failed to decode image');
        return null;
      }

      // Detect face for cropping
      final inputImage = InputImage.fromFile(imageFile);
      final faces = await _faceDetector.processImage(inputImage);

      if (faces.isEmpty) {
        print('❌ No face detected for preprocessing');
        return null;
      }

      // Get first face bounding box
      final faceRect = faces.first.boundingBox;

      // Ensure bounding box is within image bounds
      final x = faceRect.left.clamp(0, originalImage.width - 1).toInt();
      final y = faceRect.top.clamp(0, originalImage.height - 1).toInt();
      final width = faceRect.width.clamp(1, originalImage.width - x).toInt();
      final height = faceRect.height.clamp(1, originalImage.height - y).toInt();

      // Crop face with boundary checks
      final croppedImage = img.copyCrop(
        originalImage,
        x: x,
        y: y,
        width: width,
        height: height,
      );

      // Resize to 112x112
      final resizedImage = img.copyResize(
        croppedImage,
        width: _inputSize,
        height: _inputSize,
        interpolation: img.Interpolation.cubic,
      );

      // Convert to Float32List and normalize
      final inputData = Float32List(_inputSize * _inputSize * 3);
      int index = 0;

      for (int y = 0; y < _inputSize; y++) {
        for (int x = 0; x < _inputSize; x++) {
          final pixel = resizedImage.getPixel(x, y);

          // Extract RGB components using img library methods
          final r = pixel.r.toDouble();
          final g = pixel.g.toDouble();
          final b = pixel.b.toDouble();

          // MobileFaceNet expects normalized pixels [-1, 1]
          inputData[index++] = (r - 127.5) / 127.5;   // R
          inputData[index++] = (g - 127.5) / 127.5; // G
          inputData[index++] = (b - 127.5) / 127.5;  // B
        }
      }

      return inputData;
    } catch (e) {
      print('❌ Error preprocessing image: $e');
      return null;
    }
  }

  // Alternative preprocessing method without face detection
  Future<Float32List?> _preprocessImageSimple(File imageFile) async {
    try {
      // Read image bytes
      final imageBytes = await imageFile.readAsBytes();

      // Decode image
      final originalImage = img.decodeImage(imageBytes);
      if (originalImage == null) {
        return null;
      }

      // Resize to 112x112
      final resizedImage = img.copyResize(
        originalImage,
        width: _inputSize,
        height: _inputSize,
      );

      // Convert to Float32List and normalize
      final inputData = Float32List(_inputSize * _inputSize * 3);
      int index = 0;

      for (int y = 0; y < _inputSize; y++) {
        for (int x = 0; x < _inputSize; x++) {
          final pixel = resizedImage.getPixel(x, y);

          // Extract RGB components
          final r = pixel.r.toDouble();
          final g = pixel.g.toDouble();
          final b = pixel.b.toDouble();

          // Normalize to [-1, 1]
          inputData[index++] = (r - 127.5) / 127.5;
          inputData[index++] = (g - 127.5) / 127.5;
          inputData[index++] = (b - 127.5) / 127.5;
        }
      }

      return inputData;
    } catch (e) {
      print('❌ Error in simple preprocessing: $e');
      return null;
    }
  }

  // Normalize vector (L2 normalization)
  List<double> _normalizeVector(List<double> vector) {
    double sum = 0.0;
    for (final value in vector) {
      sum += value * value;
    }

    // Menggunakan sqrt dari dart:math
    final norm = sqrt(sum);
    if (norm == 0) return vector;

    return vector.map((value) => value / norm).toList();
  }

  // Calculate cosine similarity
  double _cosineSimilarity(List<double> a, List<double> b) {
    if (a.length != b.length) {
      throw Exception('Vectors must have same length (${a.length} vs ${b.length})');
    }

    double dotProduct = 0.0;
    double normA = 0.0;
    double normB = 0.0;

    for (int i = 0; i < a.length; i++) {
      dotProduct += a[i] * b[i];
      normA += a[i] * a[i];
      normB += b[i] * b[i];
    }

    // Menggunakan sqrt dari dart:math
    normA = sqrt(normA);
    normB = sqrt(normB);

    if (normA == 0 || normB == 0) {
      return 0.0;
    }

    return dotProduct / (normA * normB);
  }

  // Calculate Euclidean distance (alternative metric)
  double _euclideanDistance(List<double> a, List<double> b) {
    if (a.length != b.length) {
      throw Exception('Vectors must have same length');
    }

    double sum = 0.0;
    for (int i = 0; i < a.length; i++) {
      final diff = a[i] - b[i];
      sum += diff * diff;
    }

    return sqrt(sum);
  }

  // Get similarity as percentage (0-100%)
  String getSimilarityPercentage(double similarity) {
    final percentage = (similarity * 100).clamp(0, 100);
    return '${percentage.toStringAsFixed(1)}%';
  }

  // Check if similarity meets threshold
  bool isSimilarityAboveThreshold(double similarity) {
    return similarity >= _threshold;
  }

  // Clean up resources
  void dispose() {
    _faceDetector.close();
    _interpreter?.close();
  }
}