# CulinaX — Hybrid Architecture

**Flutter + Firebase + Generative AI (Gemini/OpenAI)**

Pakistani cooking assistant combining **deterministic rule-based pantry logic** with **generative AI intelligence**.

## Hybrid Flow

```
STEP 1 — Rule Engine (deterministic)
  ├── Pantry inventory & expiry
  ├── Ingredient matching & scores
  ├── Grocery list generation
  └── Meal scheduling

STEP 2 — AI Layer (generative)
  ├── AI Chef chatbot
  ├── Recipe generation
  ├── Recommendation explanations
  ├── Ingredient substitutions
  ├── Cooking guidance
  └── Meal suggestions
```

## AI Features

| Feature | Layer |
|---------|--------|
| Pantry CRUD, expiry alerts | Rule-based |
| Recipe % match ranking | Rule-based |
| Auto grocery list | Rule-based |
| **AI Chef chat** | Gemini / OpenAI |
| **AI recipe generator** | Gemini / OpenAI |
| **Why recommended?** | Hybrid |
| **AI substitutions** | Generative |
| **Step-by-step AI tips** | Generative + TTS |
| Barcode / image scan | On-device |

## Setup

### 1. Firebase
```bash
flutterfire configure
```
Enable Auth (Email), Firestore, Storage.

### 2. AI API Key
**Profile → AI Settings** or:
```bash
flutter run --dart-define=GEMINI_API_KEY=your_key_here
```
Get Gemini key: https://aistudio.google.com/apikey

### 3. Run
```bash
flutter pub get
flutter run
```

## Project Structure

```
lib/
├── ai_services/          # Gemini, OpenAI, AiChef, Hybrid
├── repositories/         # ai_repository (Firestore history)
├── services/             # recipe_engine, firestore (rules)
├── providers/
├── models/
├── screens/
│   ├── ai_chef_screen.dart
│   ├── ai_recipe_generator_screen.dart
│   └── ai_settings_screen.dart
└── widgets/
    ├── ai_explanation_card.dart
    └── ai_recipe_card.dart
```

## Firestore Collections

- `users`, `pantry_items`, `recipes`, `grocery_list`, `meal_plans`
- `ai_interactions` — chat & generation history

## FYP Demo Script

1. Login → add pantry (Chicken, Rice, Milk with expiry)
2. **Home** — see hybrid AI Smart Picks with explanations
3. **AI Chef** — ask "What can I cook with eggs and potatoes?"
4. **AI Recipe Generator** — create hostel dinner from pantry
5. **Recipe detail** — "AI: Why this recipe?" + substitution button
6. **Cooking mode** — AI tip per step + TTS

## Tech Stack

- Flutter, Provider, Firebase
- `google_generative_ai` (Gemini)
- `http` (OpenAI fallback)
- Rule engine unchanged in `services/recipe_engine.dart`
