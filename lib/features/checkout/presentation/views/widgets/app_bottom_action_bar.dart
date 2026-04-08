import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'app_primary_button.dart';

class AppBottomActionBar extends StatelessWidget {
  final String primaryText;
  final String secondaryText;
  final VoidCallback onPrimaryTap;
  final VoidCallback onSecondaryTap;

  const AppBottomActionBar({
    super.key,
    required this.primaryText,
    required this.secondaryText,
    required this.onPrimaryTap,
    required this.onSecondaryTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding:
          EdgeInsets.only(top: 20.h, left: 20.w, right: 20.w, bottom: 36.h),
      decoration: ShapeDecoration(
        color: Color(0xFFFAFAF7),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20.r),
            topRight: Radius.circular(20.r),
          ),
        ),
        shadows: [
          BoxShadow(
            color: Color(0x26000000),
            blurRadius: 8,
            offset: Offset(1, 0),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: AppPrimaryButton(
              text: secondaryText,
              onTap: onSecondaryTap,
              isOutlined: true,
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: AppPrimaryButton(
              text: primaryText,
              onTap: onPrimaryTap,
            ),
          ),
        ],
      ),
    );
  }
}
