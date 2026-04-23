// ignore_for_file: use_full_hex_values_for_flutter_colors

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class DeleteButton extends StatelessWidget {
  final VoidCallback onPressed;
  final String text;
  final bool isLoading;
  final bool isEnabled;
  final double? width;
  final double height;

  const DeleteButton({
    super.key,
    required this.onPressed,
    this.text = 'Delete Account',
    this.isLoading = false,
    this.isEnabled = true,
    this.width,
    this.height = 56,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width ?? double.infinity,
      height: height.h,
      child: GestureDetector(
        onTap: (isEnabled && !isLoading) ? onPressed : null,
        child: Center(
          child: _buildChild(),
        ),
      ),
    );
  }

  Widget _buildChild() {
    if (isLoading) {
      return SizedBox(
        height: 20.h,
        width: 20.h,
        child: const CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFC90000)),
        ),
      );
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.delete_outline,
          size: 18.sp,
          color: const Color(0xFFC90000),
        ),
        SizedBox(width: 12.w),
        Text(
          text,
          style: TextStyle(
            color: const Color(0xFFC90000),
            fontSize: 16.sp,
            fontFamily: 'Montserrat',
            fontWeight: FontWeight.w600,
            height: 1.50,
          ),
        ),
      ],
    );
  }
}
