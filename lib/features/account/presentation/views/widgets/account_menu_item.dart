import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AccountMenuItem extends StatelessWidget {
  final String title;
  final IconData icon;
  final VoidCallback onTap;
  final bool isLast;
  final Color? titleColor;
  final Widget? trailing;

  const AccountMenuItem({
    super.key,
    required this.title,
    required this.icon,
    required this.onTap,
    this.isLast = false,
    this.titleColor,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListTile(
          onTap: onTap,
          contentPadding: EdgeInsets.symmetric(vertical: 4.h),
          leading: Icon(icon, size: 18, color: const Color(0xFF3C4119)),
          title: Text(
            title,
            style: TextStyle(
              color: titleColor ?? const Color(0xFF28293D),
              fontSize: 14.sp,
              fontFamily: 'Montserrat',
              fontWeight: FontWeight.w500,
              letterSpacing: 0.28,
            ),
          ),
          trailing:
              trailing ??
              const Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: Color(0xFF8B8B8B),
              ),
        ),
        if (!isLast)
          Divider(height: 1.h, color: Color(0xFFCACBD4), thickness: 1),
      ],
    );
  }
}
