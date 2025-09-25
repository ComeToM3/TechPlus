/// État de base unifié pour tous les providers
abstract class BaseState {
  final bool isLoading;
  final String? error;

  const BaseState({
    this.isLoading = false,
    this.error,
  });

  BaseState copyWith({
    bool? isLoading,
    String? error,
  });
}

/// État de base avec données
abstract class BaseDataState<T> extends BaseState {
  final T? data;

  const BaseDataState({
    super.isLoading,
    super.error,
    this.data,
  });

  @override
  BaseDataState<T> copyWith({
    bool? isLoading,
    String? error,
    T? data,
  });
}

/// État de base avec liste de données
abstract class BaseListState<T> extends BaseState {
  final List<T> items;

  const BaseListState({
    super.isLoading,
    super.error,
    this.items = const [],
  });

  @override
  BaseListState<T> copyWith({
    bool? isLoading,
    String? error,
    List<T>? items,
  });
}
