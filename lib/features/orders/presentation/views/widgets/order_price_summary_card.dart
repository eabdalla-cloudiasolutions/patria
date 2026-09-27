import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class OrderPriceSummaryCard extends StatelessWidget {
  final double subtotal;
  final double deliveryFee;
  final double discount;

  const OrderPriceSummaryCard({
    super.key,
    required this.subtotal,
    required this.deliveryFee,
    this.discount = 0,
  });

  double get _total => subtotal + deliveryFee - discount;

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
          if (discount > 0) ...[
            SizedBox(height: 10.h),
            _buildPriceRow(
              context,
              'discount'.tr(),
              discount,
              isDiscount: true,
            ),
          ],
          SizedBox(height: 10.h),
          Divider(color: const Color(0xFFCACBD4), height: 1.h),
          SizedBox(height: 10.h),
          _buildPriceRow(context, 'total'.tr(), _total, isTotal: true),
        ],
      ),
    );
  }

  Widget _buildPriceRow(
    BuildContext context,
    String label,
    double amount, {
    bool isTotal = false,
    bool isDiscount = false,
  }) {
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
              if (isDiscount)
                TextSpan(
                  text: '- ',
                  style: TextStyle(
                    color: Colors.green,
                    fontSize: 13.sp,
                    fontFamily: 'Montserrat',
                    fontWeight: FontWeight.w600,
                    height: 1.10,
                  ),
                ),
              TextSpan(
                text: 'currency'.tr(),
                style: TextStyle(
                  color: isDiscount ? Colors.green : const Color(0xFF515151),
                  fontSize: 13.sp,
                  fontFamily: 'Montserrat',
                  fontWeight: FontWeight.w400,
                  height: 1.10,
                ),
              ),
              TextSpan(
                text: amount.toStringAsFixed(2),
                style: TextStyle(
                  color: isDiscount ? Colors.green : const Color(0xFF515151),
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
