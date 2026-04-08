import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:erb/features/account/data/models/loyalty_points_model.dart';
import 'package:erb/features/account/data/repos/loyalty_repo.dart';
import 'package:erb/features/account/presentation/manager/loyalty/loyalty_event.dart';

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
      emit(LoyaltyError(message: e.toString()));
    }
  }

  Future<void> _onRefreshLoyaltyPoints(
    RefreshLoyaltyPoints event,
    Emitter<LoyaltyState> emit,
  ) async {
    // Same as fetch, but we can add refresh-specific logic if needed
    emit(LoyaltyLoading());

    try {
      final loyaltyData = await _loyaltyRepo.getLoyaltyPoints();
      emit(LoyaltyLoaded(loyaltyData: loyaltyData));
    } catch (e) {
      emit(LoyaltyError(message: e.toString()));
    }
  }
}
