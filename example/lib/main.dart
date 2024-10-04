import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_offline_translator/flutter_offline_translator.dart';

void main() {
  runApp(const MyApp());
}

/// The main widget of the application.
class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  // Instance of FlutterOfflineTranslator to handle translation tasks.
  final _offlineTranslator = FlutterOfflineTranslator();

  // Holds the translated text to display.
  String _translatedText = 'Translation will appear here';

  // List of available languages for translation.
  List<String> _availableLanguages = [];

  // Controller for managing text input in the TextField.
  final TextEditingController _textController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadLanguages(); // Load the available languages when the app starts.
  }

  /// Loads the available languages for translation from the offline translator.
  Future<void> _loadLanguages() async {
    final languages = await _offlineTranslator.getAvailableLanguages();
    setState(() {
      _availableLanguages = languages;
    });
  }

  /// Translates the text entered by the user.
  Future<void> _translateText() async {
    if (_textController.text.isNotEmpty) {
      final translation = await _offlineTranslator.translate(
        _textController.text,
        'en', // Assuming source language is English
        'ar', // Assuming target language is Arabic
      );
      setState(() {
        _translatedText = translation; // Update the translated text.
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('Flutter Offline Translator Example')),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // TextField for user to input text for translation.
              TextField(
                controller: _textController,
                decoration:
                    const InputDecoration(labelText: 'Enter text to translate'),
              ),
              // Button to trigger the translation.
              ElevatedButton(
                onPressed: _translateText,
                child: const Text('Translate'),
              ),
              const SizedBox(height: 20),
              // Display the translated text.
              Text('Translated Text: $_translatedText'),
              const SizedBox(height: 20),
              // Display the available languages.
              Text('Available Languages: ${_availableLanguages.join(", ")}'),
            ],
          ),
        ),
      ),
    );
  }
}
