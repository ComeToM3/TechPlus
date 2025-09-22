import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
// import 'accessibility_constants.dart'; // Unused
import 'accessibility_utils.dart';

/// Service pour gérer les annonces aux lecteurs d'écran
class ScreenReaderService {
  static final ScreenReaderService _instance = ScreenReaderService._internal();
  factory ScreenReaderService() => _instance;
  ScreenReaderService._internal();

  /// Annonce un message aux lecteurs d'écran
  static void announce(String message, {String? priority}) {
    final announcement = AccessibilityUtils.createAnnouncement(
      message,
      priority: priority,
    );

    // Utiliser Semantics pour annoncer le message
    SemanticsService.announce(announcement, TextDirection.ltr);
  }

  /// Annonce une erreur
  static void announceError(String message) {
    announce(message, priority: 'error');
  }

  /// Annonce un succès
  static void announceSuccess(String message) {
    announce(message, priority: 'success');
  }

  /// Annonce un avertissement
  static void announceWarning(String message) {
    announce(message, priority: 'warning');
  }

  /// Annonce une information
  static void announceInfo(String message) {
    announce(message, priority: 'info');
  }

  /// Annonce un changement d'état
  static void announceStateChange(String message) {
    announce(message, priority: 'info');
  }

  /// Annonce une action effectuée
  static void announceAction(String action, {String? target}) {
    final message = target != null ? '$action sur $target' : action;
    announce(message, priority: 'info');
  }

  /// Annonce une navigation
  static void announceNavigation(String destination) {
    announce('Navigation vers $destination', priority: 'info');
  }

  /// Annonce un chargement
  static void announceLoading(String? context) {
    final message = context != null
        ? 'Chargement de $context'
        : 'Chargement en cours';
    announce(message, priority: 'info');
  }

  /// Annonce la fin du chargement
  static void announceLoaded(String? context) {
    final message = context != null ? '$context chargé' : 'Chargement terminé';
    announce(message, priority: 'info');
  }

  /// Annonce une validation
  static void announceValidation(String message, bool isValid) {
    final status = isValid ? 'valide' : 'invalide';
    announce('$message: $status', priority: isValid ? 'info' : 'error');
  }

  /// Annonce un compteur
  static void announceCounter(int current, int total, {String? context}) {
    final message = context != null
        ? '$context: $current sur $total'
        : '$current sur $total';
    announce(message, priority: 'info');
  }

  /// Annonce une sélection
  static void announceSelection(String item, bool isSelected) {
    final status = isSelected ? 'sélectionné' : 'désélectionné';
    announce('$item $status', priority: 'info');
  }

  /// Annonce une expansion/réduction
  static void announceExpansion(String item, bool isExpanded) {
    final status = isExpanded ? 'développé' : 'réduit';
    announce('$item $status', priority: 'info');
  }

  /// Annonce une ouverture/fermeture
  static void announceToggle(String item, bool isOpen) {
    final status = isOpen ? 'ouvert' : 'fermé';
    announce('$item $status', priority: 'info');
  }

  /// Annonce une valeur numérique
  static void announceValue(String label, dynamic value, {String? unit}) {
    final message = unit != null ? '$label: $value $unit' : '$label: $value';
    announce(message, priority: 'info');
  }

  /// Annonce une date
  static void announceDate(DateTime date, {String? context}) {
    final formattedDate = '${date.day}/${date.month}/${date.year}';
    final message = context != null
        ? '$context: $formattedDate'
        : formattedDate;
    announce(message, priority: 'info');
  }

  /// Annonce une heure
  static void announceTime(TimeOfDay time, {String? context}) {
    final formattedTime =
        '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
    final message = context != null
        ? '$context: $formattedTime'
        : formattedTime;
    announce(message, priority: 'info');
  }

