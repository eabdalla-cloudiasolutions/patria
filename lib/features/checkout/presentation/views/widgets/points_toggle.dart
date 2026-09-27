import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class PointsToggle extends StatelessWidget {
  final bool isEnabled;
  final bool canRedeem;
  final int points;
  final int pointsValue;
  final String redeemDisplayLabel;
  final VoidCallback onToggle;
  final int minRedeemPoints;

  const PointsToggle({
    super.key,
    required this.isEnabled,
    required this.canRedeem,
    required this.points,
    required this.pointsValue,
    required this.redeemDisplayLabel,
    required this.onToggle,
    required this.minRedeemPoints,
  });

  @override
  Widget build(BuildContext context) {
    final formattedPoints = points.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (m) => '${m[1]},',
    );

    return Opacity(
      // ✅ Dim if can't redeem
      opacity: canRedeem ? 1.0 : 0.5,
      child: Container(
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
                        color: const Color(0xFF333333),
                        fontSize: 14.sp,
                        fontFamily: 'Montserrat',
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.28,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      // ✅ Show API label + balance
                      '$formattedPoints pts · $redeemDisplayLabel',
                      style: TextStyle(
                        color: const Color(0xFF8B8B8B),
                        fontSize: 11.sp,
                        fontFamily: 'Montserrat',
                        fontWeight: FontWeight.w500,
                        letterSpacing: 0.22,
                      ),
                    ),
                    if (!canRedeem)
                      Text(
                        'min_points_required'.tr(
                          args: [minRedeemPoints.toString()],
                        ),
                        style: TextStyle(
                          color: Colors.red,
                          fontSize: 10.sp,
                          fontFamily: 'Montserrat',
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                  ],
                ),
              ],
            ),
            GestureDetector(
              // ✅ Only allow toggle if canRedeem
              onTap: canRedeem ? onToggle : null,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                width: 48.w,
                height: 26.h,
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  color: isEnabled
                      ? const Color(0xFF3C4119)
                      : const Color(0xFFCACBD4),
                  borderRadius: BorderRadius.circular(13.r),
                ),
                child: AnimatedAlign(
                  duration: const Duration(milliseconds: 250),
                  alignment: isEnabled
                      ? Alignment.centerRight
                      : Alignment.centerLeft,
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
      ),
    );
  }
}
