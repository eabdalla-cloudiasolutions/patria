import 'package:erb/core/widgets/safe_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class HomeBannerItem extends StatelessWidget {
  final String title;
  final String subtitle;
  final String? discountPercent; // only this, no price fields
  final String imageUrl;

  const HomeBannerItem({
    super.key,
    required this.title,
    required this.subtitle,
    required this.imageUrl,
    this.discountPercent,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(16.r),
          child: SafeNetworkImage(
            imageUrl: imageUrl,
            width: 353.w,
            height: 154.h,
            fit: BoxFit.cover,
          ),
        ),
        Container(
          width: 353.w,
          height: 154.h,
          decoration: ShapeDecoration(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16.r),
            ),
            color: Colors.black.withOpacity(0.35),
          ),
        ),
        Container(
          width: 353.w,
          height: 154.h,
          padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 12.h),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16.sp,
                        fontFamily: 'Montserrat',
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.32,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12.sp,
                        fontFamily: 'Montserrat',
                        fontWeight: FontWeight.w400,
                        letterSpacing: 0.24,
                      ),
                    ),
                  ],
                ),
              ),
              // Show discount badge if available
              if (discountPercent != null)
                Container(
                  padding:
                      EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                  decoration: ShapeDecoration(
                    color: const Color(0xFFFFF0F0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30.r),
                    ),
                  ),
                  child: Text(
                    discountPercent!,
                    style: TextStyle(
                      color: const Color(0xFFC90000),
                      fontSize: 14.sp,
                      fontFamily: 'Montserrat',
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}
