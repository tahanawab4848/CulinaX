/// Local barcode → product name map (Pakistani / common grocery).
/// Extend with real product barcodes from packaging.
class BarcodeProduct {
  final String name;
  final String category;
  final String icon;

  const BarcodeProduct({
    required this.name,
    required this.category,
    this.icon = '🛒',
  });
}

const Map<String, BarcodeProduct> kBarcodeDatabase = {
  // Sample EAN-13 codes — replace with real local product codes
  '8901030865678': BarcodeProduct(name: 'National Salt', category: 'Spice', icon: '🧂'),
  '8901490001234': BarcodeProduct(name: 'Dalda Cooking Oil', category: 'Staple', icon: '🫒'),
  '8901490005678': BarcodeProduct(name: 'Basmati Rice 1kg', category: 'Grain', icon: '🍚'),
  '8901030456789': BarcodeProduct(name: 'Shan Biryani Masala', category: 'Spice', icon: '🌶️'),
  '8901030789012': BarcodeProduct(name: 'Nestle Milk Pack', category: 'Dairy', icon: '🥛'),
  '8901030123456': BarcodeProduct(name: 'Tapal Tea', category: 'Staple', icon: '🍵'),
  '8901030987654': BarcodeProduct(name: 'Knorr Chicken Cube', category: 'Spice', icon: '🍗'),
  '8901490009012': BarcodeProduct(name: 'Atta 5kg', category: 'Staple', icon: '🌾'),
  '8901490003456': BarcodeProduct(name: 'Yogurt Dahi', category: 'Dairy', icon: '🥛'),
  '8901030567890': BarcodeProduct(name: 'Ketchup', category: 'Staple', icon: '🍅'),
};
