// import 'flutter_offline_translator_platform_interface.dart';

// class FlutterOfflineTranslator {
//   Future<String> translate(
//       String text, String fromLanguage, String toLanguage) {
//     return FlutterOfflineTranslatorPlatform.instance
//         .translate(text, fromLanguage, toLanguage);
//   }

//   Future<List<String>> getAvailableLanguages() {
//     return FlutterOfflineTranslatorPlatform.instance.getAvailableLanguages();
//   }

//   Future<void> downloadLanguageModel(String language) {
//     return FlutterOfflineTranslatorPlatform.instance
//         .downloadLanguageModel(language);
//   }
// }

import 'flutter_offline_translator_platform_interface.dart';

/// A class that provides translation functionalities using an offline translator.
class FlutterOfflineTranslator {
  /// Translates the given [text] from [fromLanguage] to [toLanguage].
  ///
  /// Returns a [Future] that resolves to the translated text.
  Future<String> translate(
      String text, String fromLanguage, String toLanguage) {
    return FlutterOfflineTranslatorPlatform.instance
        .translate(text, fromLanguage, toLanguage);
  }

  /// Retrieves a list of available languages for translation.
  ///
  /// Returns a [Future] that resolves to a list of language codes.
  Future<List<String>> getAvailableLanguages() {
    return FlutterOfflineTranslatorPlatform.instance.getAvailableLanguages();
  }

  /// Downloads the language model for the given [language] to be used offline.
  ///
  /// Returns a [Future] that resolves when the download is complete.
  Future<void> downloadLanguageModel(String language) {
    return FlutterOfflineTranslatorPlatform.instance
        .downloadLanguageModel(language);
  }
}
