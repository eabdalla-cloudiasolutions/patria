import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:patria/core/routing/routes.dart';
import 'package:patria/features/previous_orders/data/models/order_model.dart';

import 'action_buttons.dart';
import 'address_payment_card.dart';
import 'items_ordered_section.dart';
import 'order_header.dart';
import 'order_progress.dart';
import 'order_summary_card.dart';

class OrderDetailsContent extends StatelessWidget {
  final OrderModel order;

  const OrderDetailsContent({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    final bool isCancelled = order.status.toLowerCase() == 'cancelled';
    final bool hasOrderNotes =
        order.orderNotes != null && order.orderNotes!.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        OrderHeader(order: order),
        SizedBox(height: 24.h),
        if (!isCancelled) ...[
          OrderProgress(status: order.status),
          SizedBox(height: 24.h),
        ],
        ItemsOrderedSection(items: order.items),
        SizedBox(height: 16.h),
        OrderSummaryCard(order: order),
        if (hasOrderNotes) ...[
          SizedBox(height: 16.h),
          _buildOrderNotesSection(order.orderNotes!),
        ],
        SizedBox(height: 24.h),
        AddressPaymentCard(order: order),
        SizedBox(height: 24.h),
        ActionButtons(
          status: order.status,
          order: order,
          onTrackOrder: () {
            Navigator.of(context, rootNavigator: true).pushNamed(
              Routes.trackOrder,
              arguments: {
                'orderNumber': order.orderNumber,
                'orderId': order.id,
                'estimatedArrival': '30 min : 60 min',
                'currentStep': 0,
              },
            );
          },
        ),
        SizedBox(height: 20.h),
      ],
    );
  }

  Widget _buildOrderNotesSection(String notes) {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: const Color(0xFFFAFAF7),
        borderRadius: BorderRadius.circular(15.r),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Image.asset('assets/images/order_note.png', height: 20, width: 20),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'order_notes'.tr(),
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontFamily: 'Montserrat',
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  notes,
                  style: TextStyle(
                    color: const Color(0xFF23252A),
                    fontSize: 14.sp,
                    fontFamily: 'Montserrat',
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
