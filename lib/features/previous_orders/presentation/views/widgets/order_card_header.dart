import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'order_status_badge.dart';

class OrderCardHeader extends StatelessWidget {
  final String orderNumber;
  final String dateTime;
  final String status;

  const OrderCardHeader({
    super.key,
    required this.orderNumber,
    required this.dateTime,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'order_erb_number'.tr(args: [orderNumber]),
              style: TextStyle(
                color: Color(0xFF333333),
                fontSize: 13.sp,
                fontFamily: 'Montserrat',
                fontWeight: FontWeight.w600,
                letterSpacing: 0.26,
              ),
            ),
            SizedBox(height: 4.h),
            Text(
              dateTime,
              style: TextStyle(
                color: Color(0xFF8B8B8B),
                fontSize: 10.sp,
                fontFamily: 'Montserrat',
                fontWeight: FontWeight.w400,
                letterSpacing: 0.20,
              ),
            ),
          ],
        ),
        OrderStatusBadge(status: status),
      ],
    );
  }
}
