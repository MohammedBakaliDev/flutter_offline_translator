import 'flutter_offline_translator_platform_interface.dart';

class FlutterOfflineTranslator {
  Future<String> translate(
      String text, String fromLanguage, String toLanguage) {
    return FlutterOfflineTranslatorPlatform.instance
        .translate(text, fromLanguage, toLanguage);
  }

  Future<List<String>> getAvailableLanguages() {
    return FlutterOfflineTranslatorPlatform.instance.getAvailableLanguages();
  }

  Future<void> downloadLanguageModel(String language) {
    return FlutterOfflineTranslatorPlatform.instance
        .downloadLanguageModel(language);
  }
}
