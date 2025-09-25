import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/base_state.dart';

/// État global de l'application unifié
class AppState extends BaseState {
  final bool isOnline;
  final String currentLanguage;
  final String? currentRoute;

  const AppState({
    super.isLoading,
    super.error,
    this.isOnline = true,
    this.currentLanguage = 'fr',
    this.currentRoute,
  });

  @override
  AppState copyWith({
    bool? isLoading,
    String? error,
    bool? isOnline,
    String? currentLanguage,
    String? currentRoute,
  }) {
    return AppState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      isOnline: isOnline ?? this.isOnline,
      currentLanguage: currentLanguage ?? this.currentLanguage,
      currentRoute: currentRoute ?? this.currentRoute,
    );
  }
}

/// Notifier pour l'état global de l'application
class AppStateNotifier extends StateNotifier<AppState> {
  AppStateNotifier() : super(const AppState());

  void setLoading(bool loading) {
    state = state.copyWith(isLoading: loading);
  }

  void setError(String? error) {
    state = state.copyWith(error: error);
  }

  void setOnline(bool online) {
    state = state.copyWith(isOnline: online);
  }

  void setLanguage(String language) {
    state = state.copyWith(currentLanguage: language);
  }

  void setCurrentRoute(String? route) {
    state = state.copyWith(currentRoute: route);
  }

  void clearError() {
    state = state.copyWith(error: null);
  }

  void reset() {
    state = const AppState();
  }
}

/// Provider pour l'état global de l'application
final appStateProvider = StateNotifierProvider<AppStateNotifier, AppState>((ref) {
  return AppStateNotifier();
});

/// Provider pour vérifier si l'application est en ligne
final isOnlineProvider = Provider<bool>((ref) {
  return ref.watch(appStateProvider).isOnline;
});

/// Provider pour la langue actuelle
final currentLanguageProvider = Provider<String>((ref) {
  return ref.watch(appStateProvider).currentLanguage;
});

/// Provider pour la route actuelle
final currentRouteProvider = Provider<String?>((ref) {
  return ref.watch(appStateProvider).currentRoute;
});
