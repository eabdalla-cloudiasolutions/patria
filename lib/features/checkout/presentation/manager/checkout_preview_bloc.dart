import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:patria/features/checkout/data/apis/checkout_preview_api.dart';

import 'checkout_preview_event.dart';
import 'checkout_preview_state.dart';

class CheckoutPreviewBloc
    extends Bloc<CheckoutPreviewEvent, CheckoutPreviewState> {
  final CheckoutPreviewApi _api = CheckoutPreviewApi();

  CheckoutPreviewBloc() : super(CheckoutPreviewInitial()) {
    on<FetchCheckoutPreview>(_onFetchPreview);
  }

  Future<void> _onFetchPreview(
    FetchCheckoutPreview event,
    Emitter<CheckoutPreviewState> emit,
  ) async {
    emit(CheckoutPreviewLoading());
    try {
      final data = await _api.getCheckoutPreview(
        subtotal: event.subtotal,
        deliveryFee: event.deliveryFee,
        couponDiscount: event.couponDiscount,
        pointsToRedeem: event.pointsToRedeem,
      );
      emit(CheckoutPreviewLoaded(data));
    } catch (e) {
      final message = e is String ? e : e.toString();
      emit(CheckoutPreviewError(message));
    }
  }
}
