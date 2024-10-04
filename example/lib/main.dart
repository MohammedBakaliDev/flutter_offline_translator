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
  String _translatedText = 'Translation will appear here';
  List<String> _availableLanguages = [];
  final TextEditingController _textController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadLanguages();
  }

  Future<void> _loadLanguages() async {
    final languages = await _offlineTranslator.getAvailableLanguages();
    setState(() {
      _availableLanguages = languages;
    });
  }

  Future<void> _translateText() async {
    if (_textController.text.isNotEmpty) {
      final translation = await _offlineTranslator.translate(
        _textController.text,
        'en', // Assuming source language is English
        'ar', // Assuming target language is Spanish
      );
      setState(() {
        _translatedText = translation;
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
              TextField(
                controller: _textController,
                decoration:
                    const InputDecoration(labelText: 'Enter text to translate'),
              ),
              ElevatedButton(
                onPressed: _translateText,
                child: const Text('Translate'),
              ),
              const SizedBox(height: 20),
              Text('Translated Text: $_translatedText'),
              const SizedBox(height: 20),
              Text('Available Languages: ${_availableLanguages.join(", ")}'),
            ],
          ),
        ),
      ),
    );
  }
}
