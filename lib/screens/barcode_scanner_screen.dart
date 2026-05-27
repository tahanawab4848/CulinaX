import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:provider/provider.dart';

import '../core/theme.dart';
import '../providers/grocery_provider.dart';
import '../services/barcode_service.dart';

class BarcodeScannerScreen extends StatefulWidget {
  const BarcodeScannerScreen({super.key});

  @override
  State<BarcodeScannerScreen> createState() => _BarcodeScannerScreenState();
}

class _BarcodeScannerScreenState extends State<BarcodeScannerScreen> {
  final MobileScannerController _controller = MobileScannerController();
  final BarcodeService _barcodeService = BarcodeService();
  bool _handled = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _onDetect(BarcodeCapture capture) async {
    if (_handled) return;
    final raw = capture.barcodes.firstOrNull?.rawValue;
    if (raw == null || raw.isEmpty) return;
    _handled = true;
    await _controller.stop();

    if (!mounted) return;
    final result = _barcodeService.lookup(raw);
    await _showAddDialog(result);
    if (mounted) {
      _handled = false;
      await _controller.start();
    }
  }

  Future<void> _showAddDialog(BarcodeLookupResult result) async {
    final nameCtrl = TextEditingController(text: result.name);
    final added = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: C.dark3,
        title: Row(
          children: [
            Text(result.icon, style: const TextStyle(fontSize: 28)),
            const SizedBox(width: 12),
            Expanded(child: Text('Barcode Found', style: T.head(18))),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Code: ${result.barcode}', style: T.body(12, c: C.white40)),
            if (!result.isKnown)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  'Unknown product — edit name below',
                  style: T.body(12, c: C.a400),
                ),
              ),
            const SizedBox(height: 12),
            TextField(
              controller: nameCtrl,
              style: T.body(15, c: C.white),
              decoration: const InputDecoration(labelText: 'Grocery item name'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Add to Grocery'),
          ),
        ],
      ),
    );

    if (added == true && nameCtrl.text.trim().isNotEmpty && mounted) {
      await context.read<GroceryProvider>().addItem(nameCtrl.text.trim());
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Added ${nameCtrl.text.trim()} to grocery list')),
        );
        Navigator.pop(context);
      }
    }
    nameCtrl.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: C.dark1,
      appBar: AppBar(
        title: Text('Scan Barcode', style: T.head(18)),
        actions: [
          IconButton(
            icon: const Icon(Icons.flash_on),
            onPressed: () => _controller.toggleTorch(),
          ),
          IconButton(
            icon: const Icon(Icons.cameraswitch),
            onPressed: () => _controller.switchCamera(),
          ),
        ],
      ),
      body: Stack(
        children: [
          MobileScanner(
            controller: _controller,
            onDetect: _onDetect,
          ),
          Positioned(
            left: 24,
            right: 24,
            bottom: 32,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: D.card(r: 16),
              child: Text(
                'Point camera at product barcode.\nWorks with Pakistani grocery items.',
                textAlign: TextAlign.center,
                style: T.body(13, c: C.white70),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
