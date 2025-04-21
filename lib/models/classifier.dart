import 'dart:io';
import 'package:image/image.dart' as img;
import 'package:tflite_flutter/tflite_flutter.dart';

class ImageClassifier {
  static const String _modelPath = 'assets/models/good_morning_model.tflite';
  static const int _inputSize = 224; // Standard input size for many models

  Interpreter? _interpreter;

  Future<void> loadModel() async {
    try {
      final interpreterOptions = InterpreterOptions();

      // Use asset from the APK
      _interpreter = await Interpreter.fromAsset(
        _modelPath,
        options: interpreterOptions,
      );

      print('Model loaded successfully');
    } catch (e) {
      print('Error loading model: $e');
    }
  }

  void dispose() {
    _interpreter?.close();
  }

  Future<bool> classifyImage(String imagePath) async {
    if (_interpreter == null) {
      print('Interpreter not initialized');
      return false;
    }

    // Read and preprocess the image
    final imageData = await _preprocessImage(imagePath);
    if (imageData == null) return false;

    // Output tensor shape: [1, 2] for binary classification
    // (good morning or not good morning)
    final outputBuffer = List<List<double>>.filled(
      1,
      List<double>.filled(2, 0.0),
    );

    // Run inference
    _interpreter!.run(imageData, outputBuffer);

    // Get results
    final results = outputBuffer[0];

    // Index 1 probability represents "Good Morning" class
    // Using a threshold to determine if it's a good morning image
    // Assume index 1 is "Good Morning" class probability
    return results[1] > 0.7; // 70% threshold
  }

  Future<List<List<List<List<double>>>>?> _preprocessImage(
      String imagePath) async {
    try {
      final imageFile = File(imagePath);
      if (!await imageFile.exists()) {
        print('Image file does not exist: $imagePath');
        return null;
      }

      // Read image data
      final imageBytes = await imageFile.readAsBytes();
      final image = img.decodeImage(imageBytes);

      if (image == null) {
        print('Could not decode image: $imagePath');
        return null;
      }

      // Resize the image to match model input size
      final resizedImage = img.copyResize(
        image,
        width: _inputSize,
        height: _inputSize,
      );

      // Convert to float tensor
      // Shape: [1, 224, 224, 3]
      final tensor = List<List<List<List<double>>>>.from(
        List.generate(
          1,
          (_) => List.generate(
            _inputSize,
            (y) => List.generate(
              _inputSize,
              (x) {
                final pixel = resizedImage.getPixel(x, y);

                // Normalize pixel values to [0, 1]
                // return [
                //   img.getColor(pixel, 0) / 255.0, // Red
                //   img.getColor(pixel, 1) / 255.0, // Green
                //   img.getColor(pixel, 2) / 255.0, // Blue
                // ].map((e) => e!).toList();
              },
            ),
          ),
        ),
      );

      return tensor;
    } catch (e) {
      print('Error preprocessing image: $e');
      return null;
    }
  }
}
