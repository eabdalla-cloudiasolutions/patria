import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'account_menu_item.dart';

class AccountSection extends StatelessWidget {
  final String title;
  final List<AccountMenuItem> items;

  const AccountSection({
    super.key,
    required this.title,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            color: Color(0xFF515151),
            fontSize: 14.sp,
            fontFamily: 'Montserrat',
            fontWeight: FontWeight.w500,
            letterSpacing: 0.28,
          ),
        ),
        SizedBox(height: 16.h),
        Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15.r),
          ),
          child: Column(
            children: items,
          ),
        ),
      ],
    );
  }
}
