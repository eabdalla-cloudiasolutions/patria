part of 'loyalty_bloc.dart';

abstract class LoyaltyState extends Equatable {
  const LoyaltyState();

  @override
  List<Object> get props => [];
}

class LoyaltyInitial extends LoyaltyState {}

class LoyaltyLoading extends LoyaltyState {}

class LoyaltyLoaded extends LoyaltyState {
  final LoyaltyPointsModel loyaltyData;

  const LoyaltyLoaded({required this.loyaltyData});

  @override
  List<Object> get props => [loyaltyData];
}

class LoyaltyError extends LoyaltyState {
  final String message;

  const LoyaltyError({required this.message});

  @override
  List<Object> get props => [message];
}
