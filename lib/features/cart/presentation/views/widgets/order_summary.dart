import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class OrderSummary extends StatelessWidget {
  final double subtotal;
  final double discount;
  // final double deliveryFee;

  const OrderSummary({
    super.key,
    required this.subtotal,
    this.discount = 0,
    // this.deliveryFee = 25.0,
  });

  double get total => subtotal - discount;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'order_summary'.tr(),
          style: TextStyle(
            color: Colors.black,
            fontSize: 16.sp,
            fontFamily: 'Montserrat',
            fontWeight: FontWeight.w700,
            letterSpacing: 0.32,
          ),
        ),
        SizedBox(height: 16.h),
        _buildRow(context, 'subtotal'.tr(), subtotal, isBold: false),
        SizedBox(height: 10.h),
        if (discount > 0) ...[
          _buildRow(context, 'discount'.tr(), discount,
              isBold: false, isDiscount: true),
          SizedBox(height: 10.h),
        ],
        // _buildRow(context, 'delivery_fee'.tr(), deliveryFee, isBold: false),
        SizedBox(height: 10.h),
        const Divider(color: Color(0xFFE5E5E5), height: 1),
        SizedBox(height: 10.h),
        _buildRow(context, 'total'.tr(), total, isBold: true),
      ],
    );
  }

  Widget _buildRow(BuildContext context, String label, double amount,
      {required bool isBold, bool isDiscount = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            color: isBold
                ? const Color(0xFF333333)
                : isDiscount
                    ? const Color(0xFF059B5A)
                    : const Color(0xFF515151),
            fontSize: 14.sp,
            fontFamily: 'Montserrat',
            fontWeight: isBold ? FontWeight.w600 : FontWeight.w400,
            height: 1.10,
          ),
        ),
        Text.rich(
          TextSpan(
            children: [
              if (!isDiscount)
                TextSpan(
                  text: 'currency'.tr(),
                  style: TextStyle(
                    color: const Color(0xFF515151),
                    fontSize: 13.sp,
                    fontFamily: 'Montserrat',
                    fontWeight: FontWeight.w400,
                    height: 1.10,
                  ),
                ),
              TextSpan(
                text: isDiscount
                    ? '- ${amount.toStringAsFixed(2)}'
                    : amount.toStringAsFixed(2),
                style: TextStyle(
                  color: isDiscount
                      ? const Color(0xFF059B5A)
                      : const Color(0xFF515151),
                  fontSize: 13.sp,
                  fontFamily: 'Montserrat',
                  fontWeight:
                      isDiscount || isBold ? FontWeight.w600 : FontWeight.w400,
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
