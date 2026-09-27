import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class TrackOrderEtaCard extends StatelessWidget {
  final String estimatedArrival;
  // final String minsAway;

  const TrackOrderEtaCard({
    super.key,
    required this.estimatedArrival,
    // required this.minsAway,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 16.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15.r),
      ),
      child: Row(
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 20),
            child: Image.asset('assets/images/Clock.png'),
          ),
          SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'estimated_arrival'.tr(),
                  style: TextStyle(
                    color: Color(0xFF28293D),
                    fontSize: 12.sp,
                    fontFamily: 'Montserrat',
                    fontWeight: FontWeight.w400,
                    letterSpacing: 0.24,
                  ),
                ),
                SizedBox(height: 6.h),
                Text(
                  estimatedArrival,
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 18.sp,
                    fontFamily: 'Montserrat',
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.36,
                  ),
                ),
              ],
            ),
          ),
          // Container(
          //   padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
          //   decoration: BoxDecoration(
          //     color: const Color(0xFFE5E8D3),
          //     borderRadius: BorderRadius.circular(3.r),
          //     border: Border.all(color: const Color(0x194A3F33), width: 2.w),
          //   ),
          //   child: Text(
          //     'mins_away'.tr(args: [minsAway]),
          //     style: TextStyle(
          //       color: Colors.black,
          //       fontSize: 12.sp,
          //       fontFamily: 'Montserrat',
          //       fontWeight: FontWeight.w500,
          //       letterSpacing: 0.24,
          //     ),
          //   ),
          // ),
        ],
      ),
    );
  }
}
