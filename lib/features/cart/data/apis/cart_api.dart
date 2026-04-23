import 'package:dio/dio.dart';
import 'package:erb/core/network/api_client.dart';
import 'package:erb/core/network/api_endpoints.dart';

class CartApi {
  Future<Response> getCart() async {
    return await ApiClient.instance.get(ApiEndpoints.cart);
  }

  Future<Response> addToCart({
    required String productId,
    required int quantity,
    String? notes,
    Map<String, dynamic>? customization,
  }) async {
    return await ApiClient.instance.post(
      ApiEndpoints.addCart,
      data: {
        'productId': productId,
        'quantity': quantity,
        if (notes != null) 'notes': notes,
        if (customization != null) 'customization': customization,
      },
    );
  }

  Future<Response> updateQuantity({
    required String itemId,
    required int quantity,
  }) async {
    return await ApiClient.instance.put(
      ApiEndpoints.updateCartItem(
          itemId), // 👈 was: '${ApiEndpoints.cart}/$itemId'
      data: {'quantity': quantity},
    );
  }

  Future<Response> removeItem({required String itemId}) async {
    return await ApiClient.instance.delete(
      ApiEndpoints.removeCartItem(
          itemId), // 👈 was: '${ApiEndpoints.cart}/$itemId'
    );
  }

  Future<Response> clearCart() async {
    return await ApiClient.instance.delete(ApiEndpoints.clearCart);
  }
}
