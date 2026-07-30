import 'package:bloc/bloc.dart';
import 'package:patria/features/checkout/data/repos/place_order_repository.dart';
import 'package:patria/features/checkout/presentation/manager/place_order_event.dart';
import 'package:patria/features/checkout/presentation/manager/place_order_state.dart';

class PlaceOrderBloc extends Bloc<PlaceOrderEvent, PlaceOrderState> {
  final PlaceOrderRepository repository;

  PlaceOrderBloc({required this.repository}) : super(PlaceOrderInitial()) {
    on<PlaceOrderRequested>(_onPlaceOrderRequested);
  }

  Future<void> _onPlaceOrderRequested(
    PlaceOrderRequested event,
    Emitter<PlaceOrderState> emit,
  ) async {
    emit(PlaceOrderLoading());
    try {
      final response = await repository.placeOrder(event.request);
      emit(PlaceOrderSuccess(response));
    } catch (e) {
      emit(PlaceOrderFailure(e.toString()));
    }
  }
}
