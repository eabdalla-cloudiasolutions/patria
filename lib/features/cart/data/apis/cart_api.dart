import 'package:dio/dio.dart';
import 'package:patria/core/network/api_client.dart';
import 'package:patria/core/network/api_endpoints.dart';

class CartApi {
  Future<Response> getCart() async {
    return await ApiClient.instance.get(ApiEndpoints.cart);
  }

  Future<Response> addToCart({
    required String productId,
    required int quantity,
    String? notes,
    Map<String, dynamic>? customization,
    List<Map<String, dynamic>>? selectedVariants,
  }) async {
    final body = {
      'productId': productId,
      'quantity': quantity,
      'notes': ?notes,
      'customization': ?customization,
      if (selectedVariants != null && selectedVariants.isNotEmpty)
        'selectedVariants': selectedVariants,
    };

    print('AddToCart body: $body'); // ← add this

    return await ApiClient.instance.post(ApiEndpoints.addCart, data: body);
  }

  // ✅ Generic update for cart item (quantity, customization, notes)
  Future<Response> updateCartItem({
    required String itemId,
    required int quantity,
    Map<String, dynamic>? customization,
    String? notes,
  }) async {
    return await ApiClient.instance.put(
      ApiEndpoints.updateCartItem(itemId),
      data: {
        'quantity': quantity,
        'customization': ?customization,
        if (notes != null && notes.isNotEmpty) 'notes': notes,
      },
    );
  }

  Future<Response> updateQuantity({
    required String itemId,
    required int quantity,
  }) async {
    return await ApiClient.instance.put(
      ApiEndpoints.updateCartItem(
        itemId,
      ), // 👈 was: '${ApiEndpoints.cart}/$itemId'
      data: {'quantity': quantity},
    );
  }

  Future<Response> removeItem({required String itemId}) async {
    return await ApiClient.instance.delete(
      ApiEndpoints.removeCartItem(
        itemId,
      ), // 👈 was: '${ApiEndpoints.cart}/$itemId'
    );
  }

  Future<Response> clearCart() async {
    return await ApiClient.instance.delete(ApiEndpoints.clearCart);
  }
}
