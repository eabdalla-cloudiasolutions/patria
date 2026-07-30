// ─── States ───────────────────────────────────────────
import 'package:patria/features/account/data/models/address_model.dart';

abstract class AddressesState {}

class AddressesInitial extends AddressesState {}

class AddressesLoading extends AddressesState {}

class AddressesLoaded extends AddressesState {
  final List<AddressModel> addresses;
  AddressesLoaded(this.addresses);
}

class AddressesError extends AddressesState {
  final String message;
  AddressesError(this.message);
}
