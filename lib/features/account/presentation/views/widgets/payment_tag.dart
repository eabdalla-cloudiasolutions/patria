import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class PaymentTag extends StatelessWidget {
  final String label;
  final Color color;
  final Color bgColor;

  const PaymentTag({
    super.key,
    required this.label,
    required this.color,
    required this.bgColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(30.r),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 10.sp,
          fontFamily: 'Montserrat',
          fontWeight: FontWeight.w600,
          letterSpacing: 0.20,
        ),
      ),
    );
  }
}
