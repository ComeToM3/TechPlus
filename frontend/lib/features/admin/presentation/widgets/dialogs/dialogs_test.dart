import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import '../../../../../generated/l10n/app_localizations.dart';
import '../../../domain/entities/schedule_entity.dart';
import 'slot_duration_dialog.dart';
import 'buffer_time_dialog.dart';
import 'advance_booking_dialog.dart';
import 'add_time_slot_dialog.dart';

void main() {
  group('Schedule Dialogs Tests', () {
    testWidgets('SlotDurationDialog should display correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: SlotDurationDialog(
              currentDuration: 30,
              onDurationChanged: (duration) {},
            ),
          ),
        ),
      );

      expect(find.text('30min'), findsOneWidget);
      expect(find.text('Standard'), findsOneWidget);
    });

    testWidgets('BufferTimeDialog should display correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: BufferTimeDialog(
              currentBufferTime: 15,
              onBufferTimeChanged: (bufferTime) {},
            ),
          ),
        ),
      );

      expect(find.text('15min'), findsOneWidget);
      expect(find.text('Pause confortable'), findsOneWidget);
    });

    testWidgets('AdvanceBookingDialog should display correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: AdvanceBookingDialog(
              currentMaxAdvanceDays: 30,
              onMaxAdvanceDaysChanged: (days) {},
            ),
          ),
        ),
      );

      expect(find.text('30 jours'), findsOneWidget);
      expect(find.text('Moyen terme'), findsOneWidget);
    });

    testWidgets('AddTimeSlotDialog should display correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: AddTimeSlotDialog(
              dayOfWeek: DayOfWeek.monday,
              onTimeSlotAdded: (timeSlot) {},
            ),
          ),
        ),
      );

      expect(find.text('Ajouter un créneau - Lundi'), findsOneWidget);
      expect(find.text('12:00'), findsOneWidget);
    });
  });
}
