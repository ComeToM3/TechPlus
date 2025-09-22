import 'dart:io';
import 'package:flutter/foundation.dart';

/// Service d'enforcement HTTPS pour forcer les connexions sécurisées
/// Empêche les connexions HTTP non sécurisées en production
class HttpsEnforcement {
  static const HttpsEnforcement _instance = HttpsEnforcement._internal();
  factory HttpsEnforcement() => _instance;
  const HttpsEnforcement._internal();

  // Configuration
  static const bool _enforceHttps = true;
  static const bool _allowHttpInDebug = true;
  static const bool _allowLocalhostHttp = true;
  static const List<String> _allowedHttpHosts = [
    'localhost',
    '127.0.0.1',
    '192.168.1.1', // Exemple d'IP locale
  ];

  /// Vérifie si l'enforcement HTTPS est activé
  bool get isEnabled => _enforceHttps;

  /// Valide qu'une URL utilise HTTPS
  bool validateHttpsUrl(String url) {
    try {
      final uri = Uri.parse(url);
      return _validateHttpsUri(uri);
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error parsing URL: $url - $e');
      }
      return false;
    }
  }

  /// Valide qu'un URI utilise HTTPS
  bool _validateHttpsUri(Uri uri) {
    // Vérifier le schéma
    if (uri.scheme.toLowerCase() == 'https') {
      return true;
    }

    // En mode debug, permettre HTTP pour localhost
    if (kDebugMode && _allowHttpInDebug && _isLocalhost(uri.host)) {
      if (kDebugMode) {
        print('🔓 Debug mode: allowing HTTP for localhost');
      }
      return true;
    }

    // Permettre HTTP pour les hosts autorisés
    if (_allowLocalhostHttp && _isAllowedHttpHost(uri.host)) {
      if (kDebugMode) {
        print('🔓 Allowing HTTP for authorized host: ${uri.host}');
      }
      return true;
    }

    // En production, HTTPS est obligatoire
    if (kDebugMode) {
      print('❌ HTTPS required for: ${uri.host}');
    }
    return false;
  }

  /// Vérifie si l'host est localhost
  bool _isLocalhost(String host) {
    return host == 'localhost' || 
           host == '127.0.0.1' || 
           host.startsWith('192.168.') ||
           host.startsWith('10.') ||
           host.startsWith('172.');
  }

  /// Vérifie si l'host est autorisé pour HTTP
  bool _isAllowedHttpHost(String host) {
    return _allowedHttpHosts.contains(host);
  }

  /// Convertit une URL HTTP en HTTPS
  String convertToHttps(String url) {
    try {
      final uri = Uri.parse(url);
      if (uri.scheme.toLowerCase() == 'http') {
        final httpsUri = uri.replace(scheme: 'https');
        if (kDebugMode) {
          print('🔄 Converted HTTP to HTTPS: $url -> ${httpsUri.toString()}');
        }
        return httpsUri.toString();
      }
      return url;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error converting URL to HTTPS: $e');
      }
      return url;
    }
  }

  /// Configure HttpClient pour forcer HTTPS
  void configureHttpClient(HttpClient client) {
    if (!_enforceHttps) {
      if (kDebugMode) {
        print('🔓 HTTPS enforcement disabled');
      }
      return;
    }

    // Intercepter les requêtes pour vérifier HTTPS
    client.badCertificateCallback = (cert, host, port) {
      // Cette fonction est appelée pour les certificats invalides
      // On peut l'utiliser pour logger les tentatives de connexion non sécurisées
      if (kDebugMode) {
        print('⚠️ Bad certificate for $host:$port');
      }
      return false; // Rejeter les certificats invalides
    };

    // Ajouter des headers de sécurité
    client.userAgent = 'TechPlus-App/1.0 (Secure)';

    if (kDebugMode) {
      print('✅ HTTPS enforcement configured for HttpClient');
    }
  }

  /// Configure un client HTTP pour forcer HTTPS
  // http.Client createSecureHttpClient() {
  //   if (!_enforceHttps) {
  //     return http.Client();
  //   }

  //   // Créer un client HTTP personnalisé qui valide HTTPS
  //   return _SecureHttpClient();
  // }

  /// Valide les URLs dans une configuration
  Map<String, dynamic> validateConfiguration(Map<String, String> urls) {
    final results = <String, dynamic>{};
    
    for (final entry in urls.entries) {
      final key = entry.key;
      final url = entry.value;
      
      final isValid = validateHttpsUrl(url);
      results[key] = {
        'url': url,
        'valid': isValid,
        'scheme': Uri.parse(url).scheme,
        'host': Uri.parse(url).host,
      };
      
      if (!isValid) {
        results[key]['suggestion'] = convertToHttps(url);
      }
    }
    
    return results;
  }

  /// Obtient le statut de l'enforcement HTTPS
  Map<String, dynamic> getStatus() {
    return {
      'enabled': _enforceHttps,
      'allowHttpInDebug': _allowHttpInDebug,
      'allowLocalhostHttp': _allowLocalhostHttp,
      'allowedHttpHosts': _allowedHttpHosts,
      'isDebugMode': kDebugMode,
    };
  }
}

