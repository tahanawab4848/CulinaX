class MealPlanEntry {
  final String id;
  final String userId;
  final int dayIndex;
  final String mealType;
  final String? recipeId;
  final String? recipeName;
  final DateTime plannedDate;

  const MealPlanEntry({
    required this.id,
    required this.userId,
    required this.dayIndex,
    required this.mealType,
    this.recipeId,
    this.recipeName,
    required this.plannedDate,
  });

  factory MealPlanEntry.fromMap(String id, Map<String, dynamic> map) {
    return MealPlanEntry(
      id: id,
      userId: map['userId'] as String? ?? '',
      dayIndex: map['dayIndex'] as int? ?? 0,
      mealType: map['mealType'] as String? ?? 'Lunch',
      recipeId: map['recipeId'] as String?,
      recipeName: map['recipeName'] as String?,
      plannedDate: DateTime.parse(
        map['plannedDate'] as String? ?? DateTime.now().toIso8601String(),
      ),
    );
  }

  Map<String, dynamic> toMap() => {
        'userId': userId,
        'dayIndex': dayIndex,
        'mealType': mealType,
        'recipeId': recipeId,
        'recipeName': recipeName,
        'plannedDate': plannedDate.toIso8601String(),
      };
}
