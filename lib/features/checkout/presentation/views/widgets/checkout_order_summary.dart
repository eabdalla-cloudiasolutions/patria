import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CheckoutOrderSummary extends StatelessWidget {
  final List<Map<String, dynamic>> cartItems;
  final double deliveryFee;
  final double couponDiscount;
  final double pointsDiscount;
  final double? totalOverride;
  final int rewardPoints;

  const CheckoutOrderSummary({
    super.key,
    this.deliveryFee = 25.0,
    this.couponDiscount = 0,
    this.pointsDiscount = 0,
    this.totalOverride,
    this.rewardPoints = 0,
    required this.cartItems,
  });

  double get subtotal => cartItems.fold(
    0,
    (sum, item) => sum + (item['price'] * item['quantity']),
  );

  double get total =>
      totalOverride ??
      (subtotal - couponDiscount - pointsDiscount + deliveryFee);

  Widget _buildRow(
    BuildContext context,
    String label,
    double amount, {
    bool isBold = false,
    bool isDiscount = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            color: isBold ? const Color(0xFF333333) : const Color(0xFF515151),
            fontSize: 14.sp,
            fontFamily: 'Montserrat',
            fontWeight: isBold ? FontWeight.w600 : FontWeight.w500,
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
                    color: const Color(0xFF059B5A),
                    fontSize: 13.sp,
                    fontFamily: 'Montserrat',
                    fontWeight: FontWeight.w600,
                  ),
                ),
              TextSpan(
                text: 'currency'.tr(),
                style: TextStyle(
                  color: isDiscount
                      ? const Color(0xFF059B5A)
                      : const Color(0xFF515151),
                  fontSize: 13.sp,
                  fontFamily: 'Montserrat',
                  fontWeight: FontWeight.w400,
                  height: 1.10,
                ),
              ),
              TextSpan(
                text: amount.toStringAsFixed(2),
                style: TextStyle(
                  color: isDiscount
                      ? const Color(0xFF059B5A)
                      : const Color(0xFF515151),
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

  @override
  Widget build(BuildContext context) {
    return Column(
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
        SizedBox(height: 16.h),
        Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 12.h),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15.r),
          ),
          child: Column(
            children: [
              ...cartItems.map(
                (item) => Padding(
                  padding: EdgeInsets.only(bottom: 10.h),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'item_quantity'.tr(
                          args: [item['quantity'].toString(), item['name']],
                        ),
                        style: TextStyle(
                          color: const Color(0xFF515151),
                          fontSize: 14.sp,
                          fontFamily: 'Montserrat',
                          fontWeight: FontWeight.w500,
                          height: 1.10,
                        ),
                      ),
                      Text.rich(
                        TextSpan(
                          children: [
                            TextSpan(
                              text: 'currency'.tr(),
                              style: TextStyle(
                                color: const Color(0xFF515151),
                                fontSize: 13.sp,
                                fontFamily: 'Montserrat',
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                            TextSpan(
                              text: (item['price'] * item['quantity'])
                                  .toStringAsFixed(2),
                              style: TextStyle(
                                color: const Color(0xFF515151),
                                fontSize: 13.sp,
                                fontFamily: 'Montserrat',
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Divider(color: const Color(0xFFCACBD4), height: 24.h),
              _buildRow(context, 'subtotal'.tr(), subtotal),
              SizedBox(height: 10.h),
              _buildRow(context, 'delivery_fee'.tr(), deliveryFee),
              if (couponDiscount > 0) ...[
                SizedBox(height: 10.h),
                _buildRow(
                  context,
                  'coupon_discount'.tr(),
                  couponDiscount,
                  isDiscount: true,
                ),
              ],
              if (pointsDiscount > 0) ...[
                SizedBox(height: 10.h),
                _buildRow(
                  context,
                  'points_discount'.tr(),
                  pointsDiscount,
                  isDiscount: true,
                ),
              ],
              Divider(color: const Color(0xFFCACBD4), height: 24.h),
              _buildRow(context, 'total'.tr(), total, isBold: true),
              SizedBox(height: 16.h),
              Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
                decoration: BoxDecoration(
                  color: const Color(0xFFE5E8D3),
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Row(
                  children: [
                    Image.asset(
                      'assets/images/star.png',
                      width: 18.w,
                      height: 18.h,
                    ),
                    SizedBox(width: 2.w),
                    Text(
                      'earn_reward_points'.tr(args: [rewardPoints.toString()]),
                      style: TextStyle(
                        color: const Color(0xFF28293D),
                        fontSize: 12.sp,
                        fontFamily: 'Montserrat',
                        fontWeight: FontWeight.w500,
                        letterSpacing: 0.24,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
