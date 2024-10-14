import Flutter
import UIKit
import MLKitTranslate

public class FlutterOfflineTranslatorPlugin: NSObject, FlutterPlugin {
    private var translators: [String: Translator] = [:]
    private let modelManager = ModelManager.modelManager()
    
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
        case "deleteLanguageModel":
            if let args = call.arguments as? [String: Any],
               let language = args["language"] as? String {
                deleteLanguageModel(language: language, result: result)
            } else {
                result(FlutterError(code: "INVALID_ARGUMENTS", message: "Invalid arguments for deleteLanguageModel", details: nil))
            }
        case "isLanguageDownloaded":
            if let args = call.arguments as? [String: Any],
               let language = args["language"] as? String {
                let isDownloaded = isLanguageDownloaded(TranslateLanguage(rawValue: language))
                result(isDownloaded)
            } else {
                result(FlutterError(code: "INVALID_ARGUMENTS", message: "Invalid arguments for isLanguageDownloaded", details: nil))
            }
        default:
            result(FlutterMethodNotImplemented)
        }
    }

    private func translate(text: String, from sourceLanguage: String, to targetLanguage: String, result: @escaping FlutterResult) {
        let sourceTranslateLanguage = TranslateLanguage(rawValue: sourceLanguage)
        let targetTranslateLanguage = TranslateLanguage(rawValue: targetLanguage)
        
        let options = TranslatorOptions(sourceLanguage: sourceTranslateLanguage, targetLanguage: targetTranslateLanguage)
        let translator = Translator.translator(options: options)
        
        translator.downloadModelIfNeeded { [weak self] error in
            if let error = error {
                result(FlutterError(code: "MODEL_DOWNLOAD_ERROR", message: error.localizedDescription, details: nil))
            } else {
                self?.performTranslation(translator: translator, text: text, result: result)
            }
        }
    }

    private func performTranslation(translator: Translator, text: String, result: @escaping FlutterResult) {
        translator.translate(text) { (translatedText: String?, error: Error?) in
            if let error = error {
                result(FlutterError(code: "TRANSLATION_ERROR", message: error.localizedDescription, details: nil))
                return
            }
            
            if let translatedText = translatedText {
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
        handleModelDownload(for: language) { success, error in
            DispatchQueue.main.async {
                if let error = error {
                    result(FlutterError(code: "DOWNLOAD_FAILED", message: error.localizedDescription, details: nil))
                } else {
                    result(success)
                }
            }
        }
    }

    private func handleModelDownload(for language: String, completion: @escaping (Bool, Error?) -> Void) {
    let translateLanguage = TranslateLanguage(rawValue: language)
    let model = TranslateRemoteModel.translateRemoteModel(language: translateLanguage)
    
    if modelManager.isModelDownloaded(model) {
        let error = NSError(domain: "MODEL_ALREADY_DOWNLOADED", code: 0, userInfo: [NSLocalizedDescriptionKey: "Model for \(language) is already downloaded"])
        completion(false, error)
    } else {
        let conditions = ModelDownloadConditions(
            allowsCellularAccess: false,
            allowsBackgroundDownloading: true
        )
        
        let downloadProgress = modelManager.download(model, conditions: conditions)
        
        downloadProgress.addObserver(self, forKeyPath: "fractionCompleted", options: .new, context: nil)
        
        NotificationCenter.default.addObserver(forName: .mlkitModelDownloadDidSucceed, object: downloadProgress, queue: nil) { _ in
            NotificationCenter.default.removeObserver(self, name: .mlkitModelDownloadDidSucceed, object: downloadProgress)
            completion(true, nil)
        }
        
        NotificationCenter.default.addObserver(forName: .mlkitModelDownloadDidFail, object: downloadProgress, queue: nil) { notification in
            NotificationCenter.default.removeObserver(self, name: .mlkitModelDownloadDidFail, object: downloadProgress)
            let error = (notification.userInfo?[ModelDownloadUserInfoKey.error] as? NSError) ?? NSError(domain: "UNKNOWN_ERROR", code: 0, userInfo: nil)
            completion(false, error)
        }
    }
}

    private func deleteLanguageModel(language: String, result: @escaping FlutterResult) {
        let translateLanguage = TranslateLanguage(rawValue: language)
        let model = TranslateRemoteModel.translateRemoteModel(language: translateLanguage)
        
        modelManager.deleteDownloadedModel(model) { error in
            if let error = error {
                result(FlutterError(code: "MODEL_DELETE_ERROR", message: error.localizedDescription, details: nil))
            } else {
                result(nil)
            }
        }
    }

    private func isLanguageDownloaded(_ language: TranslateLanguage) -> Bool {
        let model = TranslateRemoteModel.translateRemoteModel(language: language)
        return modelManager.isModelDownloaded(model)
    }

    override public func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
    if keyPath == "fractionCompleted", let progress = object as? Progress {
        print("Download progress: \(progress.fractionCompleted)")
    }
}
}