import 'package:erb/features/previous_orders/data/models/order_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AddressPaymentCard extends StatelessWidget {
  final OrderModel order;

  const AddressPaymentCard({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: const Color(0xFFFAFAF7),
        borderRadius: BorderRadius.circular(15.r),
      ),
      child: Column(
        children: [
          _infoRow(Icons.location_on_outlined, 'Delivery Address',
              order.deliveryAddress),
          SizedBox(height: 16.h),
          Divider(color: const Color(0xFFCACBD4), height: 1),
          SizedBox(height: 16.h),
          _infoRow(Icons.credit_card, 'Payment Method', order.paymentMethod),
        ],
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: const Color(0xFF333333)),
        SizedBox(width: 8.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 13.sp,
                  fontFamily: 'Montserrat',
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF333333),
                ),
              ),
              SizedBox(height: 4.h),
              Text(
                value,
                style: TextStyle(
                  fontSize: 13.sp,
                  fontFamily: 'Montserrat',
                  fontWeight: FontWeight.w400,
                  color: const Color(0xFF595959),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
