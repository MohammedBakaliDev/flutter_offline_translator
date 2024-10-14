import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'flutter_offline_translator_method_channel.dart';

abstract class FlutterOfflineTranslatorPlatform extends PlatformInterface {
  FlutterOfflineTranslatorPlatform() : super(token: _token);

  static final Object _token = Object();

  static FlutterOfflineTranslatorPlatform _instance =
      MethodChannelFlutterOfflineTranslator();

  static FlutterOfflineTranslatorPlatform get instance => _instance;

  static set instance(FlutterOfflineTranslatorPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  /// Translates text from one language to another.
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
    throw UnimplementedError('translate() has not been implemented.');
  }

  /// Retrieves a list of all available languages supported by the translator.
  ///
  /// Returns a [Future] with a list of language codes in ISO 639-1 format
  /// (e.g., ['en', 'es', 'fr']).
  ///
  /// Throws [PlatformException] if the operation fails.
  Future<List<String>> getAvailableLanguages() {
    throw UnimplementedError(
        'getAvailableLanguages() has not been implemented.');
  }

  /// Downloads a specific language model for offline translation.
  ///
  /// Parameters:
  /// - [language]: The language code of the model to download (e.g., 'en' for English)
  ///
  /// The download happens asynchronously and may take time depending on the model size
  /// and network conditions.
  ///
  /// Throws [PlatformException] if the download fails or if the model is already being downloaded.
  Future<void> downloadLanguageModel(String language) {
    throw UnimplementedError(
        'downloadLanguageModel() has not been implemented.');
  }

  /// Checks if a specific language model is downloaded and available for offline use.
  ///
  /// Parameters:
  /// - [language]: The language code to check (e.g., 'en' for English)
  ///
  /// Returns a [Future] with a boolean indicating if the model is downloaded.
  ///
  /// Throws [PlatformException] if the check fails.
  Future<bool> isLanguageDownloaded(String language) {
    throw UnimplementedError(
        'isLanguageDownloaded() has not been implemented.');
  }

  /// Deletes a downloaded language model to free up storage space.
  ///
  /// Parameters:
  /// - [language]: The language code of the model to delete (e.g., 'en' for English)
  ///
  /// Throws [PlatformException] if the deletion fails or if the model isn't downloaded.
  Future<void> deleteLanguageModel(String language) {
    throw UnimplementedError('deleteLanguageModel() has not been implemented.');
  }
}
