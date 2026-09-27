import 'package:equatable/equatable.dart';
import 'package:patria/features/checkout/data/models/place_order_response.dart';

abstract class PlaceOrderState extends Equatable {
  const PlaceOrderState();
  @override
  List<Object?> get props => [];
}

class PlaceOrderInitial extends PlaceOrderState {}

class PlaceOrderLoading extends PlaceOrderState {}

class PlaceOrderSuccess extends PlaceOrderState {
  final PlaceOrderResponse response;
  const PlaceOrderSuccess(this.response);
  @override
  List<Object?> get props => [response];
}

class PlaceOrderFailure extends PlaceOrderState {
  final String error;
  const PlaceOrderFailure(this.error);
  @override
  List<Object?> get props => [error];
}
