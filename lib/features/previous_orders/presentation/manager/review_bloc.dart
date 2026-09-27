import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:patria/core/network/api_error_handler.dart'; // adjust path
import 'package:patria/features/previous_orders/data/models/review_model.dart';
import 'package:patria/features/previous_orders/data/repos/review_repository.dart';
import 'package:patria/features/previous_orders/presentation/manager/review_event.dart';
import 'package:patria/features/previous_orders/presentation/manager/review_state.dart';

class ReviewBloc extends Bloc<ReviewEvent, ReviewState> {
  final ReviewRepository _repository = ReviewRepository();

  ReviewBloc() : super(ReviewInitial()) {
    on<SubmitReviewEvent>(_onSubmitReview);
  }

  Future<void> _onSubmitReview(
    SubmitReviewEvent event,
    Emitter<ReviewState> emit,
  ) async {
    emit(ReviewSubmitting());
    try {
      final request = ReviewRequest(
        orderId: event.orderId,
        rating: event.rating,
        comment: event.comment,
        tags: event.tags,
      );
      await _repository.submitReview(request);
      emit(ReviewSuccess());
    } catch (e) {
      String message;
      if (e is DioException) {
        // ✅ Use your ApiErrorHandler to extract the user‑friendly message
        message = ApiErrorHandler.handle(e);
      } else {
        message = 'Unexpected error occurred.';
      }
      emit(ReviewError(message));
    }
  }
}
