class ReviewRequest {
  final String orderId;
  final int rating;
  final String comment;
  final List<String> tags;

  ReviewRequest({
    required this.orderId,
    required this.rating,
    required this.comment,
    required this.tags,
  });

  Map<String, dynamic> toJson() => {
        'orderId': orderId,
        'rating': rating,
        'comment': comment,
        'tags': tags,
      };
}
