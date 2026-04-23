import 'package:equatable/equatable.dart';

abstract class CartEvent extends Equatable {
  const CartEvent();
  @override
  List<Object?> get props => [];
}

class LoadCart extends CartEvent {}

class AddToCart extends CartEvent {
  final String productId;
  final int quantity;
  final String? notes; // 👈 per-item note only
  final Map<String, dynamic>? customization;

  const AddToCart({
    required this.productId,
    required this.quantity,
    this.notes,
    this.customization,
  });

  @override
  List<Object?> get props => [productId, quantity, notes, customization];
}

class UpdateCartItemQuantity extends CartEvent {
  final String itemId;
  final int quantity;

  const UpdateCartItemQuantity({required this.itemId, required this.quantity});

  @override
  List<Object?> get props => [itemId, quantity];
}

class RemoveCartItem extends CartEvent {
  final String itemId;

  const RemoveCartItem({required this.itemId});

  @override
  List<Object?> get props => [itemId];
}

class ClearCart extends CartEvent {}
