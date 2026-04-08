import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';

class SocialButton extends StatelessWidget {
  final String label;
  final String iconPath;
  final VoidCallback onPressed;

  const SocialButton({
    super.key,
    required this.label,
    required this.iconPath,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFFF5F0EA),
        minimumSize: Size(double.infinity, 44.h),
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: BorderSide(
            width: 1.w,
            color: Colors.black,
          ),
        ),
        elevation: 0,
        shadowColor: Colors.transparent,
      ),
      icon: SvgPicture.asset(iconPath, width: 24.w, height: 24.h),
      label: Text(
        label,
        style: TextStyle(
          color: Colors.black,
          fontSize: 16.sp,
          fontFamily: 'Montserrat',
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
