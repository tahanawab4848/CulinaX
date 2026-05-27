import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:provider/provider.dart';
import '../ai_services/pantry_context_builder.dart';
import '../core/theme.dart';
import '../models/recipe.dart';
import '../providers/ai_chef_provider.dart';
import '../providers/auth_provider.dart';
import '../providers/pantry_provider.dart';
import '../providers/recipe_provider.dart';

class CookingModeScreen extends StatefulWidget {
  final Recipe recipe;
  final int servings;

  const CookingModeScreen({
    super.key,
    required this.recipe,
    this.servings = 4,
  });

  @override
  State<CookingModeScreen> createState() => _CookingModeScreenState();
}

class _CookingModeScreenState extends State<CookingModeScreen> {
  int _stepIndex = 0;
  final FlutterTts _tts = FlutterTts();
  bool _ttsEnabled = false;
  String? _aiTip;
  bool _loadingTip = false;

  @override
  void initState() {
    super.initState();
    _initTts();
  }

  Future<void> _initTts() async {
    await _tts.setLanguage('en-US');
    await _tts.setSpeechRate(0.45);
  }

  Future<void> _fetchAiTip() async {
    setState(() {
      _loadingTip = true;
      _aiTip = null;
    });
    final pantry = context.read<PantryProvider>();
    final recipes = context.read<RecipeProvider>();
    final auth = context.read<AuthProvider>();
    final ctx = PantryContextBuilder.build(
      pantryItems: pantry.activeItems,
      recipes: recipes.recipes,
      budgetMode: recipes.budgetMode,
      cuisinePreference:
          auth.profile?.preferences.cuisinePreference ?? 'Punjabi',
      diet: auth.profile?.preferences.diet ?? 'None',
    );
    final tip = await context.read<AiChefProvider>().getStepGuidance(
          recipe: widget.recipe,
          stepIndex: _stepIndex,
          context: ctx,
        );
    if (mounted) {
      setState(() {
        _aiTip = tip;
        _loadingTip = false;
      });
    }
  }

  Future<void> _speakStep() async {
    if (!_ttsEnabled) return;
    await _tts.speak(
      'Step ${_stepIndex + 1}. ${widget.recipe.steps[_stepIndex]}',
    );
  }

  @override
  void dispose() {
    _tts.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final steps = widget.recipe.steps;
    final step = steps[_stepIndex];

    return Scaffold(
      backgroundColor: C.dark1,
      appBar: AppBar(
        title: Text('Cooking Mode', style: T.head(16)),
        actions: [
          IconButton(
            icon: _loadingTip
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.psychology, color: C.v400),
            onPressed: _loadingTip ? null : _fetchAiTip,
          ),
          IconButton(
            icon: Icon(
              _ttsEnabled ? Icons.volume_up : Icons.volume_off,
              color: _ttsEnabled ? C.g400 : C.white40,
            ),
            onPressed: () {
              setState(() => _ttsEnabled = !_ttsEnabled);
              if (_ttsEnabled) _speakStep();
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Text(widget.recipe.name, style: T.head(20)),
            const SizedBox(height: 8),
            Text(
              'Step ${_stepIndex + 1} of ${steps.length}',
              style: T.lbl(c: C.g400),
            ),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: (_stepIndex + 1) / steps.length,
              backgroundColor: C.white10,
              color: C.g500,
            ),
            const SizedBox(height: 32),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(24),
                      decoration: D.glow(C.g500, r: 24),
                      child: Text(step, style: T.body(18, c: C.white)),
                    ),
                    if (_aiTip != null) ...[
                      const SizedBox(height: 16),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: D.glow(C.v500, r: 16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('AI TIP', style: T.lbl(c: C.v400)),
                            const SizedBox(height: 8),
                            Text(_aiTip!, style: T.body(14)),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _stepIndex > 0
                        ? () => setState(() {
                              _stepIndex--;
                              _aiTip = null;
                              if (_ttsEnabled) _speakStep();
                            })
                        : null,
                    child: const Text('Previous'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _stepIndex < steps.length - 1
                        ? () => setState(() {
                              _stepIndex++;
                              _aiTip = null;
                              if (_ttsEnabled) _speakStep();
                            })
                        : () => Navigator.pop(context),
                    child: Text(
                      _stepIndex < steps.length - 1 ? 'Next Step' : 'Done!',
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
