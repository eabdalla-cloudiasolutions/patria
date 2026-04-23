import 'package:dio/dio.dart';
import 'package:erb/core/network/api_error_handler.dart';
import 'package:erb/features/previous_orders/data/apis/orders_api.dart';
import 'package:erb/features/previous_orders/presentation/manager/orders_event.dart';
import 'package:erb/features/previous_orders/presentation/manager/orders_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class OrdersBloc extends Bloc<OrdersEvent, OrdersState> {
  final OrdersApi _api = OrdersApi();

  OrdersBloc() : super(OrdersInitial()) {
    on<LoadOrders>(_onLoadOrders);
    on<RefreshOrders>(_onRefreshOrders); // 👈 added
  }

  Future<void> _onLoadOrders(
    LoadOrders event,
    Emitter<OrdersState> emit,
  ) async {
    emit(OrdersLoading()); // 👈 shows shimmer
    try {
      final orders = await _api.getMyOrders();
      emit(OrdersLoaded(orders));
    } catch (e, stackTrace) {
      print('Error type: ${e.runtimeType}');
      print('Error: $e');
      print('StackTrace: $stackTrace');
      String errorMessage;
      if (e is DioException) {
        errorMessage = ApiErrorHandler.handle(e);
      } else if (e is TypeError) {
        errorMessage = 'Data format error. Please contact support.';
        print('TypeError in OrdersBloc: $e');
      } else {
        errorMessage = 'Something went wrong. Please try again.';
      }
      emit(OrdersError(errorMessage));
    }
  }

  // 👇 Silent refresh — no loading state, no shimmer
  Future<void> _onRefreshOrders(
    RefreshOrders event,
    Emitter<OrdersState> emit,
  ) async {
    try {
      final orders = await _api.getMyOrders();
      emit(OrdersLoaded(orders)); // 👈 directly emit loaded, no shimmer
    } catch (e) {
      // silently fail — keep current state visible
      print('Silent refresh failed: $e');
    }
  }
}
