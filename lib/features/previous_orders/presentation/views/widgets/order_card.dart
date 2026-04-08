import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'order_card_header.dart';
import 'order_card_items_row.dart';
import 'order_card_actions.dart';

class OrderCard extends StatelessWidget {
  final Map<String, dynamic> order;
  final VoidCallback? onTrackOrder;
  final VoidCallback? onViewDetails;
  final VoidCallback? onReorder;

  const OrderCard({
    super.key,
    required this.order,
    this.onTrackOrder,
    this.onViewDetails,
    this.onReorder,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      decoration: ShapeDecoration(
        color: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          OrderCardHeader(
            orderNumber: order['orderNumber'],
            dateTime: order['dateTime'],
            status: order['status'],
          ),
          SizedBox(height: 12.h),
          Divider(color: Color(0xFFE5E5E5), height: 1.h),
          SizedBox(height: 12.h),
          OrderCardItemsRow(
            imageUrls: List<String>.from(order['imageUrls']),
            itemNames: order['itemNames'],
            itemCount: order['itemCount'],
            total: order['total'],
          ),
          SizedBox(height: 12.h),
          Divider(color: Color(0xFFE5E5E5), height: 1.h),
          SizedBox(height: 12.h),
          OrderCardActions(
            status: order['status'],
            onTrackOrder: onTrackOrder,
            onViewDetails: onViewDetails,
            onReorder: onReorder,
          ),
        ],
      ),
    );
  }
}
