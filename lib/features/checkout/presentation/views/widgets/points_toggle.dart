import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class PointsToggle extends StatelessWidget {
  final bool isEnabled;
  final int points;
  final int pointsValue;
  final VoidCallback onToggle;

  const PointsToggle({
    super.key,
    required this.isEnabled,
    required this.points,
    required this.pointsValue,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final formattedPoints = points.toString().replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (m) => '${m[1]},',
        );

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFDCDCDC)),
        borderRadius: BorderRadius.circular(10.r),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Image.asset(
                'assets/images/points.png',
                width: 32.w,
                height: 32.h,
              ),
              SizedBox(width: 12.w),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'use_points'.tr(),
                    style: TextStyle(
                      color: Color(0xFF333333),
                      fontSize: 14.sp,
                      fontFamily: 'Montserrat',
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.28,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    'points_available'.tr(args: [
                      formattedPoints,
                      pointsValue.toString(),
                    ]),
                    style: TextStyle(
                      color: Color(0xFF8B8B8B),
                      fontSize: 11.sp,
                      fontFamily: 'Montserrat',
                      fontWeight: FontWeight.w500,
                      letterSpacing: 0.22,
                    ),
                  ),
                ],
              ),
            ],
          ),

          // Animated toggle
          GestureDetector(
            onTap: onToggle,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              width: 48.w,
              height: 26.h,
              padding: const EdgeInsets.all(3),
              decoration: BoxDecoration(
                color: isEnabled
                    ? const Color(0xFF6B5E4B)
                    : const Color(0xFFCACBD4),
                borderRadius: BorderRadius.circular(13.r),
              ),
              child: AnimatedAlign(
                duration: const Duration(milliseconds: 250),
                alignment:
                    isEnabled ? Alignment.centerRight : Alignment.centerLeft,
                child: Container(
                  width: 20.w,
                  height: 20.h,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10.r),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x26000000),
                        blurRadius: 4,
                        offset: Offset(0, 1.5),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
