import 'package:flutter/foundation.dart';

/// Service untuk simpan app settings (termasuk Gemini API key)
/// Menggunakan SharedPreferences (installasi nanti di pubspec.yaml jika belum)
class AppSettings {
  static final AppSettings _instance = AppSettings._internal();

  String? _geminiApiKey;
  bool _useGemini = false;

  AppSettings._internal();

  factory AppSettings() {
    return _instance;
  }

  /// Get Gemini API key
  String? getGeminiApiKey() {
    return _geminiApiKey;
  }

  /// Set Gemini API key
  void setGeminiApiKey(String apiKey) {
    _geminiApiKey = apiKey;
    // Todo: Save to SharedPreferences jika ada
  }

  /// Clear Gemini API key
  void clearGeminiApiKey() {
    _geminiApiKey = null;
    _useGemini = false;
    // Todo: Delete from SharedPreferences jika ada
  }

  /// Check jika punya valid API key
  bool hasValidApiKey() {
    return _geminiApiKey != null && _geminiApiKey!.isNotEmpty;
  }

  /// Set apakah ingin use Gemini
  void setUseGemini(bool use) {
    _useGemini = use;
  }

  /// Check apakah use Gemini
  bool shouldUseGemini() {
    return _useGemini && hasValidApiKey();
  }

  void debugPrint(String msg) {
    if (kDebugMode) {
      print('[AppSettings] $msg');
    }
  }
}
