import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:dio/dio.dart';
import '../../data/auth_service.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/auth_token_manager.dart';

/// État de l'authentification
class AuthState {
  final bool isAuthenticated;
  final bool isLoading;
  final String? errorMessage;
  final User? user;
  final String? accessToken;
  final String? refreshToken;

  AuthState({
    this.isAuthenticated = false,
    this.isLoading = false,
    this.errorMessage,
    this.user,
    this.accessToken,
    this.refreshToken,
  });

  AuthState copyWith({
    bool? isAuthenticated,
    bool? isLoading,
    String? errorMessage,
    User? user,
    String? accessToken,
    String? refreshToken,
  }) {
    return AuthState(
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      user: user ?? this.user,
      accessToken: accessToken ?? this.accessToken,
      refreshToken: refreshToken ?? this.refreshToken,
    );
  }
}

/// Modèle utilisateur
class User {
  final String id;
  final String email;
  final String? name;
  final String? phone;
  final String? avatar;
  final UserRole role;
  final DateTime createdAt;
  final DateTime updatedAt;

  User({
    required this.id,
    required this.email,
    this.name,
    this.phone,
    this.avatar,
    this.role = UserRole.CLIENT,
    required this.createdAt,
    required this.updatedAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String,
      email: json['email'] as String,
      name: json['name'] as String?,
      phone: json['phone'] as String?,
      avatar: json['avatar'] as String?,
      role: UserRole.values.firstWhere(
        (e) => e.toString().split('.').last == json['role'],
        orElse: () => UserRole.CLIENT,
      ),
      createdAt: json['createdAt'] != null 
          ? DateTime.parse(json['createdAt'] as String)
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null 
          ? DateTime.parse(json['updatedAt'] as String)
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'phone': phone,
      'avatar': avatar,
      'role': role.toString().split('.').last,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}

enum UserRole {
  CLIENT,
  ADMIN,
  SUPER_ADMIN,
}

/// Notifier pour la gestion de l'authentification
class AuthNotifier extends StateNotifier<AuthState> {
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  final SharedPreferences? _prefs;
  final AuthService _authService;

  AuthNotifier(this._prefs, this._authService) : super(AuthState()) {
    _loadStoredAuth();
  }

  // Constructeur pour l'état de chargement
  AuthNotifier._loading() : _prefs = null, _authService = AuthService(ApiClient(Dio())), super(AuthState(isLoading: true));

  // Constructeur pour l'état d'erreur
  AuthNotifier._error() : _prefs = null, _authService = AuthService(ApiClient(Dio())), super(AuthState(errorMessage: 'Failed to initialize authentication'));

  /// Charger l'authentification stockée
  Future<void> _loadStoredAuth() async {
    if (_prefs == null) {
      // Si SharedPreferences n'est pas disponible, on reste en état de chargement
      return;
    }

    state = state.copyWith(isLoading: true);

    try {
      final accessToken = await _secureStorage.read(key: 'access_token');
      final refreshToken = await _secureStorage.read(key: 'refresh_token');
      final userJson = await _secureStorage.read(key: 'user_data');

      if (accessToken != null && userJson != null) {
        final userData = Map<String, dynamic>.from(
          Uri.splitQueryString(userJson)
        );
        final user = User.fromJson(userData);
        
        // Mettre à jour le token dans le gestionnaire global
        AuthTokenManager().updateToken(accessToken);
        
        state = state.copyWith(
          isAuthenticated: true,
          user: user,
          accessToken: accessToken,
          refreshToken: refreshToken,
          isLoading: false,
        );
      } else {
        state = state.copyWith(isLoading: false);
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Erreur lors du chargement de l\'authentification: $e',
      );
    }
  }

  /// Connexion avec email et mot de passe
  Future<void> login({
    required String email,
    required String password,
  }) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      // Appeler l'API backend pour la connexion
      final response = await _authService.login(
        email: email,
        password: password,
      );

      // Extraire les données de la réponse
      final userData = response['data']['user'] as Map<String, dynamic>;
      final tokens = response['data']['tokens'] as Map<String, dynamic>;
      
      final user = User.fromJson(userData);
      final accessToken = tokens['accessToken'] as String;
      final refreshToken = tokens['refreshToken'] as String;

      // Stocker les données d'authentification
      await _secureStorage.write(key: 'access_token', value: accessToken);
      await _secureStorage.write(key: 'refresh_token', value: refreshToken);
      await _secureStorage.write(key: 'user_data', value: user.toJson().toString());

      // Mettre à jour le token dans le gestionnaire global
      AuthTokenManager().updateToken(accessToken);

      state = state.copyWith(
        isAuthenticated: true,
        user: user,
        accessToken: accessToken,
        refreshToken: refreshToken,
        isLoading: false,
        errorMessage: null,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString().replaceFirst('Exception: ', ''),
      );
    }
  }

