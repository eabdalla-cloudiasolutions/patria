import 'package:erb/features/previous_orders/data/apis/orders_api.dart';
import 'package:erb/features/previous_orders/presentation/manager/orders_event.dart';
import 'package:erb/features/previous_orders/presentation/manager/orders_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class OrdersBloc extends Bloc<OrdersEvent, OrdersState> {
  final OrdersApi _api = OrdersApi();

  OrdersBloc() : super(OrdersInitial()) {
    on<LoadOrders>(_onLoadOrders);
  }

  Future<void> _onLoadOrders(
    LoadOrders event,
    Emitter<OrdersState> emit,
  ) async {
    emit(OrdersLoading());
    try {
      final orders = await _api.getMyOrders();
      emit(OrdersLoaded(orders));
    } catch (e) {
      emit(OrdersError(e.toString()));
    }
  }
}
