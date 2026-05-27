import 'package:cloud_firestore/cloud_firestore.dart';

class GroceryItem {
  final String name;
  final bool checked;
  final String? recipeSource;

  const GroceryItem({
    required this.name,
    this.checked = false,
    this.recipeSource,
  });

  factory GroceryItem.fromMap(Map<String, dynamic> map) => GroceryItem(
        name: map['name'] as String? ?? '',
        checked: map['checked'] as bool? ?? false,
        recipeSource: map['recipeSource'] as String?,
      );

  Map<String, dynamic> toMap() => {
        'name': name,
        'checked': checked,
        if (recipeSource != null) 'recipeSource': recipeSource,
      };

  GroceryItem copyWith({bool? checked}) => GroceryItem(
        name: name,
        checked: checked ?? this.checked,
        recipeSource: recipeSource,
      );
}

class GroceryListDoc {
  final String id;
  final String userId;
  final List<GroceryItem> items;
  final DateTime createdAt;

  const GroceryListDoc({
    required this.id,
    required this.userId,
    required this.items,
    required this.createdAt,
  });

  factory GroceryListDoc.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    final rawItems = data['items'] as List<dynamic>? ?? [];
    return GroceryListDoc(
      id: doc.id,
      userId: data['userId'] as String? ?? '',
      items: rawItems
          .map((e) => GroceryItem.fromMap(e as Map<String, dynamic>))
          .toList(),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() => {
        'userId': userId,
        'items': items.map((e) => e.toMap()).toList(),
        'createdAt': Timestamp.fromDate(createdAt),
      };
}
