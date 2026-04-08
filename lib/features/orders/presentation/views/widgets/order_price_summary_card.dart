import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class OrderPriceSummaryCard extends StatelessWidget {
  final double subtotal;
  final double deliveryFee;
  final double serviceFee;

  const OrderPriceSummaryCard({
    super.key,
    required this.subtotal,
    required this.deliveryFee,
    required this.serviceFee,
  });

  double get _total => subtotal + deliveryFee + serviceFee;

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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'order_summary'.tr(),
            style: TextStyle(
              color: Colors.black,
              fontSize: 14.sp,
              fontFamily: 'Montserrat',
              fontWeight: FontWeight.w600,
              letterSpacing: 0.28,
            ),
          ),
          SizedBox(height: 12.h),
          _buildPriceRow(context, 'subtotal'.tr(), subtotal),
          SizedBox(height: 10.h),
          _buildPriceRow(context, 'delivery_fee'.tr(), deliveryFee),
          SizedBox(height: 10.h),
          _buildPriceRow(context, 'service_fee'.tr(), serviceFee),
          SizedBox(height: 10.h),
          Divider(color: Color(0xFFCACBD4), height: 1.h),
          SizedBox(height: 10.h),
          _buildPriceRow(context, 'total'.tr(), _total, isTotal: true),
        ],
      ),
    );
  }

  Widget _buildPriceRow(BuildContext context, String label, double amount,
      {bool isTotal = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            color: isTotal ? const Color(0xFF333333) : const Color(0xFF515151),
            fontSize: 14.sp,
            fontFamily: 'Montserrat',
            fontWeight: isTotal ? FontWeight.w600 : FontWeight.w400,
            height: 1.10,
          ),
        ),
        Text.rich(
          TextSpan(
            children: [
              TextSpan(
                text: 'currency'.tr(),
                style: TextStyle(
                  color: Color(0xFF515151),
                  fontSize: 13.sp,
                  fontFamily: 'Montserrat',
                  fontWeight: FontWeight.w400,
                  height: 1.10,
                ),
              ),
              TextSpan(
                text: amount.toStringAsFixed(2),
                style: TextStyle(
                  color: Color(0xFF515151),
                  fontSize: 13.sp,
                  fontFamily: 'Montserrat',
                  fontWeight: FontWeight.w600,
                  height: 1.10,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
