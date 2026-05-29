import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../core/theme.dart';
import '../data/ingredient_label_map.dart';
import '../providers/pantry_provider.dart';
import '../services/image_ingredient_scanner.dart';

class IngredientScannerScreen extends StatefulWidget {
  const IngredientScannerScreen({super.key});

  @override
  State<IngredientScannerScreen> createState() =>
      _IngredientScannerScreenState();
}

class _IngredientScannerScreenState extends State<IngredientScannerScreen> {
  final ImagePicker _picker = ImagePicker();
  final ImageIngredientScanner _scanner = ImageIngredientScanner();

  File? _image;
  List<DetectedIngredient> _detected = [];
  ScanMode? _scanMode;
  bool _scanning = false;
  String? _error;

  @override
  void dispose() {
    _scanner.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    setState(() {
      _error = null;
      _detected = [];
      _scanMode = null;
    });
    try {
      final file = await _picker.pickImage(
        source: source,
        maxWidth: 1280,
        imageQuality: 85,
      );
      if (file == null) return;
      setState(() {
        _image = File(file.path);
        _scanning = true;
      });

      final result = await _scanner.scanImage(_image!);
      if (!mounted) return;
      setState(() {
        _detected = result.ingredients;
        _scanMode = result.mode;
        _scanning = false;
        if (result.ingredients.isEmpty) {
          _error = result.mode == ScanMode.mlKitOffline
              ? 'ML Kit could not identify ingredients. Try better lighting, a closer shot, or ensure internet is on for AI scanning.'
              : 'No ingredients detected. Try a clearer photo with good lighting.';
        }
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _scanning = false;
        _error = kIsWeb
            ? 'Image scanning works best on Android/iOS.'
            : 'Scan failed: $e';
      });
    }
  }

