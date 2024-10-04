import Flutter
import UIKit
import MLKitTranslate

public class FlutterOfflineTranslatorPlugin: NSObject, FlutterPlugin {
  private var translators: [String: Translator] = [:]
  
  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "flutter_offline_translator", binaryMessenger: registrar.messenger())
    let instance = FlutterOfflineTranslatorPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

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

  private func getAvailableLanguages(result: @escaping FlutterResult) {
    let languages = TranslateLanguage.allLanguages().map { $0.rawValue }
    result(languages)
  }

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