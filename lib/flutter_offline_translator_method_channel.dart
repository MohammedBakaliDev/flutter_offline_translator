import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'flutter_offline_translator_platform_interface.dart';

class MethodChannelFlutterOfflineTranslator
    extends FlutterOfflineTranslatorPlatform {
  @visibleForTesting
  final methodChannel = const MethodChannel('flutter_offline_translator');

  @override
  Future<String> translate(
      String text, String fromLanguage, String toLanguage) async {
    try {
      final translation = await methodChannel.invokeMethod<String>(
        'translate',
        {
          'text': text,
          'fromLanguage': fromLanguage,
          'toLanguage': toLanguage,
        },
      );
      if (translation == null) {
        throw PlatformException(
          code: 'TRANSLATION_ERROR',
          message: 'Translation returned null',
        );
      }
      return translation;
    } on PlatformException catch (e) {
      throw PlatformException(
        code: e.code,
        message: e.message ?? 'Translation failed',
        details: e.details,
      );
    }
  }

  @override
  Future<List<String>> getAvailableLanguages() async {
    try {
      final languages =
          await methodChannel.invokeListMethod<String>('getAvailableLanguages');
      if (languages == null) {
        throw PlatformException(
          code: 'LANGUAGES_ERROR',
          message: 'Failed to get available languages',
        );
      }
      return languages;
    } on PlatformException catch (e) {
      throw PlatformException(
        code: e.code,
        message: e.message ?? 'Failed to get available languages',
        details: e.details,
      );
    }
  }

  @override
  Future<void> downloadLanguageModel(String language) async {
    try {
      await methodChannel
          .invokeMethod<void>('downloadLanguageModel', {'language': language});
    } on PlatformException catch (e) {
      throw PlatformException(
        code: e.code,
        message: e.message ?? 'Failed to download language model',
        details: e.details,
      );
    }
  }

  @override
  Future<bool> isLanguageDownloaded(String language) async {
    try {
      final isDownloaded = await methodChannel
          .invokeMethod<bool>('isLanguageDownloaded', {'language': language});
      if (isDownloaded == null) {
        throw PlatformException(
          code: 'CHECK_ERROR',
          message: 'Failed to check language download status',
        );
      }
      return isDownloaded;
    } on PlatformException catch (e) {
      throw PlatformException(
        code: e.code,
        message: e.message ?? 'Failed to check language download status',
        details: e.details,
      );
    }
  }

  @override
  Future<void> deleteLanguageModel(String language) async {
    try {
      await methodChannel
          .invokeMethod<void>('deleteLanguageModel', {'language': language});
    } on PlatformException catch (e) {
      throw PlatformException(
        code: e.code,
        message: e.message ?? 'Failed to delete language model',
        details: e.details,
      );
    }
  }
}
