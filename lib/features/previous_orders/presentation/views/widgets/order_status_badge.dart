import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class OrderStatusBadge extends StatelessWidget {
  final String status;

  const OrderStatusBadge({super.key, required this.status});

  // 👇 Normalize status to display category
  String get _normalizedStatus {
    final s = status.toLowerCase();
    if (s == 'active' ||
        s == 'pending' ||
        s == 'confirmed' ||
        s == 'preparing' ||
        s == 'out for delivery' ||
        s == 'on the way') {
      return 'active';
    }
    if (s == 'delivered') return 'delivered';
    if (s == 'cancelled') return 'cancelled';
    return s;
  }

  Color get _color {
    switch (_normalizedStatus) {
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
    switch (_normalizedStatus) {
      case 'active':
        return 'status_active'.tr();
      case 'delivered':
        return 'status_delivered'.tr();
      case 'cancelled':
        return 'status_cancelled'.tr();
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
