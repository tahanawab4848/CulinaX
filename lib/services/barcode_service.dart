import '../data/barcode_products.dart';

class BarcodeLookupResult {
  final String barcode;
  final String name;
  final String category;
  final String icon;
  final bool isKnown;

  const BarcodeLookupResult({
    required this.barcode,
    required this.name,
    required this.category,
    required this.icon,
    required this.isKnown,
  });
}

class BarcodeService {
  BarcodeLookupResult lookup(String rawBarcode) {
    final code = rawBarcode.replaceAll(RegExp(r'\D'), '');
    final product = kBarcodeDatabase[code];
    if (product != null) {
      return BarcodeLookupResult(
        barcode: code,
        name: product.name,
        category: product.category,
        icon: product.icon,
        isKnown: true,
      );
    }
    return BarcodeLookupResult(
      barcode: code,
      name: 'Product $code',
      category: 'Other',
      icon: '🛒',
      isKnown: false,
    );
  }
}
