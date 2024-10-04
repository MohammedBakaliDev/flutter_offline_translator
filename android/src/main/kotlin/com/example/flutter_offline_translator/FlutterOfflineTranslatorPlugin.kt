package com.example.flutter_offline_translator

import androidx.annotation.NonNull
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import com.google.mlkit.nl.translate.TranslateLanguage
import com.google.mlkit.nl.translate.Translation
import com.google.mlkit.nl.translate.Translator
import com.google.mlkit.nl.translate.TranslatorOptions

/** FlutterOfflineTranslatorPlugin */
class FlutterOfflineTranslatorPlugin: FlutterPlugin, MethodCallHandler {
  /// The MethodChannel that will the communication between Flutter and native Android
  ///
  /// This local reference serves to register the plugin with the Flutter Engine and unregister it
  /// when the Flutter Engine is detached from the Activity
  private lateinit var channel : MethodChannel
  private var translator: Translator? = null

  override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
    channel = MethodChannel(flutterPluginBinding.binaryMessenger, "flutter_offline_translator")
    channel.setMethodCallHandler(this)
  }

  override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: Result) {
    when (call.method) {
      "translate" -> {
        val text = call.argument<String>("text") ?: ""
        val fromLanguage = call.argument<String>("fromLanguage") ?: ""
        val toLanguage = call.argument<String>("toLanguage") ?: ""
        translate(text, fromLanguage, toLanguage, result)
      }
      "getAvailableLanguages" -> getAvailableLanguages(result)
      "downloadLanguageModel" -> {
        val language = call.argument<String>("language") ?: ""
        downloadLanguageModel(language, result)
      }
      else -> result.notImplemented()
    }
  }

  private fun translate(text: String, fromLanguage: String, toLanguage: String, result: Result) {
    val options = TranslatorOptions.Builder()
      .setSourceLanguage(fromLanguage)
      .setTargetLanguage(toLanguage)
      .build()
    translator = Translation.getClient(options)
    
    translator?.downloadModelIfNeeded()?.addOnSuccessListener {
      translator?.translate(text)?.addOnSuccessListener { translatedText ->
        result.success(translatedText)
      }?.addOnFailureListener { exception ->
        result.error("TRANSLATION_ERROR", exception.localizedMessage, null)
      }
    }?.addOnFailureListener { exception ->
      result.error("MODEL_DOWNLOAD_ERROR", exception.localizedMessage, null)
    }
  }

  private fun getAvailableLanguages(result: Result) {
    result.success(TranslateLanguage.getAllLanguages().map { it.toString() })
  }

  private fun downloadLanguageModel(language: String, result: Result) {
    val options = TranslatorOptions.Builder()
      .setSourceLanguage(TranslateLanguage.ENGLISH)
      .setTargetLanguage(language)
      .build()
    val tempTranslator = Translation.getClient(options)
    tempTranslator.downloadModelIfNeeded().addOnSuccessListener {
      result.success(null)
    }.addOnFailureListener { exception ->
      result.error("MODEL_DOWNLOAD_ERROR", exception.localizedMessage, null)
    }
  }

  override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
    channel.setMethodCallHandler(null)
    translator?.close()
  }
}