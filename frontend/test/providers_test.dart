import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:techplus_frontend/core/providers/theme_provider.dart';
import 'package:techplus_frontend/core/providers/locale_provider.dart';

void main() {
  group('Provider Tests', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer();
    });

    tearDown(() {
      container.dispose();
    });

    test('Theme provider should have system theme by default', () {
      final themeMode = container.read(themeProvider);
      expect(themeMode, ThemeMode.system);
    });

    test('Theme provider should toggle between light and dark', () {
      // Read initial theme
      final initialTheme = container.read(themeProvider);

      // Toggle theme
      container.read(themeProvider.notifier).toggleTheme();

      // Verify theme changed
      final newTheme = container.read(themeProvider);
      expect(newTheme, isNot(equals(initialTheme)));
    });

    test('Locale provider should have French as default', () {
      final locale = container.read(localeProvider);
      expect(locale.languageCode, 'fr');
    });

    test('Locale provider should change locale', () {
      // Change to English
      container
          .read(localeProvider.notifier)
          .setLocale(const Locale('en', 'US'));

      // Verify locale changed
      final newLocale = container.read(localeProvider);
      expect(newLocale.languageCode, 'en');
    });
  });
}
