import 'package:erb/features/home/data/models/favorite_product_model.dart';
import 'package:erb/features/home/data/repos/favorites_repo.dart';
import 'package:erb/features/home/presentation/manager/favorites_event.dart';
import 'package:erb/features/home/presentation/manager/favorites_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class FavoritesBloc extends Bloc<FavoritesEvent, FavoritesState> {
  final FavoritesRepo _favoritesRepo;

  FavoritesBloc({required FavoritesRepo favoritesRepo})
      : _favoritesRepo = favoritesRepo,
        super(FavoritesInitial()) {
    on<FetchFavorites>(_onFetchFavorites);
    on<AddToFavorites>(_onAddToFavorites);
    on<RemoveFromFavorites>(_onRemoveFromFavorites);
    on<ToggleFavorite>(_onToggleFavorite);
  }

  // Future<void> _onFetchFavorites(
  //   FetchFavorites event,
  //   Emitter<FavoritesState> emit,
  // ) async {
  //   emit(FavoritesLoading());
  //   try {
  //     final favorites = await _favoritesRepo.getFavorites();
  //     emit(FavoritesLoaded(favorites: favorites));
  //   } catch (e) {
  //     final message = e is String ? e : e.toString();
  //     emit(FavoritesError(message: message));
  //   }
  // }

  Future<void> _onAddToFavorites(
    AddToFavorites event,
    Emitter<FavoritesState> emit,
  ) async {
    // ✅ Save current favorites before loading
    final currentState = state;
    final currentFavorites = currentState is FavoritesLoaded
        ? currentState.favorites
        : <FavoriteProductModel>[];

    emit(FavoritesActionLoading(productId: event.productId));
    try {
      await _favoritesRepo.addToFavorites(event.productId);
      final updated = await _favoritesRepo.getFavorites();
      emit(FavoritesLoaded(
          favorites: updated)); // ✅ directly emit, no add(FetchFavorites)
    } catch (e) {
      final message = e is String ? e : e.toString();
      emit(FavoritesError(message: message));
      emit(FavoritesLoaded(favorites: currentFavorites)); // ✅ restore on error
    }
  }

  Future<void> _onRemoveFromFavorites(
    RemoveFromFavorites event,
    Emitter<FavoritesState> emit,
  ) async {
    final currentState = state;
    final currentFavorites = currentState is FavoritesLoaded
        ? currentState.favorites
        : <FavoriteProductModel>[];

    emit(FavoritesActionLoading(productId: event.productId));
    try {
      await _favoritesRepo.removeFromFavorites(event.productId);
      // ✅ Optimistically remove without re-fetching
      final updated =
          currentFavorites.where((item) => item.id != event.productId).toList();
      emit(FavoritesLoaded(favorites: updated));
    } catch (e) {
      final message = e is String ? e : e.toString();
      emit(FavoritesError(message: message));
      emit(FavoritesLoaded(favorites: currentFavorites)); // ✅ restore on error
    }
  }

  Future<void> _onFetchFavorites(
    FetchFavorites event,
    Emitter<FavoritesState> emit,
  ) async {
    // ✅ Don't emit FavoritesLoading here to avoid wiping the list
    try {
      final favorites = await _favoritesRepo.getFavorites();
      emit(FavoritesLoaded(favorites: favorites));
    } catch (e) {
      final message = e is String ? e : e.toString();
      emit(FavoritesError(message: message));
    }
  }

  Future<void> _onToggleFavorite(
    ToggleFavorite event,
    Emitter<FavoritesState> emit,
  ) async {
    if (event.isCurrentlyFavorite) {
      add(RemoveFromFavorites(productId: event.productId));
    } else {
      add(AddToFavorites(productId: event.productId));
    }
  }
}
