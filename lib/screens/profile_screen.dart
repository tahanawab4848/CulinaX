import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/theme.dart';
import '../models/user_profile.dart';
import '../providers/auth_provider.dart';
import '../services/notification_service.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final prefs = auth.profile?.preferences ?? const UserPreferences();

    return Scaffold(
      backgroundColor: C.dark2,
      appBar: AppBar(title: Text('Profile', style: T.head(18))),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          CircleAvatar(
            radius: 40,
            backgroundColor: C.g700,
            child: Text(
              (auth.profile?.name.isNotEmpty == true
                      ? auth.profile!.name[0]
                      : 'S')
                  .toUpperCase(),
              style: T.head(28),
            ),
          ),
          const SizedBox(height: 12),
          Text(auth.profile?.name ?? auth.user?.displayName ?? 'User', style: T.head(22)),
          Text(auth.profile?.email ?? auth.user?.email ?? '', style: T.body(14, c: C.white40)),
          const SizedBox(height: 20),
          Text('PREFERENCES', style: T.lbl()),
          const SizedBox(height: 12),
          _PrefTile(
            title: 'Cuisine Preference',
            value: prefs.cuisinePreference,
            options: ['Punjabi', 'Sindhi', 'Balochi', 'Kashmiri'],
            onChanged: (v) => auth.updatePreferences(prefs.copyWith(cuisinePreference: v)),
          ),
          _PrefTile(
            title: 'Budget Level',
            value: prefs.budgetLevel,
            options: ['Low', 'Medium', 'High'],
            onChanged: (v) => auth.updatePreferences(prefs.copyWith(budgetLevel: v)),
          ),
          _PrefTile(
            title: 'Diet',
            value: prefs.diet,
            options: ['None', 'Vegetarian', 'Halal'],
            onChanged: (v) => auth.updatePreferences(prefs.copyWith(diet: v)),
          ),
          SwitchListTile(
            title: Text('Budget Mode Default', style: T.sub(14)),
            value: prefs.budgetMode,
            activeThumbColor: C.g500,
            onChanged: (v) => auth.updatePreferences(prefs.copyWith(budgetMode: v)),
          ),
          SwitchListTile(
            title: Text('Notifications', style: T.sub(14)),
            value: prefs.notificationsEnabled,
            activeThumbColor: C.g500,
            onChanged: (v) async {
              await auth.updatePreferences(prefs.copyWith(notificationsEnabled: v));
              if (v) await NotificationService().scheduleWeeklyMealReminder();
            },
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () => auth.signOut(),
              style: OutlinedButton.styleFrom(
                foregroundColor: C.r400,
                side: const BorderSide(color: C.r400),
              ),
              child: const Text('Sign Out'),
            ),
          ),
        ],
      ),
    );
  }
}

class _PrefTile extends StatelessWidget {
  final String title, value;
  final List<String> options;
  final ValueChanged<String> onChanged;

  const _PrefTile({
    required this.title,
    required this.value,
    required this.options,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: D.card(r: 14),
      child: ListTile(
        title: Text(title, style: T.sub(14)),
        trailing: DropdownButton<String>(
          value: options.contains(value) ? value : options.first,
          dropdownColor: C.card,
          items: options.map((o) => DropdownMenuItem(value: o, child: Text(o))).toList(),
          onChanged: (v) {
            if (v != null) onChanged(v);
          },
        ),
      ),
    );
  }
}
