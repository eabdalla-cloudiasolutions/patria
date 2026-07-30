import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:patria/core/network/api_error_handler.dart';
import 'package:patria/features/account/data/apis/addresses_api.dart';
import 'package:patria/features/account/presentation/manager/saved_address/addresses_event.dart';
import 'package:patria/features/account/presentation/manager/saved_address/addresses_state.dart';

// ─── Bloc ─────────────────────────────────────────────
class AddressesBloc extends Bloc<AddressesEvent, AddressesState> {
  final AddressesApi _api = AddressesApi();

  AddressesBloc() : super(AddressesInitial()) {
    on<LoadAddresses>(_onLoadAddresses);
  }

  Future<void> _onLoadAddresses(
    LoadAddresses event,
    Emitter<AddressesState> emit,
  ) async {
    emit(AddressesLoading());
    try {
      final addresses = await _api.getAddresses();
      emit(AddressesLoaded(addresses));
    } catch (e) {
      final errorMessage = ApiErrorHandler.handle(e as DioException);
      emit(AddressesError(errorMessage));
    }
  }
}
