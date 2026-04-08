import 'package:erb/core/network/api_client.dart';
import 'package:erb/core/network/api_endpoints.dart';
import 'package:erb/features/previous_orders/data/models/order_model.dart';

class OrdersApi {
  Future<List<OrderModel>> getMyOrders() async {
    final response = await ApiClient.instance.get(ApiEndpoints.myOrders);
    final List data = response.data as List;
    return data.map((e) => OrderModel.fromJson(e)).toList();
  }
}
