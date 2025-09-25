import 'dart:convert';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:crypto/crypto.dart';
import 'secure_storage_service.dart';
import '../network/api_service.dart';

/// Service de gestion sécurisée des tokens JWT
/// Gère le stockage, la validation, et le renouvellement des tokens
class TokenManager {
  static final TokenManager _instance = TokenManager._internal();
  factory TokenManager() => _instance;
  TokenManager._internal();

  late final SecureStorageService _secureStorage;
  ApiService? _apiService;
  
  // Configuration des tokens
  static const int _accessTokenExpiryBuffer = 300; // 5 minutes avant expiration
  static const int _refreshTokenExpiryBuffer = 3600; // 1 heure avant expiration
  static const int _maxRefreshAttempts = 3;
  
  // État des tokens
  late String? _accessToken;
  late String? _refreshToken;
  late DateTime? _accessTokenExpiry;
  late DateTime? _refreshTokenExpiry;
  late int _refreshAttempts;

  /// Initialise le gestionnaire de tokens
  Future<void> initialize({ApiService? apiService}) async {
    try {
      // Initialiser le service de stockage sécurisé
      _secureStorage = SecureStorageService();
      _apiService = apiService;
      
      // Initialiser les variables d'état
      _accessToken = null;
      _refreshToken = null;
      _accessTokenExpiry = null;
      _refreshTokenExpiry = null;
      _refreshAttempts = 0;
      
      // Charger les tokens depuis le stockage sécurisé
      _accessToken = await _secureStorage.getAccessToken();
      _refreshToken = await _secureStorage.getRefreshToken();
      
      // Calculer les dates d'expiration
      if (_accessToken != null) {
        _accessTokenExpiry = _getTokenExpiry(_accessToken!);
      }
      if (_refreshToken != null) {
        _refreshTokenExpiry = _getTokenExpiry(_refreshToken!);
      }
      
      if (kDebugMode) {
        print('✅ Token manager initialized');
        print('   Access token: ${_accessToken != null ? "Present" : "Missing"}');
        print('   Refresh token: ${_refreshToken != null ? "Present" : "Missing"}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error initializing token manager: $e');
      }
      rethrow;
    }
  }

