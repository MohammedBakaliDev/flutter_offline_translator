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
import com.google.mlkit.common.model.DownloadConditions
import com.google.mlkit.common.model.RemoteModelManager
import com.google.mlkit.nl.translate.TranslateRemoteModel
import android.util.LruCache
import kotlinx.coroutines.*
import java.util.concurrent.ConcurrentHashMap
import com.google.android.gms.tasks.Task
import kotlin.coroutines.resume
import kotlin.coroutines.resumeWithException
import kotlin.coroutines.suspendCoroutine

class FlutterOfflineTranslatorPlugin: FlutterPlugin, MethodCallHandler {
    private lateinit var channel: MethodChannel
    private val scope = CoroutineScope(Dispatchers.Main + Job())
    private val modelManager = RemoteModelManager.getInstance()
    
    // Add suspending extension function for Task
    private suspend fun <T> Task<T>.await(): T = suspendCoroutine { continuation ->
        addOnSuccessListener { result ->
            continuation.resume(result)
        }
        addOnFailureListener { exception ->
            continuation.resumeWithException(exception)
        }
    }
    
    private val translators = object : LruCache<TranslatorOptions, Translator>(NUM_TRANSLATORS) {
        override fun create(options: TranslatorOptions): Translator {
            return Translation.getClient(options)
        }

        override fun entryRemoved(
            evicted: Boolean,
            key: TranslatorOptions,
            oldValue: Translator,
            newValue: Translator?
        ) {
            oldValue.close()
        }
    }

    private val pendingDownloads = ConcurrentHashMap<String, Boolean>()

    override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        channel = MethodChannel(flutterPluginBinding.binaryMessenger, "flutter_offline_translator")
        channel.setMethodCallHandler(this)
    }

    override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: Result) {
        when (call.method) {
            "translate" -> {
                val text = call.argument<String>("text")
                val fromLanguage = call.argument<String>("fromLanguage")
                val toLanguage = call.argument<String>("toLanguage")
                
                if (text.isNullOrEmpty() || fromLanguage.isNullOrEmpty() || toLanguage.isNullOrEmpty()) {
                    result.error("INVALID_ARGUMENTS", "Missing or invalid arguments", null)
                    return
                }
                
                translate(text, fromLanguage, toLanguage, result)
            }
            "getAvailableLanguages" -> getAvailableLanguages(result)
            "downloadLanguageModel" -> {
                val language = call.argument<String>("language")
                if (language.isNullOrEmpty()) {
                    result.error("INVALID_LANGUAGE", "Language code cannot be empty", null)
                    return
                }
                downloadLanguageModel(language, result)
            }
            "isLanguageDownloaded" -> {
                val language = call.argument<String>("language")
                if (language.isNullOrEmpty()) {
                    result.error("INVALID_LANGUAGE", "Language code cannot be empty", null)
                    return
                }
                checkLanguageDownloaded(language, result)
            }
            "deleteLanguageModel" -> {
                val language = call.argument<String>("language")
                if (language.isNullOrEmpty()) {
                    result.error("INVALID_LANGUAGE", "Language code cannot be empty", null)
                    return
                }
                deleteLanguageModel(language, result)
            }
            else -> result.notImplemented()
        }
    }

    private fun translate(text: String, fromLanguage: String, toLanguage: String, result: Result) {
        scope.launch {
            try {
                val options = TranslatorOptions.Builder()
                    .setSourceLanguage(fromLanguage)
                    .setTargetLanguage(toLanguage)
                    .build()

                val translator = translators.get(options)
                
                withContext(Dispatchers.IO) {
                    translator.downloadModelIfNeeded().await()
                    val translatedText = translator.translate(text).await()
                    withContext(Dispatchers.Main) {
                        result.success(translatedText)
                    }
                }
            } catch (e: Exception) {
                withContext(Dispatchers.Main) {
                    result.error(
                        "TRANSLATION_ERROR",
                        "Translation failed: ${e.localizedMessage}",
                        e.toString()
                    )
                }
            }
        }
    }

    private fun getAvailableLanguages(result: Result) {
        scope.launch {
            try {
                val languages = TranslateLanguage.getAllLanguages()
                result.success(languages)
            } catch (e: Exception) {
                result.error(
                    "LANGUAGE_LIST_ERROR",
                    "Failed to get available languages: ${e.localizedMessage}",
                    null
                )
            }
        }
    }

    private fun downloadLanguageModel(language: String, result: Result) {
        if (pendingDownloads[language] == true) {
            result.error("ALREADY_DOWNLOADING", "Model is already downloading", null)
            return
        }

        scope.launch {
            try {
                pendingDownloads[language] = true
                val model = TranslateRemoteModel.Builder(language).build()
                val conditions = DownloadConditions.Builder().build()
                
                withContext(Dispatchers.IO) {
                    modelManager.download(model, conditions).await()
                    pendingDownloads.remove(language)
                    withContext(Dispatchers.Main) {
                        result.success(null)
                    }
                }
            } catch (e: Exception) {
                pendingDownloads.remove(language)
                withContext(Dispatchers.Main) {
                    result.error(
                        "DOWNLOAD_ERROR",
                        "Failed to download model: ${e.localizedMessage}",
                        null
                    )
                }
            }
        }
    }

    private fun checkLanguageDownloaded(language: String, result: Result) {
        scope.launch {
            try {
                val model = TranslateRemoteModel.Builder(language).build()
                val downloadedModels = withContext(Dispatchers.IO) {
                    modelManager.getDownloadedModels(TranslateRemoteModel::class.java).await()
                }
                result.success(downloadedModels.any { model -> model.language == language })
            } catch (e: Exception) {
                result.error(
                    "CHECK_MODEL_ERROR",
                    "Failed to check model status: ${e.localizedMessage}",
                    null
                )
            }
        }
    }

    private fun deleteLanguageModel(language: String, result: Result) {
        scope.launch {
            try {
                val model = TranslateRemoteModel.Builder(language).build()
                withContext(Dispatchers.IO) {
                    modelManager.deleteDownloadedModel(model).await()
                    withContext(Dispatchers.Main) {
                        result.success(null)
                    }
                }
            } catch (e: Exception) {
                result.error(
                    "DELETE_ERROR",
                    "Failed to delete model: ${e.localizedMessage}",
                    null
                )
            }
        }
    }

    override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
        translators.evictAll()
        scope.cancel()
    }

    companion object {
        private const val NUM_TRANSLATORS = 3
    }
}