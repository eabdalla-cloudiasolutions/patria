import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class SectionTitle extends StatelessWidget {
  final String title;
  final String? subtitle;
  final double fontSize;

  const SectionTitle({
    super.key,
    required this.title,
    this.subtitle,
    this.fontSize = 14,
  });

  @override
  Widget build(BuildContext context) {
    if (subtitle == null) {
      return Text(
        title,
        style: TextStyle(
          color: Colors.black,
          fontSize: fontSize.sp,
          fontFamily: 'Montserrat',
          fontWeight: FontWeight.w600,
        ),
      );
    }

    return Text.rich(
      TextSpan(
        children: [
          TextSpan(
            text: '$title ',
            style: TextStyle(
              color: Colors.black,
              fontSize: fontSize.sp,
              fontFamily: 'Montserrat',
              fontWeight: FontWeight.w600,
            ),
          ),
          TextSpan(
            text: subtitle,
            style: TextStyle(
              color: const Color(0xFF515151),
              fontSize: fontSize.sp,
              fontFamily: 'Montserrat',
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
