import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Provider pour la gestion de la localisation de l'application
final localeProvider = StateNotifierProvider<LocaleNotifier, Locale>((ref) {
  return LocaleNotifier();
});

class LocaleNotifier extends StateNotifier<Locale> {
  static const String _localeKey = 'app_locale';

  LocaleNotifier() : super(const Locale('fr', 'FR')) {
    _loadLocale();
  }

  /// Charge la locale sauvegardée
  Future<void> _loadLocale() async {
    final prefs = await SharedPreferences.getInstance();
    final localeCode = prefs.getString(_localeKey) ?? 'fr';
    state = Locale(localeCode);
  }

  /// Sauvegarde la locale sélectionnée
  Future<void> _saveLocale(String localeCode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_localeKey, localeCode);
  }

  /// Change la locale
  Future<void> setLocale(String localeCode) async {
    state = Locale(localeCode);
    await _saveLocale(localeCode);
  }

  /// Retourne si la locale actuelle est française
  bool get isFrench => state.languageCode == 'fr';

  /// Retourne si la locale actuelle est anglaise
  bool get isEnglish => state.languageCode == 'en';

  /// Retourne le code de langue actuel
  String get languageCode => state.languageCode;
}
