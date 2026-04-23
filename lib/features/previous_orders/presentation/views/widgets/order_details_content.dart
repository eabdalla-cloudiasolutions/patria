import 'package:erb/core/routing/routes.dart';
import 'package:erb/features/previous_orders/data/models/order_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

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
        SizedBox(height: 24.h),
        OrderSummaryCard(order: order),
        SizedBox(height: 24.h),
        AddressPaymentCard(order: order),
        SizedBox(height: 24.h),
        ActionButtons(
          status: order.status,
          order: order,
          onTrackOrder: () {
            // 👈 added
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
}
