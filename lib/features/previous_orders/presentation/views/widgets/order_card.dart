import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:patria/features/previous_orders/presentation/views/widgets/already_rated_row.dart';
import 'package:patria/features/previous_orders/presentation/views/widgets/rating_row.dart';

import 'order_card_actions.dart';
import 'order_card_header.dart';
import 'order_card_items_row.dart';

class OrderCard extends StatelessWidget {
  final Map<String, dynamic> order;
  final VoidCallback? onTrackOrder;
  final VoidCallback? onViewDetails;
  final VoidCallback? onReorder;
  final Function(int)? onRatingChanged;

  const OrderCard({
    super.key,
    required this.order,
    this.onTrackOrder,
    this.onViewDetails,
    this.onReorder,
    this.onRatingChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isReviewed = order['isReviewed'] ?? false;
    final status = order['status'] as String? ?? '';
    final rating = order['rating'] ?? 0;

    final showRatingRow = !isReviewed && status == 'Delivered';
    final showAlreadyRatedRow = isReviewed && status == 'Delivered';

    return Column(
      children: [
        // Main card content
        Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
          decoration: ShapeDecoration(
            color: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(16.r),
                topRight: Radius.circular(16.r),
              ),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              OrderCardHeader(
                orderNumber: order['orderNumber'],
                dateTime: order['dateTime'],
                status: status,
              ),
              SizedBox(height: 12.h),
              Divider(color: const Color(0xFFE5E5E5), height: 1.h),
              SizedBox(height: 12.h),
              // ✅ Make the entire items row tappable
              GestureDetector(
                onTap: onViewDetails,
                child: OrderCardItemsRow(
                  imageUrls: List<String>.from(order['imageUrls']),
                  itemNames: order['itemNames'],
                  itemCount: order['itemCount'],
                  total: order['total'],
                ),
              ),
              SizedBox(height: 12.h),
              Divider(color: const Color(0xFFE5E5E5), height: 1.h),
              SizedBox(height: 12.h),
              OrderCardActions(
                status: status,
                onTrackOrder: onTrackOrder,
                onViewDetails: onViewDetails,
                onReorder: onReorder,
              ),
            ],
          ),
        ),
        // Bottom row – dynamic based on review status
        if (showRatingRow)
          OrderRatingRow(
            orderId: order['_id'],
            currentRating: rating,
            productImage: (order['imageUrls'] as List).isNotEmpty
                ? (order['imageUrls'] as List).first
                : '',
            productName: order['itemNames'].split(', ').first,
            onRatingChanged: (newRating) {
              onRatingChanged?.call(newRating);
            },
          )
        else if (showAlreadyRatedRow)
          AlreadyRatedRow(rating: rating),
      ],
    );
  }
}
