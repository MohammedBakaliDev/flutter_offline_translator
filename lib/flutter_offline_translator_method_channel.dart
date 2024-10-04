// import 'package:flutter/foundation.dart';
// import 'package:flutter/services.dart';

// import 'flutter_offline_translator_platform_interface.dart';

// /// An implementation of [FlutterOfflineTranslatorPlatform] that uses method channels.
// class MethodChannelFlutterOfflineTranslator
//     extends FlutterOfflineTranslatorPlatform {
//   /// The method channel used to interact with the native platform.
//   @visibleForTesting
//   final methodChannel = const MethodChannel('flutter_offline_translator');

//   @override
//   Future<String> translate(
//       String text, String fromLanguage, String toLanguage) async {
//     final translation = await methodChannel.invokeMethod<String>(
//       'translate',
//       {'text': text, 'fromLanguage': fromLanguage, 'toLanguage': toLanguage},
//     );
//     return translation ?? 'Translation failed';
//   }

//   @override
//   Future<List<String>> getAvailableLanguages() async {
//     final languages =
//         await methodChannel.invokeListMethod<String>('getAvailableLanguages');
//     return languages ?? [];
//   }

//   @override
//   Future<void> downloadLanguageModel(String language) async {
//     await methodChannel
//         .invokeMethod<void>('downloadLanguageModel', {'language': language});
//   }
// }

/// Implementation of the Flutter Offline Translator using method channels.
/// This class handles the platform-specific implementation of the translation functionality
/// by communicating with native code (Android/iOS) through method channels.
library;

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'flutter_offline_translator_platform_interface.dart';

/// An implementation of [FlutterOfflineTranslatorPlatform] that uses method channels.
/// This class serves as the concrete implementation for platform-specific translation
/// functionality, bridging Flutter with native Android and iOS code.
class MethodChannelFlutterOfflineTranslator
    extends FlutterOfflineTranslatorPlatform {
  /// The method channel used to interact with the native platform.
  ///
  /// This channel establishes a communication bridge between Flutter and platform-specific code.
  /// The identifier 'flutter_offline_translator' must match the channel name used in native code.
  @visibleForTesting
  final methodChannel = const MethodChannel('flutter_offline_translator');

  /// Translates the given text from one language to another.
  ///
  /// Parameters:
  /// - [text]: The text to be translated
  /// - [fromLanguage]: The source language code (e.g., 'en' for English)
  /// - [toLanguage]: The target language code (e.g., 'es' for Spanish)
  ///
  /// Returns:
  /// A [Future] that completes with the translated text string.
  /// If translation fails, returns 'Translation failed'.
  @override
  Future<String> translate(
      String text, String fromLanguage, String toLanguage) async {
    final translation = await methodChannel.invokeMethod<String>(
      'translate',
      {'text': text, 'fromLanguage': fromLanguage, 'toLanguage': toLanguage},
    );
    return translation ?? 'Translation failed';
  }

  /// Retrieves a list of all available languages supported by the translator.
  ///
  /// Returns:
  /// A [Future] that completes with a list of language codes.
  /// If the operation fails, returns an empty list.
  ///
  /// The language codes follow ISO 639-1 format (e.g., 'en' for English, 'es' for Spanish).
  @override
  Future<List<String>> getAvailableLanguages() async {
    final languages =
        await methodChannel.invokeListMethod<String>('getAvailableLanguages');
    return languages ?? [];
  }

  /// Downloads a language model for offline translation.
  ///
  /// Parameters:
  /// - [language]: The language code of the model to download (e.g., 'en' for English)
  ///
  /// This method triggers the download of a language model that enables offline translation.
  /// The download happens in the background and may take some time depending on the model size
  /// and network conditions.
  ///
  /// Throws:
  /// - [PlatformException] if the download fails or if there are network issues
  @override
  Future<void> downloadLanguageModel(String language) async {
    await methodChannel
        .invokeMethod<void>('downloadLanguageModel', {'language': language});
  }
}
