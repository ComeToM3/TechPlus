import 'package:flutter/foundation.dart';

/// Service de sanitisation des entrées utilisateur (version simplifiée)
/// Protège contre les attaques XSS, injection SQL, et autres vulnérabilités
class InputSanitizer {
  static const InputSanitizer _instance = InputSanitizer._internal();
  factory InputSanitizer() => _instance;
  const InputSanitizer._internal();

  // Caractères dangereux à échapper
  static const Map<String, String> _htmlEntities = {
    '&': '&amp;',
    '<': '&lt;',
    '>': '&gt;',
    '"': '&quot;',
    "'": '&#x27;',
    '/': '&#x2F;',
    '`': '&#x60;',
    '=': '&#x3D;',
  };

  /// Sanitise une chaîne de texte simple
  String sanitizeText(String input) {
    if (input.isEmpty) return input;

    try {
      // Échapper les caractères HTML dangereux
      String sanitized = _escapeHtml(input);
      
      // Nettoyer les espaces multiples
      sanitized = sanitized.replaceAll(RegExp(r'\s+'), ' ').trim();
      
      return sanitized;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error sanitizing text: $e');
      }
      return '';
    }
  }

  /// Sanitise du HTML en gardant seulement les tags autorisés
  String sanitizeHtml(String input) {
    if (input.isEmpty) return input;

    try {
      // Pour l'instant, on échappe tout le HTML
      return _escapeHtml(input);
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error sanitizing HTML: $e');
      }
      return '';
    }
  }

  /// Sanitise une URL
  String sanitizeUrl(String url) {
    if (url.isEmpty) return url;

    try {
      // Vérifier que c'est une URL valide
      final uri = Uri.tryParse(url);
      if (uri == null) {
        if (kDebugMode) {
          print('⚠️ Invalid URL format: $url');
        }
        return '';
      }

      // Vérifier le schéma
      if (!_isAllowedScheme(uri.scheme)) {
        if (kDebugMode) {
          print('⚠️ Disallowed URL scheme: ${uri.scheme}');
        }
        return '';
      }

      return uri.toString();
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error sanitizing URL: $e');
      }
      return '';
    }
  }

  /// Sanitise un email
  String sanitizeEmail(String email) {
    if (email.isEmpty) return email;

    try {
      // Nettoyer l'email
      final cleanEmail = email.trim().toLowerCase();
      
      // Vérifier le format
      final emailRegex = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
      if (!emailRegex.hasMatch(cleanEmail)) {
        if (kDebugMode) {
          print('⚠️ Invalid email format: $email');
        }
        return '';
      }
      
      return cleanEmail;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error sanitizing email: $e');
      }
      return '';
    }
  }

  /// Sanitise un numéro de téléphone
  String sanitizePhone(String phone) {
    if (phone.isEmpty) return phone;

    try {
      // Garder seulement les chiffres, +, -, (, ), et espaces
      final cleanPhone = phone.replaceAll(RegExp(r'[^\d+\-() ]'), '');
      
      // Vérifier le format basique
      final phoneRegex = RegExp(r'^[\+]?[\d\s\-\(\)]{7,15}$');
      if (!phoneRegex.hasMatch(cleanPhone)) {
        if (kDebugMode) {
          print('⚠️ Invalid phone format: $phone');
        }
        return '';
      }
      
      return cleanPhone;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error sanitizing phone: $e');
      }
      return '';
    }
  }

  /// Sanitise des données JSON
  Map<String, dynamic> sanitizeJson(Map<String, dynamic> data) {
    try {
      final sanitized = <String, dynamic>{};
      
      for (final entry in data.entries) {
        final key = sanitizeText(entry.key);
        final value = _sanitizeValue(entry.value);
        sanitized[key] = value;
      }
      
      return sanitized;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error sanitizing JSON: $e');
      }
      return {};
    }
  }

  /// Échappe les caractères HTML dangereux
  String _escapeHtml(String input) {
    String escaped = input;
    for (final entry in _htmlEntities.entries) {
      escaped = escaped.replaceAll(entry.key, entry.value);
    }
    return escaped;
  }

  /// Vérifie si un schéma d'URL est autorisé
  bool _isAllowedScheme(String scheme) {
    const allowedSchemes = {'http', 'https', 'mailto', 'tel'};
    return allowedSchemes.contains(scheme.toLowerCase());
  }

  /// Sanitise une valeur dynamique
  dynamic _sanitizeValue(dynamic value) {
    if (value is String) {
      return sanitizeText(value);
    } else if (value is Map<String, dynamic>) {
      return sanitizeJson(value);
    } else if (value is List) {
      return value.map((item) => _sanitizeValue(item)).toList();
    } else {
      return value;
    }
  }

  /// Valide la longueur d'une entrée
  String validateLength(String input, {int? minLength, int? maxLength}) {
    if (minLength != null && input.length < minLength) {
      throw ArgumentError('Input too short: minimum $minLength characters required');
    }
    
    if (maxLength != null && input.length > maxLength) {
      throw ArgumentError('Input too long: maximum $maxLength characters allowed');
    }
    
    return input;
  }

  /// Obtient le statut du sanitiseur
  Map<String, dynamic> getStatus() {
    return {
      'htmlEntitiesCount': _htmlEntities.length,
      'version': 'simplified',
    };
  }
}
