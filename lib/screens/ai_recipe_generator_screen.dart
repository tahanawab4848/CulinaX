import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../ai_services/pantry_context_builder.dart';
import '../core/constants.dart';
import '../core/theme.dart';
import '../providers/ai_chef_provider.dart';
import '../providers/auth_provider.dart';
import '../providers/pantry_provider.dart';
import '../providers/recipe_provider.dart';
import '../widgets/ai_recipe_card.dart';
import 'recipe_detail_screen.dart';

class AiRecipeGeneratorScreen extends StatefulWidget {
  const AiRecipeGeneratorScreen({super.key});

  @override
  State<AiRecipeGeneratorScreen> createState() => _AiRecipeGeneratorScreenState();
}

class _AiRecipeGeneratorScreenState extends State<AiRecipeGeneratorScreen> {
  String _mealType = 'Dinner';
  String _cuisine = 'Punjabi';
  final _extra = TextEditingController();

  @override
  void dispose() {
    _extra.dispose();
    super.dispose();
  }

  Future<void> _generate() async {
    final pantry = context.read<PantryProvider>();
    final recipes = context.read<RecipeProvider>();
    final auth = context.read<AuthProvider>();
    final chef = context.read<AiChefProvider>();

    final ctx = PantryContextBuilder.build(
      pantryItems: pantry.activeItems,
      recipes: recipes.recipes,
      budgetMode: recipes.budgetMode,
      cuisinePreference: _cuisine,
      diet: auth.profile?.preferences.diet ?? 'None',
      mealTimeHint: _mealType,
    );

    final result = await chef.generateRecipe(
      ctx,
      mealType: _mealType,
      extraPrompt: _extra.text.trim().isEmpty ? null : _extra.text.trim(),
      userId: auth.userId,
    );

    if (result != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Generated: ${result.name}')),
      );
    } else if (chef.error != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('⏳ Quota reached. Wait a moment then try again.'),
          duration: Duration(seconds: 4),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final chef = context.watch<AiChefProvider>();
    final generated = chef.lastGeneratedRecipe;

    return Scaffold(
      backgroundColor: C.dark2,
      appBar: AppBar(
        title: Text('AI Recipe Generator', style: T.head(18)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(
            'Uses your pantry + preferences to create a Pakistani recipe via generative AI.',
            style: T.body(14, c: C.white40),
          ),
          const SizedBox(height: 20),
          DropdownButtonFormField<String>(
            initialValue: _mealType,
            dropdownColor: C.card,
            decoration: const InputDecoration(labelText: 'Meal type'),
            items: [...AppConstants.mealTypes, 'Snack', 'Chai-time']
                .map((m) => DropdownMenuItem(value: m, child: Text(m)))
                .toList(),
            onChanged: (v) => setState(() => _mealType = v ?? 'Dinner'),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            initialValue: _cuisine,
            dropdownColor: C.card,
            decoration: const InputDecoration(labelText: 'Cuisine'),
            items: ['Punjabi', 'Sindhi', 'Balochi', 'Kashmiri', 'Pakistani']
                .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                .toList(),
            onChanged: (v) => setState(() => _cuisine = v ?? 'Punjabi'),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _extra,
            style: T.body(14, c: C.white),
            maxLines: 2,
            decoration: const InputDecoration(
              labelText: 'Extra instructions (optional)',
              hintText: 'e.g. healthy, no oil, hostel style',
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton.icon(
              onPressed: chef.loading ? null : _generate,
              icon: chef.loading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.auto_awesome),
              label: Text(chef.loading ? 'Generating…' : 'Generate Recipe'),
              style: ElevatedButton.styleFrom(backgroundColor: C.v600),
            ),
          ),
          if (chef.error != null) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: C.r500.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: C.r400.withValues(alpha: 0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Text('⏳', style: TextStyle(fontSize: 16)),
                      SizedBox(width: 8),
                      Text('AI Quota Reached', style: TextStyle(color: C.r400, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Your Gemini free tier daily limit is used up.\n\n'
                    '• Wait a few minutes and tap Generate again\n'
                    '• Or get a fresh key: aistudio.google.com/apikey',
                    style: TextStyle(color: C.white70, fontSize: 13, height: 1.5),
                  ),
                ],
              ),
            ),
          ],
          if (generated != null) ...[
            const SizedBox(height: 28),
            AiRecipeCard(
              recipe: generated,
              onOpen: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => RecipeDetailScreen(
                    recipe: generated.toRecipe(),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
