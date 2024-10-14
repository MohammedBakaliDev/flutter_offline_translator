import 'flutter_offline_translator_platform_interface.dart';

class FlutterOfflineTranslator {
  /// Translates the given [text] from [fromLanguage] to [toLanguage].
  ///
  /// Parameters:
  /// - [text]: The text to be translated
  /// - [fromLanguage]: The source language code (e.g., 'en' for English)
  /// - [toLanguage]: The target language code (e.g., 'es' for Spanish)
  ///
  /// Returns a [Future] with the translated text.
  /// Throws [PlatformException] if translation fails.
  Future<String> translate(
      String text, String fromLanguage, String toLanguage) {
    return FlutterOfflineTranslatorPlatform.instance
        .translate(text, fromLanguage, toLanguage);
  }

  /// Retrieves a list of available languages for translation.
  ///
  /// Returns a [Future] that resolves to a list of language codes.
  /// Throws [PlatformException] if the operation fails.
  Future<List<String>> getAvailableLanguages() {
    return FlutterOfflineTranslatorPlatform.instance.getAvailableLanguages();
  }

  /// Downloads the language model for the given [language] to be used offline.
  ///
  /// Parameters:
  /// - [language]: The language code of the model to download (e.g., 'en' for English)
  ///
  /// Throws [PlatformException] if:
  /// - The download fails
  /// - The model is already being downloaded
  /// - There are network connectivity issues
  /// - There isn't enough storage space
  Future<void> downloadLanguageModel(String language) {
    return FlutterOfflineTranslatorPlatform.instance
        .downloadLanguageModel(language);
  }

  /// Checks if a specific language model is downloaded and available for offline use.
  ///
  /// Parameters:
  /// - [language]: The language code to check (e.g., 'en' for English)
  ///
  /// Returns a [Future] with a boolean indicating if the model is downloaded.
  /// Throws [PlatformException] if the check fails.
  Future<bool> isLanguageDownloaded(String language) {
    return FlutterOfflineTranslatorPlatform.instance
        .isLanguageDownloaded(language);
  }

  /// Deletes a downloaded language model to free up storage space.
  ///
  /// Parameters:
  /// - [language]: The language code of the model to delete (e.g., 'en' for English)
  ///
  /// Throws [PlatformException] if:
  /// - The deletion fails
  /// - The model isn't downloaded
  /// - The model is currently in use
  Future<void> deleteLanguageModel(String language) {
    return FlutterOfflineTranslatorPlatform.instance
        .deleteLanguageModel(language);
  }
}
