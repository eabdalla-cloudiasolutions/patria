import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:patria/features/previous_orders/data/models/order_model.dart';

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
          _infoRow(
            'assets/images/map-marker-alt.png',
            'delivery_address'.tr(),
            order.deliveryAddress,
          ),
          SizedBox(height: 16.h),
          Divider(color: const Color(0xFFCACBD4), height: 1),
          SizedBox(height: 16.h),
          _infoRow(
            'assets/images/Wallet.png',
            'payment_method'.tr(),
            order.paymentMethod,
          ),
        ],
      ),
    );
  }

  Widget _infoRow(String image, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Image.asset(image, width: 20, height: 20),
        // Icon(icon, size: 20, color: const Color(0xFF333333)),
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
