import 'package:equatable/equatable.dart';
import 'package:patria/features/orders/data/models/track_order_model.dart';

abstract class TrackOrderState extends Equatable {
  const TrackOrderState();

  @override
  List<Object?> get props => [];
}

class TrackOrderInitial extends TrackOrderState {}

class TrackOrderLoading extends TrackOrderState {}

class TrackOrderLoaded extends TrackOrderState {
  final TrackOrderModel order;
  final DateTime timestamp; // 👈 add this

  TrackOrderLoaded(this.order)
    : timestamp = DateTime.now(); // 👈 unique every time

  @override
  List<Object?> get props => [timestamp]; // 👈 always different = always rebuilds
}

class TrackOrderError extends TrackOrderState {
  final String message;

  const TrackOrderError(this.message);

  @override
  List<Object?> get props => [message];
}
