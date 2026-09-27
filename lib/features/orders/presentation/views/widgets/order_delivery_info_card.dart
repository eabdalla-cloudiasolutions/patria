import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class OrderDeliveryInfoCard extends StatelessWidget {
  final String deliveryAddress;
  final String paymentMethod;

  const OrderDeliveryInfoCard({
    super.key,
    required this.deliveryAddress,
    required this.paymentMethod,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15.r),
      ),
      child: Column(
        children: [
          _buildInfoRow(
            image: 'assets/images/map-marker-alt.png',
            title: 'delivery_address'.tr(),
            value: deliveryAddress,
          ),
          SizedBox(height: 16.h),
          Divider(color: Color(0xFFCACBD4), height: 1.h),
          SizedBox(height: 16.h),
          _buildInfoRow(
            image: 'assets/images/Wallet.png',
            title: 'payment_method'.tr(),
            value: paymentMethod,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow({
    required String image,
    required String title,
    required String value,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Image.asset(
          image,
          height: 20,
          width: 20,
        ),
        SizedBox(width: 8.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  color: Color(0xFF333333),
                  fontSize: 13.sp,
                  fontFamily: 'Montserrat',
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.26,
                ),
              ),
              SizedBox(height: 6.h),
              Text(
                value,
                style: TextStyle(
                  color: Color(0xFF595959),
                  fontSize: 13.sp,
                  fontFamily: 'Montserrat',
                  fontWeight: FontWeight.w400,
                  letterSpacing: 0.26,
                  height: 1.40,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
