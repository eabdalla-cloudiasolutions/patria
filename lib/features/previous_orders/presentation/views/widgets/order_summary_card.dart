import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:patria/features/previous_orders/data/models/order_model.dart';

class OrderSummaryCard extends StatelessWidget {
  final OrderModel order;

  const OrderSummaryCard({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: const Color(0xFFFAFAF7),
        borderRadius: BorderRadius.circular(15.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'order_summary'.tr(),
            style: TextStyle(
              fontSize: 14.sp,
              fontFamily: 'Montserrat',
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 12.h),
          _summaryRow('subtotal'.tr(), order.subtotal),
          _summaryRow('delivery_fee'.tr(), order.deliveryFee),
          Divider(color: const Color(0xFFCACBD4), height: 16.h),
          _summaryRow('total'.tr(), order.total, isTotal: true),
        ],
      ),
    );
  }

  Widget _summaryRow(String label, double amount, {bool isTotal = false}) {
    return Padding(
      padding: EdgeInsets.only(bottom: 10.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: isTotal
                  ? const Color(0xFF333333)
                  : const Color(0xFF23252A),
              fontSize: 14.sp,
              fontFamily: 'Montserrat',
              fontWeight: isTotal ? FontWeight.w600 : FontWeight.w400,
            ),
          ),
          Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: 'egp'.tr(),
                  style: const TextStyle(fontWeight: FontWeight.w400),
                ),
                TextSpan(
                  text: amount.toStringAsFixed(2),
                  style: TextStyle(
                    fontWeight: isTotal ? FontWeight.w600 : FontWeight.w600,
                  ),
                ),
              ],
            ),
            style: TextStyle(
              color: const Color(0xFF23252A),
              fontSize: 13.sp,
              fontFamily: 'Montserrat',
            ),
          ),
        ],
      ),
    );
  }
}
