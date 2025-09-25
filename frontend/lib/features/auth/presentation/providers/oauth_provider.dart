import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/oauth_service.dart';
import '../../../../shared/providers/core_providers.dart';
import '../../../../shared/models/user.dart';
import '../../../../shared/models/base_state.dart';
import '../../../../shared/errors/contextual_errors.dart';

/// État OAuth pour l'admin
class OAuthState extends BaseState {
  final bool isSignedIn;
  final User? user;
  final String? accessToken;
  final String? refreshToken;
  final OAuthProvider? provider;

  const OAuthState({
    super.isLoading,
    super.error,
    this.isSignedIn = false,
    this.user,
    this.accessToken,
    this.refreshToken,
    this.provider,
  });

  @override
  OAuthState copyWith({
    bool? isLoading,
    String? error,
    bool? isSignedIn,
    User? user,
    String? accessToken,
    String? refreshToken,
    OAuthProvider? provider,
  }) {
    return OAuthState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      isSignedIn: isSignedIn ?? this.isSignedIn,
      user: user ?? this.user,
      accessToken: accessToken ?? this.accessToken,
      refreshToken: refreshToken ?? this.refreshToken,
      provider: provider ?? this.provider,
    );
  }
}

/// Types de fournisseurs OAuth
enum OAuthProvider {
  google,
  facebook,
  apple,
}

/// Notifier pour la gestion OAuth admin
class OAuthNotifier extends StateNotifier<OAuthState> {
  final OAuthService _oauthService;

  OAuthNotifier(this._oauthService) : super(const OAuthState()) {
    _checkSignInStatus();
  }

  /// Vérifier le statut de connexion OAuth
  Future<void> _checkSignInStatus() async {
    state = state.copyWith(isLoading: true);

    try {
      final isSignedIn = await _oauthService.isSignedIn();
      
      if (isSignedIn) {
        // TODO: Récupérer les informations utilisateur depuis le stockage local
        state = state.copyWith(
          isSignedIn: true,
          isLoading: false,
        );
      } else {
        state = state.copyWith(
          isSignedIn: false,
          isLoading: false,
        );
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Erreur lors de la vérification du statut OAuth',
      );
    }
  }

  /// Connexion Google
  Future<void> signInWithGoogle() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final result = await _oauthService.signInWithGoogle();
      
      if (result.isSuccess) {
        state = state.copyWith(
          isSignedIn: true,
          user: result.user,
          accessToken: result.accessToken,
          refreshToken: result.refreshToken,
          provider: OAuthProvider.google,
          isLoading: false,
          error: null,
        );
      } else if (result.isCancelled) {
        state = state.copyWith(
          isLoading: false,
          error: null,
        );
      } else {
        state = state.copyWith(
          isLoading: false,
          error: result.error?.message ?? 'Erreur de connexion Google',
        );
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Erreur de connexion Google: ${e.toString()}',
      );
    }
  }

  /// Connexion Facebook
  Future<void> signInWithFacebook() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final result = await _oauthService.signInWithFacebook();
      
      if (result.isSuccess) {
        state = state.copyWith(
          isSignedIn: true,
          user: result.user,
          accessToken: result.accessToken,
          refreshToken: result.refreshToken,
          provider: OAuthProvider.facebook,
          isLoading: false,
          error: null,
        );
      } else if (result.isCancelled) {
        state = state.copyWith(
          isLoading: false,
          error: null,
        );
      } else {
        state = state.copyWith(
          isLoading: false,
          error: result.error?.message ?? 'Erreur de connexion Facebook',
        );
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Erreur de connexion Facebook: ${e.toString()}',
      );
    }
  }

  /// Connexion Apple
  Future<void> signInWithApple() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final result = await _oauthService.signInWithApple();
      
      if (result.isSuccess) {
        state = state.copyWith(
          isSignedIn: true,
          user: result.user,
          accessToken: result.accessToken,
          refreshToken: result.refreshToken,
          provider: OAuthProvider.apple,
          isLoading: false,
          error: null,
        );
      } else if (result.isCancelled) {
        state = state.copyWith(
          isLoading: false,
          error: null,
        );
      } else {
        state = state.copyWith(
          isLoading: false,
          error: result.error?.message ?? 'Erreur de connexion Apple',
        );
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Erreur de connexion Apple: ${e.toString()}',
      );
    }
  }

  /// Déconnexion OAuth
  Future<void> signOut() async {
    state = state.copyWith(isLoading: true);

    try {
      await _oauthService.signOut();
      
      state = const OAuthState();
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Erreur de déconnexion: ${e.toString()}',
      );
    }
  }

  /// Effacer l'erreur
  void clearError() {
    state = state.copyWith(error: null);
  }
}

/// Provider pour le service OAuth
final oauthServiceProvider = Provider<OAuthService>((ref) {
  final dio = ref.watch(dioProvider);
  return OAuthService(dio);
});

/// Provider pour l'état OAuth
final oauthProvider = StateNotifierProvider<OAuthNotifier, OAuthState>((ref) {
  final oauthService = ref.watch(oauthServiceProvider);
  return OAuthNotifier(oauthService);
});

/// Provider pour vérifier si l'admin est connecté via OAuth
final isOAuthSignedInProvider = Provider<bool>((ref) {
  return ref.watch(oauthProvider).isSignedIn;
});

/// Provider pour l'utilisateur OAuth
final oauthUserProvider = Provider<User?>((ref) {
  return ref.watch(oauthProvider).user;
});

/// Provider pour vérifier si l'utilisateur OAuth est admin
final isOAuthAdminProvider = Provider<bool>((ref) {
  final user = ref.watch(oauthUserProvider);
  return user?.role == UserRole.ADMIN || user?.role == UserRole.SUPER_ADMIN;
});
