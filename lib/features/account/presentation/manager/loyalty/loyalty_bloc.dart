import 'package:bloc/bloc.dart';
import 'package:dio/dio.dart'; // ✅ add this
import 'package:equatable/equatable.dart';
import 'package:patria/core/network/api_error_handler.dart'; // ✅ add this
import 'package:patria/features/account/data/models/loyalty_points_model.dart';
import 'package:patria/features/account/data/repos/loyalty_repo.dart';
import 'package:patria/features/account/presentation/manager/loyalty/loyalty_event.dart';

part 'loyalty_state.dart';

class LoyaltyBloc extends Bloc<LoyaltyEvent, LoyaltyState> {
  final LoyaltyRepo _loyaltyRepo;

  LoyaltyBloc({required LoyaltyRepo loyaltyRepo})
    : _loyaltyRepo = loyaltyRepo,
      super(LoyaltyInitial()) {
    on<FetchLoyaltyPoints>(_onFetchLoyaltyPoints);
    on<RefreshLoyaltyPoints>(_onRefreshLoyaltyPoints);
  }

  Future<void> _onFetchLoyaltyPoints(
    FetchLoyaltyPoints event,
    Emitter<LoyaltyState> emit,
  ) async {
    emit(LoyaltyLoading());

    try {
      final loyaltyData = await _loyaltyRepo.getLoyaltyPoints();
      emit(LoyaltyLoaded(loyaltyData: loyaltyData));
    } catch (e) {
      // ✅ Use ApiErrorHandler
      final errorMessage = ApiErrorHandler.handle(e as DioException);
      emit(LoyaltyError(message: errorMessage));
    }
  }

  Future<void> _onRefreshLoyaltyPoints(
    RefreshLoyaltyPoints event,
    Emitter<LoyaltyState> emit,
  ) async {
    emit(LoyaltyLoading());

    try {
      final loyaltyData = await _loyaltyRepo.getLoyaltyPoints();
      emit(LoyaltyLoaded(loyaltyData: loyaltyData));
    } catch (e) {
      // ✅ Use ApiErrorHandler
      final errorMessage = ApiErrorHandler.handle(e as DioException);
      emit(LoyaltyError(message: errorMessage));
    }
  }
}
