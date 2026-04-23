import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AlreadyRatedRow extends StatelessWidget {
  final int rating;

  const AlreadyRatedRow({super.key, required this.rating});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      clipBehavior: Clip.antiAlias,
      decoration: ShapeDecoration(
        color: const Color(0xFFF5F2ED),
        shape: RoundedRectangleBorder(
          side: const BorderSide(width: 1, color: Color(0xFFE5E5E5)),
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(16.r),
            bottomRight: Radius.circular(16.r),
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'You rated $rating/5',
            style: TextStyle(
              color: const Color(0xFF28293D),
              fontSize: 13.sp,
              fontFamily: 'Montserrat',
              fontWeight: FontWeight.w500,
              letterSpacing: 0.26,
            ),
          ),
          SizedBox(width: 10.w),
          Icon(
            Icons.star,
            size: 16.sp,
            color: const Color(0xFFFFB800),
          ),
        ],
      ),
    );
  }
}
