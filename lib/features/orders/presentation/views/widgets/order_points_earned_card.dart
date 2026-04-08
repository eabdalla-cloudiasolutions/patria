import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class OrderPointsEarnedCard extends StatelessWidget {
  final int pointsEarned;

  const OrderPointsEarnedCard({
    super.key,
    required this.pointsEarned,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 16.h),
      decoration: BoxDecoration(
        color: Colors.white,
        image: const DecorationImage(
          image: AssetImage('assets/images/Rewards Earned Star.png'),
          fit: BoxFit.cover,
        ),
        border: Border.all(color: const Color(0xFFE5E5E5)),
        borderRadius: BorderRadius.circular(14.r),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(6.r),
            child: Image.asset(
              'assets/images/StarMedia.png',
              width: 64.w,
              height: 64.h,
              fit: BoxFit.cover,
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'points_earned'.tr(),
                  style: TextStyle(
                    color: Color(0xFF333333),
                    fontSize: 14.sp,
                    fontFamily: 'Montserrat',
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.28,
                  ),
                ),
                SizedBox(height: 6.h),
                Text(
                  'points_added'.tr(args: [pointsEarned.toString()]),
                  style: TextStyle(
                    color: Color(0xFF595959),
                    fontSize: 13.sp,
                    fontFamily: 'Montserrat',
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0.26,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
