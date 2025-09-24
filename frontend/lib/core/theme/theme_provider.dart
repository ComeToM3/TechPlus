import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Provider pour la gestion du thème de l'application
final themeProvider = StateNotifierProvider<ThemeNotifier, ThemeMode>((ref) {
  return ThemeNotifier();
});

class ThemeNotifier extends StateNotifier<ThemeMode> {
  static const String _themeKey = 'theme_mode';

  ThemeNotifier() : super(ThemeMode.system) {
    _loadTheme();
  }

  /// Charge le thème sauvegardé
  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final themeIndex = prefs.getInt(_themeKey) ?? 0;
    state = ThemeMode.values[themeIndex];
  }

  /// Sauvegarde le thème sélectionné
  Future<void> _saveTheme(ThemeMode theme) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_themeKey, theme.index);
  }

  /// Change le thème
  Future<void> setTheme(ThemeMode theme) async {
    state = theme;
    await _saveTheme(theme);
  }

  /// Alterne entre le thème clair et sombre
  Future<void> toggleTheme() async {
    final newTheme = state == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    await setTheme(newTheme);
  }

  /// Retourne si le thème actuel est sombre
  bool get isDarkMode => state == ThemeMode.dark;

  /// Retourne si le thème actuel est clair
  bool get isLightMode => state == ThemeMode.light;
}
