import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

import '../core/constants.dart';
import '../core/theme.dart';
import '../models/recipe.dart';
import '../providers/recipe_provider.dart';
import '../services/storage_service.dart';

class AddRecipeScreen extends StatefulWidget {
  const AddRecipeScreen({super.key});

  @override
  State<AddRecipeScreen> createState() => _AddRecipeScreenState();
}

class _AddRecipeScreenState extends State<AddRecipeScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _desc = TextEditingController();
  final _cookTime = TextEditingController(text: '30');
  final _servings = TextEditingController(text: '4');
  final _ingredients = TextEditingController();
  final _steps = TextEditingController();
  final _cost = TextEditingController(text: '300');

  String _difficulty = 'Easy';
  String _cuisine = 'Punjabi';
  bool _isBudgetFriendly = false;
  bool _isLeftoverRecipe = false;

  File? _image;
  bool _uploading = false;
  final ImagePicker _picker = ImagePicker();
  final StorageService _storageService = StorageService();

  @override
  void dispose() {
    _name.dispose();
    _desc.dispose();
    _cookTime.dispose();
    _servings.dispose();
    _ingredients.dispose();
    _steps.dispose();
    _cost.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final picked = await _picker.pickImage(
        source: source,
        maxWidth: 1024,
        imageQuality: 85,
      );
      if (picked != null) {
        setState(() => _image = File(picked.path));
      }
    } catch (e) {
      debugPrint('Error picking image: $e');
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _uploading = true);

    try {
      final recipeId = 'recipe_${const Uuid().v4()}';
      String imageUrl = 'https://images.unsplash.com/photo-1546069901-ba9599a7e63c?w=800'; // Default placeholder

      // Upload to Firebase Storage if image selected
      if (_image != null) {
        final uploadedUrl = await _storageService.uploadRecipeImage(recipeId, _image!);
        if (uploadedUrl != null) {
          imageUrl = uploadedUrl;
        }
      }

      // Parse ingredients (comma separated or lines)
      final ingList = _ingredients.text
          .split(RegExp(r'[,\n]'))
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList();

      // Parse steps (lines)
      final stepList = _steps.text
          .split('\n')
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList();

      final newRecipe = Recipe(
        id: recipeId,
        name: _name.text.trim(),
        description: _desc.text.trim(),
        imageUrl: imageUrl,
        cookingTime: int.tryParse(_cookTime.text) ?? 30,
        servings: int.tryParse(_servings.text) ?? 4,
        difficulty: _difficulty,
        cuisineType: _cuisine,
        ingredients: ingList,
        steps: stepList,
        isBudgetFriendly: _isBudgetFriendly,
        isLeftoverRecipe: _isLeftoverRecipe,
        estimatedCost: double.tryParse(_cost.text) ?? 0,
      );

      if (mounted) {
        await context.read<RecipeProvider>().addCustomRecipe(newRecipe);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Custom recipe shared successfully!')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to share recipe: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _uploading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: C.dark2,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('SHARE RECIPE', style: T.lbl(c: C.g400)),
            Text('Add Custom Recipe', style: T.head(17)),
          ],
        ),
      ),
      body: _uploading
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: C.g500),
                  SizedBox(height: 16),
                  Text('Uploading recipe details & image to Firebase...', style: TextStyle(color: C.white70)),
                ],
              ),
            )
          : Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  GestureDetector(
                    onTap: () => _showImageSourceSheet(),
                    child: Container(
                      height: 180,
                      decoration: BoxDecoration(
                        color: C.card,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: C.white10),
                      ),
                      child: _image != null
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(20),
                              child: Image.file(_image!, fit: BoxFit.cover, width: double.infinity),
                            )
                          : Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.add_photo_alternate, size: 44, color: C.g400),
                                const SizedBox(height: 8),
                                Text('Add Recipe Image', style: T.sub(14)),
                                Text('Upload to Firebase Storage', style: T.body(11, c: C.white40)),
                              ],
                            ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: _name,
                    style: T.body(15, c: C.white),
                    decoration: const InputDecoration(labelText: 'Recipe Name (e.g. Peshawari Sajji)'),
                    validator: (v) => v == null || v.trim().isEmpty ? 'Name required' : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _desc,
                    style: T.body(15, c: C.white),
                    maxLines: 2,
                    decoration: const InputDecoration(labelText: 'Description'),
                    validator: (v) => v == null || v.trim().isEmpty ? 'Description required' : null,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _cookTime,
                          style: T.body(15, c: C.white),
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(labelText: 'Cook Time (min)'),
                          validator: (v) => int.tryParse(v ?? '') == null ? 'Enter number' : null,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextFormField(
                          controller: _servings,
                          style: T.body(15, c: C.white),
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(labelText: 'Servings'),
                          validator: (v) => int.tryParse(v ?? '') == null ? 'Enter number' : null,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          value: _difficulty,
                          dropdownColor: C.card,
                          decoration: const InputDecoration(labelText: 'Difficulty'),
                          items: ['Easy', 'Medium', 'Hard']
                              .map((d) => DropdownMenuItem(value: d, child: Text(d)))
                              .toList(),
                          onChanged: (v) => setState(() => _difficulty = v ?? 'Easy'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          value: _cuisine,
                          dropdownColor: C.card,
                          decoration: const InputDecoration(labelText: 'Cuisine'),
                          items: ['Punjabi', 'Sindhi', 'Balochi', 'Kashmiri', 'Desi snacks']
                              .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                              .toList(),
                          onChanged: (v) => setState(() => _cuisine = v ?? 'Punjabi'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _cost,
                    style: T.body(15, c: C.white),
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Estimated Cost (Rs.)'),
                    validator: (v) => double.tryParse(v ?? '') == null ? 'Enter cost' : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _ingredients,
                    style: T.body(15, c: C.white),
                    maxLines: 4,
                    decoration: const InputDecoration(
                      labelText: 'Ingredients',
                      hintText: 'Enter ingredients separated by commas or newlines (e.g. Chicken, Rice, Onion)',
                    ),
                    validator: (v) => v == null || v.trim().isEmpty ? 'Ingredients required' : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _steps,
                    style: T.body(15, c: C.white),
                    maxLines: 5,
                    decoration: const InputDecoration(
                      labelText: 'Steps',
                      hintText: 'Enter each step on a new line',
                    ),
                    validator: (v) => v == null || v.trim().isEmpty ? 'Steps required' : null,
                  ),
                  const SizedBox(height: 16),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text('Budget Friendly / Hostel Style', style: T.sub(14)),
                    subtitle: Text('Affordable and student friendly recipe', style: T.body(11, c: C.white40)),
                    value: _isBudgetFriendly,
                    activeThumbColor: C.g500,
                    onChanged: (v) => setState(() => _isBudgetFriendly = v),
                  ),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text('Leftover Recipe', style: T.sub(14)),
                    subtitle: Text('Made primarily from leftover foods/meals', style: T.body(11, c: C.white40)),
                    value: _isLeftoverRecipe,
                    activeThumbColor: C.g500,
                    onChanged: (v) => setState(() => _isLeftoverRecipe = v),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _submit,
                      child: const Text('Share Recipe to Cloud'),
                    ),
                  ),
                  const SizedBox(height: 30),
                ],
              ),
            ),
    );
  }

  void _showImageSourceSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: C.dark3,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt, color: C.g400),
              title: const Text('Take Photo'),
              onTap: () {
                Navigator.pop(ctx);
                _pickImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library, color: C.g400),
              title: const Text('Choose from Gallery'),
              onTap: () {
                Navigator.pop(ctx);
                _pickImage(ImageSource.gallery);
              },
            ),
          ],
        ),
      ),
    );
  }
}
