import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AppPreferencesController extends ChangeNotifier {
  AppPreferencesController({FlutterSecureStorage? storage})
    : _storage = storage ?? const FlutterSecureStorage();

  static const _themeKey = 'sb_mechanization_theme_mode';
  static const _localeKey = 'sb_mechanization_locale';
  static final _legacyThemeKey = String.fromCharCodes(const [
    107,
    119,
    97,
    110,
    122,
    97,
    95,
    116,
    114,
    97,
    99,
    107,
    95,
    116,
    104,
    101,
    109,
    101,
    95,
    109,
    111,
    100,
    101,
  ]);
  static final _legacyLocaleKey = String.fromCharCodes(const [
    107,
    119,
    97,
    110,
    122,
    97,
    95,
    116,
    114,
    97,
    99,
    107,
    95,
    108,
    111,
    99,
    97,
    108,
    101,
  ]);

  final FlutterSecureStorage _storage;
  ThemeMode _themeMode = ThemeMode.system;
  Locale _locale = const Locale('en');

  ThemeMode get themeMode => _themeMode;
  Locale get locale => _locale;
  bool get usesDarkMode => _themeMode == ThemeMode.dark;
  bool get usesSwahili => _locale.languageCode == 'sw';

  Future<void> load() async {
    final theme = await _readMigrated(_themeKey, _legacyThemeKey);
    final language = await _readMigrated(_localeKey, _legacyLocaleKey);
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
    await _storage.delete(key: _legacyThemeKey);
    notifyListeners();
  }

  Future<void> setSwahili(bool enabled) async {
    await setLocale(Locale(enabled ? 'sw' : 'en'));
  }

  Future<void> setLocale(Locale locale) async {
    _locale = Locale(locale.languageCode == 'sw' ? 'sw' : 'en');
    await _storage.write(key: _localeKey, value: _locale.languageCode);
    await _storage.delete(key: _legacyLocaleKey);
    notifyListeners();
  }

  Future<String?> _readMigrated(String key, String legacyKey) async {
    final current = await _storage.read(key: key);
    if (current != null && current.isNotEmpty) return current;
    final legacy = await _storage.read(key: legacyKey);
    if (legacy == null || legacy.isEmpty) return null;
    await _storage.write(key: key, value: legacy);
    await _storage.delete(key: legacyKey);
    return legacy;
  }
}
