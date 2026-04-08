import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class OrderCardActions extends StatelessWidget {
  final String status;
  final VoidCallback? onTrackOrder;
  final VoidCallback? onViewDetails;
  final VoidCallback? onReorder;

  const OrderCardActions({
    super.key,
    required this.status,
    this.onTrackOrder,
    this.onViewDetails,
    this.onReorder,
  });

  @override
  Widget build(BuildContext context) {
    if (status == 'active') {
      return _buildPrimaryButton(
        label: 'track_order'.tr(),
        onTap: onTrackOrder,
      );
    }

    if (status == 'cancelled') {
      return _buildOutlinedButton(
        label: 'view_details'.tr(),
        onTap: onViewDetails,
      );
    }

    // delivered
    return Row(
      children: [
        Expanded(
          child: _buildOutlinedButton(
            label: 'view_details'.tr(),
            onTap: onViewDetails,
          ),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: _buildPrimaryButton(
            label: 'reorder'.tr(),
            onTap: onReorder,
          ),
        ),
      ],
    );
  }

  Widget _buildPrimaryButton({
    required String label,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 40.h,
        decoration: ShapeDecoration(
          color: const Color(0xFF6B5E4B),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(5.r),
          ),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: TextStyle(
            color: Colors.white,
            fontSize: 12.sp,
            fontFamily: 'Montserrat',
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildOutlinedButton({
    required String label,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 40.h,
        decoration: ShapeDecoration(
          shape: RoundedRectangleBorder(
            side: BorderSide(width: 1.w, color: Color(0xFF6B5E4B)),
            borderRadius: BorderRadius.circular(5.r),
          ),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: TextStyle(
            color: Color(0xFF6B5E4B),
            fontSize: 12.sp,
            fontFamily: 'Montserrat',
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
