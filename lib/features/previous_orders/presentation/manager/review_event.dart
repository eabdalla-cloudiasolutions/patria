abstract class ReviewEvent {}

class SubmitReviewEvent extends ReviewEvent {
  final String orderId;
  final int rating;
  final String comment;
  final List<String> tags;

  SubmitReviewEvent({
    required this.orderId,
    required this.rating,
    required this.comment,
    required this.tags,
  });
}
