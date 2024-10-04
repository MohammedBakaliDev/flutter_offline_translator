# 🌐 Offline Translator Flutter Plugin

![Flutter Version](https://img.shields.io/badge/Flutter-%3E%3D2.0.0-blue.svg)
![Platform](https://img.shields.io/badge/Platform-iOS%20%7C%20Android-lightgrey.svg)

Translate text offline with ease! This Flutter plugin brings the power of ML Kit to your app for seamless language translation, even without an internet connection.

## ✨ Features

- 🔌 **Offline Translation**: No internet? No problem!
- 🌍 **Multiple Languages**: Supports a wide range of languages
- 📱 **Cross-Platform**: Works on both iOS and Android
- 🚀 **Easy Integration**: Simple API for quick implementation

## 🚀 Getting Started

### Prerequisites

- Flutter SDK (2.0.0 or later)
- iOS 11.0+ / Android API level 21+

### Installation

1. Add this to your `pubspec.yaml`:

   ```yaml
   dependencies:
     flutter_offline_translator: ^0.0.1
   ```

2. Run this command:
   ```
   flutter pub get
   ```

3. Import the package in your Dart code:
   ```dart
   import 'package:flutter_offline_translator/flutter_offline_translator.dart';
   ```

## 🎯 Usage

### Quick Start

```dart
final translator = FlutterOfflineTranslator();

// Translate text
String result = await translator.translate('Hello', from: 'en', to: 'es');
print(result); // Outputs: Hola
```

### Available Methods

| Method | Description |
|--------|-------------|
| `translate` | Translate text from one language to another |
| `getAvailableLanguages` | Get a list of supported languages |
| `downloadLanguageModel` | Download a specific language model for offline use |

### Detailed Examples

<details>
<summary>Click to expand</summary>

#### Translating Text

```dart
try {
  String translatedText = await translator.translate(
    'Hello, world!',
    from: 'en',
    to: 'es'
  );
  print('Translated text: $translatedText');
} catch (e) {
  print('Translation error: $e');
}
```

#### Getting Available Languages

```dart
try {
  List<String> languages = await translator.getAvailableLanguages();
  print('Available languages: $languages');
} catch (e) {
  print('Error getting languages: $e');
}
```

#### Downloading a Language Model

```dart
try {
  await translator.downloadLanguageModel('es');
  print('Spanish language model downloaded successfully');
} catch (e) {
  print('Error downloading language model: $e');
}
```

</details>

## 🌍 Supported Languages

The plugin supports numerous languages, including:

- 🇺🇸 English (en)
- 🇪🇸 Spanish (es)
- 🇫🇷 French (fr)
- 🇩🇪 German (de)
- 🇨🇳 Chinese (zh)
- 🇯🇵 Japanese (ja)
- 🇰🇷 Korean (ko)

And many more! Use `getAvailableLanguages()` for a complete list.

## ⚠️ Important Notes

- First-time translations might be slower due to model download
- Ensure sufficient device storage for language models
- Internet required for initial model downloads

## 🐛 Troubleshooting

| Issue | Solution |
|-------|----------|
| Slow first translation | Wait for model download to complete |
| "Language not supported" error | Check if you've downloaded the language model |
| App crashes on translation | Ensure you have the latest plugin version |

## 🤝 Contributing

Contributions, issues, and feature requests are welcome! Feel free to check [issues page](https://github.com/MohammedBakaliDev/flutter_offline_translator/issues).

## 📄 License

This project is [MIT](https://opensource.org/licenses/MIT) licensed.

---

Made with ❤️ by Mohammed Bakali