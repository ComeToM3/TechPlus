import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../theme/app_theme.dart';

/// Provider pour la gestion du thème
final themeProvider = StateNotifierProvider<ThemeNotifier, ThemeMode>((ref) {
  return ThemeNotifier();
});

/// Notifier pour la gestion du thème
class ThemeNotifier extends StateNotifier<ThemeMode> {
  static const String _themeKey = 'theme_mode';

  ThemeNotifier() : super(ThemeMode.system) {
    _loadTheme();
  }

  /// Charger le thème sauvegardé
  Future<void> _loadTheme() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final themeIndex = prefs.getInt(_themeKey) ?? 0;
      state = ThemeMode.values[themeIndex];
    } catch (e) {
      // En cas d'erreur, utiliser le thème système
      state = ThemeMode.system;
    }
  }

  /// Sauvegarder le thème
  Future<void> _saveTheme(ThemeMode theme) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_themeKey, theme.index);
    } catch (e) {
      // Ignorer les erreurs de sauvegarde
    }
  }

  /// Changer le thème
  Future<void> setTheme(ThemeMode theme) async {
    state = theme;
    await _saveTheme(theme);
  }

  /// Basculer entre clair et sombre
  Future<void> toggleTheme() async {
    final newTheme = state == ThemeMode.light
        ? ThemeMode.dark
        : ThemeMode.light;
    await setTheme(newTheme);
  }

  /// Obtenir le thème actuel
  ThemeData getCurrentTheme(BuildContext context) {
    switch (state) {
      case ThemeMode.light:
        return AppTheme.lightTheme;
      case ThemeMode.dark:
        return AppTheme.darkTheme;
      case ThemeMode.system:
        return MediaQuery.of(context).platformBrightness == Brightness.dark
            ? AppTheme.darkTheme
            : AppTheme.lightTheme;
    }
  }

  /// Vérifier si le mode sombre est actif
  bool isDarkMode(BuildContext context) {
    switch (state) {
      case ThemeMode.light:
        return false;
      case ThemeMode.dark:
        return true;
      case ThemeMode.system:
        return MediaQuery.of(context).platformBrightness == Brightness.dark;
    }
  }
}

/// Provider pour obtenir le thème actuel
final currentThemeProvider = Provider<ThemeData>((ref) {
  // Ce provider sera utilisé dans le contexte de l'application
  return AppTheme.lightTheme; // Valeur par défaut
});

/// Provider pour vérifier le mode sombre
final isDarkModeProvider = Provider<bool>((ref) {
  // Ce provider sera utilisé dans le contexte de l'application
  return false; // Valeur par défaut
});
