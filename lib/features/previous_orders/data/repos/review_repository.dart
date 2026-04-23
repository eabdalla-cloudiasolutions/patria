import 'package:erb/features/previous_orders/data/apis/review_api.dart';
import 'package:erb/features/previous_orders/data/models/review_model.dart';

class ReviewRepository {
  final ReviewApi _api = ReviewApi();

  Future<void> submitReview(ReviewRequest request) async {
    await _api.submitReview(
      orderId: request.orderId,
      rating: request.rating,
      comment: request.comment,
      tags: request.tags,
    );
  }
}
