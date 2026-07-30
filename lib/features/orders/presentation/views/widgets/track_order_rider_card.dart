import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';

class TrackOrderRiderCard extends StatelessWidget {
  final String riderName;

  const TrackOrderRiderCard({super.key, required this.riderName});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'your_delivery_rider'.tr(),
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
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15.r),
          ),
          child: Row(
            children: [
              SvgPicture.asset(
                'assets/images/Object [Vectorized].svg',
                width: 44.w,
                height: 44.h,
                color: const Color(0xFF3C4119), // Applies color to the SVG
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      riderName,
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 16.sp,
                        fontFamily: 'Montserrat',
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.32,
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      'rider_subtitle'.tr(),
                      style: TextStyle(
                        color: Color(0xFF28293D),
                        fontSize: 12.sp,
                        fontFamily: 'Montserrat',
                        fontWeight: FontWeight.w400,
                        letterSpacing: 0.24,
                      ),
                    ),
                  ],
                ),
              ),
              _buildActionButton(Icons.call_outlined),
              SizedBox(width: 8.w),
              _buildActionButton(Icons.chat_bubble_outline),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton(IconData icon) {
    return Container(
      width: 40.w,
      height: 40.h,
      decoration: BoxDecoration(
        color: const Color(0xFFE5E8D3),
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Icon(icon, color: const Color(0xFF3C4119), size: 20),
    );
  }
}
