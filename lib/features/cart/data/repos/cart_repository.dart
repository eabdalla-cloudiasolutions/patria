import 'package:erb/features/cart/data/apis/cart_api.dart';
import 'package:erb/features/cart/data/models/cart_model.dart';

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
  }) async {
    final response = await _api.addToCart(
      productId: productId,
      quantity: quantity,
      notes: notes,
      customization: customization,
    );
    return CartResponse.fromJson(response.data);
  }

  Future<CartResponse> updateQuantity({
    required String itemId,
    required int quantity,
  }) async {
    final response =
        await _api.updateQuantity(itemId: itemId, quantity: quantity);
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
