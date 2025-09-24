import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dio/dio.dart';
import '../network/api_client.dart';

/// Provider pour le client API
final apiClientProvider = Provider<ApiClient>((ref) {
  final dio = Dio();
  final apiClient = ApiClient(dio);
  apiClient.initialize();
  return apiClient;
});

/// Provider pour SharedPreferences
final sharedPreferencesProvider = FutureProvider<SharedPreferences>((ref) async {
  return await SharedPreferences.getInstance();
});

/// Provider pour l'état de l'application
final appStateProvider = StateNotifierProvider<AppStateNotifier, AppState>((
  ref,
) {
  return AppStateNotifier();
});

/// État global de l'application
class AppState {
  final bool isLoading;
  final String? error;
  final bool isOnline;
  final String currentLanguage;

  const AppState({
    this.isLoading = false,
    this.error,
    this.isOnline = true,
    this.currentLanguage = 'fr',
  });

  AppState copyWith({
    bool? isLoading,
    String? error,
    bool? isOnline,
    String? currentLanguage,
  }) {
    return AppState(
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      isOnline: isOnline ?? this.isOnline,
      currentLanguage: currentLanguage ?? this.currentLanguage,
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

  void clearError() {
    state = state.copyWith(error: null);
  }
}
