import 'package:patria/features/orders/data/apis/track_order_api.dart';
import 'package:patria/features/orders/data/models/track_order_model.dart';

class TrackOrderRepository {
  final TrackOrderApi _api = TrackOrderApi();

  Future<TrackOrderModel> getOrderById(String orderId) async {
    final response = await _api.getOrderById(orderId);
    return TrackOrderModel.fromJson(response.data);
  }
}
