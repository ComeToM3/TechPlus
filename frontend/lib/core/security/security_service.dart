import 'package:flutter/foundation.dart';
import 'secure_storage_service.dart';
import 'certificate_pinning.dart';
import 'input_sanitizer_simple.dart';
import 'https_enforcement.dart';
import 'token_manager.dart';

/// Service principal de sécurité qui orchestre tous les composants de sécurité
class SecurityService {
  static final SecurityService _instance = SecurityService._internal();
  factory SecurityService() => _instance;
  SecurityService._internal();

  // Services de sécurité
  late final SecureStorageService _secureStorage;
  late final CertificatePinning _certificatePinning;
  late final InputSanitizer _inputSanitizer;
  late final HttpsEnforcement _httpsEnforcement;
  late final TokenManager _tokenManager;

  // État de la sécurité
  bool _isInitialized = false;
  bool _isSecure = false;

  /// Initialise le service de sécurité
  Future<void> initialize() async {
    if (_isInitialized) {
      if (kDebugMode) {
        print('⚠️ Security service already initialized');
      }
      return;
    }

    try {
      if (kDebugMode) {
        print('🔒 Initializing security service...');
      }

      // Initialiser les services
      _secureStorage = SecureStorageService();
      _certificatePinning = CertificatePinning();
      _inputSanitizer = InputSanitizer();
      _httpsEnforcement = HttpsEnforcement();
      _tokenManager = TokenManager();

      // Vérifier la disponibilité du stockage sécurisé
      final storageAvailable = await _secureStorage.isAvailable();
      if (!storageAvailable) {
        throw SecurityException('Secure storage not available');
      }

      // Initialiser le gestionnaire de tokens
      await _tokenManager.initialize();

      // Valider la configuration du certificate pinning
      final pinningValid = _certificatePinning.validateConfiguration();
      if (!pinningValid) {
        if (kDebugMode) {
          print('⚠️ Certificate pinning configuration invalid');
        }
      }

      // Configurer la sécurité réseau
      await _configureNetworkSecurity();

      // Configurer les canaux de sécurité
      await _configureSecurityChannels();

      _isInitialized = true;
      _isSecure = true;

      if (kDebugMode) {
        print('✅ Security service initialized successfully');
        print('   Secure storage: Available');
        print('   Certificate pinning: ${pinningValid ? "Valid" : "Invalid"}');
        print('   HTTPS enforcement: ${_httpsEnforcement.isEnabled ? "Enabled" : "Disabled"}');
        print('   Token manager: Initialized');
      }
    } catch (e) {
      _isInitialized = false;
      _isSecure = false;
      
      if (kDebugMode) {
        print('❌ Error initializing security service: $e');
      }
      rethrow;
    }
  }

  /// Configure la sécurité réseau
  Future<void> _configureNetworkSecurity() async {
    try {
      // Configurer la sécurité réseau pour Android/iOS
      // Les configurations spécifiques sont dans les fichiers de configuration
      
      if (kDebugMode) {
        print('🌐 Configuring network security...');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error configuring network security: $e');
      }
      rethrow;
    }
  }

  /// Configure les canaux de sécurité
  Future<void> _configureSecurityChannels() async {
    try {
      // Configurer les canaux de communication sécurisés
      // Pour les communications avec le backend
      
      if (kDebugMode) {
        print('📡 Configuring security channels...');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error configuring security channels: $e');
      }
      rethrow;
    }
  }

  /// Vérifie si le service de sécurité est initialisé
  bool get isInitialized => _isInitialized;

  /// Vérifie si l'application est en mode sécurisé
  bool get isSecure => _isSecure;

  /// Obtient le service de stockage sécurisé
  SecureStorageService get secureStorage => _secureStorage;

  /// Obtient le service de certificate pinning
  CertificatePinning get certificatePinning => _certificatePinning;

  /// Obtient le service de sanitisation des entrées
  InputSanitizer get inputSanitizer => _inputSanitizer;

  /// Obtient le service d'enforcement HTTPS
  HttpsEnforcement get httpsEnforcement => _httpsEnforcement;

  /// Obtient le gestionnaire de tokens
  TokenManager get tokenManager => _tokenManager;

