import 'package:equatable/equatable.dart';
import 'package:patria/features/checkout/data/models/place_order_request.dart';

abstract class PlaceOrderEvent extends Equatable {
  const PlaceOrderEvent();
  @override
  List<Object?> get props => [];
}

class PlaceOrderRequested extends PlaceOrderEvent {
  final PlaceOrderRequest request;
  const PlaceOrderRequested(this.request);
  @override
  List<Object?> get props => [request];
}
