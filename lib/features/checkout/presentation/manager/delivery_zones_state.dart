import 'package:equatable/equatable.dart';
import 'package:erb/features/checkout/data/models/delivery_zone_model.dart';

abstract class DeliveryZonesState extends Equatable {
  const DeliveryZonesState();
  @override
  List<Object> get props => [];
}

class DeliveryZonesInitial extends DeliveryZonesState {}

class DeliveryZonesLoading extends DeliveryZonesState {}

class DeliveryZonesLoaded extends DeliveryZonesState {
  final List<DeliveryZone> zones;
  const DeliveryZonesLoaded(this.zones);
  @override
  List<Object> get props => [zones];
}

class DeliveryZonesError extends DeliveryZonesState {
  final String message;
  const DeliveryZonesError(this.message);
  @override
  List<Object> get props => [message];
}
