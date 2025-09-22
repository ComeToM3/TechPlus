import 'package:flutter/material.dart';

/// Constantes d'accessibilité selon WCAG 2.1 AA
class AccessibilityConstants {
  // === CONTRASTE DES COULEURS (WCAG 2.1 AA) ===

  /// Contraste minimum requis pour le texte normal (4.5:1)
  static const double minContrastRatio = 4.5;

  /// Contraste minimum requis pour le texte large (3:1)
  static const double minContrastRatioLarge = 3.0;

  /// Taille de texte considérée comme "large" (18pt+ ou 14pt+ bold)
  static const double largeTextSize = 18.0;

  // === TAILLES MINIMALES DE TOUCH TARGETS ===

  /// Taille minimale recommandée pour les éléments interactifs (44x44dp)
  static const double minTouchTargetSize = 44.0;

  /// Espacement minimal entre les éléments interactifs (8dp)
  static const double minTouchTargetSpacing = 8.0;

  // === DURÉES D'ANIMATION ===

  /// Durée maximale pour les animations (5 secondes selon WCAG)
  static const Duration maxAnimationDuration = Duration(seconds: 5);

  /// Durée recommandée pour les transitions (300ms)
  static const Duration recommendedTransitionDuration = Duration(
    milliseconds: 300,
  );

  // === FOCUS ET NAVIGATION ===

  /// Épaisseur du focus ring (2dp)
  static const double focusRingWidth = 2.0;

  /// Couleur du focus ring (contraste élevé)
  static const Color focusRingColor = Color(0xFF0066CC);

  /// Couleur du focus ring en mode sombre
  static const Color focusRingColorDark = Color(0xFF66B3FF);

  // === SEMANTIC LABELS ===

  /// Labels sémantiques pour les actions courantes
  static const Map<String, String> semanticLabels = {
    'close': 'Fermer',
    'back': 'Retour',
    'next': 'Suivant',
    'previous': 'Précédent',
    'submit': 'Soumettre',
    'cancel': 'Annuler',
    'save': 'Enregistrer',
    'edit': 'Modifier',
    'delete': 'Supprimer',
    'search': 'Rechercher',
    'filter': 'Filtrer',
    'sort': 'Trier',
    'menu': 'Menu',
    'home': 'Accueil',
    'profile': 'Profil',
    'settings': 'Paramètres',
    'help': 'Aide',
    'logout': 'Déconnexion',
    'login': 'Connexion',
    'register': 'S\'inscrire',
    'reserve': 'Réserver',
    'confirm': 'Confirmer',
    'select': 'Sélectionner',
    'deselect': 'Désélectionner',
    'expand': 'Développer',
    'collapse': 'Réduire',
    'show': 'Afficher',
    'hide': 'Masquer',
    'play': 'Lire',
    'pause': 'Pause',
    'stop': 'Arrêter',
    'loading': 'Chargement en cours',
    'error': 'Erreur',
    'success': 'Succès',
    'warning': 'Avertissement',
    'info': 'Information',
  };

  // === RÔLES ARIA ÉQUIVALENTS ===

  /// Rôles sémantiques pour les composants
  static const Map<String, String> semanticRoles = {
    'button': 'Bouton',
    'link': 'Lien',
    'textbox': 'Zone de texte',
    'checkbox': 'Case à cocher',
    'radio': 'Bouton radio',
    'slider': 'Curseur',
    'progressbar': 'Barre de progression',
    'tab': 'Onglet',
    'tabpanel': 'Panneau d\'onglet',
    'menu': 'Menu',
    'menuitem': 'Élément de menu',
    'list': 'Liste',
    'listitem': 'Élément de liste',
    'heading': 'Titre',
    'region': 'Région',
    'banner': 'Bannière',
    'navigation': 'Navigation',
    'main': 'Contenu principal',
    'complementary': 'Contenu complémentaire',
    'contentinfo': 'Informations sur le contenu',
    'search': 'Recherche',
    'form': 'Formulaire',
    'alert': 'Alerte',
    'status': 'Statut',
    'dialog': 'Dialogue',
    'tooltip': 'Info-bulle',
  };

  // === MESSAGES D'ACCESSIBILITÉ ===

  /// Messages pour les annonces aux lecteurs d'écran
  static const Map<String, String> accessibilityMessages = {
    'required': 'Obligatoire',
    'optional': 'Optionnel',
    'invalid': 'Invalide',
    'valid': 'Valide',
    'selected': 'Sélectionné',
    'unselected': 'Non sélectionné',
    'checked': 'Coché',
    'unchecked': 'Décoché',
    'expanded': 'Développé',
    'collapsed': 'Réduit',
    'loading': 'Chargement en cours',
    'loaded': 'Chargé',
    'error': 'Erreur',
    'success': 'Succès',
    'warning': 'Avertissement',
    'info': 'Information',
    'new': 'Nouveau',
    'updated': 'Mis à jour',
    'deleted': 'Supprimé',
    'copied': 'Copié',
    'pasted': 'Collé',
    'cut': 'Coupé',
    'undo': 'Annuler',
    'redo': 'Refaire',
  };

  // === CONFIGURATION DES LECTEURS D'ÉCRAN ===

  /// Délai pour les annonces automatiques (ms)
  static const int screenReaderAnnounceDelay = 100;

  /// Priorité des annonces
  static const Map<String, int> announcementPriority = {
    'error': 3,
    'warning': 2,
    'info': 1,
    'success': 1,
  };

  // === TESTS D'ACCESSIBILITÉ ===

  /// Seuils pour les tests automatisés
  static const Map<String, double> testThresholds = {
    'contrastRatio': 4.5,
    'touchTargetSize': 44.0,
    'focusRingWidth': 2.0,
    'animationDuration': 5000.0, // ms
  };

  /// Couleurs de test pour le contraste
  static const List<Color> testColors = [
    Color(0xFF000000), // Noir
    Color(0xFFFFFFFF), // Blanc
    Color(0xFF666666), // Gris moyen
    Color(0xFF999999), // Gris clair
    Color(0xFF333333), // Gris foncé
    Color(0xFF0066CC), // Bleu
    Color(0xFF00C896), // Vert
    Color(0xFFFFB800), // Orange
    Color(0xFFE17055), // Rouge
  ];
}
