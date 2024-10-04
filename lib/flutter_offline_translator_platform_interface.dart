import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'flutter_offline_translator_method_channel.dart';

abstract class FlutterOfflineTranslatorPlatform extends PlatformInterface {
  /// Constructs a FlutterOfflineTranslatorPlatform.
  FlutterOfflineTranslatorPlatform() : super(token: _token);

  static final Object _token = Object();

  static FlutterOfflineTranslatorPlatform _instance =
      MethodChannelFlutterOfflineTranslator();

  /// The default instance of [FlutterOfflineTranslatorPlatform] to use.
  ///
  /// Defaults to [MethodChannelFlutterOfflineTranslator].
  static FlutterOfflineTranslatorPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [FlutterOfflineTranslatorPlatform] when
  /// they register themselves.
  static set instance(FlutterOfflineTranslatorPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String> translate(
      String text, String fromLanguage, String toLanguage) {
    throw UnimplementedError('translate() has not been implemented.');
  }

  Future<List<String>> getAvailableLanguages() {
    throw UnimplementedError(
        'getAvailableLanguages() has not been implemented.');
  }

  Future<void> downloadLanguageModel(String language) {
    throw UnimplementedError(
        'downloadLanguageModel() has not been implemented.');
  }
}
