import 'package:equatable/equatable.dart';

abstract class FavoritesEvent extends Equatable {
  const FavoritesEvent();
  @override
  List<Object> get props => [];
}

class FetchFavorites extends FavoritesEvent {}

class AddToFavorites extends FavoritesEvent {
  final String productId;
  const AddToFavorites({required this.productId});
  @override
  List<Object> get props => [productId];
}

class RemoveFromFavorites extends FavoritesEvent {
  final String productId;
  const RemoveFromFavorites({required this.productId});
  @override
  List<Object> get props => [productId];
}

class ToggleFavorite extends FavoritesEvent {
  final String productId;
  final bool isCurrentlyFavorite;
  const ToggleFavorite(
      {required this.productId, required this.isCurrentlyFavorite});
  @override
  List<Object> get props => [productId, isCurrentlyFavorite];
}
