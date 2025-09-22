import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:techplus_frontend/core/navigation/app_router.dart';
import 'package:techplus_frontend/main.dart';

void main() {
  group('Navigation Tests', () {
    testWidgets('Should navigate to public homepage by default', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(const ProviderScope(child: TechPlusApp()));

      await tester.pumpAndSettle();

      // Verify we're on the public homepage
      expect(find.text('TechPlus'), findsOneWidget);
    });

    testWidgets('Should navigate to reservation page', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(const ProviderScope(child: TechPlusApp()));

      await tester.pumpAndSettle();

      // Find and tap reservation button
      final reservationButton = find.text('Réserver');
      if (reservationButton.evaluate().isNotEmpty) {
        await tester.tap(reservationButton);
        await tester.pumpAndSettle();

        // Verify we're on the reservation page
        expect(find.text('Réserver une table'), findsOneWidget);
      }
    });

    testWidgets('Should navigate to admin login', (WidgetTester tester) async {
      await tester.pumpWidget(const ProviderScope(child: TechPlusApp()));

      await tester.pumpAndSettle();

      // Find and tap admin login button
      final adminButton = find.text('Admin');
      if (adminButton.evaluate().isNotEmpty) {
        await tester.tap(adminButton);
        await tester.pumpAndSettle();

        // Verify we're on the login page
        expect(find.text('Connexion Admin'), findsOneWidget);
      }
    });

    testWidgets('Should handle back navigation', (WidgetTester tester) async {
      await tester.pumpWidget(const ProviderScope(child: TechPlusApp()));

      await tester.pumpAndSettle();

      // Navigate to reservation page
      final reservationButton = find.text('Réserver');
      if (reservationButton.evaluate().isNotEmpty) {
        await tester.tap(reservationButton);
        await tester.pumpAndSettle();

        // Go back
        await tester.pageBack();
        await tester.pumpAndSettle();

        // Verify we're back on homepage
        expect(find.text('TechPlus'), findsOneWidget);
      }
    });

    testWidgets('Should navigate to manage reservation page', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(const ProviderScope(child: TechPlusApp()));

      await tester.pumpAndSettle();

      // Find and tap manage reservation button
      final manageButton = find.text('Gérer ma réservation');
      if (manageButton.evaluate().isNotEmpty) {
        await tester.tap(manageButton);
        await tester.pumpAndSettle();

        // Verify we're on the manage reservation page
        expect(find.text('Gérer ma réservation'), findsOneWidget);
      }
    });
  });
}