  /// Annonce une durée
  static void announceDuration(Duration duration, {String? context}) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);

    String formattedDuration;
    if (hours > 0) {
      formattedDuration = '${hours}h ${minutes}min';
    } else if (minutes > 0) {
      formattedDuration = '${minutes}min ${seconds}s';
    } else {
      formattedDuration = '${seconds}s';
    }

    final message = context != null
        ? '$context: $formattedDuration'
        : formattedDuration;
    announce(message, priority: 'info');
  }

  /// Annonce une liste
  static void announceList(List<String> items, {String? context}) {
    if (items.isEmpty) {
      final message = context != null ? '$context: liste vide' : 'Liste vide';
      announce(message, priority: 'info');
      return;
    }

    final count = items.length;
    final message = context != null
        ? '$context: $count éléments'
        : 'Liste de $count éléments';
    announce(message, priority: 'info');
  }

  /// Annonce une recherche
  static void announceSearch(String query, int results, {String? context}) {
    final message = context != null
        ? 'Recherche "$query" dans $context: $results résultats'
        : 'Recherche "$query": $results résultats';
    announce(message, priority: 'info');
  }

  /// Annonce un tri
  static void announceSort(String field, bool ascending) {
    final direction = ascending ? 'croissant' : 'décroissant';
    announce('Tri par $field en ordre $direction', priority: 'info');
  }

  /// Annonce un filtre
  static void announceFilter(String filter, bool isActive) {
    final status = isActive ? 'activé' : 'désactivé';
    announce('Filtre $filter $status', priority: 'info');
  }

  /// Annonce une pagination
  static void announcePagination(int currentPage, int totalPages) {
    announce('Page $currentPage sur $totalPages', priority: 'info');
  }

  /// Annonce une progression
  static void announceProgress(int current, int total, {String? context}) {
    final percentage = ((current / total) * 100).round();
    final message = context != null
        ? '$context: $current sur $total ($percentage%)'
        : '$current sur $total ($percentage%)';
    announce(message, priority: 'info');
  }

  /// Annonce une connexion
  static void announceConnection(bool isConnected, {String? service}) {
    final status = isConnected ? 'connecté' : 'déconnecté';
    final message = service != null ? '$service $status' : 'Connexion $status';
    announce(message, priority: isConnected ? 'success' : 'error');
  }

  /// Annonce une synchronisation
  static void announceSync(bool isSyncing, {String? context}) {
    final status = isSyncing ? 'en cours' : 'terminée';
    final message = context != null
        ? 'Synchronisation $context $status'
        : 'Synchronisation $status';
    announce(message, priority: 'info');
  }

  /// Annonce une sauvegarde
  static void announceSave(bool isSaving, {String? context}) {
    final status = isSaving ? 'en cours' : 'terminée';
    final message = context != null
        ? 'Sauvegarde $context $status'
        : 'Sauvegarde $status';
    announce(message, priority: 'info');
  }

  /// Annonce une suppression
  static void announceDelete(String item, bool isDeleted) {
    final status = isDeleted ? 'supprimé' : 'suppression annulée';
    announce('$item $status', priority: isDeleted ? 'success' : 'info');
  }

  /// Annonce une copie
  static void announceCopy(String item, bool isCopied) {
    final status = isCopied ? 'copié' : 'copie annulée';
    announce('$item $status', priority: isCopied ? 'success' : 'info');
  }

  /// Annonce un collage
  static void announcePaste(String item, bool isPasted) {
    final status = isPasted ? 'collé' : 'collage annulé';
    announce('$item $status', priority: isPasted ? 'success' : 'info');
  }

  /// Annonce une annulation
  static void announceUndo(String action, bool isUndone) {
    final status = isUndone ? 'annulée' : 'annulation annulée';
    announce('$action $status', priority: isUndone ? 'success' : 'info');
  }

  /// Annonce une restauration
  static void announceRedo(String action, bool isRedone) {
    final status = isRedone ? 'restaurée' : 'restauration annulée';
    announce('$action $status', priority: isRedone ? 'success' : 'info');
  }
}
