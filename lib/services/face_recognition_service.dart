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

  // ✅ UPDATED: Threshold untuk Euclidean Distance (Makin kecil makin ketat)
  // 0.6 - 0.8 adalah range standar. 0.75 cukup aman.
  static const double _threshold = 0.75;

  // === PUBLIC METHODS ===

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

  // Extract Embedding (Tetap sama)
  Future<List<double>?> extractFaceEmbedding(File faceImage) async {
    try {
      if (!_isModelLoaded) await initialize();

      final inputData = await _preprocessImage(faceImage);
      if (inputData == null) {
        print('❌ Failed to preprocess image');
        return null;
      }

      var outputBuffer = List.filled(1 * 192, 0.0).reshape([1, 192]);
      _interpreter!.run(inputData, outputBuffer);

      List<double> embedding = List<double>.from(outputBuffer[0]);
      return _normalizeVector(embedding);

    } catch (e) {
      print('❌ Error extracting embedding: $e');
      return null;
    }
  }

  // ✅ UPDATED: Menggunakan Euclidean Distance
  Future<double> verifyFace({
    required File liveFaceImage,
    required List<double> storedEmbedding,
  }) async {
    try {
      final liveEmbedding = await extractFaceEmbedding(liveFaceImage);
      if (liveEmbedding == null) return 10.0; // Return jarak jauh jika gagal

      // Gunakan Euclidean Distance
      final distance = _euclideanDistance(liveEmbedding, storedEmbedding);
      print('🔍 Euclidean Distance: ${distance.toStringAsFixed(4)}');

      return distance;
    } catch (e) {
      print('❌ Error in face verification: $e');
      return 10.0;
    }
  }

  // ✅ UPDATED: Check Logic (Distance <= Threshold)
  Future<bool> isFaceVerified({
    required File liveFaceImage,
    required List<double> storedEmbedding,
  }) async {
    final distance = await verifyFace(
      liveFaceImage: liveFaceImage,
      storedEmbedding: storedEmbedding,
    );
    // Jika jarak LEBIH KECIL atau SAMA DENGAN threshold, berarti COCOK
    return distance <= _threshold;
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

// ✅ UPDATE V3: TIGHT CROP (FOKUS WAJAH, BUANG BADAN)
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

      final face = faces.first;
      final faceRect = face.boundingBox;

      // --- LOGIC TIGHT CROP (Potong Ketat) ---

      // 1. Gunakan LEBAR wajah sebagai patokan ukuran persegi.
      // Kenapa? Karena tinggi (height) seringkali bablas sampai leher/dada.
      // Lebar (width) biasanya pas dari telinga ke telinga.
      // Kita tambah sedikit padding (20%) biar dagu/jidat gak kepotong ekstrim.
      int size = (faceRect.width * 1.2).toInt();

      // 2. Cari titik tengah wajah (Center Point)
      int centerX = faceRect.left.toInt() + (faceRect.width.toInt() ~/ 2);

      // 3. Geser titik tengah Y sedikit ke ATAS.
      // ML Kit sering mendeteksi kotak wajah agak turun ke bawah.
      // Kita naikkan 10% biar leher/baju makin terbuang.
      int centerY = (faceRect.top.toInt() + (faceRect.height.toInt() ~/ 2)) - (faceRect.height * 0.1).toInt();

      // 4. Hitung koordinat potong (Top-Left X, Y)
      int x = centerX - (size ~/ 2);
      int y = centerY - (size ~/ 2);

      // 5. Handling Boundary (Jangan sampai keluar batas gambar)
      // Kalau keluar batas, kita geser atau potong seadanya, tapi tetap pertahankan Aspect Ratio persegi
      if (x < 0) x = 0;
      if (y < 0) y = 0;
      if (x + size > originalImage.width) size = originalImage.width - x;
      if (y + size > originalImage.height) size = originalImage.height - y;

      // 6. Lakukan Cropping
      final croppedImage = img.copyCrop(
        originalImage,
        x: x,
        y: y,
        width: size,
        height: size,
      );

      // 7. Resize ke 112x112
      final resizedImage = img.copyResize(
        croppedImage,
        width: _inputSize,
        height: _inputSize,
      );

      // --- KONVERSI KE 4D ARRAY (Sama seperti sebelumnya) ---
      var inputBuffer = List.generate(
          1,
              (i) => List.generate(
              _inputSize,
                  (y) => List.generate(
                  _inputSize,
                      (x) {
                    final pixel = resizedImage.getPixel(x, y);
                    // Normalisasi standar
                    return [
                      (pixel.r - 127.5) / 127.5,
                      (pixel.g - 127.5) / 127.5,
                      (pixel.b - 127.5) / 127.5
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

  // ✅ UPDATED: Rumus Euclidean Distance
  double _euclideanDistance(List<double> a, List<double> b) {
    if (a.length != b.length) return 10.0; // Error value

    double sum = 0.0;
    for (int i = 0; i < a.length; i++) {
      final diff = a[i] - b[i];
      sum += diff * diff;
    }

    return sqrt(sum);
  }

  void dispose() {
    _faceDetector.close();
    _interpreter?.close();
  }
}