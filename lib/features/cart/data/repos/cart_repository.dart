import 'package:patria/features/cart/data/apis/cart_api.dart';
import 'package:patria/features/cart/data/models/cart_model.dart';

class CartRepository {
  final CartApi _api = CartApi();

  Future<CartResponse> getCart() async {
    final response = await _api.getCart();
    return CartResponse.fromJson(response.data);
  }

  Future<CartResponse> addToCart({
    required String productId,
    required int quantity,
    String? notes,
    Map<String, dynamic>? customization,
    List<Map<String, dynamic>>? selectedVariants, // ← add this
  }) async {
    final response = await _api.addToCart(
      productId: productId,
      quantity: quantity,
      notes: notes,
      customization: customization,
      selectedVariants: selectedVariants, // ← add this
    );
    return CartResponse.fromJson(response.data);
  }

  Future<CartResponse> updateQuantity({
    required String itemId,
    required int quantity,
  }) async {
    final response = await _api.updateQuantity(
      itemId: itemId,
      quantity: quantity,
    );
    return CartResponse.fromJson(response.data);
  }

  Future<CartResponse> updateCartItem({
    required String itemId,
    required int quantity,
    Map<String, dynamic>? customization,
    String? notes,
  }) async {
    final response = await _api.updateCartItem(
      itemId: itemId,
      quantity: quantity,
      customization: customization,
      notes: notes,
    );
    return CartResponse.fromJson(response.data);
  }

  Future<CartResponse> removeItem({required String itemId}) async {
    final response = await _api.removeItem(itemId: itemId);
    return CartResponse.fromJson(response.data);
  }

  Future<CartResponse> clearCart() async {
    final response = await _api.clearCart();
    if (response.data == null) {
      return CartResponse(items: [], total: 0.0, itemCount: 0);
    }
    return CartResponse.fromJson(response.data);
  }
}
