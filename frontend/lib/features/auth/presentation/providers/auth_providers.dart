import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Provider pour l'état d'authentification
final authStateProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier();
});

/// État d'authentification
class AuthState {
  final bool isAuthenticated;
  final bool isLoading;
  final String? error;
  final User? user;
  final String? token;

  const AuthState({
    this.isAuthenticated = false,
    this.isLoading = false,
    this.error,
    this.user,
    this.token,
  });

  AuthState copyWith({
    bool? isAuthenticated,
    bool? isLoading,
    String? error,
    User? user,
    String? token,
  }) {
    return AuthState(
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      user: user ?? this.user,
      token: token ?? this.token,
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
  final String role;

  const User({
    required this.id,
    required this.email,
    this.name,
    this.phone,
    this.avatar,
    this.role = 'CLIENT',
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String,
      email: json['email'] as String,
      name: json['name'] as String?,
      phone: json['phone'] as String?,
      avatar: json['avatar'] as String?,
      role: json['role'] as String? ?? 'CLIENT',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'phone': phone,
      'avatar': avatar,
      'role': role,
    };
  }
}

/// Notifier pour l'authentification
class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier() : super(const AuthState());

  /// Connexion
  Future<void> login(String email, String password) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      // TODO: Implémenter l'appel API
      await Future.delayed(const Duration(seconds: 2)); // Simulation

      // Simulation d'une connexion réussie
      final user = User(
        id: '1',
        email: email,
        name: 'Utilisateur Test',
        role: 'CLIENT',
      );

      state = state.copyWith(
        isAuthenticated: true,
        isLoading: false,
        user: user,
        token: 'fake_token_123',
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  /// Inscription
  Future<void> register(String email, String password, String name) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      // TODO: Implémenter l'appel API
      await Future.delayed(const Duration(seconds: 2)); // Simulation

      // Simulation d'une inscription réussie
      final user = User(id: '1', email: email, name: name, role: 'CLIENT');

      state = state.copyWith(
        isAuthenticated: true,
        isLoading: false,
        user: user,
        token: 'fake_token_123',
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  /// Déconnexion
  Future<void> logout() async {
    state = state.copyWith(isLoading: true);

    try {
      // TODO: Implémenter l'appel API de déconnexion
      await Future.delayed(const Duration(seconds: 1)); // Simulation

      state = const AuthState();
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  /// Rafraîchir le token
  Future<void> refreshToken() async {
    try {
      // TODO: Implémenter le rafraîchissement du token
      await Future.delayed(const Duration(seconds: 1)); // Simulation

      state = state.copyWith(token: 'new_fake_token_456');
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  /// Effacer l'erreur
  void clearError() {
    state = state.copyWith(error: null);
  }
}
