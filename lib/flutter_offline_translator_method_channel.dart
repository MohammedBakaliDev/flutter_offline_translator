import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'flutter_offline_translator_platform_interface.dart';

/// An implementation of [FlutterOfflineTranslatorPlatform] that uses method channels.
class MethodChannelFlutterOfflineTranslator
    extends FlutterOfflineTranslatorPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('flutter_offline_translator');

  @override
  Future<String> translate(
      String text, String fromLanguage, String toLanguage) async {
    final translation = await methodChannel.invokeMethod<String>(
      'translate',
      {'text': text, 'fromLanguage': fromLanguage, 'toLanguage': toLanguage},
    );
    return translation ?? 'Translation failed';
  }

  @override
  Future<List<String>> getAvailableLanguages() async {
    final languages =
        await methodChannel.invokeListMethod<String>('getAvailableLanguages');
    return languages ?? [];
  }

  @override
  Future<void> downloadLanguageModel(String language) async {
    await methodChannel
        .invokeMethod<void>('downloadLanguageModel', {'language': language});
  }
}
