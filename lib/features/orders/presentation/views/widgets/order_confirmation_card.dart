import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lottie/lottie.dart';

class OrderConfirmationCard extends StatefulWidget {
  final String orderNumber;

  const OrderConfirmationCard({
    super.key,
    required this.orderNumber,
  });

  @override
  State<OrderConfirmationCard> createState() => _OrderConfirmationCardState();
}

class _OrderConfirmationCardState extends State<OrderConfirmationCard> {
  bool _animationDone = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding:
          EdgeInsets.only(top: 12.h, left: 12.w, right: 12.w, bottom: 16.h),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFE5E5E5)),
        borderRadius: BorderRadius.circular(15.r),
      ),
      child: Column(
        children: [
          // Animation
          SizedBox(
            width: 120.w,
            height: 120.h,
            child: Lottie.asset(
              'assets/animations/success.json',
              width: 120.w,
              height: 120.h,
              fit: BoxFit.cover,
              repeat: false,
              onLoaded: (composition) {
                Future.delayed(composition.duration, () {
                  if (mounted) {
                    setState(() => _animationDone = true);
                  }
                });
              },
            ),
          ),
          SizedBox(height: 12.h),

          Text(
            'order_placed'.tr(),
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.black,
              fontSize: 20.sp,
              fontFamily: 'Montserrat',
              fontWeight: FontWeight.w700,
              letterSpacing: 0.40,
            ),
          ),
          const SizedBox(height: 6),

          Text(
            'order_confirmed'.tr(),
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Color(0xFF515151),
              fontSize: 16.sp,
              fontFamily: 'Montserrat',
              fontWeight: FontWeight.w500,
              letterSpacing: 0.32,
            ),
          ),
          SizedBox(height: 12.h),

          Container(
            padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 8.h),
            decoration: BoxDecoration(
              color: const Color(0xFFF5F0EA),
              borderRadius: BorderRadius.circular(5.r),
            ),
            child: Text(
              'order_number'.tr(args: [widget.orderNumber]),
              style: TextStyle(
                color: Colors.black,
                fontSize: 12.sp,
                fontFamily: 'Montserrat',
                fontWeight: FontWeight.w500,
                letterSpacing: 0.24,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
