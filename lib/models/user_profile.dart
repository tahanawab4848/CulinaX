class UserPreferences {
  final String diet;
  final String budgetLevel;
  final String cuisinePreference;
  final bool budgetMode;
  final bool notificationsEnabled;

  const UserPreferences({
    this.diet = 'None',
    this.budgetLevel = 'Medium',
    this.cuisinePreference = 'Punjabi',
    this.budgetMode = false,
    this.notificationsEnabled = true,
  });

  factory UserPreferences.fromMap(Map<String, dynamic>? map) {
    if (map == null) return const UserPreferences();
    return UserPreferences(
      diet: map['diet'] as String? ?? 'None',
      budgetLevel: map['budgetLevel'] as String? ?? 'Medium',
      cuisinePreference: map['cuisinePreference'] as String? ?? 'Punjabi',
      budgetMode: map['budgetMode'] as bool? ?? false,
      notificationsEnabled: map['notificationsEnabled'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toMap() => {
        'diet': diet,
        'budgetLevel': budgetLevel,
        'cuisinePreference': cuisinePreference,
        'budgetMode': budgetMode,
        'notificationsEnabled': notificationsEnabled,
      };

  UserPreferences copyWith({
    String? diet,
    String? budgetLevel,
    String? cuisinePreference,
    bool? budgetMode,
    bool? notificationsEnabled,
  }) {
    return UserPreferences(
      diet: diet ?? this.diet,
      budgetLevel: budgetLevel ?? this.budgetLevel,
      cuisinePreference: cuisinePreference ?? this.cuisinePreference,
      budgetMode: budgetMode ?? this.budgetMode,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
    );
  }
}

class UserProfile {
  final String userId;
  final String name;
  final String email;
  final UserPreferences preferences;

  const UserProfile({
    required this.userId,
    required this.name,
    required this.email,
    this.preferences = const UserPreferences(),
  });

  factory UserProfile.fromMap(String id, Map<String, dynamic> map) {
    return UserProfile(
      userId: id,
      name: map['name'] as String? ?? '',
      email: map['email'] as String? ?? '',
      preferences: UserPreferences.fromMap(
        map['preferences'] as Map<String, dynamic>?,
      ),
    );
  }

  Map<String, dynamic> toMap() => {
        'userId': userId,
        'name': name,
        'email': email,
        'preferences': preferences.toMap(),
      };

  UserProfile copyWith({
    String? name,
    String? email,
    UserPreferences? preferences,
  }) {
    return UserProfile(
      userId: userId,
      name: name ?? this.name,
      email: email ?? this.email,
      preferences: preferences ?? this.preferences,
    );
  }
}