  /// Inscription avec email et mot de passe
  Future<void> register({
    required String email,
    required String password,
    required String name,
    String? phone,
  }) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      // TODO: Appeler l'API backend pour l'inscription
      await Future.delayed(const Duration(seconds: 2)); // Simuler un appel API

      // Simuler une réponse d'inscription réussie
      final user = User(
        id: 'user_${DateTime.now().millisecondsSinceEpoch}',
        email: email,
        name: name,
        phone: phone,
        role: UserRole.CLIENT,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final accessToken = 'access_token_${DateTime.now().millisecondsSinceEpoch}';
      final refreshToken = 'refresh_token_${DateTime.now().millisecondsSinceEpoch}';

      // Stocker les données d'authentification
      await _secureStorage.write(key: 'access_token', value: accessToken);
      await _secureStorage.write(key: 'refresh_token', value: refreshToken);
      await _secureStorage.write(key: 'user_data', value: user.toJson().toString());

      state = state.copyWith(
        isAuthenticated: true,
        user: user,
        accessToken: accessToken,
        refreshToken: refreshToken,
        isLoading: false,
        errorMessage: null,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Erreur d\'inscription: $e',
      );
    }
  }

  /// Connexion OAuth2 (Google, Facebook)
  Future<void> loginWithOAuth({
    required String provider,
    required String accessToken,
    required Map<String, dynamic> userData,
  }) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      // TODO: Appeler l'API backend pour la connexion OAuth2
      await Future.delayed(const Duration(seconds: 2)); // Simuler un appel API

      // Simuler une réponse de connexion OAuth2 réussie
      final user = User(
        id: userData['id'] ?? 'oauth_user_${DateTime.now().millisecondsSinceEpoch}',
        email: userData['email'] ?? '',
        name: userData['name'],
        phone: userData['phone'],
        avatar: userData['picture'],
        role: UserRole.CLIENT,
        createdAt: DateTime.now().subtract(const Duration(days: 7)),
        updatedAt: DateTime.now(),
      );

      final backendAccessToken = 'oauth_access_token_${DateTime.now().millisecondsSinceEpoch}';
      final refreshToken = 'oauth_refresh_token_${DateTime.now().millisecondsSinceEpoch}';

      // Stocker les données d'authentification
      await _secureStorage.write(key: 'access_token', value: backendAccessToken);
      await _secureStorage.write(key: 'refresh_token', value: refreshToken);
      await _secureStorage.write(key: 'user_data', value: user.toJson().toString());
      await _secureStorage.write(key: 'oauth_provider', value: provider);

      state = state.copyWith(
        isAuthenticated: true,
        user: user,
        accessToken: backendAccessToken,
        refreshToken: refreshToken,
        isLoading: false,
        errorMessage: null,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Erreur de connexion OAuth2: $e',
      );
    }
  }

  /// Rafraîchir le token d'accès
  Future<void> refreshAccessToken() async {
    if (state.refreshToken == null) {
      state = state.copyWith(
        errorMessage: 'Aucun token de rafraîchissement disponible',
      );
      return;
    }

    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      // TODO: Appeler l'API backend pour rafraîchir le token
      await Future.delayed(const Duration(seconds: 1)); // Simuler un appel API

      final newAccessToken = 'refreshed_access_token_${DateTime.now().millisecondsSinceEpoch}';

      // Mettre à jour le token d'accès
      await _secureStorage.write(key: 'access_token', value: newAccessToken);

      state = state.copyWith(
        accessToken: newAccessToken,
        isLoading: false,
        errorMessage: null,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Erreur lors du rafraîchissement du token: $e',
      );
      
      // Si le rafraîchissement échoue, déconnecter l'utilisateur
      await logout();
    }
  }

  /// Déconnexion
  Future<void> logout() async {
    state = state.copyWith(isLoading: true);

    try {
      // TODO: Appeler l'API backend pour la déconnexion
      await Future.delayed(const Duration(seconds: 1)); // Simuler un appel API

      // Supprimer les données d'authentification stockées
      await _secureStorage.delete(key: 'access_token');
      await _secureStorage.delete(key: 'refresh_token');
      await _secureStorage.delete(key: 'user_data');
      await _secureStorage.delete(key: 'oauth_provider');

      // Effacer le token dans le gestionnaire global
      AuthTokenManager().updateToken(null);

      state = AuthState();
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Erreur lors de la déconnexion: $e',
      );
    }
  }

  /// Mettre à jour le profil utilisateur
  Future<void> updateProfile({
    String? name,
    String? phone,
    String? avatar,
  }) async {
    if (state.user == null) return;

    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      // TODO: Appeler l'API backend pour mettre à jour le profil
      await Future.delayed(const Duration(seconds: 1)); // Simuler un appel API

      final updatedUser = User(
        id: state.user!.id,
        email: state.user!.email,
        name: name ?? state.user!.name,
        phone: phone ?? state.user!.phone,
        avatar: avatar ?? state.user!.avatar,
        role: state.user!.role,
        createdAt: state.user!.createdAt,
        updatedAt: DateTime.now(),
      );

      // Mettre à jour les données utilisateur stockées
      await _secureStorage.write(key: 'user_data', value: updatedUser.toJson().toString());

      state = state.copyWith(
        user: updatedUser,
        isLoading: false,
        errorMessage: null,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Erreur lors de la mise à jour du profil: $e',
      );
    }
  }

  /// Effacer les messages d'erreur
  void clearError() {
    state = state.copyWith(errorMessage: null);
  }

  /// Vérifier si l'utilisateur est authentifié
  bool get isAuthenticated => state.isAuthenticated;

  /// Vérifier si l'utilisateur est un admin
  bool get isAdmin => state.user?.role == UserRole.ADMIN || state.user?.role == UserRole.SUPER_ADMIN;

  /// Obtenir le token d'accès
  String? get accessToken => state.accessToken;
}

/// Provider pour SharedPreferences
final sharedPreferencesProvider = FutureProvider<SharedPreferences>((ref) {
  return SharedPreferences.getInstance();
});

/// Provider pour l'état d'authentification
final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final prefsAsync = ref.watch(sharedPreferencesProvider);
  final authService = ref.watch(authServiceProvider);
  
  return prefsAsync.when(
    data: (prefs) => AuthNotifier(prefs, authService),
    loading: () => AuthNotifier._loading(),
    error: (error, stack) => AuthNotifier._error(),
  );
});

/// Provider pour vérifier l'authentification
final isAuthenticatedProvider = Provider<bool>((ref) {
  return ref.watch(authProvider).isAuthenticated;
});

/// Provider pour l'utilisateur actuel
final currentUserProvider = Provider<User?>((ref) {
  return ref.watch(authProvider).user;
});

/// Provider pour vérifier si l'utilisateur est admin
final isAdminProvider = Provider<bool>((ref) {
  final user = ref.watch(currentUserProvider);
  return user?.role == UserRole.ADMIN || user?.role == UserRole.SUPER_ADMIN;
});
