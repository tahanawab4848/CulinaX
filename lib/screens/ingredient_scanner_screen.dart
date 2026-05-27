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
  State<IngredientScannerScreen> createState() => _IngredientScannerScreenState();
}

class _IngredientScannerScreenState extends State<IngredientScannerScreen> {
  final ImagePicker _picker = ImagePicker();
  final ImageIngredientScanner _scanner = ImageIngredientScanner();
  File? _image;
  List<DetectedIngredient> _detected = [];
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
      final results = await _scanner.scanImage(_image!);
      if (!mounted) return;
      setState(() {
        _detected = results;
        _scanning = false;
        if (results.isEmpty) {
          _error = 'No ingredients detected. Try better lighting or a closer shot.';
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
        SnackBar(content: Text('Added ${item.nameEn} (${item.nameUr}) to pantry')),
      );
    }
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
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _scanning ? null : () => _pickImage(ImageSource.camera),
                  icon: const Icon(Icons.camera_alt),
                  label: const Text('Camera'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _scanning ? null : () => _pickImage(ImageSource.gallery),
                  icon: const Icon(Icons.photo_library),
                  label: const Text('Gallery'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          if (_image != null)
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.file(_image!, height: 200, width: double.infinity, fit: BoxFit.cover),
            ),
          if (_scanning) ...[
            const SizedBox(height: 24),
            const Center(child: CircularProgressIndicator(color: C.g500)),
            const SizedBox(height: 8),
            Text('Analyzing image…', style: T.body(14), textAlign: TextAlign.center),
          ],
          if (_error != null) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: C.a500.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: C.a500.withValues(alpha: 0.3)),
              ),
              child: Text(_error!, style: T.body(13, c: C.a400)),
            ),
          ],
          if (_detected.isNotEmpty) ...[
            const SizedBox(height: 24),
            Text('DETECTED INGREDIENTS', style: T.lbl(c: C.g400)),
            const SizedBox(height: 12),
            ..._detected.map(
              (d) => Container(
                margin: const EdgeInsets.only(bottom: 10),
                decoration: D.card(r: 14),
                child: ListTile(
                  leading: Text(d.icon, style: const TextStyle(fontSize: 28)),
                  title: Text(d.nameEn, style: T.sub(14)),
                  subtitle: Text(
                    '${d.nameUr} · ${(d.confidence * 100).round()}% · ${d.category}',
                    style: T.body(12, c: C.white40),
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.add_circle, color: C.g500),
                    onPressed: () => _addToPantry(d),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
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
                child: Text('Add All (${_detected.length})'),
              ),
            ),
          ],
          const SizedBox(height: 16),
          Text(
            'Uses on-device ML to detect common desi ingredients. Works offline on mobile.',
            style: T.body(12, c: C.white40),
          ),
        ],
      ),
    );
  }
}
