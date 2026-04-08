import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class EditCardPreview extends StatelessWidget {
  final String cardNumber;
  final String cardHolder;

  const EditCardPreview({
    super.key,
    required this.cardNumber,
    required this.cardHolder,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 185.h,
      child: Stack(
        children: [
          // Background gradient card
          Container(
            width: double.infinity,
            height: 185.h,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment(-0.14, -0.11),
                end: Alignment(1.14, 1.11),
                colors: [Color(0xFF064A7D), Color(0xFF632400)],
              ),
              borderRadius: BorderRadius.circular(20.r),
            ),
          ),
          // Overlay
          Container(
            width: double.infinity,
            height: 185.h,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.03),
              borderRadius: BorderRadius.circular(20.r),
            ),
          ),
          // Card type label
          Positioned(
            left: 24.w,
            top: 28.h,
            child: Opacity(
              opacity: 0.90,
              child: Text(
                'credit'.tr(),
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16.sp,
                  fontFamily: 'Montserrat',
                  fontWeight: FontWeight.w400,
                  height: 1.50.h,
                ),
              ),
            ),
          ),
          // Mastercard logo
          Positioned(
            right: 16.w,
            top: 24.h,
            child: SizedBox(
              width: 48.w,
              height: 48.h,
              child: Stack(
                children: [
                  Positioned(
                    left: 0.w,
                    top: 9.h,
                    child: Container(
                      width: 30.w,
                      height: 30.h,
                      decoration: const ShapeDecoration(
                        color: Color(0xFFEB001B),
                        shape: OvalBorder(),
                      ),
                    ),
                  ),
                  Positioned(
                    left: 18.w,
                    top: 9.h,
                    child: Container(
                      width: 30.w,
                      height: 30.h,
                      decoration: const ShapeDecoration(
                        color: Color(0xFFF79E1B),
                        shape: OvalBorder(),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Card number
          Positioned(
            left: 24.w,
            top: 113.h,
            child: Text(
              cardNumber,
              style: TextStyle(
                color: Colors.white,
                fontSize: 16.sp,
                fontFamily: 'Montserrat',
                fontWeight: FontWeight.w400,
                height: 1.50.h,
              ),
            ),
          ),
          // Cardholder name
          Positioned(
            left: 24.w,
            top: 137.h,
            child: Text(
              cardHolder,
              style: TextStyle(
                color: Colors.white,
                fontSize: 16.sp,
                fontFamily: 'Montserrat',
                fontWeight: FontWeight.w400,
                height: 1.50.h,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
