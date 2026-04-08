import 'package:equatable/equatable.dart';

abstract class LoyaltyEvent extends Equatable {
  const LoyaltyEvent();

  @override
  List<Object> get props => [];
}

class FetchLoyaltyPoints extends LoyaltyEvent {}

class RefreshLoyaltyPoints extends LoyaltyEvent {}
