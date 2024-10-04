/**
 * FlutterOfflineTranslatorPlugin
 *
 * A Flutter plugin implementation for iOS that provides offline translation capabilities
 * using Google's ML Kit. This plugin enables text translation between multiple languages
 * without requiring an internet connection after the initial language model download.
 */
import Flutter
import UIKit
import MLKitTranslate

public class FlutterOfflineTranslatorPlugin: NSObject, FlutterPlugin {
    /**
     * Dictionary to store translator instances for different language pairs.
     * Key format: "sourceLanguage-targetLanguage"
     */
    private var translators: [String: Translator] = [:]
    
    /**
     * Registers the plugin with the Flutter engine.
     * Sets up the method channel for communication between Flutter and iOS.
     *
     * @param registrar The registrar used to maintain the plugin's registration with a Flutter engine
     */
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "flutter_offline_translator", binaryMessenger: registrar.messenger())
        let instance = FlutterOfflineTranslatorPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
    }

    /**
     * Handles method calls from Flutter.
     * Supports three main operations:
     * - translate: Translates text between specified languages
     * - getAvailableLanguages: Returns list of supported languages
     * - downloadLanguageModel: Downloads a specific language model for offline use
     *
     * @param call The method call containing the method name and arguments
     * @param result A callback to handle the result of the method call
     */
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "translate":
            if let args = call.arguments as? [String: Any],
               let text = args["text"] as? String,
               let fromLanguage = args["fromLanguage"] as? String,
               let toLanguage = args["toLanguage"] as? String {
                translate(text: text, from: fromLanguage, to: toLanguage, result: result)
            } else {
                result(FlutterError(code: "INVALID_ARGUMENTS", message: "Invalid arguments for translate", details: nil))
            }
        case "getAvailableLanguages":
            getAvailableLanguages(result: result)
        case "downloadLanguageModel":
            if let args = call.arguments as? [String: Any],
               let language = args["language"] as? String {
                downloadLanguageModel(language: language, result: result)
            } else {
                result(FlutterError(code: "INVALID_ARGUMENTS", message: "Invalid arguments for downloadLanguageModel", details: nil))
            }
        default:
            result(FlutterMethodNotImplemented)
        }
    }

    /**
     * Handles the translation of text between specified languages.
     * Creates or reuses a translator instance for the given language pair.
     * Downloads language models if needed before performing translation.
     *
     * @param text The text to be translated
     * @param sourceLanguage The source language code
     * @param targetLanguage The target language code
     * @param result A callback to handle the translation result
     */
    private func translate(text: String, from sourceLanguage: String, to targetLanguage: String, result: @escaping FlutterResult) {
        let translatorKey = "\(sourceLanguage)-\(targetLanguage)"
        
        if let translator = translators[translatorKey] {
            performTranslation(translator: translator, text: text, result: result)
        } else {
            let sourceTranslateLanguage = TranslateLanguage(rawValue: sourceLanguage)
            let targetTranslateLanguage = TranslateLanguage(rawValue: targetLanguage)
            
            let options = TranslatorOptions(sourceLanguage: sourceTranslateLanguage, targetLanguage: targetTranslateLanguage)
            let translator = Translator.translator(options: options)
            translators[translatorKey] = translator
            
            let conditions = ModelDownloadConditions(
                allowsCellularAccess: true,
                allowsBackgroundDownloading: true
            )
            
            translator.downloadModelIfNeeded(with: conditions) { error in
                if let error = error {
                    result(FlutterError(code: "MODEL_DOWNLOAD_ERROR", message: error.localizedDescription, details: nil))
                } else {
                    self.performTranslation(translator: translator, text: text, result: result)
                }
            }
        }
    }

    /**
     * Performs the actual translation using a configured translator instance.
     * Handles success and error cases, returning appropriate results to Flutter.
     *
     * @param translator The configured translator instance to use
     * @param text The text to translate
     * @param result A callback to handle the translation result
     */
    private func performTranslation(translator: Translator, text: String, result: @escaping FlutterResult) {
        translator.translate(text) { translatedText, error in
            if let error = error {
                result(FlutterError(code: "TRANSLATION_ERROR", message: error.localizedDescription, details: nil))
            } else if let translatedText = translatedText {
                result(translatedText)
            } else {
                result(FlutterError(code: "TRANSLATION_ERROR", message: "Translation failed", details: nil))
            }
        }
    }

    /**
     * Returns a list of all available languages supported by ML Kit Translation.
     *
     * @param result A callback to return the list of available languages
     */
    private func getAvailableLanguages(result: @escaping FlutterResult) {
        let languages = TranslateLanguage.allLanguages().map { $0.rawValue }
        result(languages)
    }

    /**
     * Downloads a specific language model for offline use.
     * Creates a temporary translator to trigger the download.
     *
     * @param language The language code of the model to download
     * @param result A callback to handle the download result
     */
    private func downloadLanguageModel(language: String, result: @escaping FlutterResult) {
        let translateLanguage = TranslateLanguage(rawValue: language)
        
        let options = TranslatorOptions(sourceLanguage: .english, targetLanguage: translateLanguage)
        let translator = Translator.translator(options: options)
        let conditions = ModelDownloadConditions(
            allowsCellularAccess: true,
            allowsBackgroundDownloading: true
        )
        
        translator.downloadModelIfNeeded(with: conditions) { error in
            if let error = error {
                result(FlutterError(code: "MODEL_DOWNLOAD_ERROR", message: error.localizedDescription, details: nil))
            } else {
                result(nil)
            }
        }
    }
}