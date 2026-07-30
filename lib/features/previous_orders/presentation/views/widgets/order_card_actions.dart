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
    final lowerStatus = status.toLowerCase();

    // Cancelled: only View Details
    if (lowerStatus == 'cancelled') {
      return _buildOutlinedButton(
        label: 'view_details'.tr(),
        onTap: onViewDetails,
        fullWidth: true,
        withIcon: true,
      );
    }

    if (lowerStatus == 'active' ||
        lowerStatus == 'pending' ||
        lowerStatus == 'confirmed' ||
        lowerStatus == 'preparing' ||
        lowerStatus == 'out for delivery' ||
        lowerStatus == 'on the way') {
      return _buildPrimaryButton(
        label: 'track_order'.tr(),
        onTap: onTrackOrder,
        fullWidth: true,
      );
    }
    // Delivered: View Details + Reorder
    if (lowerStatus == 'delivered') {
      return Row(
        children: [
          Expanded(
            child: _buildOutlinedButton(
              label: 'view_details'.tr(),
              onTap: onViewDetails,
              withIcon: true,
            ),
          ),
          if (onReorder != null) ...[
            SizedBox(width: 12.w),
            Expanded(
              child: _buildPrimaryButton(
                label: 'reorder'.tr(),
                onTap: onReorder,
                withIcon: true, // 👈 adds refresh icon before text
              ),
            ),
          ],
        ],
      );
    }

    // Fallback
    return const SizedBox.shrink();
  }

  Widget _buildPrimaryButton({
    required String label,
    VoidCallback? onTap,
    bool fullWidth = false,
    bool withIcon = false,
  }) {
    final button = GestureDetector(
      onTap: onTap,
      child: Container(
        height: 40.h,
        decoration: ShapeDecoration(
          color: const Color(0xFF3C4119),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(5.r),
          ),
        ),
        alignment: Alignment.center,
        child: withIcon
            ? Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.refresh, // reorder icon
                    size: 16.sp,
                    color: Colors.white,
                  ),
                  SizedBox(width: 6.w),
                  Text(
                    label,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12.sp,
                      fontFamily: 'Montserrat',
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              )
            : Text(
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

    if (fullWidth) {
      return SizedBox(width: double.infinity, child: button);
    }
    return button;
  }

  Widget _buildOutlinedButton({
    required String label,
    VoidCallback? onTap,
    bool fullWidth = false,
    bool withIcon = false,
  }) {
    final button = GestureDetector(
      onTap: onTap,
      child: Container(
        height: 40.h,
        decoration: ShapeDecoration(
          shape: RoundedRectangleBorder(
            side: BorderSide(width: 1.w, color: const Color(0xFF3C4119)),
            borderRadius: BorderRadius.circular(5.r),
          ),
        ),
        alignment: Alignment.center,
        child: withIcon
            ? Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.visibility_outlined,
                    size: 16.sp,
                    color: const Color(0xFF3C4119),
                  ),
                  SizedBox(width: 6.w),
                  Text(
                    label,
                    style: TextStyle(
                      color: const Color(0xFF3C4119),
                      fontSize: 12.sp,
                      fontFamily: 'Montserrat',
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              )
            : Text(
                label,
                style: TextStyle(
                  color: const Color(0xFF3C4119),
                  fontSize: 12.sp,
                  fontFamily: 'Montserrat',
                  fontWeight: FontWeight.w600,
                ),
              ),
      ),
    );

    if (fullWidth) {
      return SizedBox(width: double.infinity, child: button);
    }
    return button;
  }
}
