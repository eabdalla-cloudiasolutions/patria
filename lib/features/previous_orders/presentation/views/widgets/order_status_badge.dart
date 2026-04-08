import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class OrderStatusBadge extends StatelessWidget {
  final String status; // 'active' | 'delivered' | 'cancelled'

  const OrderStatusBadge({super.key, required this.status});

  Color get _color {
    switch (status) {
      case 'active':
        return const Color(0xFF6B5E4B);
      case 'delivered':
        return const Color(0xFF059B5A);
      case 'cancelled':
        return const Color(0xFFC90000);
      default:
        return Colors.grey;
    }
  }

  String get _label {
    switch (status) {
      case 'active':
        return 'Active';
      case 'delivered':
        return 'Delivered';
      case 'cancelled':
        return 'Cancelled';
      default:
        return status;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 4.43.w,
          height: 4.43.h,
          decoration: ShapeDecoration(
            color: _color,
            shape: const OvalBorder(),
          ),
        ),
        SizedBox(width: 6.w),
        Text(
          _label,
          style: TextStyle(
            color: _color,
            fontSize: 11.sp,
            fontFamily: 'Montserrat',
            fontWeight: FontWeight.w600,
            letterSpacing: 0.22,
          ),
        ),
      ],
    );
  }
}
