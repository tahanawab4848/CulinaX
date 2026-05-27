import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/ai_config.dart';
import '../core/theme.dart';
import '../providers/ai_chef_provider.dart';

class AiSettingsScreen extends StatefulWidget {
  const AiSettingsScreen({super.key});

  @override
  State<AiSettingsScreen> createState() => _AiSettingsScreenState();
}

class _AiSettingsScreenState extends State<AiSettingsScreen> {
  final _geminiKey = TextEditingController();
  final _openAiKey = TextEditingController();
  AiProviderType _provider = AiProviderType.gemini;
  bool _obscure = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    _provider = await AiConfig.getProviderType();
    final g = await AiConfig.getGeminiKey();
    final o = await AiConfig.getOpenAiKey();
    if (g != null) _geminiKey.text = g;
    if (o != null) _openAiKey.text = o;
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _geminiKey.dispose();
    _openAiKey.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_geminiKey.text.trim().isNotEmpty) {
      await AiConfig.saveGeminiKey(_geminiKey.text);
    }
    if (_openAiKey.text.trim().isNotEmpty) {
      await AiConfig.saveOpenAiKey(_openAiKey.text);
    }
    await AiConfig.setProviderType(_provider);
    if (mounted) {
      await context.read<AiChefProvider>().refreshApiStatus();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('AI settings saved')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: C.dark2,
      appBar: AppBar(title: Text('AI Settings', style: T.head(18))),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: D.glow(C.v500, r: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Hybrid Architecture', style: T.head(16)),
                const SizedBox(height: 8),
                Text(
                  'Pantry scoring stays rule-based. Gemini/OpenAI powers chat, recipes, and explanations.',
                  style: T.body(13, c: C.white70),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Text('AI PROVIDER', style: T.lbl()),
          RadioListTile<AiProviderType>(
            title: Text('Google Gemini (recommended)', style: T.sub(14)),
            value: AiProviderType.gemini,
            groupValue: _provider,
            activeColor: C.v500,
            onChanged: (v) => setState(() => _provider = v!),
          ),
          RadioListTile<AiProviderType>(
            title: Text('OpenAI GPT-4o-mini', style: T.sub(14)),
            value: AiProviderType.openai,
            groupValue: _provider,
            activeColor: C.v500,
            onChanged: (v) => setState(() => _provider = v!),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _geminiKey,
            obscureText: _obscure,
            style: T.body(14, c: C.white),
            decoration: InputDecoration(
              labelText: 'Gemini API Key',
              suffixIcon: IconButton(
                icon: Icon(_obscure ? Icons.visibility : Icons.visibility_off),
                onPressed: () => setState(() => _obscure = !_obscure),
              ),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _openAiKey,
            obscureText: _obscure,
            style: T.body(14, c: C.white),
            decoration: const InputDecoration(labelText: 'OpenAI API Key (optional)'),
          ),
          const SizedBox(height: 8),
          Text(
            'Get Gemini key: aistudio.google.com/apikey\n'
            'Or run: flutter run --dart-define=GEMINI_API_KEY=your_key',
            style: T.body(11, c: C.white40),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _save,
              style: ElevatedButton.styleFrom(backgroundColor: C.v600),
              child: const Text('Save AI Settings'),
            ),
          ),
        ],
      ),
    );
  }
}
