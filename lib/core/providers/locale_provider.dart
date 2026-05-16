import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ── UI locale (en / fa) ───────────────────────────────────────────────────────

/// Persisted app UI locale (en or fa).
/// Controls navigation labels, button text, etc.
final localeProvider = StateNotifierProvider<LocaleNotifier, Locale>((ref) {
  return LocaleNotifier();
});

class LocaleNotifier extends StateNotifier<Locale> {
  LocaleNotifier() : super(const Locale('en')) {
    _load();
  }

  static const _key = 'app_locale';

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final code = prefs.getString(_key) ?? 'en';
    state = Locale(code);
  }

  Future<void> setLocale(Locale locale) async {
    state = locale;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, locale.languageCode);
  }
}

// ── Teaching language (en / fa) ───────────────────────────────────────────────

/// The language used to *explain* Polish content.
/// 'en' = Polish explained in English.
/// 'fa' = Polish explained in Persian (Farsi).
///
/// This is independent of [localeProvider] — you can have a Persian UI
/// that explains grammar in English, or vice versa.
final teachingLanguageProvider =
    StateNotifierProvider<TeachingLanguageNotifier, String>((ref) {
  return TeachingLanguageNotifier();
});

class TeachingLanguageNotifier extends StateNotifier<String> {
  TeachingLanguageNotifier() : super('en') {
    _load();
  }

  static const _key = 'teaching_language';

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    state = prefs.getString(_key) ?? 'en';
  }

  Future<void> setLanguage(String code) async {
    state = code;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, code);
  }
}
