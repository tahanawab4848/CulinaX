import 'package:flutter/material.dart';
import '../core/theme.dart';

/// Shown when Firebase is not configured yet.
class FirebaseSetupScreen extends StatelessWidget {
  const FirebaseSetupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: C.dark2,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Firebase Setup Required', style: T.hero(24)),
              const SizedBox(height: 16),
              Text(
                '1. Create a Firebase project at console.firebase.google.com\n'
                '2. Enable Authentication (Email/Password)\n'
                '3. Create Firestore database\n'
                '4. Enable Storage\n'
                '5. Run in project folder:\n'
                '   dart pub global activate flutterfire_cli\n'
                '   flutterfire configure\n'
                '6. Add google-services.json to android/app/\n'
                '7. Restart the app',
                style: T.body(14),
              ),
              const Spacer(),
              Text(
                'Firestore collections: users, pantry_items, recipes, grocery_list, meal_plans',
                style: T.body(12, c: C.white40),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
