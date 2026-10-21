import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AppPreferencesController extends ChangeNotifier {
  AppPreferencesController({FlutterSecureStorage? storage})
    : _storage = storage ?? const FlutterSecureStorage();

  static const _themeKey = 'kwanza_track_theme_mode';
  static const _localeKey = 'kwanza_track_locale';

  final FlutterSecureStorage _storage;
  ThemeMode _themeMode = ThemeMode.system;
  Locale _locale = const Locale('en');

  ThemeMode get themeMode => _themeMode;
  Locale get locale => _locale;
  bool get usesDarkMode => _themeMode == ThemeMode.dark;
  bool get usesSwahili => _locale.languageCode == 'sw';

  Future<void> load() async {
    final theme = await _storage.read(key: _themeKey);
    final language = await _storage.read(key: _localeKey);
    _themeMode = switch (theme) {
      'dark' => ThemeMode.dark,
      'light' => ThemeMode.light,
      _ => ThemeMode.system,
    };
    _locale = Locale(language == 'sw' ? 'sw' : 'en');
    notifyListeners();
  }

  Future<void> setDarkMode(bool enabled) async {
    _themeMode = enabled ? ThemeMode.dark : ThemeMode.light;
    await _storage.write(key: _themeKey, value: enabled ? 'dark' : 'light');
    notifyListeners();
  }

  Future<void> setSwahili(bool enabled) async {
    await setLocale(Locale(enabled ? 'sw' : 'en'));
  }

  Future<void> setLocale(Locale locale) async {
    _locale = Locale(locale.languageCode == 'sw' ? 'sw' : 'en');
    await _storage.write(key: _localeKey, value: _locale.languageCode);
    notifyListeners();
  }
}
