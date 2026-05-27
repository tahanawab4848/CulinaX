import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'app.dart';
import 'core/theme.dart';
import 'firebase_options.dart';
import 'screens/firebase_setup_screen.dart';
import 'providers/auth_provider.dart';
import 'providers/ai_chef_provider.dart';
import 'providers/hybrid_recommendation_provider.dart';
import 'providers/grocery_provider.dart';
import 'providers/meal_planner_provider.dart';
import 'providers/pantry_provider.dart';
import 'providers/recipe_provider.dart';
import 'services/notification_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: C.dark2,
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );
  await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

  bool firebaseFailed = false;
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    await NotificationService().init();
  } catch (e) {
    debugPrint('Firebase init failed: $e');
    firebaseFailed = true;
  }

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => RecipeProvider()),
        ChangeNotifierProvider(create: (_) => PantryProvider()),
        ChangeNotifierProvider(create: (_) => GroceryProvider()),
        ChangeNotifierProvider(create: (_) => MealPlannerProvider()),
        ChangeNotifierProvider(create: (_) => AiChefProvider()),
        ChangeNotifierProvider(create: (_) => HybridRecommendationProvider()),
      ],
      child: CulinaXApp(firebaseFailed: firebaseFailed),
    ),
  );
}

class CulinaXApp extends StatefulWidget {
  final bool firebaseFailed;
  const CulinaXApp({super.key, required this.firebaseFailed});

  @override
  State<CulinaXApp> createState() => _CulinaXAppState();
}

class _CulinaXAppState extends State<CulinaXApp> {
  late bool _showSetup;

  @override
  void initState() {
    super.initState();
    _showSetup = widget.firebaseFailed;
  }

  @override
  Widget build(BuildContext context) {
    if (_showSetup) {
      return MaterialApp(
        title: 'CulinaX',
        debugShowCheckedModeBanner: false,
        theme: buildAppTheme(),
        home: FirebaseSetupScreen(
          onBypass: () => setState(() => _showSetup = false),
        ),
      );
    }
    return const AppRoot();
  }
}