  Future<void> _addToPantry(DetectedIngredient item) async {
    await context.read<PantryProvider>().addItem(
          itemName: item.nameEn,
          category: item.category,
          icon: item.icon,
        );
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Added ${item.nameEn} (${item.nameUr}) to pantry ✓'),
          backgroundColor: C.g700,
        ),
      );
    }
  }

  Widget _categoryBadge(String category) {
    final colors = <String, Color>{
      'Vegetable':       const Color(0xFF4CAF50),
      'Fruit':           const Color(0xFFFF9800),
      'Protein':         const Color(0xFFF44336),
      'Dairy':           const Color(0xFF2196F3),
      'Grain':           const Color(0xFF795548),
      'Lentil':          const Color(0xFF8BC34A),
      'Spice':           const Color(0xFFFF5722),
      'Herb':            const Color(0xFF009688),
      'Oil & Fat':       const Color(0xFFFFEB3B),
      'Condiment':       const Color(0xFF9C27B0),
      'Nut & Dry Fruit': const Color(0xFFBF9000),
      'Sweetener':       const Color(0xFFE91E63),
      'Beverage':        const Color(0xFF00BCD4),
    };
    final color = colors[category] ?? const Color(0xFF607D8B);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.5)),
      ),
      child: Text(
        category,
        style: TextStyle(
            color: color, fontSize: 10, fontWeight: FontWeight.w600),
      ),
    );
  }

  Widget _scanModeBadge() {
    final Color bgColor;
    final Color borderColor;
    final Color textColor;
    final IconData icon;
    final String text;

    if (_scanMode == ScanMode.geminiVision) {
      bgColor = C.v600.withValues(alpha: 0.15);
      borderColor = C.v400.withValues(alpha: 0.5);
      textColor = C.v400;
      icon = Icons.auto_awesome;
      text = 'Gemini AI Vision';
    } else if (_scanMode == ScanMode.groqVision) {
      bgColor = C.a600.withValues(alpha: 0.15);
      borderColor = C.a400.withValues(alpha: 0.5);
      textColor = C.a400;
      icon = Icons.bolt;
      text = 'Groq Llama 3.2 Vision';
    } else {
      bgColor = C.t600.withValues(alpha: 0.15);
      borderColor = C.t400.withValues(alpha: 0.5);
      textColor = C.t400;
      icon = Icons.memory;
      text = 'ML Kit Offline';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 13,
            color: textColor,
          ),
          const SizedBox(width: 5),
          Text(
            text,
            style: TextStyle(
              color: textColor,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: C.dark2,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('INGREDIENT SCAN', style: T.lbl(c: C.t400)),
            Text('AI Image Detection', style: T.head(17)),
          ],
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // ── Scan buttons ─────────────────────────────────────────────────
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _scanning
                      ? null
                      : () => _pickImage(ImageSource.camera),
                  icon: const Icon(Icons.camera_alt),
                  label: const Text('Camera'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _scanning
                      ? null
                      : () => _pickImage(ImageSource.gallery),
                  icon: const Icon(Icons.photo_library),
                  label: const Text('Gallery'),
                ),
              ),
            ],
          ),

          // ── Info banner ───────────────────────────────────────────────────
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: C.v600.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: C.v600.withValues(alpha: 0.2)),
            ),
            child: Row(
              children: [
                const Icon(Icons.auto_awesome, color: C.v400, size: 16),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'AI Vision detects any ingredient including desi items. '
                    'Works best with clear, well-lit photos.',
                    style: T.body(12, c: C.white70),
                  ),
                ),
              ],
            ),
          ),

          // ── Image preview ─────────────────────────────────────────────────
          if (_image != null) ...[
            const SizedBox(height: 16),
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.file(_image!,
                  height: 200, width: double.infinity, fit: BoxFit.cover),
            ),
          ],

          // ── Scanning indicator ────────────────────────────────────────────
          if (_scanning) ...[
            const SizedBox(height: 24),
            const Center(
                child: CircularProgressIndicator(color: C.v400)),
            const SizedBox(height: 12),
            Text('Analyzing with AI Vision…',
                style: T.body(14, c: C.v400),
                textAlign: TextAlign.center),
            const SizedBox(height: 4),
            Text('Identifying ingredients from photo',
                style: T.body(12, c: C.white40),
                textAlign: TextAlign.center),
          ],

          // ── Error ─────────────────────────────────────────────────────────
          if (_error != null) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: C.a500.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: C.a500.withValues(alpha: 0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [
                    const Icon(Icons.warning_amber_rounded,
                        color: C.a400, size: 18),
                    const SizedBox(width: 8),
                    Text('Detection failed',
                        style: T.sub(13, c: C.a400)),
                  ]),
                  const SizedBox(height: 6),
                  Text(_error!, style: T.body(12, c: C.white70)),
                ],
              ),
            ),
          ],

          // ── Results ───────────────────────────────────────────────────────
          if (_detected.isNotEmpty) ...[
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: Text(
                    'DETECTED INGREDIENTS (${_detected.length})',
                    style: T.lbl(c: C.g400),
                  ),
                ),
                if (_scanMode != null) _scanModeBadge(),
              ],
            ),
            const SizedBox(height: 12),

            ..._detected.map((d) => Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  decoration: D.card(r: 14),
                  child: ListTile(
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    leading: Text(d.icon,
                        style: const TextStyle(fontSize: 30)),
                    title: Row(
                      children: [
                        Expanded(child: Text(d.nameEn, style: T.sub(14))),
                        _categoryBadge(d.category),
                      ],
                    ),
                    subtitle: Text(d.nameUr, style: T.body(12, c: C.white40)),
                    trailing: IconButton(
                      icon:
                          const Icon(Icons.add_circle, color: C.g500, size: 28),
                      onPressed: () => _addToPantry(d),
                    ),
                  ),
                )),

            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                onPressed: () async {
                  final nav = Navigator.of(context);
                  for (final d in _detected) {
                    await context.read<PantryProvider>().addItem(
                          itemName: d.nameEn,
                          category: d.category,
                          icon: d.icon,
                        );
                  }
                  if (mounted) nav.pop();
                },
                icon: const Icon(Icons.playlist_add_check),
                label: Text('Add All ${_detected.length} to Pantry'),
                style: ElevatedButton.styleFrom(backgroundColor: C.g600),
              ),
            ),
          ],

          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
