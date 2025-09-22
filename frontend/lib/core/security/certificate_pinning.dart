import 'dart:convert';
import 'dart:io';
import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';

/// Service de certificate pinning pour sécuriser les connexions HTTPS
/// Empêche les attaques man-in-the-middle en vérifiant les certificats
class CertificatePinning {
  static const CertificatePinning _instance = CertificatePinning._internal();
  factory CertificatePinning() => _instance;
  const CertificatePinning._internal();

  // Certificats épinglés pour les différents environnements
  static const Map<String, List<String>> _pinnedCertificates = {
    // Production
    'api.techplus.com': [
      'sha256/AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=', // Remplacez par le vrai hash
      'sha256/BBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBB=', // Certificat de backup
    ],
    // Staging
    'staging-api.techplus.com': [
      'sha256/CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC=', // Remplacez par le vrai hash
    ],
    // Development (optionnel - désactivé en debug)
    'localhost': [
      'sha256/DDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDD=', // Certificat auto-signé
    ],
  };

  // Configuration du pinning
  static const bool _enablePinning = true;
  static const bool _allowSelfSignedInDebug = true;

  /// Vérifie si le certificate pinning est activé
  bool get isEnabled => _enablePinning;

  /// Vérifie un certificat contre les certificats épinglés
  bool checkCertificate(X509Certificate cert, String host) {
    if (!_enablePinning) {
      if (kDebugMode) {
        print('🔓 Certificate pinning disabled');
      }
      return true;
    }

    // En mode debug, permettre les certificats auto-signés pour localhost
    if (kDebugMode && _allowSelfSignedInDebug && _isLocalhost(host)) {
      if (kDebugMode) {
        print('🔓 Debug mode: allowing self-signed certificate for localhost');
      }
      return true;
    }

    try {
      // Obtenir les certificats épinglés pour ce host
      final pinnedCerts = _pinnedCertificates[host];
      if (pinnedCerts == null || pinnedCerts.isEmpty) {
        if (kDebugMode) {
          print('⚠️ No pinned certificates found for host: $host');
        }
        return false;
      }

      // Calculer le hash du certificat
      final certHash = _calculateCertificateHash(cert);
      
      // Vérifier si le hash correspond à un certificat épinglé
      final isPinned = pinnedCerts.contains(certHash);
      
      if (kDebugMode) {
        print('🔍 Certificate check for $host:');
        print('   Certificate hash: $certHash');
        print('   Pinned certificates: $pinnedCerts');
        print('   Result: ${isPinned ? "✅ VALID" : "❌ INVALID"}');
      }

      return isPinned;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error checking certificate: $e');
      }
      return false;
    }
  }

  /// Calcule le hash SHA-256 d'un certificat
  String _calculateCertificateHash(X509Certificate cert) {
    try {
      // Convertir le certificat en bytes
      final certBytes = cert.der;
      
      // Calculer le hash SHA-256
      final hash = sha256.convert(certBytes);
      
      // Retourner le hash en format base64
      return 'sha256/${base64Encode(hash.bytes)}';
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error calculating certificate hash: $e');
      }
      rethrow;
    }
  }

  /// Vérifie si l'host est localhost
  bool _isLocalhost(String host) {
    return host == 'localhost' || 
           host == '127.0.0.1' || 
           host.startsWith('192.168.') ||
           host.startsWith('10.') ||
           host.startsWith('172.');
  }

  /// Obtient les certificats épinglés pour un host
  List<String> getPinnedCertificates(String host) {
    return _pinnedCertificates[host] ?? [];
  }

  /// Ajoute un certificat épinglé pour un host (pour les tests)
  void addPinnedCertificate(String host, String certHash) {
    if (kDebugMode) {
      _pinnedCertificates[host] = [...(_pinnedCertificates[host] ?? []), certHash];
      print('✅ Added pinned certificate for $host: $certHash');
    }
  }

  /// Génère le hash d'un certificat à partir de son contenu PEM
  static String generateCertificateHash(String pemContent) {
    try {
      // Nettoyer le contenu PEM
      final cleanPem = pemContent
          .replaceAll('-----BEGIN CERTIFICATE-----', '')
          .replaceAll('-----END CERTIFICATE-----', '')
          .replaceAll('\n', '')
          .replaceAll('\r', '')
          .replaceAll(' ', '');

      // Décoder base64
      final certBytes = base64Decode(cleanPem);
      
      // Calculer le hash SHA-256
      final hash = sha256.convert(certBytes);
      
      // Retourner le hash en format base64
      return 'sha256/${base64Encode(hash.bytes)}';
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error generating certificate hash: $e');
      }
      rethrow;
    }
  }

  /// Valide la configuration des certificats épinglés
  bool validateConfiguration() {
    try {
      for (final entry in _pinnedCertificates.entries) {
        final host = entry.key;
        final certs = entry.value;
        
        if (certs.isEmpty) {
          if (kDebugMode) {
            print('⚠️ No certificates pinned for host: $host');
          }
          return false;
        }
        
        // Vérifier le format des hashes
        for (final cert in certs) {
          if (!cert.startsWith('sha256/')) {
            if (kDebugMode) {
              print('❌ Invalid certificate hash format for $host: $cert');
            }
            return false;
          }
        }
      }
      
      if (kDebugMode) {
        print('✅ Certificate pinning configuration is valid');
      }
      return true;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error validating certificate configuration: $e');
      }
      return false;
    }
  }

  /// Obtient le statut du certificate pinning
  Map<String, dynamic> getStatus() {
    return {
      'enabled': _enablePinning,
      'allowSelfSignedInDebug': _allowSelfSignedInDebug,
      'pinnedHosts': _pinnedCertificates.keys.toList(),
      'totalPinnedCertificates': _pinnedCertificates.values
          .fold(0, (sum, certs) => sum + certs.length),
      'configurationValid': validateConfiguration(),
    };
  }
}

/// Extension pour HttpClient avec certificate pinning
extension HttpClientCertificatePinning on HttpClient {
  /// Configure le certificate pinning pour ce client
  void enableCertificatePinning() {
    final pinning = CertificatePinning();
    
    if (!pinning.isEnabled) {
      if (kDebugMode) {
        print('🔓 Certificate pinning is disabled');
      }
      return;
    }

    // Configurer la vérification des certificats
    this.badCertificateCallback = (cert, host, port) {
      final isValid = pinning.checkCertificate(cert, host);
      
      if (!isValid) {
        if (kDebugMode) {
          print('❌ Certificate pinning failed for $host:$port');
          print('   Certificate: ${cert.subject}');
          print('   Issuer: ${cert.issuer}');
          print('   Valid from: ${cert.startValidity}');
          print('   Valid to: ${cert.endValidity}');
        }
      }
      
      return isValid;
    };

    if (kDebugMode) {
      print('✅ Certificate pinning enabled for HttpClient');
    }
  }
}
