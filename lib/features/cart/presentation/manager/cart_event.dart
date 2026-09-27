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
  final String? notes;
  final Map<String, dynamic>? customization;
  final List<Map<String, dynamic>>? selectedVariants; // ← add this

  const AddToCart({
    required this.productId,
    required this.quantity,
    this.notes,
    this.customization,
    this.selectedVariants, // ← add this
  });

  @override
  List<Object?> get props => [
    productId,
    quantity,
    notes,
    customization,
    selectedVariants,
  ];
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

class UpdateCartItem extends CartEvent {
  final String itemId;
  final int quantity;
  final Map<String, dynamic>? customization;
  final String? notes;

  const UpdateCartItem({
    required this.itemId,
    required this.quantity,
    this.customization,
    this.notes,
  });

  @override
  List<Object?> get props => [itemId, quantity, customization, notes];
}

class ClearCart extends CartEvent {}
