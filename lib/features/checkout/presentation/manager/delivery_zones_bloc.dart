import 'package:erb/features/checkout/data/repos/delivery_zones_repo.dart';
import 'package:erb/features/checkout/presentation/manager/delivery_zones_event.dart';
import 'package:erb/features/checkout/presentation/manager/delivery_zones_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class DeliveryZonesBloc extends Bloc<DeliveryZonesEvent, DeliveryZonesState> {
  final DeliveryZonesRepo _repo;

  DeliveryZonesBloc(this._repo) : super(DeliveryZonesInitial()) {
    on<FetchDeliveryZones>(_onFetch);
  }

  Future<void> _onFetch(
      FetchDeliveryZones event, Emitter<DeliveryZonesState> emit) async {
    emit(DeliveryZonesLoading());
    try {
      final zones = await _repo.getDeliveryZones();
      emit(DeliveryZonesLoaded(zones));
    } catch (e) {
      final message = e is String ? e : e.toString();
      emit(DeliveryZonesError(message));
    }
  }
}
