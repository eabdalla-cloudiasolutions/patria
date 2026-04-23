import 'package:equatable/equatable.dart';

abstract class DeliveryZonesEvent extends Equatable {
  const DeliveryZonesEvent();
  @override
  List<Object> get props => [];
}

class FetchDeliveryZones extends DeliveryZonesEvent {}
