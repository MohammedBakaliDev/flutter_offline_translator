import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_offline_translator/flutter_offline_translator.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final _offlineTranslator = FlutterOfflineTranslator();
  final TextEditingController _textController = TextEditingController();

  String _translatedText = 'Translation will appear here';
  List<String> _availableLanguages = [];
  String _selectedSourceLang = 'en';
  String _selectedTargetLang = 'es';
  bool _isLoading = false;
  String? _errorMessage;
  final Map<String, bool> _downloadedLanguages = {};

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    setState(() => _isLoading = true);
    try {
      await _loadLanguages();
      await _updateDownloadedLanguages();
    } catch (e) {
      setState(() => _errorMessage = 'Failed to initialize: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _loadLanguages() async {
    final languages = await _offlineTranslator.getAvailableLanguages();
    setState(() {
      _availableLanguages = languages;
      if (!languages.contains(_selectedSourceLang)) {
        _selectedSourceLang = languages.first;
      }
      if (!languages.contains(_selectedTargetLang)) {
        _selectedTargetLang = languages.last;
      }
    });
  }

  Future<void> _updateDownloadedLanguages() async {
    for (final lang in _availableLanguages) {
      try {
        final isDownloaded =
            await _offlineTranslator.isLanguageDownloaded(lang);
        setState(() {
          _downloadedLanguages[lang] = isDownloaded;
        });
      } catch (e) {
        debugPrint('Error checking language $lang: $e');
      }
    }
  }

  Future<void> _downloadLanguage(String language) async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      var a = await _offlineTranslator.downloadLanguageModel(language);
      await _updateDownloadedLanguages();
    } catch (e) {
      setState(() => _errorMessage = 'Failed to download language: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _deleteLanguage(String language) async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await _offlineTranslator.deleteLanguageModel(language);
      await _updateDownloadedLanguages();
    } catch (e) {
      setState(() => _errorMessage = 'Failed to delete language: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _translateText() async {
    if (_textController.text.isEmpty) {
      setState(() => _errorMessage = 'Please enter text to translate');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Check if languages are downloaded
      if (!(_downloadedLanguages[_selectedSourceLang] ?? false)) {
        await _downloadLanguage(_selectedSourceLang);
      }
      if (!(_downloadedLanguages[_selectedTargetLang] ?? false)) {
        await _downloadLanguage(_selectedTargetLang);
      }

      final translation = await _offlineTranslator.translate(
        _textController.text,
        _selectedSourceLang,
        _selectedTargetLang,
      );
      setState(() => _translatedText = translation);
    } catch (e) {
      setState(() => _errorMessage = 'Translation failed: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.blue,
        appBarTheme: const AppBarTheme(
          centerTitle: true,
          elevation: 0,
        ),
      ),
      home: Scaffold(
        appBar: AppBar(
          title: const Text(
            'Offline Translator',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: _isLoading ? null : _initializeApp,
              tooltip: 'Refresh languages',
            ),
          ],
        ),
        body: _isLoading
            ? const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text('Loading...'),
                  ],
                ),
              )
            : SafeArea(
                child: CustomScrollView(
                  slivers: [
                    SliverPadding(
                      padding: const EdgeInsets.all(16.0),
                      sliver: SliverList(
                        delegate: SliverChildListDelegate([
                          if (_errorMessage != null)
                            Container(
                              margin: const EdgeInsets.only(bottom: 16),
                              child: Material(
                                elevation: 1,
                                borderRadius: BorderRadius.circular(8),
                                color: Colors.red.shade50,
                                child: Padding(
                                  padding: const EdgeInsets.all(12.0),
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.error_outline,
                                        color: Colors.red.shade700,
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: SelectableText(
                                          _errorMessage!,
                                          style: TextStyle(
                                            color: Colors.red.shade700,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          _buildTranslatorCard(),
                          const SizedBox(height: 16),
                          _buildTranslationOutput(),
                          const SizedBox(height: 16),
                          _buildLanguageModelsSection(),
                        ]),
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildTranslatorCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildLanguageSelectors(),
            const SizedBox(height: 16),
            _buildInputField(),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _isLoading ? null : _translateText,
              icon: const Icon(Icons.translate),
              label: Text(_isLoading ? 'Translating...' : 'Translate'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.all(16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLanguageSelectors() {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Theme.of(context)
            .colorScheme
            .surfaceContainerHighest
            .withOpacity(0.3),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildLanguageDropdown(
              value: _selectedSourceLang,
              hint: 'From',
              onChanged: (value) {
                if (value != null) {
                  setState(() => _selectedSourceLang = value);
                }
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Icon(
              Icons.arrow_forward,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          Expanded(
            child: _buildLanguageDropdown(
              value: _selectedTargetLang,
              hint: 'To',
              onChanged: (value) {
                if (value != null) {
                  setState(() => _selectedTargetLang = value);
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLanguageDropdown({
    required String value,
    required String hint,
    required void Function(String?) onChanged,
  }) {
    return DropdownButtonHideUnderline(
      child: DropdownButton<String>(
        value: value,
        isExpanded: true,
        hint: Text(hint),
        items: _availableLanguages.map((lang) {
          final isDownloaded = _downloadedLanguages[lang] ?? false;
          return DropdownMenuItem(
            value: lang,
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    lang,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (isDownloaded)
                  Icon(
                    Icons.check_circle,
                    color: Theme.of(context).colorScheme.primary,
                    size: 16,
                  ),
              ],
            ),
          );
        }).toList(),
        onChanged: onChanged,
      ),
    );
  }

  Widget _buildInputField() {
    return TextField(
      controller: _textController,
      decoration: InputDecoration(
        labelText: 'Enter text to translate',
        alignLabelWithHint: true,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        filled: true,
      ),
      maxLines: 3,
    );
  }

  Widget _buildTranslationOutput() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.text_fields),
                const SizedBox(width: 8),
                Text(
                  'Translation',
                  style: Theme.of(context).textTheme.titleMedium!.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const Divider(),
            Text(
              _translatedText,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLanguageModelsSection() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ExpansionTile(
        title: const Row(
          children: [
            Icon(Icons.language),
            SizedBox(width: 8),
            Text('Language Models'),
          ],
        ),
        children: [
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _availableLanguages.length,
            itemBuilder: (context, index) {
              final lang = _availableLanguages[index];
              final isDownloaded = _downloadedLanguages[lang] ?? false;
              return ListTile(
                title: Text(lang),
                trailing: isDownloaded
                    ? FilledButton.tonalIcon(
                        icon: const Icon(Icons.delete_outline),
                        label: const Text('Delete'),
                        onPressed: () => _deleteLanguage(lang),
                      )
                    : FilledButton.icon(
                        icon: const Icon(Icons.download),
                        label: const Text('Download'),
                        onPressed: () => _downloadLanguage(lang),
                      ),
              );
            },
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }
}
