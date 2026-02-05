import 'dart:io';
import 'package:google_mlkit_custom_image_labeling/google_mlkit_custom_image_labeling.dart';

class FoodAIService {
  late final ImageLabeler _labeler;

  FoodAIService() {
    final options = CustomImageLabelerOptions(
      modelPath: 'assets/models/food_model.tflite',
      confidenceThreshold: 0.6,
    );

    _labeler = ImageLabeler(options: options);
  }

  Future<String?> detectFood(File imageFile) async {
    final inputImage = InputImage.fromFile(imageFile);
    final labels = await _labeler.processImage(inputImage);

    if (labels.isEmpty) return null;

    labels.sort((a, b) => b.confidence.compareTo(a.confidence));
    return labels.first.label;
  }

  void dispose() {
    _labeler.close();
  }
}
