import 'package:erb/features/checkout/data/apis/place_order_api.dart';
import 'package:erb/features/checkout/data/models/place_order_request.dart';
import 'package:erb/features/checkout/data/models/place_order_response.dart';

class PlaceOrderRepository {
  final PlaceOrderApi api;

  PlaceOrderRepository({required this.api});

  Future<PlaceOrderResponse> placeOrder(PlaceOrderRequest request) {
    return api.placeOrder(request);
  }
}
