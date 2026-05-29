import 'dart:io';

import 'package:google_mlkit_image_labeling/google_mlkit_image_labeling.dart';

import '../core/ai_config.dart';
import '../data/ingredient_label_map.dart';
import 'gemini_vision_scanner.dart';

enum ScanMode { geminiVision, groqVision, mlKitOffline }

class ScanResult {
  final List<DetectedIngredient> ingredients;
  final ScanMode mode;
  ScanResult(this.ingredients, this.mode);
}

/// Two-layer ingredient scanner:
///   1. AI Vision (Gemini / Groq) — sends photo to AI, identifies ANY ingredient accurately
///   2. ML Kit offline — falls back if Gemini/Groq is unavailable / quota exceeded
class ImageIngredientScanner {
  final _gemini = GeminiVisionScanner();

  final ImageLabeler _labeler = ImageLabeler(
    options: ImageLabelerOptions(confidenceThreshold: 0.40),
  );

  /// Tries AI Vision (Gemini / Groq) first. Falls back to ML Kit if it fails.
  Future<ScanResult> scanImage(File imageFile) async {
    // ── Layer 1: AI Vision ──────────────────────────────────────────────────
    try {
      final provider = await AiConfig.getProviderType();
      final results = await _gemini.scan(imageFile);
      if (results.isNotEmpty) {
        return ScanResult(
          results,
          provider == AiProviderType.groq
              ? ScanMode.groqVision
              : ScanMode.geminiVision,
        );
      }
    } catch (e) {
      // Quota exceeded, no key, or network issue → fall through to ML Kit
    }

    // ── Layer 2: ML Kit (offline fallback) ──────────────────────────────────
    final mlResults = await _mlKitScan(imageFile);
    return ScanResult(mlResults, ScanMode.mlKitOffline);
  }

  Future<List<DetectedIngredient>> _mlKitScan(File imageFile) async {
    final inputImage = InputImage.fromFile(imageFile);
    final labels = await _labeler.processImage(inputImage);

    final bestByName = <String, DetectedIngredient>{};

    for (final label in labels) {
      final hint = IngredientLabelMap.matchLabel(label.label);
      if (hint == null) continue;
      final existing = bestByName[hint.nameEn];
      if (existing == null || label.confidence > existing.confidence) {
        bestByName[hint.nameEn] = DetectedIngredient(
          nameEn: hint.nameEn,
          nameUr: hint.nameUr,
          category: hint.category,
          icon: hint.icon,
          confidence: label.confidence,
        );
      }
    }

    final list = bestByName.values.toList()
      ..sort((a, b) => b.confidence.compareTo(a.confidence));
    return list.isNotEmpty ? [list.first] : [];
  }

  void dispose() => _labeler.close();
}
