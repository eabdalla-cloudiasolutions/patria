import 'package:equatable/equatable.dart';
import 'package:erb/features/home/data/models/favorite_product_model.dart';

abstract class FavoritesState extends Equatable {
  const FavoritesState();

  @override
  List<Object> get props => [];
}

class FavoritesInitial extends FavoritesState {}

class FavoritesLoading extends FavoritesState {}

class FavoritesLoaded extends FavoritesState {
  final List<FavoriteProductModel>
      favorites; // ✅ Use 'favorites' as property name

  const FavoritesLoaded({required this.favorites});

  @override
  List<Object> get props => [favorites];
}

class FavoritesError extends FavoritesState {
  final String message;

  const FavoritesError({required this.message});

  @override
  List<Object> get props => [message];
}

class FavoritesActionLoading extends FavoritesState {
  final String productId;

  const FavoritesActionLoading({required this.productId});

  @override
  List<Object> get props => [productId];
}
