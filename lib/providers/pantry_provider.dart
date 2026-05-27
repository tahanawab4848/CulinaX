import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/pantry_item.dart';
import '../services/firestore_service.dart';
import '../services/notification_service.dart';

class PantryProvider extends ChangeNotifier {
  final FirestoreService _firestore = FirestoreService();
  final NotificationService _notifications = NotificationService();

  List<PantryItem> _items = [];
  StreamSubscription? _sub;
  String? _userId;
  bool _loading = true;

  List<PantryItem> get items => List.unmodifiable(_items);
  bool get loading => _loading;

  List<PantryItem> get activeItems =>
      _items.where((i) => !i.isUsed).toList();

  List<PantryItem> get expiringSoon =>
      activeItems.where((i) => i.isExpiringSoon).toList();

  List<PantryItem> get lowStock =>
      activeItems.where((i) => i.isLowStock).toList();

  Map<String, List<PantryItem>> get groupedByCategory {
    final map = <String, List<PantryItem>>{};
    for (final item in activeItems) {
      map.putIfAbsent(item.category, () => []).add(item);
    }
    return map;
  }

  Set<String> get pantryIngredientNames => activeItems
      .map((i) => i.itemName.trim())
      .toSet();

  void bindUser(String? userId) {
    _sub?.cancel();
    _userId = userId;
    _items = [];
    if (userId == null) {
      _loading = false;
      notifyListeners();
      return;
    }
    _loading = true;
    notifyListeners();
    _sub = _firestore.watchPantry(userId).listen((list) {
      _items = list;
      _loading = false;
      _checkAlerts();
      notifyListeners();
    }, onError: (e) {
      debugPrint('Firestore watchPantry failed: $e');
      _items = [];
      _loading = false;
      notifyListeners();
    });
  }

  void _checkAlerts() {
    final expiring = expiringSoon.map((i) => i.itemName).toList();
    final low = lowStock.map((i) => i.itemName).toList();
    if (expiring.isNotEmpty) _notifications.notifyExpiringItems(expiring);
    if (low.isNotEmpty) _notifications.notifyLowStock(low);
  }

  Future<void> addItem({
    required String itemName,
    required String category,
    double quantity = 1,
    String unit = 'piece',
    DateTime? expiryDate,
    String icon = '🥘',
  }) async {
    if (_userId == null) return;
    final item = PantryItem(
      id: '',
      userId: _userId!,
      itemName: itemName.trim(),
      category: category,
      quantity: quantity,
      unit: unit,
      expiryDate: expiryDate,
      icon: icon,
    );
    await _firestore.addPantryItem(item);
  }

  Future<void> updateItem(PantryItem item) async {
    await _firestore.updatePantryItem(item);
  }

  Future<void> deleteItem(String id) async {
    await _firestore.deletePantryItem(id);
  }

  Future<void> markAsUsed(PantryItem item) async {
    await updateItem(item.copyWith(isUsed: true));
  }

  Future<void> restock(PantryItem item, {double addQty = 1}) async {
    await updateItem(
      item.copyWith(quantity: item.quantity + addQty, isUsed: false),
    );
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}
