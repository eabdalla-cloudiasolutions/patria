import 'package:dio/dio.dart';
import 'package:erb/core/network/api_error_handler.dart';
import 'package:erb/features/orders/data/repos/track_order_repository.dart';
import 'package:erb/features/orders/presentation/manager/track_order_event.dart';
import 'package:erb/features/orders/presentation/manager/track_order_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class TrackOrderBloc extends Bloc<TrackOrderEvent, TrackOrderState> {
  final TrackOrderRepository _repository = TrackOrderRepository();

  TrackOrderBloc() : super(TrackOrderInitial()) {
    on<LoadTrackOrder>(_onLoadTrackOrder);
    on<RefreshTrackOrder>(_onRefreshTrackOrder);
  }

  Future<void> _onLoadTrackOrder(
      LoadTrackOrder event, Emitter<TrackOrderState> emit) async {
    emit(TrackOrderLoading());
    try {
      final order = await _repository.getOrderById(event.orderId);
      emit(TrackOrderLoaded(order));
    } catch (e) {
      final message =
          e is DioException ? ApiErrorHandler.handle(e) : e.toString();
      emit(TrackOrderError(message));
    }
  }

  Future<void> _onRefreshTrackOrder(
      RefreshTrackOrder event, Emitter<TrackOrderState> emit) async {
    try {
      final order = await _repository.getOrderById(event.orderId);
      emit(TrackOrderLoaded(order)); // 👈 just emit loaded, no loading first
    } catch (e) {
      final message =
          e is DioException ? ApiErrorHandler.handle(e) : e.toString();
      emit(TrackOrderError(message));
    }
  }
}
