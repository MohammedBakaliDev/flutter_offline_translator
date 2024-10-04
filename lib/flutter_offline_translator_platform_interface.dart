// import 'package:plugin_platform_interface/plugin_platform_interface.dart';

// import 'flutter_offline_translator_method_channel.dart';

// abstract class FlutterOfflineTranslatorPlatform extends PlatformInterface {
//   /// Constructs a FlutterOfflineTranslatorPlatform.
//   FlutterOfflineTranslatorPlatform() : super(token: _token);

//   static final Object _token = Object();

//   static FlutterOfflineTranslatorPlatform _instance =
//       MethodChannelFlutterOfflineTranslator();

//   /// The default instance of [FlutterOfflineTranslatorPlatform] to use.
//   ///
//   /// Defaults to [MethodChannelFlutterOfflineTranslator].
//   static FlutterOfflineTranslatorPlatform get instance => _instance;

//   /// Platform-specific implementations should set this with their own
//   /// platform-specific class that extends [FlutterOfflineTranslatorPlatform] when
//   /// they register themselves.
//   static set instance(FlutterOfflineTranslatorPlatform instance) {
//     PlatformInterface.verifyToken(instance, _token);
//     _instance = instance;
//   }

//   Future<String> translate(
//       String text, String fromLanguage, String toLanguage) {
//     throw UnimplementedError('translate() has not been implemented.');
//   }

//   Future<List<String>> getAvailableLanguages() {
//     throw UnimplementedError(
//         'getAvailableLanguages() has not been implemented.');
//   }

//   Future<void> downloadLanguageModel(String language) {
//     throw UnimplementedError(
//         'downloadLanguageModel() has not been implemented.');
//   }
// }

/// Platform interface for the Flutter Offline Translator plugin.
///
/// This abstract class defines the interface that platform-specific implementations
/// must implement to provide offline translation functionality. It ensures consistency
/// across different platforms while allowing platform-specific implementations.
library;

import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'flutter_offline_translator_method_channel.dart';

/// The interface that implementations of flutter_offline_translator must implement.
///
/// Platform implementations should extend this class rather than implement it as
/// flutter_offline_translator does not consider newly added methods to be breaking
/// changes. Extending this class ensures that the implementation will get the
/// default implementation of any future added methods.
abstract class FlutterOfflineTranslatorPlatform extends PlatformInterface {
  /// Creates a new platform interface instance with verification.
  ///
  /// This constructor is protected to prevent direct instantiation of the platform
  /// interface, forcing implementers to extend the class instead.
  FlutterOfflineTranslatorPlatform() : super(token: _token);

  /// Unique token used to verify platforms extend [FlutterOfflineTranslatorPlatform].
  ///
  /// This token ensures that only valid implementations can be registered as
  /// the platform interface implementation.
  static final Object _token = Object();

  /// The default instance of [FlutterOfflineTranslatorPlatform].
  ///
  /// This instance will be the default method channel implementation unless
  /// overridden by tests or other implementations.
  static FlutterOfflineTranslatorPlatform _instance =
      MethodChannelFlutterOfflineTranslator();

  /// Returns the current default instance of [FlutterOfflineTranslatorPlatform].
  ///
  /// This instance can be overridden for testing or to provide a different
  /// implementation for specific platforms.
  ///
  /// Defaults to [MethodChannelFlutterOfflineTranslator].
  static FlutterOfflineTranslatorPlatform get instance => _instance;

  /// Sets the default instance of [FlutterOfflineTranslatorPlatform].
  ///
  /// Platform-specific implementations should use this setter to register themselves
  /// as the default instance when they are initialized.
  ///
  /// Throws an [AssertionError] if [instance] does not extend [FlutterOfflineTranslatorPlatform]
  /// with a valid token.
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
  ///
  /// Throws [UnimplementedError] if the platform implementation doesn't override this method.
  Future<String> translate(
      String text, String fromLanguage, String toLanguage) {
    throw UnimplementedError('translate() has not been implemented.');
  }

  /// Retrieves a list of all available languages supported by the translator.
  ///
  /// Returns a [Future] with a list of language codes in ISO 639-1 format
  /// (e.g., ['en', 'es', 'fr']).
  ///
  /// Throws [UnimplementedError] if the platform implementation doesn't override this method.
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
  /// Throws:
  /// - [UnimplementedError] if the platform implementation doesn't override this method
  /// - Platform-specific exceptions for network or storage issues
  Future<void> downloadLanguageModel(String language) {
    throw UnimplementedError(
        'downloadLanguageModel() has not been implemented.');
  }
}
