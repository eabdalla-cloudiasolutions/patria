import 'package:erb/features/previous_orders/data/models/order_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

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
            'Order Summary',
            style: TextStyle(
              fontSize: 14.sp,
              fontFamily: 'Montserrat',
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 12.h),
          _summaryRow('Subtotal', order.subtotal), // sub total
          _summaryRow('Delivery fee', 25.0), // fetch from order if available
          _summaryRow('Service fee', 32.0),
          Divider(color: const Color(0xFFCACBD4), height: 16.h),
          _summaryRow('Total', order.total, isTotal: true),
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
              color:
                  isTotal ? const Color(0xFF333333) : const Color(0xFF23252A),
              fontSize: 14.sp,
              fontFamily: 'Montserrat',
              fontWeight: isTotal ? FontWeight.w600 : FontWeight.w400,
            ),
          ),
          Text.rich(
            TextSpan(
              children: [
                TextSpan(
                    text: 'EGP ',
                    style: TextStyle(fontWeight: FontWeight.w400)),
                TextSpan(
                  text: amount.toStringAsFixed(2),
                  style: TextStyle(
                      fontWeight: isTotal ? FontWeight.w600 : FontWeight.w600),
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
