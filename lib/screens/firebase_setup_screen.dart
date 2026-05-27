import 'package:flutter/material.dart';
import '../core/theme.dart';

/// Shown when Firebase is not configured yet, with a bypass to Demo Mode.
class FirebaseSetupScreen extends StatelessWidget {
  final VoidCallback? onBypass;

  const FirebaseSetupScreen({super.key, this.onBypass});

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
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'This application is configured to run with Firebase services (Authentication, Firestore, Storage).\n\n'
                        'To complete full Firebase setup:\n'
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
                      const SizedBox(height: 24),
                      Text(
                        'Required Firestore collections: users, pantry_items, recipes, grocery_list, meal_plans',
                        style: T.body(12, c: C.white40),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              if (onBypass != null) ...[
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: C.v600,
                    ),
                    onPressed: onBypass,
                    icon: const Icon(Icons.play_arrow),
                    label: const Text('Use Local Demo / Offline Mode'),
                  ),
                ),
                const SizedBox(height: 12),
                Center(
                  child: Text(
                    'No Firebase account needed. App will run offline with local data.',
                    style: T.body(11, c: C.white40),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
