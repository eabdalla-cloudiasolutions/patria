import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

class PaymentOption extends StatelessWidget {
  final String title;
  final String? subtitle;
  final String image;
  final bool isSelected;
  final VoidCallback onTap;

  const PaymentOption({
    super.key,
    required this.title,
    this.subtitle,
    required this.image,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: double.infinity,
        height: 56.h,
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
        decoration: ShapeDecoration(
          color: isSelected ? const Color(0xFFF5F2ED) : Colors.white,
          shape: RoundedRectangleBorder(
            side: BorderSide(
              width: isSelected ? 1.5.w : 1.w,
              color: isSelected
                  ? const Color(0xFF6B5E4B)
                  : const Color(0xFFE5E5E5),
            ),
            borderRadius: BorderRadius.circular(8.r),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                // Payment icon
                Container(
                  width: 36.w,
                  height: 36.h,
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(
                        color: const Color(0xFFE5E5E5), width: 0.6.w),
                    borderRadius: BorderRadius.circular(4.r),
                  ),
                  child: SvgPicture.asset(
                    image,
                    fit: BoxFit.contain,
                  ),
                ),
                SizedBox(width: 8.w),

                // Title + subtitle
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        color: Color(0xFF28293D),
                        fontSize: 14.sp,
                        fontFamily: 'Montserrat',
                        fontWeight: FontWeight.w400,
                        height: 1.43,
                      ),
                    ),
                    if (subtitle != null)
                      Text(
                        subtitle!,
                        style: TextStyle(
                          color: Color(0xFF28293D),
                          fontSize: 8.sp,
                          fontFamily: 'Montserrat',
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                  ],
                ),
              ],
            ),

            // ✅ Radio circle — empty when unselected, filled with check when selected
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 20.w,
              height: 20.h,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color:
                    isSelected ? const Color(0xFF6B5E4B) : Colors.transparent,
                border: Border.all(
                  color: const Color(0xFF6B5E4B),
                  width: 1.5.w,
                ),
              ),
              child: isSelected
                  ? const Icon(
                      Icons.check,
                      size: 13,
                      color: Colors.white, // ✅ white checkmark inside
                    )
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}
