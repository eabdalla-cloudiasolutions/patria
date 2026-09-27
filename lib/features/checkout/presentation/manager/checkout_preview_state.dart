import 'package:patria/features/checkout/data/models/checkout_preview_model.dart';

abstract class CheckoutPreviewState {}

class CheckoutPreviewInitial extends CheckoutPreviewState {}

class CheckoutPreviewLoading extends CheckoutPreviewState {}

class CheckoutPreviewLoaded extends CheckoutPreviewState {
  final CheckoutPreviewModel data;
  CheckoutPreviewLoaded(this.data);
}

class CheckoutPreviewError extends CheckoutPreviewState {
  final String message;
  CheckoutPreviewError(this.message);
}
