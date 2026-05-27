import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/theme.dart';
import 'providers/auth_provider.dart';
import 'providers/grocery_provider.dart';
import 'providers/meal_planner_provider.dart';
import 'providers/pantry_provider.dart';
import 'providers/recipe_provider.dart';
import 'screens/auth/login_screen.dart';
import 'screens/main_shell.dart';

class AppRoot extends StatefulWidget {
  const AppRoot({super.key});

  @override
  State<AppRoot> createState() => _AppRootState();
}

class _AppRootState extends State<AppRoot> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _onAuthChanged());
    context.read<AuthProvider>().addListener(_onAuthChanged);
    context.read<RecipeProvider>().init();
  }

  void _onAuthChanged() {
    final uid = context.read<AuthProvider>().userId;
    context.read<PantryProvider>().bindUser(uid);
    context.read<GroceryProvider>().bindUser(uid);
    context.read<MealPlannerProvider>().bindUser(uid);
  }

  @override
  void dispose() {
    context.read<AuthProvider>().removeListener(_onAuthChanged);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    return MaterialApp(
      title: 'CulinaX',
      debugShowCheckedModeBanner: false,
      theme: buildAppTheme(),
      home: auth.isLoggedIn ? const MainShell() : const LoginScreen(),
    );
  }
}
