import 'dart:io';

import 'package:google_mlkit_image_labeling/google_mlkit_image_labeling.dart';

import '../data/ingredient_label_map.dart';

class ImageIngredientScanner {
  final ImageLabeler _labeler = ImageLabeler(
    options: ImageLabelerOptions(confidenceThreshold: 0.55),
  );

  Future<List<DetectedIngredient>> scanImage(File imageFile) async {
    final inputImage = InputImage.fromFile(imageFile);
    final labels = await _labeler.processImage(inputImage);
    final detected = <DetectedIngredient>[];
    final seen = <String>{};

    for (final label in labels) {
      final hint = IngredientLabelMap.matchLabel(label.label);
      if (hint == null) continue;
      if (seen.contains(hint.nameEn)) continue;
      seen.add(hint.nameEn);
      detected.add(
        DetectedIngredient(
          nameEn: hint.nameEn,
          nameUr: hint.nameUr,
          category: hint.category,
          icon: hint.icon,
          confidence: label.confidence,
        ),
      );
    }

    detected.sort((a, b) => b.confidence.compareTo(a.confidence));
    return detected;
  }

  void dispose() => _labeler.close();
}
