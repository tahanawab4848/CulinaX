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
  final _groqKey = TextEditingController();
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
    final gr = await AiConfig.getGroqKey();
    if (g != null) _geminiKey.text = g;
    if (o != null) _openAiKey.text = o;
    if (gr != null) _groqKey.text = gr;
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _geminiKey.dispose();
    _openAiKey.dispose();
    _groqKey.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final aiChefProvider = context.read<AiChefProvider>();
    final messenger = ScaffoldMessenger.of(context);

    if (_geminiKey.text.trim().isNotEmpty) {
      await AiConfig.saveGeminiKey(_geminiKey.text);
    }
    if (_openAiKey.text.trim().isNotEmpty) {
      await AiConfig.saveOpenAiKey(_openAiKey.text);
    }
    if (_groqKey.text.trim().isNotEmpty) {
      await AiConfig.saveGroqKey(_groqKey.text);
    }
    await AiConfig.setProviderType(_provider);

    await aiChefProvider.refreshApiStatus();
    messenger.showSnackBar(
      const SnackBar(content: Text('AI settings saved successfully')),
    );
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
                  'Rule-based local pantry scoring blended with high-intelligence LLMs for chat, recipes, substitutes, and vision scanning.',
                  style: T.body(13, c: C.white70),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Text('ACTIVE AI PROVIDER', style: T.lbl()),
          const SizedBox(height: 8),
          RadioListTile<AiProviderType>(
            title: Text('Groq (Extremely Fast & Truly Free)', style: T.sub(14)),
            subtitle: Text('Highly recommended. 14,400 free daily calls. Zero rate limits.', style: T.body(11, c: C.white40)),
            value: AiProviderType.groq,
            groupValue: _provider,
            activeColor: C.v500,
            onChanged: (v) => setState(() => _provider = v!),
          ),
          RadioListTile<AiProviderType>(
            title: Text('Google Gemini', style: T.sub(14)),
            subtitle: Text('Default provider. Uses gemini-1.5-flash.', style: T.body(11, c: C.white40)),
            value: AiProviderType.gemini,
            groupValue: _provider,
            activeColor: C.v500,
            onChanged: (v) => setState(() => _provider = v!),
          ),
          RadioListTile<AiProviderType>(
            title: Text('OpenAI GPT-4o-mini', style: T.sub(14)),
            subtitle: Text('Requires a paid OpenAI platform API key.', style: T.body(11, c: C.white40)),
            value: AiProviderType.openai,
            groupValue: _provider,
            activeColor: C.v500,
            onChanged: (v) => setState(() => _provider = v!),
          ),
          const SizedBox(height: 24),
          Text('PROVIDER CREDENTIALS', style: T.lbl()),
          const SizedBox(height: 12),
          if (_provider == AiProviderType.groq) ...[
            TextField(
              controller: _groqKey,
              obscureText: _obscure,
              style: T.body(14, c: C.white),
              decoration: InputDecoration(
                labelText: 'Groq API Key',
                hintText: 'gsk_...',
                suffixIcon: IconButton(
                  icon: Icon(_obscure ? Icons.visibility : Icons.visibility_off),
                  onPressed: () => setState(() => _obscure = !_obscure),
                ),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Get a free Groq key instantly: console.groq.com\n'
              'Or run: flutter run --dart-define=GROQ_API_KEY=your_key',
              style: T.body(11, c: C.white40),
            ),
          ] else if (_provider == AiProviderType.gemini) ...[
            TextField(
              controller: _geminiKey,
              obscureText: _obscure,
              style: T.body(14, c: C.white),
              decoration: InputDecoration(
                labelText: 'Gemini API Key',
                hintText: 'AIzaSy...',
                suffixIcon: IconButton(
                  icon: Icon(_obscure ? Icons.visibility : Icons.visibility_off),
                  onPressed: () => setState(() => _obscure = !_obscure),
                ),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Get a free Gemini key: aistudio.google.com/apikey\n'
              'Or run: flutter run --dart-define=GEMINI_API_KEY=your_key',
              style: T.body(11, c: C.white40),
            ),
          ] else if (_provider == AiProviderType.openai) ...[
            TextField(
              controller: _openAiKey,
              obscureText: _obscure,
              style: T.body(14, c: C.white),
              decoration: InputDecoration(
                labelText: 'OpenAI API Key',
                hintText: 'sk-proj-...',
                suffixIcon: IconButton(
                  icon: Icon(_obscure ? Icons.visibility : Icons.visibility_off),
                  onPressed: () => setState(() => _obscure = !_obscure),
                ),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Get an OpenAI platform key: platform.openai.com\n'
              'Or run: flutter run --dart-define=OPENAI_API_KEY=your_key',
              style: T.body(11, c: C.white40),
            ),
          ],
          const SizedBox(height: 32),
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
