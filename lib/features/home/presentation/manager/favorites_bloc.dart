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

  Future<void> _onFetchFavorites(
    FetchFavorites event,
    Emitter<FavoritesState> emit,
  ) async {
    emit(FavoritesLoading());

    try {
      final favorites = await _favoritesRepo.getFavorites();
      emit(
          FavoritesLoaded(favorites: favorites)); // ✅ Use 'favorites' parameter
    } catch (e) {
      emit(FavoritesError(message: e.toString()));
    }
  }

  Future<void> _onAddToFavorites(
    AddToFavorites event,
    Emitter<FavoritesState> emit,
  ) async {
    final currentState = state;
    if (currentState is FavoritesLoaded) {
      // Optimistic update
      final updatedFavorites =
          List<FavoriteProductModel>.from(currentState.favorites);
      // Note: You might need to add the product to the list if you have the full product data
      emit(FavoritesLoaded(favorites: updatedFavorites));
    }

    try {
      await _favoritesRepo.addToFavorites(event.productId);
      add(FetchFavorites()); // Refresh to get accurate data
    } catch (e) {
      emit(FavoritesError(message: e.toString()));
      add(FetchFavorites()); // Revert on error
    }
  }

  Future<void> _onRemoveFromFavorites(
    RemoveFromFavorites event,
    Emitter<FavoritesState> emit,
  ) async {
    final currentState = state;
    if (currentState is FavoritesLoaded) {
      // Optimistic update
      final updatedFavorites = currentState.favorites
          .where((item) => item.id != event.productId)
          .toList();
      emit(FavoritesLoaded(favorites: updatedFavorites));
    }

    try {
      await _favoritesRepo.removeFromFavorites(event.productId);
      // No need to refresh since we already updated optimistically
    } catch (e) {
      emit(FavoritesError(message: e.toString()));
      add(FetchFavorites()); // Revert on error
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
