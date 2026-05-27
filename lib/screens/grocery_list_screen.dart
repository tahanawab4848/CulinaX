import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/theme.dart';
import '../providers/grocery_provider.dart';
import '../providers/pantry_provider.dart';
import '../providers/recipe_provider.dart';
import 'barcode_scanner_screen.dart';

class GroceryListScreen extends StatelessWidget {
  const GroceryListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final grocery = context.watch<GroceryProvider>();
    final items = grocery.items;

    return Scaffold(
      backgroundColor: C.dark2,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('GROCERY', style: T.lbl(c: C.a400)),
            Text('Smart List', style: T.head(18)),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Scan barcode',
            icon: const Icon(Icons.qr_code_scanner),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const BarcodeScannerScreen()),
            ),
          ),
          IconButton(
            tooltip: 'Auto-generate from top recipes',
            icon: const Icon(Icons.auto_awesome),
            onPressed: () async {
              final recipes = context.read<RecipeProvider>();
              final pantry = context.read<PantryProvider>();
              recipes.rankForPantry(pantry.activeItems);
              final top = recipes.rankedMatches
                  .take(3)
                  .map((m) => m.recipe)
                  .toList();
              await grocery.generateFromRecipes(top, pantry.activeItems);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Grocery list generated from missing ingredients')),
                );
              }
            },
          ),
        ],
      ),
      body: items.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('🛒', style: TextStyle(fontSize: 56)),
                  const SizedBox(height: 12),
                  Text('No grocery items', style: T.head(18)),
                  Text('Tap ✨ to auto-generate', style: T.body(13, c: C.white40)),
                ],
              ),
            )
          : Column(
              children: [
                if (items.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: LinearProgressIndicator(
                      value: items.isEmpty
                          ? 0
                          : grocery.checkedCount / items.length,
                      backgroundColor: C.white10,
                      color: C.g500,
                    ),
                  ),
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    itemCount: items.length,
                    itemBuilder: (ctx, i) {
                      final item = items[i];
                      return CheckboxListTile(
                        value: item.checked,
                        onChanged: (_) => grocery.toggleItem(i),
                        title: Text(
                          item.name,
                          style: T.body(15, c: item.checked ? C.white40 : C.white).copyWith(
                            decoration: item.checked
                                ? TextDecoration.lineThrough
                                : null,
                          ),
                        ),
                        secondary: IconButton(
                          icon: const Icon(Icons.delete_outline, color: C.r400),
                          onPressed: () => grocery.removeItem(i),
                        ),
                        activeColor: C.g500,
                        checkColor: C.white,
                        tileColor: C.card,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _addItemDialog(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _addItemDialog(BuildContext context) {
    final ctrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: C.dark3,
        title: Text('Add Item', style: T.head(18)),
        content: TextField(
          controller: ctrl,
          style: T.body(15, c: C.white),
          decoration: const InputDecoration(hintText: 'Ingredient name'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (ctrl.text.trim().isNotEmpty) {
                await context.read<GroceryProvider>().addItem(ctrl.text.trim());
              }
              if (ctx.mounted) Navigator.pop(ctx);
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }
}