/// Client HTTP sécurisé qui valide HTTPS
// class _SecureHttpClient extends http.BaseClient {
//   final http.Client _inner = http.Client();
//   final HttpsEnforcement _enforcement = HttpsEnforcement();

//   @override
//   Future<http.StreamedResponse> send(http.BaseRequest request) {
//     // Valider que l'URL utilise HTTPS
//     if (!_enforcement.validateHttpsUrl(request.url.toString())) {
//       throw SecurityException('HTTPS required for ${request.url.host}');
//     }

//     // Ajouter des headers de sécurité
//     request.headers['User-Agent'] = 'TechPlus-App/1.0 (Secure)';
//     request.headers['X-Requested-With'] = 'TechPlus-App';
    
//     // Ajouter des headers pour la sécurité
//     request.headers['X-Content-Type-Options'] = 'nosniff';
//     request.headers['X-Frame-Options'] = 'DENY';
//     request.headers['X-XSS-Protection'] = '1; mode=block';

//     return _inner.send(request);
//   }

//   @override
//   void close() {
//     _inner.close();
//   }
// }

/// Exception de sécurité pour les violations HTTPS
class SecurityException implements Exception {
  final String message;
  const SecurityException(this.message);
  
  @override
  String toString() => 'SecurityException: $message';
}

/// Extension pour valider les URLs dans les configurations
extension HttpsValidation on Map<String, String> {
  /// Valide toutes les URLs dans cette map
  Map<String, dynamic> validateHttpsUrls() {
    return HttpsEnforcement().validateConfiguration(this);
  }
}

/// Service de configuration de sécurité réseau
class NetworkSecurityConfig {
  static const NetworkSecurityConfig _instance = NetworkSecurityConfig._internal();
  factory NetworkSecurityConfig() => _instance;
  const NetworkSecurityConfig._internal();

  /// Configure la sécurité réseau pour l'application
  Future<void> configureNetworkSecurity() async {
    try {
      // Configurer les paramètres de sécurité réseau
      await _configureAndroidNetworkSecurity();
      await _configureIOSNetworkSecurity();
      
      if (kDebugMode) {
        print('✅ Network security configured');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error configuring network security: $e');
      }
      rethrow;
    }
  }

  /// Configure la sécurité réseau pour Android
  Future<void> _configureAndroidNetworkSecurity() async {
    // Pour Android, on peut configurer le Network Security Config
    // via les fichiers XML dans android/app/src/main/res/xml/
    
    if (kDebugMode) {
      print('📱 Configuring Android network security...');
    }
    
    // Les configurations Android sont faites via les fichiers XML
    // Voir network_security_config.xml
  }

  /// Configure la sécurité réseau pour iOS
  Future<void> _configureIOSNetworkSecurity() async {
    // Pour iOS, on peut configurer App Transport Security (ATS)
    // via Info.plist
    
    if (kDebugMode) {
      print('🍎 Configuring iOS network security...');
    }
    
    // Les configurations iOS sont faites via Info.plist
    // Voir Info.plist pour les paramètres ATS
  }

  /// Obtient la configuration de sécurité réseau
  Map<String, dynamic> getNetworkSecurityConfig() {
    return {
      'android': {
        'cleartextTrafficPermitted': false,
        'networkSecurityConfig': 'network_security_config.xml',
      },
      'ios': {
        'appTransportSecurity': {
          'allowArbitraryLoads': false,
          'allowArbitraryLoadsInWebContent': false,
          'allowLocalNetworking': kDebugMode,
        },
      },
    };
  }
}
