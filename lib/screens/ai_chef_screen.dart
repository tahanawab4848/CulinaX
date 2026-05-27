import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../ai_services/pantry_context_builder.dart';
import '../models/pantry_context.dart';
import '../core/theme.dart';
import '../providers/ai_chef_provider.dart';
import '../providers/auth_provider.dart';
import '../providers/pantry_provider.dart';
import '../providers/recipe_provider.dart';
import 'ai_recipe_generator_screen.dart';

class AiChefScreen extends StatefulWidget {
  const AiChefScreen({super.key});

  @override
  State<AiChefScreen> createState() => _AiChefScreenState();
}

class _AiChefScreenState extends State<AiChefScreen> {
  final _input = TextEditingController();
  final _scroll = ScrollController();

  @override
  void dispose() {
    _input.dispose();
    _scroll.dispose();
    super.dispose();
  }

  PantryContext _buildContext() {
    final pantry = context.read<PantryProvider>();
    final recipes = context.read<RecipeProvider>();
    final auth = context.read<AuthProvider>();
    recipes.rankForPantry(pantry.activeItems);
    return PantryContextBuilder.build(
      pantryItems: pantry.activeItems,
      recipes: recipes.recipes,
      budgetMode: recipes.budgetMode,
      cuisinePreference:
          auth.profile?.preferences.cuisinePreference ?? 'Punjabi',
      diet: auth.profile?.preferences.diet ?? 'None',
    );
  }

  void _send() {
    final text = _input.text.trim();
    if (text.isEmpty) return;
    final ctx = _buildContext();
    final uid = context.read<AuthProvider>().userId;
    context.read<AiChefProvider>().sendMessage(text, ctx, userId: uid);
    _input.clear();
    _scrollToEnd();
  }

  void _scrollToEnd() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scroll.hasClients) {
        _scroll.animateTo(
          _scroll.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final chef = context.watch<AiChefProvider>();

    return Scaffold(
      backgroundColor: C.dark2,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('AI CHEF', style: T.lbl(c: C.v400)),
            Text('Hybrid Assistant', style: T.head(17)),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.restaurant_menu),
            tooltip: 'Generate recipe',
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const AiRecipeGeneratorScreen()),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: () => context.read<AiChefProvider>().clearChat(),
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [C.v600.withValues(alpha: 0.2), C.dark3],
              ),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: C.v500.withValues(alpha: 0.3)),
            ),
            child: Row(
              children: [
                Icon(
                  chef.apiConfigured ? Icons.psychology : Icons.warning_amber,
                  color: chef.apiConfigured ? C.v400 : C.a500,
                  size: 20,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    chef.apiConfigured
                        ? 'Generative AI + rule-based pantry data'
                        : 'Add API key in Profile → AI Settings',
                    style: T.body(12, c: C.white70),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              controller: _scroll,
              padding: const EdgeInsets.all(16),
              itemCount: chef.messages.length + (chef.loading ? 1 : 0),
              itemBuilder: (ctx, i) {
                if (chef.loading && i == chef.messages.length) {
                  return const Padding(
                    padding: EdgeInsets.all(12),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2, color: C.v400),
                        ),
                        SizedBox(width: 12),
                        Text('AI Chef is thinking…', style: TextStyle(color: C.white40)),
                      ],
                    ),
                  );
                }
                final m = chef.messages[i];
                return _Bubble(message: m);
              },
            ),
          ),
          _QuickChips(onTap: (t) {
            _input.text = t;
            _send();
          }),
          Padding(
            padding: EdgeInsets.fromLTRB(
              16,
              8,
              16,
              MediaQuery.of(context).padding.bottom + 12,
            ),
            child: TextField(
              controller: _input,
              enabled: !chef.loading,
              style: T.body(15, c: C.white),
              decoration: InputDecoration(
                hintText: 'Ask in English or Urdu…',
                suffixIcon: IconButton(
                  icon: const Icon(Icons.send_rounded, color: C.v500),
                  onPressed: chef.loading ? null : _send,
                ),
              ),
              onSubmitted: (_) => _send(),
            ),
          ),
        ],
      ),
    );
  }
}

class _Bubble extends StatelessWidget {
  final AiChatMessage message;
  const _Bubble({required this.message});

  @override
  Widget build(BuildContext context) {
    final isUser = message.isUser;
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.85,
        ),
        decoration: BoxDecoration(
          color: message.isError
              ? C.r500.withValues(alpha: 0.15)
              : isUser
                  ? C.v600
                  : C.card,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: message.isError
                ? C.r400.withValues(alpha: 0.4)
                : isUser
                    ? C.v500.withValues(alpha: 0.3)
                    : C.white10,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!isUser)
              Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.auto_awesome, size: 14, color: C.v400),
                    const SizedBox(width: 6),
                    Text('AI Chef', style: T.lbl(c: C.v400).copyWith(fontSize: 9)),
                  ],
                ),
              ),
            Text(message.text, style: T.body(14, c: C.white)),
          ],
        ),
      ),
    );
  }
}

class _QuickChips extends StatelessWidget {
  final ValueChanged<String> onTap;
  const _QuickChips({required this.onTap});

  @override
  Widget build(BuildContext context) {
    const chips = [
      'What can I cook with eggs and potatoes?',
      'Suggest cheap hostel dinner',
      'Cook before milk expires?',
      'Recommend Eid breakfast',
      'Chai time snack ideas',
    ];
    return SizedBox(
      height: 40,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        children: chips
            .map(
              (c) => Padding(
                padding: const EdgeInsets.only(right: 8),
                child: ActionChip(
                  label: Text(c, style: T.sub(10)),
                  backgroundColor: C.card2,
                  onPressed: () => onTap(c),
                ),
              ),
            )
            .toList(),
      ),
    );
  }
}
