import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class EmptyStateWidget extends StatelessWidget {
  final String imagePath;
  final String title;
  final String subtitle;
  final String buttonText;
  final VoidCallback onButtonPressed;
  final double imageWidth;
  final double imageHeight;
  final Color? imageBackgroundColor;
  final EdgeInsetsGeometry? imagePadding;

  const EmptyStateWidget({
    super.key,
    required this.imagePath,
    required this.title,
    required this.subtitle,
    required this.buttonText,
    required this.onButtonPressed,
    this.imageWidth = 142,
    this.imageHeight = 142,
    this.imageBackgroundColor,
    this.imagePadding,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Image container with optional background
            Container(
              width: imageWidth.w,
              height: imageHeight.h,
              padding: imagePadding ?? const EdgeInsets.all(6.79),
              clipBehavior: Clip.antiAlias,
              decoration: ShapeDecoration(
                color: imageBackgroundColor ?? const Color(0xFFE5E8D3),
                shape: RoundedRectangleBorder(
                  side: BorderSide(width: 4, color: const Color(0x194A3F33)),
                  borderRadius: BorderRadius.circular(84.91.r),
                ),
              ),
              child: Image.asset(imagePath),
            ),
            SizedBox(height: 24.h),

            // Title
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.black,
                fontSize: 18.sp,
                fontFamily: 'Montserrat',
                fontWeight: FontWeight.w600,
                height: 1.07,
                letterSpacing: 0.36,
              ),
            ),
            SizedBox(height: 6.h),

            // Subtitle
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: const Color(0xFF8B8B8B),
                fontSize: 14.sp,
                fontFamily: 'Montserrat',
                fontWeight: FontWeight.w400,
                height: 1.40,
                letterSpacing: 0.28,
              ),
            ),
            SizedBox(height: 16.h),

            // Action button
            ElevatedButton(
              onPressed: onButtonPressed,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF3C4119),
                elevation: 0,
                padding: EdgeInsets.symmetric(horizontal: 32.w, vertical: 16.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5.r),
                ),
              ),
              child: Text(
                buttonText,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16.sp,
                  fontFamily: 'Montserrat',
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
