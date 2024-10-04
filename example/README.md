# 🌐 Flutter Offline Translator Example

![Flutter](https://img.shields.io/badge/Flutter-%2302569B.svg?style=for-the-badge&logo=Flutter&logoColor=white)
![Dart](https://img.shields.io/badge/dart-%230175C2.svg?style=for-the-badge&logo=dart&logoColor=white)

Translate text offline with ease! This example demonstrates the power of the Offline Translator plugin.

## ✨ Features

- 🔌 **Offline Translation**: No internet required!
- 🌍 **Multiple Languages**: Supports various language pairs
- 🚀 **Fast & Efficient**: Optimized for mobile devices

## 🚀 Quick Start

1. Clone the repo
2. Navigate to example directory:
   ```
   cd flutter_offline_translator/example
   ```
3. Run the example:
   ```
   flutter run
   ```

## 💡 Usage

```dart
import 'package:flutter_offline_translator/flutter_offline_translator.dart';

final translator = FlutterOfflineTranslator();

String result = await translator.translate(
  'Hello, world!',
  from: 'en',
  to: 'es',
);
print(result); // Outputs: ¡Hola Mundo!
```

## 📱 Screenshot

<p align="center">
  <img src="https://via.placeholder.com/300x600" alt="App Screenshot" width="300">
</p>

## 🤝 Contribute

Contributions, issues, and feature requests are welcome!

## 📄 License

This project is [MIT](../LICENSE) licensed.

---

<p align="center">
  Made with ❤️ by Mohammed Bakali
</p>