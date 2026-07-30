import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:patria/core/network/api_error_handler.dart';
import 'package:patria/features/cart/data/repos/cart_repository.dart';
import 'package:patria/features/cart/presentation/manager/cart_event.dart';
import 'package:patria/features/cart/presentation/manager/cart_state.dart';

class CartBloc extends Bloc<CartEvent, CartState> {
  final CartRepository _repository = CartRepository();

  CartBloc() : super(CartInitial()) {
    on<LoadCart>(_onLoadCart);
    on<AddToCart>(_onAddToCart);
    on<UpdateCartItemQuantity>(_onUpdateQuantity);
    on<RemoveCartItem>(_onRemoveItem);
    on<ClearCart>(_onClearCart);
    on<UpdateCartItem>(_onUpdateCartItem);
  }

  Future<void> _onLoadCart(LoadCart event, Emitter<CartState> emit) async {
    emit(CartLoading());
    try {
      final cart = await _repository.getCart();
      emit(CartLoaded(cart));
    } catch (e) {
      final message = e is DioException
          ? ApiErrorHandler.handle(e)
          : e.toString();
      emit(CartError(message));
    }
  }

  Future<void> _onAddToCart(AddToCart event, Emitter<CartState> emit) async {
    emit(CartLoading());
    try {
      final cart = await _repository.addToCart(
        productId: event.productId,
        quantity: event.quantity,
        notes: event.notes,
        customization: event.customization,
        selectedVariants: event.selectedVariants, // ← add this
      );
      emit(CartLoaded(cart));
    } catch (e) {
      final message = e is DioException
          ? ApiErrorHandler.handle(e)
          : e.toString();
      emit(CartError(message));
    }
  }

  Future<void> _onUpdateQuantity(
    UpdateCartItemQuantity event,
    Emitter<CartState> emit,
  ) async {
    emit(CartLoading());
    try {
      final cart = await _repository.updateQuantity(
        itemId: event.itemId,
        quantity: event.quantity,
      );
      emit(CartLoaded(cart));
    } catch (e) {
      final message = e is DioException
          ? ApiErrorHandler.handle(e)
          : e.toString();
      emit(CartError(message));
    }
  }

  Future<void> _onRemoveItem(
    RemoveCartItem event,
    Emitter<CartState> emit,
  ) async {
    emit(CartLoading());
    try {
      final cart = await _repository.removeItem(itemId: event.itemId);
      emit(CartLoaded(cart));
    } catch (e) {
      final message = e is DioException
          ? ApiErrorHandler.handle(e)
          : e.toString();
      emit(CartError(message));
    }
  }

  Future<void> _onUpdateCartItem(
    UpdateCartItem event,
    Emitter<CartState> emit,
  ) async {
    emit(CartLoading());
    try {
      final cart = await _repository.updateCartItem(
        itemId: event.itemId,
        quantity: event.quantity,
        customization: event.customization,
        notes: event.notes,
      );
      emit(CartLoaded(cart));
    } catch (e) {
      final message = e is DioException
          ? ApiErrorHandler.handle(e)
          : e.toString();
      emit(CartError(message));
    }
  }

  Future<void> _onClearCart(ClearCart event, Emitter<CartState> emit) async {
    emit(CartLoading());
    try {
      final cart = await _repository.clearCart();
      emit(CartLoaded(cart));
    } catch (e) {
      final message = e is DioException
          ? ApiErrorHandler.handle(e)
          : e.toString();
      emit(CartError(message));
    }
  }
}
