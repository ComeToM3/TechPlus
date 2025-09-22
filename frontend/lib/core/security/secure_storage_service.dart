import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter/foundation.dart';
import 'dart:convert';
import 'dart:io';

/// Service de stockage sécurisé pour les données sensibles
/// Utilise flutter_secure_storage pour chiffrer les données localement
class SecureStorageService {
  static const SecureStorageService _instance = SecureStorageService._internal();
  factory SecureStorageService() => _instance;
  const SecureStorageService._internal();

  // Configuration du stockage sécurisé
  static const FlutterSecureStorage _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
      sharedPreferencesName: 'techplus_secure_prefs',
      preferencesKeyPrefix: 'techplus_',
    ),
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock_this_device,
      groupId: 'com.techplus.app',
    ),
    lOptions: LinuxOptions(),
    wOptions: WindowsOptions(
      useBackwardCompatibility: false,
    ),
    mOptions: MacOsOptions(
      accessibility: KeychainAccessibility.first_unlock_this_device,
      groupId: 'com.techplus.app',
    ),
  );

  // Clés de stockage
  static const String _accessTokenKey = 'access_token';
  static const String _refreshTokenKey = 'refresh_token';
  static const String _userCredentialsKey = 'user_credentials';
  static const String _biometricEnabledKey = 'biometric_enabled';
  static const String _pinCodeKey = 'pin_code_hash';
  static const String _sessionDataKey = 'session_data';
  static const String _deviceIdKey = 'device_id';

  /// Stocke un token d'accès de manière sécurisée
  Future<void> storeAccessToken(String token) async {
    try {
      await _storage.write(key: _accessTokenKey, value: token);
      if (kDebugMode) {
        print('✅ Access token stored securely');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error storing access token: $e');
      }
      rethrow;
    }
  }

  /// Récupère le token d'accès
  Future<String?> getAccessToken() async {
    try {
      return await _storage.read(key: _accessTokenKey);
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error reading access token: $e');
      }
      return null;
    }
  }

  /// Stocke un refresh token de manière sécurisée
  Future<void> storeRefreshToken(String token) async {
    try {
      await _storage.write(key: _refreshTokenKey, value: token);
      if (kDebugMode) {
        print('✅ Refresh token stored securely');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error storing refresh token: $e');
      }
      rethrow;
    }
  }

  /// Récupère le refresh token
  Future<String?> getRefreshToken() async {
    try {
      return await _storage.read(key: _refreshTokenKey);
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error reading refresh token: $e');
      }
      return null;
    }
  }

  /// Stocke les credentials utilisateur de manière sécurisée
  Future<void> storeUserCredentials({
    required String email,
    required String password,
  }) async {
    try {
      final credentials = {
        'email': email,
        'password': password,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      };
      
      final encodedCredentials = base64Encode(
        utf8.encode(jsonEncode(credentials))
      );
      
      await _storage.write(key: _userCredentialsKey, value: encodedCredentials);
      if (kDebugMode) {
        print('✅ User credentials stored securely');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error storing user credentials: $e');
      }
      rethrow;
    }
  }

  /// Récupère les credentials utilisateur
  Future<Map<String, dynamic>?> getUserCredentials() async {
    try {
      final encodedCredentials = await _storage.read(key: _userCredentialsKey);
      if (encodedCredentials == null) return null;

      final decodedCredentials = utf8.decode(base64Decode(encodedCredentials));
      return jsonDecode(decodedCredentials) as Map<String, dynamic>;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error reading user credentials: $e');
      }
      return null;
    }
  }

  /// Stocke l'état d'activation de la biométrie
  Future<void> setBiometricEnabled(bool enabled) async {
    try {
      await _storage.write(key: _biometricEnabledKey, value: enabled.toString());
      if (kDebugMode) {
        print('✅ Biometric enabled state stored: $enabled');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error storing biometric state: $e');
      }
      rethrow;
    }
  }

  /// Récupère l'état d'activation de la biométrie
  Future<bool> isBiometricEnabled() async {
    try {
      final value = await _storage.read(key: _biometricEnabledKey);
      return value == 'true';
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error reading biometric state: $e');
      }
      return false;
    }
  }

  /// Stocke un hash de code PIN
  Future<void> storePinCodeHash(String pinHash) async {
    try {
      await _storage.write(key: _pinCodeKey, value: pinHash);
      if (kDebugMode) {
        print('✅ PIN code hash stored securely');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error storing PIN code hash: $e');
      }
      rethrow;
    }
  }

  /// Récupère le hash du code PIN
  Future<String?> getPinCodeHash() async {
    try {
      return await _storage.read(key: _pinCodeKey);
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error reading PIN code hash: $e');
      }
      return null;
    }
  }

  /// Stocke des données de session
  Future<void> storeSessionData(Map<String, dynamic> sessionData) async {
    try {
      final encodedData = base64Encode(
        utf8.encode(jsonEncode(sessionData))
      );
      
      await _storage.write(key: _sessionDataKey, value: encodedData);
      if (kDebugMode) {
        print('✅ Session data stored securely');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error storing session data: $e');
      }
      rethrow;
    }
  }

  /// Récupère les données de session
  Future<Map<String, dynamic>?> getSessionData() async {
    try {
      final encodedData = await _storage.read(key: _sessionDataKey);
      if (encodedData == null) return null;

      final decodedData = utf8.decode(base64Decode(encodedData));
      return jsonDecode(decodedData) as Map<String, dynamic>;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error reading session data: $e');
      }
      return null;
    }
  }

  /// Génère et stocke un ID de device unique
  Future<String> getOrCreateDeviceId() async {
    try {
      String? deviceId = await _storage.read(key: _deviceIdKey);
      
      if (deviceId == null) {
        // Générer un nouvel ID de device
        deviceId = _generateDeviceId();
        await _storage.write(key: _deviceIdKey, value: deviceId);
        if (kDebugMode) {
          print('✅ New device ID generated and stored');
        }
      }
      
      return deviceId;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error managing device ID: $e');
      }
      // Fallback: générer un ID temporaire
      return _generateDeviceId();
    }
  }

  /// Génère un ID de device unique
  String _generateDeviceId() {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final random = (timestamp * 1000 + (timestamp % 1000)).toString();
    return 'device_${random}_${Platform.operatingSystem}';
  }

  /// Supprime tous les tokens
  Future<void> clearTokens() async {
    try {
      await Future.wait([
        _storage.delete(key: _accessTokenKey),
        _storage.delete(key: _refreshTokenKey),
      ]);
      if (kDebugMode) {
        print('✅ Tokens cleared');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error clearing tokens: $e');
      }
      rethrow;
    }
  }

  /// Supprime toutes les données utilisateur
  Future<void> clearUserData() async {
    try {
      await Future.wait([
        _storage.delete(key: _userCredentialsKey),
        _storage.delete(key: _sessionDataKey),
        _storage.delete(key: _pinCodeKey),
      ]);
      if (kDebugMode) {
        print('✅ User data cleared');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error clearing user data: $e');
      }
      rethrow;
    }
  }

  /// Supprime toutes les données stockées
  Future<void> clearAll() async {
    try {
      await _storage.deleteAll();
      if (kDebugMode) {
        print('✅ All secure storage cleared');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error clearing all data: $e');
      }
      rethrow;
    }
  }

  /// Vérifie si le stockage sécurisé est disponible
  Future<bool> isAvailable() async {
    try {
      // Test d'écriture/lecture
      const testKey = 'test_availability';
      const testValue = 'test_value';
      
      await _storage.write(key: testKey, value: testValue);
      final readValue = await _storage.read(key: testKey);
      await _storage.delete(key: testKey);
      
      return readValue == testValue;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Secure storage not available: $e');
      }
      return false;
    }
  }

  /// Obtient toutes les clés stockées (pour debug uniquement)
  Future<Map<String, String>> getAllKeys() async {
    try {
      return await _storage.readAll();
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error reading all keys: $e');
      }
      return {};
    }
  }
}