  /// Stocke de nouveaux tokens
  Future<void> storeTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    try {
      // Valider les tokens
      if (!_isValidToken(accessToken) || !_isValidToken(refreshToken)) {
        throw ArgumentError('Invalid token format');
      }

      // Stocker dans le stockage sécurisé
      await Future.wait([
        _secureStorage.storeAccessToken(accessToken),
        _secureStorage.storeRefreshToken(refreshToken),
      ]);

      // Mettre à jour l'état local
      _accessToken = accessToken;
      _refreshToken = refreshToken;
      _accessTokenExpiry = _getTokenExpiry(accessToken);
      _refreshTokenExpiry = _getTokenExpiry(refreshToken);
      _refreshAttempts = 0;

      if (kDebugMode) {
        print('✅ Tokens stored successfully');
        print('   Access token expires: $_accessTokenExpiry');
        print('   Refresh token expires: $_refreshTokenExpiry');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error storing tokens: $e');
      }
      rethrow;
    }
  }

  /// Obtient le token d'accès valide
  Future<String?> getValidAccessToken() async {
    try {
      // Vérifier si le token d'accès est valide
      if (_isAccessTokenValid()) {
        return _accessToken;
      }

      // Essayer de renouveler le token
      if (await _refreshAccessToken()) {
        return _accessToken;
      }

      // Aucun token valide disponible
      return null;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error getting valid access token: $e');
      }
      return null;
    }
  }

  /// Vérifie si le token d'accès est valide
  bool _isAccessTokenValid() {
    if (_accessToken == null || _accessTokenExpiry == null) {
      return false;
    }

    // Vérifier si le token n'est pas expiré (avec buffer)
    final now = DateTime.now();
    final expiryWithBuffer = _accessTokenExpiry!.subtract(
      Duration(seconds: _accessTokenExpiryBuffer)
    );

    return now.isBefore(expiryWithBuffer);
  }

  /// Vérifie si le refresh token est valide
  bool _isRefreshTokenValid() {
    if (_refreshToken == null || _refreshTokenExpiry == null) {
      return false;
    }

    // Vérifier si le token n'est pas expiré (avec buffer)
    final now = DateTime.now();
    final expiryWithBuffer = _refreshTokenExpiry!.subtract(
      Duration(seconds: _refreshTokenExpiryBuffer)
    );

    return now.isBefore(expiryWithBuffer);
  }

  /// Renouvelle le token d'accès
  Future<bool> _refreshAccessToken() async {
    if (!_isRefreshTokenValid()) {
      if (kDebugMode) {
        print('❌ Refresh token is invalid or expired');
      }
      return false;
    }

    if (_refreshAttempts >= _maxRefreshAttempts) {
      if (kDebugMode) {
        print('❌ Maximum refresh attempts reached');
      }
      await clearTokens();
      return false;
    }

    try {
      _refreshAttempts++;
      
      if (kDebugMode) {
        print('🔄 Refreshing access token (attempt $_refreshAttempts)');
      }

      // Appeler l'API backend pour renouveler le token
      if (_apiService == null) {
        if (kDebugMode) {
          print('❌ ApiService not initialized');
        }
        return false;
      }
      
      final newTokens = await _apiService!.refreshToken(_refreshToken!);
      await storeTokens(
        accessToken: newTokens.accessToken,
        refreshToken: newTokens.refreshToken ?? _refreshToken!,
      );
      
      return true; // Succès
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error refreshing access token: $e');
      }
      return false;
    }
  }

  /// Génère un token de gestion pour les réservations guest
  String generateManagementToken() {
    try {
      final random = Random.secure();
      final bytes = List<int>.generate(32, (i) => random.nextInt(256));
      final token = base64Url.encode(bytes);
      
      if (kDebugMode) {
        print('✅ Management token generated');
      }
      
      return token;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error generating management token: $e');
      }
      rethrow;
    }
  }

  /// Valide un token de gestion
  bool validateManagementToken(String token) {
    try {
      // Vérifier le format du token
      if (token.length < 32) {
        return false;
      }

      // Décoder le token pour vérifier qu'il est valide
      base64Url.decode(token);
      
      return true;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Invalid management token: $e');
      }
      return false;
    }
  }

  /// Obtient les informations du token d'accès
  Map<String, dynamic>? getAccessTokenInfo() {
    if (_accessToken == null) return null;

    try {
      return _decodeToken(_accessToken!);
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error decoding access token: $e');
      }
      return null;
    }
  }

  /// Obtient les informations du refresh token
  Map<String, dynamic>? getRefreshTokenInfo() {
    if (_refreshToken == null) return null;

    try {
      return _decodeToken(_refreshToken!);
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error decoding refresh token: $e');
      }
      return null;
    }
  }

  /// Décode un token JWT
  Map<String, dynamic> _decodeToken(String token) {
    try {
      final parts = token.split('.');
      if (parts.length != 3) {
        throw ArgumentError('Invalid JWT format');
      }

      // Décoder le payload (partie 2)
      final payload = parts[1];
      final normalized = base64Url.normalize(payload);
      final decoded = utf8.decode(base64Url.decode(normalized));
      
      return jsonDecode(decoded) as Map<String, dynamic>;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error decoding JWT: $e');
      }
      rethrow;
    }
  }

  /// Obtient la date d'expiration d'un token
  DateTime? _getTokenExpiry(String token) {
    try {
      final payload = _decodeToken(token);
      final exp = payload['exp'];
      
      if (exp is int) {
        return DateTime.fromMillisecondsSinceEpoch(exp * 1000);
      }
      
      return null;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error getting token expiry: $e');
      }
      return null;
    }
  }

  /// Vérifie si un token a un format valide
  bool _isValidToken(String token) {
    try {
      final parts = token.split('.');
      return parts.length == 3;
    } catch (e) {
      return false;
    }
  }

  /// Vérifie si l'utilisateur est authentifié
  bool isAuthenticated() {
    return _accessToken != null && _isAccessTokenValid();
  }

  /// Obtient l'ID de l'utilisateur depuis le token
  String? getUserId() {
    final tokenInfo = getAccessTokenInfo();
    return tokenInfo?['sub'] ?? tokenInfo?['user_id'];
  }

  /// Obtient le rôle de l'utilisateur depuis le token
  String? getUserRole() {
    final tokenInfo = getAccessTokenInfo();
    return tokenInfo?['role'];
  }

  /// Obtient l'email de l'utilisateur depuis le token
  String? getUserEmail() {
    final tokenInfo = getAccessTokenInfo();
    return tokenInfo?['email'];
  }

  /// Supprime tous les tokens
  Future<void> clearTokens() async {
    try {
      await _secureStorage.clearTokens();
      
      _accessToken = null;
      _refreshToken = null;
      _accessTokenExpiry = null;
      _refreshTokenExpiry = null;
      _refreshAttempts = 0;

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

  /// Obtient le statut du gestionnaire de tokens
  Map<String, dynamic> getStatus() {
    return {
      'hasAccessToken': _accessToken != null,
      'hasRefreshToken': _refreshToken != null,
      'accessTokenValid': _isAccessTokenValid(),
      'refreshTokenValid': _isRefreshTokenValid(),
      'accessTokenExpiry': _accessTokenExpiry?.toIso8601String(),
      'refreshTokenExpiry': _refreshTokenExpiry?.toIso8601String(),
      'refreshAttempts': _refreshAttempts,
      'maxRefreshAttempts': _maxRefreshAttempts,
      'isAuthenticated': isAuthenticated(),
      'userId': getUserId(),
      'userRole': getUserRole(),
      'userEmail': getUserEmail(),
    };
  }

  /// Génère un hash sécurisé pour les données sensibles
  String generateSecureHash(String data) {
    try {
      final bytes = utf8.encode(data);
      final digest = sha256.convert(bytes);
      return digest.toString();
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error generating secure hash: $e');
      }
      rethrow;
    }
  }

  /// Vérifie un hash contre des données
  bool verifyHash(String data, String hash) {
    try {
      final computedHash = generateSecureHash(data);
      return computedHash == hash;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error verifying hash: $e');
      }
      return false;
    }
  }
}
