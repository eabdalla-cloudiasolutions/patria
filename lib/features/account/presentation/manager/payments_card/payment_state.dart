// ─── States ───────────────────────────────────────────
import 'package:erb/features/account/data/models/payment_method_model.dart';

abstract class PaymentState {}

class PaymentInitial extends PaymentState {}

class PaymentLoading extends PaymentState {}

class PaymentLoaded extends PaymentState {
  final List<PaymentMethodModel> methods;
  PaymentLoaded(this.methods);
}

class PaymentError extends PaymentState {
  final String message;
  PaymentError(this.message);
}
