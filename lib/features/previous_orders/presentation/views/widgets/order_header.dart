import 'package:easy_localization/easy_localization.dart';
import 'package:erb/features/previous_orders/data/models/order_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class OrderHeader extends StatelessWidget {
  final OrderModel order;

  const OrderHeader({super.key, required this.order});

  String _formatDate(String isoDate) {
    final dateTime = DateTime.parse(isoDate).toLocal();
    return DateFormat('MMM d, yyyy · h:mm a').format(dateTime);
  }

  Color get _statusColor {
    switch (order.status.toLowerCase()) {
      case 'active':
      case 'pending':
        return const Color(0xFF6B5E4B);
      case 'delivered':
        return const Color(0xFF059B5A);
      case 'cancelled':
        return const Color(0xFFC90000);
      default:
        return Colors.grey;
    }
  }

  Color get _statusBgColor {
    switch (order.status.toLowerCase()) {
      case 'active':
      case 'pending':
        return const Color(0xFFF5F0EA);
      case 'delivered':
        return const Color(0xFFEDF8F0);
      case 'cancelled':
        return const Color(0xFFFFEBEE);
      default:
        return Colors.grey.shade200;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'order_details'.tr(),
                style: TextStyle(
                  color: const Color(0xFF333333),
                  fontSize: 18.sp,
                  fontFamily: 'Montserrat',
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 4.h),
              Text(
                '${order.orderNumber} · ${_formatDate(order.createdAt)}',
                style: TextStyle(
                  color: const Color(0xFF8B8B8B),
                  fontSize: 12.sp,
                  fontFamily: 'Montserrat',
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
        ),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
          decoration: BoxDecoration(
            color: _statusBgColor,
            borderRadius: BorderRadius.circular(30.r),
          ),
          child: Text(
            order.status.tr(),
            style: TextStyle(
              color: _statusColor,
              fontSize: 10.sp,
              fontFamily: 'Montserrat',
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        SizedBox(width: 8.w),
        GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            width: 28.w,
            height: 28.h,
            alignment: Alignment.center,
            child: const Icon(Icons.close, size: 20, color: Color(0xFF8B8B8B)),
          ),
        ),
      ],
    );
  }
}
