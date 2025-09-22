import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:techplus_frontend/main.dart';

void main() {
  group('Widget Tests', () {
    testWidgets('App should start without crashing', (
      WidgetTester tester,
    ) async {
      // Build our app and trigger a frame
      await tester.pumpWidget(const ProviderScope(child: TechPlusApp()));

      // Verify that the app starts
      expect(find.byType(MaterialApp), findsOneWidget);
    });

    testWidgets('App should have MaterialApp as root widget', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(const ProviderScope(child: TechPlusApp()));

      // Verify MaterialApp is present
      expect(find.byType(MaterialApp), findsOneWidget);
    });

    testWidgets('App should have ProviderScope as root', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(const ProviderScope(child: TechPlusApp()));

      // Verify ProviderScope is present
      expect(find.byType(ProviderScope), findsOneWidget);
    });
  });
}
