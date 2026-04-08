import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AppPrimaryButton extends StatelessWidget {
  final String text;
  final VoidCallback onTap;
  final bool isOutlined;
  final double height;

  const AppPrimaryButton({
    super.key,
    required this.text,
    required this.onTap,
    this.isOutlined = false,
    this.height = 56,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: height,
        decoration: ShapeDecoration(
          color: isOutlined ? Colors.transparent : const Color(0xFF6B5E4B),
          shape: RoundedRectangleBorder(
            side: BorderSide(width: 1.w, color: Color(0xFF6B5E4B)),
            borderRadius: BorderRadius.circular(5.r),
          ),
        ),
        child: Center(
          child: Text(
            text,
            style: TextStyle(
              color: isOutlined ? const Color(0xFF6B5E4B) : Colors.white,
              fontSize: 16.sp,
              fontFamily: 'Montserrat',
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}
