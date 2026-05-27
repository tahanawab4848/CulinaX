import 'package:cloud_firestore/cloud_firestore.dart';

class PantryItem {
  final String id;
  final String userId;
  final String itemName;
  final double quantity;
  final String unit;
  final DateTime? expiryDate;
  final String category;
  final bool isUsed;
  final String icon;

  const PantryItem({
    required this.id,
    required this.userId,
    required this.itemName,
    this.quantity = 1,
    this.unit = 'piece',
    this.expiryDate,
    this.category = 'Other',
    this.isUsed = false,
    this.icon = '🥘',
  });

  bool get isExpiringSoon {
    if (expiryDate == null) return false;
    final days = expiryDate!.difference(DateTime.now()).inDays;
    return days >= 0 && days <= 3;
  }

  bool get isExpired {
    if (expiryDate == null) return false;
    return expiryDate!.isBefore(DateTime.now());
  }

  bool get isLowStock => quantity <= 1;

  String get normalizedName => itemName.trim().toLowerCase();

  factory PantryItem.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return PantryItem(
      id: doc.id,
      userId: data['userId'] as String? ?? '',
      itemName: data['itemName'] as String? ?? '',
      quantity: (data['quantity'] as num?)?.toDouble() ?? 1,
      unit: data['unit'] as String? ?? 'piece',
      expiryDate: (data['expiryDate'] as Timestamp?)?.toDate(),
      category: data['category'] as String? ?? 'Other',
      isUsed: data['isUsed'] as bool? ?? false,
      icon: data['icon'] as String? ?? '🥘',
    );
  }

  Map<String, dynamic> toMap() => {
        'userId': userId,
        'itemName': itemName,
        'quantity': quantity,
        'unit': unit,
        'expiryDate':
            expiryDate != null ? Timestamp.fromDate(expiryDate!) : null,
        'category': category,
        'isUsed': isUsed,
        'icon': icon,
      };

  PantryItem copyWith({
    String? itemName,
    double? quantity,
    String? unit,
    DateTime? expiryDate,
    String? category,
    bool? isUsed,
    String? icon,
    bool clearExpiry = false,
  }) {
    return PantryItem(
      id: id,
      userId: userId,
      itemName: itemName ?? this.itemName,
      quantity: quantity ?? this.quantity,
      unit: unit ?? this.unit,
      expiryDate: clearExpiry ? null : (expiryDate ?? this.expiryDate),
      category: category ?? this.category,
      isUsed: isUsed ?? this.isUsed,
      icon: icon ?? this.icon,
    );
  }
}
