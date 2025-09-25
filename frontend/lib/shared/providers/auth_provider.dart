import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:dio/dio.dart';
import '../../core/network/api_client.dart';
import '../../core/network/auth_token_manager.dart';
import '../../core/network/api_service.dart';
import '../../core/network/api_service_provider.dart';
import '../models/user.dart';
import '../models/base_state.dart';
import '../errors/app_errors.dart';
import 'core_providers.dart';

/// État d'authentification unifié
class AuthState extends BaseState {
  final bool isAuthenticated;
  final User? user;
  final String? accessToken;
  final String? refreshToken;

  const AuthState({
    super.isLoading,
    super.error,
    this.isAuthenticated = false,
    this.user,
    this.accessToken,
    this.refreshToken,
  });

  @override
  AuthState copyWith({
    bool? isLoading,
    String? error,
    bool? isAuthenticated,
    User? user,
    String? accessToken,
    String? refreshToken,
  }) {
    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      user: user ?? this.user,
      accessToken: accessToken ?? this.accessToken,
      refreshToken: refreshToken ?? this.refreshToken,
    );
  }
}

/// Notifier pour la gestion de l'authentification
class AuthNotifier extends StateNotifier<AuthState> {
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  final SharedPreferences? _prefs;
  final ApiClient _apiClient;
  final ApiService _apiService;

  AuthNotifier(this._prefs, this._apiClient, this._apiService) : super(const AuthState()) {
    _loadStoredAuth();
  }

  // Constructeur pour l'état de chargement
  AuthNotifier._loading() : _prefs = null, _apiClient = ApiClient(Dio()), _apiService = ApiService(Dio(), ''), super(const AuthState(isLoading: true));

  // Constructeur pour l'état d'erreur
  AuthNotifier._error() : _prefs = null, _apiClient = ApiClient(Dio()), _apiService = ApiService(Dio(), ''), super(const AuthState(error: 'Failed to initialize authentication'));

  /// Charger l'authentification stockée
  Future<void> _loadStoredAuth() async {
    if (_prefs == null) {
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
      final error = AppErrorFactory.fromException(e);
      state = state.copyWith(
        isLoading: false,
        error: error.message,
      );
    }
  }

  /// Connexion avec email et mot de passe
  Future<void> login({
    required String email,
    required String password,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      // Appeler l'API backend pour la connexion
      final response = await _apiService.login(
        email: email,
        password: password,
      );

      // Stocker les données d'authentification
      await _secureStorage.write(key: 'access_token', value: response.accessToken);
      if (response.refreshToken != null) {
        await _secureStorage.write(key: 'refresh_token', value: response.refreshToken!);
      }
      await _secureStorage.write(key: 'user_data', value: response.user.toJson().toString());

      // Mettre à jour le token dans le gestionnaire global
      AuthTokenManager().updateToken(response.accessToken);

      state = state.copyWith(
        isAuthenticated: true,
        user: response.user,
        accessToken: response.accessToken,
        refreshToken: response.refreshToken,
        isLoading: false,
        error: null,
      );
    } catch (e) {
      final error = AppErrorFactory.fromException(e);
      state = state.copyWith(
        isLoading: false,
        error: error.message,
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
    state = state.copyWith(isLoading: true, error: null);

    try {
      // Appeler l'API backend pour l'inscription
      final response = await _apiService.register(
        email: email,
        password: password,
        name: name,
        phone: phone,
      );

      // Stocker les données d'authentification
      await _secureStorage.write(key: 'access_token', value: response.accessToken);
      if (response.refreshToken != null) {
        await _secureStorage.write(key: 'refresh_token', value: response.refreshToken!);
      }
      await _secureStorage.write(key: 'user_data', value: response.user.toJson().toString());

      // Mettre à jour le token dans le gestionnaire global
      AuthTokenManager().updateToken(response.accessToken);

      state = state.copyWith(
        isAuthenticated: true,
        user: response.user,
        accessToken: response.accessToken,
        refreshToken: response.refreshToken,
        isLoading: false,
        error: null,
      );
    } catch (e) {
      final error = AppErrorFactory.fromException(e);
      state = state.copyWith(
        isLoading: false,
        error: error.message,
      );
    }
  }

  /// Connexion par token (pour les guests)
  Future<void> loginWithToken(String token) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      // Appeler l'API backend pour la connexion par token
      final response = await _apiService.loginWithToken(token);

      // Stocker les données d'authentification
      await _secureStorage.write(key: 'access_token', value: response.accessToken);
      if (response.refreshToken != null) {
        await _secureStorage.write(key: 'refresh_token', value: response.refreshToken!);
      }
      await _secureStorage.write(key: 'user_data', value: response.user.toJson().toString());

      // Mettre à jour le token dans le gestionnaire global
      AuthTokenManager().updateToken(response.accessToken);

      state = state.copyWith(
        isAuthenticated: true,
        user: response.user,
        accessToken: response.accessToken,
        refreshToken: response.refreshToken,
        isLoading: false,
        error: null,
      );
    } catch (e) {
      final error = AppErrorFactory.authError('Token invalide ou expiré');
      state = state.copyWith(
        isLoading: false,
        error: error.message,
      );
    }
  }

  /// Déconnexion
  Future<void> logout() async {
    state = state.copyWith(isLoading: true);

    try {
      // Appeler l'API backend pour la déconnexion
      await _apiService.logout();

      // Supprimer les données d'authentification
      await _secureStorage.delete(key: 'access_token');
      await _secureStorage.delete(key: 'refresh_token');
      await _secureStorage.delete(key: 'user_data');

      // Mettre à jour le token dans le gestionnaire global
      AuthTokenManager().clearToken();

      state = const AuthState();
    } catch (e) {
      final error = AppErrorFactory.fromException(e);
      state = state.copyWith(
        isLoading: false,
        error: error.message,
      );
    }
  }

  /// Rafraîchir le token d'accès
  Future<void> refreshAccessToken() async {
    if (state.refreshToken == null) {
      state = state.copyWith(error: 'Aucun token de rafraîchissement disponible');
      return;
    }

    state = state.copyWith(isLoading: true, error: null);

    try {
      // Appeler l'API backend pour rafraîchir le token
      final response = await _apiService.refreshToken(state.refreshToken!);

      // Mettre à jour les tokens stockés
      await _secureStorage.write(key: 'access_token', value: response.accessToken);
      if (response.refreshToken != null) {
        await _secureStorage.write(key: 'refresh_token', value: response.refreshToken!);
      }

      // Mettre à jour le token dans le gestionnaire global
      AuthTokenManager().updateToken(response.accessToken);

      state = state.copyWith(
        accessToken: response.accessToken,
        refreshToken: response.refreshToken,
        isLoading: false,
        error: null,
      );
    } catch (e) {
      final error = AppErrorFactory.fromException(e);
      state = state.copyWith(
        isLoading: false,
        error: error.message,
      );
    }
  }

  /// Effacer l'erreur
  void clearError() {
    state = state.copyWith(error: null);
  }
}

// Providers moved to core_providers.dart to avoid conflicts

/// Provider pour l'état d'authentification
final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final prefsAsync = ref.watch(sharedPreferencesProvider);
  final apiClient = ref.watch(apiClientProvider);
  final apiService = ref.watch(apiServiceProvider);
  
  return prefsAsync.when(
    data: (prefs) => AuthNotifier(prefs, apiClient, apiService),
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
