import 'package:equatable/equatable.dart';

abstract class TrackOrderEvent extends Equatable {
  const TrackOrderEvent();

  @override
  List<Object?> get props => [];
}

class LoadTrackOrder extends TrackOrderEvent {
  final String orderId;

  const LoadTrackOrder(this.orderId);

  @override
  List<Object?> get props => [orderId];
}

class RefreshTrackOrder extends TrackOrderEvent {
  final String orderId;

  const RefreshTrackOrder(this.orderId);

  @override
  List<Object?> get props => [orderId];
}
