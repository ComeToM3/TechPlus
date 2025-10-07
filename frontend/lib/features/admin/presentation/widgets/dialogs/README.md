# Dialogs de Gestion des Horaires

Ce dossier contient tous les dialogs nécessaires pour la configuration des horaires dans l'interface d'administration.

## Dialogs Disponibles

### 1. SlotDurationDialog
**Fichier:** `slot_duration_dialog.dart`

Dialog pour modifier la durée des créneaux horaires.

**Fonctionnalités:**
- Options prédéfinies (15, 30, 45, 60, 90, 120 minutes)
- Durée personnalisée
- Descriptions des options
- Validation des entrées

**Utilisation:**
```dart
SlotDurationDialog(
  currentDuration: 30,
  onDurationChanged: (duration) {
    // Mettre à jour la durée
  },
)
```

### 2. BufferTimeDialog
**Fichier:** `buffer_time_dialog.dart`

Dialog pour configurer le temps de pause entre les créneaux.

**Fonctionnalités:**
- Options prédéfinies (0, 5, 10, 15, 20, 30 minutes)
- Temps de pause personnalisé
- Information sur l'impact
- Descriptions des options

**Utilisation:**
```dart
BufferTimeDialog(
  currentBufferTime: 15,
  onBufferTimeChanged: (bufferTime) {
    // Mettre à jour le temps de pause
  },
)
```

### 3. AdvanceBookingDialog
**Fichier:** `advance_booking_dialog.dart`

Dialog pour configurer la réservation avancée.

**Fonctionnalités:**
- Options prédéfinies (7, 14, 30, 60, 90, 180 jours)
- Jours d'avance personnalisés
- Information sur l'impact
- Descriptions des options

**Utilisation:**
```dart
AdvanceBookingDialog(
  currentMaxAdvanceDays: 30,
  onMaxAdvanceDaysChanged: (days) {
    // Mettre à jour les jours d'avance
  },
)
```

### 4. AddTimeSlotDialog
**Fichier:** `add_time_slot_dialog.dart`

Dialog pour ajouter un nouveau créneau horaire.

**Fonctionnalités:**
- Saisie de l'heure
- Configuration de la capacité
- Options (disponible, recommandé)
- Créneaux prédéfinis
- Validation des entrées

**Utilisation:**
```dart
AddTimeSlotDialog(
  dayOfWeek: DayOfWeek.monday,
  onTimeSlotAdded: (timeSlot) {
    // Ajouter le créneau
  },
)
```

## Structure des Fichiers

```
dialogs/
├── dialogs.dart              # Fichier d'export principal
├── slot_duration_dialog.dart  # Dialog de durée des créneaux
├── buffer_time_dialog.dart    # Dialog de temps de pause
├── advance_booking_dialog.dart # Dialog de réservation avancée
├── add_time_slot_dialog.dart   # Dialog d'ajout de créneau
├── dialogs_test.dart          # Tests unitaires
└── README.md                  # Documentation
```

## Intégration

Tous les dialogs sont intégrés dans le `ScheduleConfigurationWidget` et peuvent être utilisés via le fichier d'export `dialogs.dart` :

```dart
import 'dialogs/dialogs.dart';
```

## Tests

Les tests unitaires sont disponibles dans `dialogs_test.dart` et couvrent :
- Affichage correct des dialogs
- Fonctionnalités de base
- Validation des entrées

## Personnalisation

Chaque dialog peut être personnalisé en modifiant :
- Les options prédéfinies
- Les descriptions
- Les validations
- L'apparence (thème, couleurs, etc.)

## Notes de Développement

- Tous les dialogs utilisent le système de localisation Flutter
- Les validations sont intégrées dans chaque dialog
- L'état est géré localement dans chaque dialog
- Les callbacks permettent la communication avec le widget parent
