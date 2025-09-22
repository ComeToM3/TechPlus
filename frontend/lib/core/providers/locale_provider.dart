import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Provider pour la gestion des langues
final localeProvider = StateNotifierProvider<LocaleNotifier, Locale>((ref) {
  return LocaleNotifier();
});

/// Notifier pour la gestion des langues
class LocaleNotifier extends StateNotifier<Locale> {
  static const String _localeKey = 'app_locale';
  static const Locale _defaultLocale = Locale('fr', 'FR');

  LocaleNotifier() : super(_defaultLocale) {
    _loadLocale();
  }

  /// Charger la langue sauvegardée
  Future<void> _loadLocale() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final localeCode = prefs.getString(_localeKey);

      if (localeCode != null) {
        final parts = localeCode.split('_');
        if (parts.length == 2) {
          state = Locale(parts[0], parts[1]);
        } else {
          state = Locale(parts[0]);
        }
      } else {
        state = _defaultLocale;
      }
    } catch (e) {
      // En cas d'erreur, utiliser la langue par défaut
      state = _defaultLocale;
    }
  }

  /// Sauvegarder la langue
  Future<void> _saveLocale(Locale locale) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final localeCode = locale.countryCode != null
          ? '${locale.languageCode}_${locale.countryCode}'
          : locale.languageCode;
      await prefs.setString(_localeKey, localeCode);
    } catch (e) {
      // Ignorer les erreurs de sauvegarde
    }
  }

  /// Changer la langue
  Future<void> setLocale(Locale locale) async {
    state = locale;
    await _saveLocale(locale);
  }

  /// Basculer entre français et anglais
  Future<void> toggleLanguage() async {
    final newLocale = state.languageCode == 'fr'
        ? const Locale('en', 'US')
        : const Locale('fr', 'FR');
    await setLocale(newLocale);
  }

  /// Obtenir la langue actuelle
  String get currentLanguageCode => state.languageCode;

  /// Vérifier si la langue est le français
  bool get isFrench => state.languageCode == 'fr';

  /// Vérifier si la langue est l'anglais
  bool get isEnglish => state.languageCode == 'en';

  /// Obtenir la liste des langues supportées
  static const List<Locale> supportedLocales = [
    Locale('fr', 'FR'),
    Locale('en', 'US'),
  ];

  /// Obtenir le nom de la langue
  String getLanguageName(Locale locale) {
    switch (locale.languageCode) {
      case 'fr':
        return 'Français';
      case 'en':
        return 'English';
      default:
        return locale.languageCode;
    }
  }

  /// Obtenir le drapeau de la langue
  String getLanguageFlag(Locale locale) {
    switch (locale.languageCode) {
      case 'fr':
        return '🇫🇷';
      case 'en':
        return '🇺🇸';
      default:
        return '🌐';
    }
  }
}