  /// Valide la sécurité de l'application
  Future<SecurityValidationResult> validateSecurity() async {
    try {
      final results = <String, bool>{};

      // Vérifier le stockage sécurisé
      results['secureStorage'] = await _secureStorage.isAvailable();

      // Vérifier le certificate pinning
      results['certificatePinning'] = _certificatePinning.validateConfiguration();

      // Vérifier l'enforcement HTTPS
      results['httpsEnforcement'] = _httpsEnforcement.isEnabled;

      // Vérifier les tokens
      results['tokenManager'] = _tokenManager.isAuthenticated();

      // Calculer le score de sécurité
      final totalChecks = results.length;
      final passedChecks = results.values.where((passed) => passed).length;
      final securityScore = (passedChecks / totalChecks * 100).round();

      return SecurityValidationResult(
        score: securityScore,
        results: results,
        isSecure: securityScore >= 80, // Minimum 80% pour être considéré sécurisé
      );
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error validating security: $e');
      }
      return SecurityValidationResult(
        score: 0,
        results: {},
        isSecure: false,
        error: e.toString(),
      );
    }
  }

  /// Effectue un audit de sécurité complet
  Future<SecurityAuditResult> performSecurityAudit() async {
    try {
      if (kDebugMode) {
        print('🔍 Performing security audit...');
      }

      final auditResults = <String, dynamic>{};

      // Audit du stockage sécurisé
      auditResults['secureStorage'] = {
        'available': await _secureStorage.isAvailable(),
        'status': await _secureStorage.getAllKeys(),
      };

      // Audit du certificate pinning
      auditResults['certificatePinning'] = _certificatePinning.getStatus();

      // Audit de la sanitisation des entrées
      auditResults['inputSanitizer'] = _inputSanitizer.getStatus();

      // Audit de l'enforcement HTTPS
      auditResults['httpsEnforcement'] = _httpsEnforcement.getStatus();

      // Audit du gestionnaire de tokens
      auditResults['tokenManager'] = _tokenManager.getStatus();

      // Audit de la configuration réseau
      auditResults['networkSecurity'] = {
        'platform': defaultTargetPlatform.name,
        'isDebugMode': kDebugMode,
        'isReleaseMode': kReleaseMode,
      };

      return SecurityAuditResult(
        timestamp: DateTime.now(),
        results: auditResults,
        recommendations: _generateSecurityRecommendations(auditResults),
      );
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error performing security audit: $e');
      }
      return SecurityAuditResult(
        timestamp: DateTime.now(),
        results: {},
        recommendations: ['Error performing audit: $e'],
      );
    }
  }

  /// Génère des recommandations de sécurité
  List<String> _generateSecurityRecommendations(Map<String, dynamic> auditResults) {
    final recommendations = <String>[];

    // Vérifier le stockage sécurisé
    final secureStorage = auditResults['secureStorage'] as Map<String, dynamic>?;
    if (secureStorage?['available'] != true) {
      recommendations.add('Enable secure storage for sensitive data');
    }

    // Vérifier le certificate pinning
    final certificatePinning = auditResults['certificatePinning'] as Map<String, dynamic>?;
    if (certificatePinning?['enabled'] != true) {
      recommendations.add('Enable certificate pinning for API communications');
    }

    // Vérifier l'enforcement HTTPS
    final httpsEnforcement = auditResults['httpsEnforcement'] as Map<String, dynamic>?;
    if (httpsEnforcement?['enabled'] != true) {
      recommendations.add('Enable HTTPS enforcement for all network communications');
    }

    // Vérifier les tokens
    final tokenManager = auditResults['tokenManager'] as Map<String, dynamic>?;
    if (tokenManager?['isAuthenticated'] != true) {
      recommendations.add('Implement proper token management and authentication');
    }

    // Recommandations générales
    if (kDebugMode) {
      recommendations.add('Disable debug mode in production builds');
    }

    if (recommendations.isEmpty) {
      recommendations.add('Security configuration looks good!');
    }

    return recommendations;
  }

  /// Nettoie toutes les données sensibles
  Future<void> clearAllSensitiveData() async {
    try {
      if (kDebugMode) {
        print('🧹 Clearing all sensitive data...');
      }

      // Nettoyer les tokens
      await _tokenManager.clearTokens();

      // Nettoyer le stockage sécurisé
      await _secureStorage.clearAll();

      if (kDebugMode) {
        print('✅ All sensitive data cleared');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error clearing sensitive data: $e');
      }
      rethrow;
    }
  }

  /// Obtient le statut complet de la sécurité
  Map<String, dynamic> getSecurityStatus() {
    return {
      'initialized': _isInitialized,
      'secure': _isSecure,
      'timestamp': DateTime.now().toIso8601String(),
      'services': {
        'secureStorage': _secureStorage.isAvailable(),
        'certificatePinning': _certificatePinning.isEnabled,
        'httpsEnforcement': _httpsEnforcement.isEnabled,
        'tokenManager': _tokenManager.isAuthenticated(),
      },
    };
  }
}

/// Résultat de validation de sécurité
class SecurityValidationResult {
  final int score;
  final Map<String, bool> results;
  final bool isSecure;
  final String? error;

  const SecurityValidationResult({
    required this.score,
    required this.results,
    required this.isSecure,
    this.error,
  });

  @override
  String toString() {
    return 'SecurityValidationResult(score: $score%, isSecure: $isSecure, results: $results)';
  }
}

/// Résultat d'audit de sécurité
class SecurityAuditResult {
  final DateTime timestamp;
  final Map<String, dynamic> results;
  final List<String> recommendations;

  const SecurityAuditResult({
    required this.timestamp,
    required this.results,
    required this.recommendations,
  });

  @override
  String toString() {
    return 'SecurityAuditResult(timestamp: $timestamp, recommendations: ${recommendations.length})';
  }
}

/// Exception de sécurité
class SecurityException implements Exception {
  final String message;
  const SecurityException(this.message);
  
  @override
  String toString() => 'SecurityException: $message';
}
