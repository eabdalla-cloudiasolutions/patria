import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ConfirmationBottomSheet extends StatelessWidget {
  final String title;
  final String subtitle;
  final String confirmText;
  final String cancelText;
  final VoidCallback onConfirm;
  final VoidCallback? onCancel;
  final Color? confirmButtonColor;
  final Color? confirmTextColor;
  final bool isDangerous; // true = red button, false = primary color button

  const ConfirmationBottomSheet({
    super.key,
    required this.title,
    required this.subtitle,
    required this.confirmText,
    this.cancelText = 'Cancel',
    required this.onConfirm,
    this.onCancel,
    this.confirmButtonColor,
    this.confirmTextColor,
    this.isDangerous = false,
  });

  @override
  Widget build(BuildContext context) {
    final dangerColor = confirmButtonColor ?? const Color(0xFFC90000);
    final primaryColor = const Color(0xFF3C4119);
    final buttonColor = isDangerous ? dangerColor : primaryColor;

    return Container(
      padding: EdgeInsets.only(
        top: 16.h,
        left: 16.w,
        right: 16.w,
        bottom: 24.h + MediaQuery.of(context).viewInsets.bottom,
      ),
      decoration: ShapeDecoration(
        color: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20.r),
            topRight: Radius.circular(20.r),
          ),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle indicator
          Container(
            width: 40.w,
            height: 4.h,
            margin: EdgeInsets.only(bottom: 16.h),
            decoration: BoxDecoration(
              color: const Color(0xFFE0E0E0),
              borderRadius: BorderRadius.circular(2.r),
            ),
          ),

          // Title and Subtitle
          Column(
            children: [
              Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: const Color(0xFF333333),
                  fontSize: 18.sp,
                  fontFamily: 'Montserrat',
                  fontWeight: FontWeight.w600,
                  height: 1.14,
                  letterSpacing: 0.36,
                ),
              ),
              SizedBox(height: 8.h),
              Text(
                subtitle,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: const Color(0xFF8B8B8B),
                  fontSize: 14.sp,
                  fontFamily: 'Montserrat',
                  fontWeight: FontWeight.w400,
                  height: 1.40,
                  letterSpacing: 0.28,
                ),
              ),
            ],
          ),
          SizedBox(height: 24.h),

          // Confirm Button
          SizedBox(
            width: double.infinity,
            height: 56.h,
            child: ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                onConfirm();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: buttonColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5.r),
                ),
                elevation: 0,
              ),
              child: Text(
                confirmText,
                style: TextStyle(
                  color: confirmTextColor ?? Colors.white,
                  fontSize: 16.sp,
                  fontFamily: 'Montserrat',
                  fontWeight: FontWeight.w600,
                  height: 1.50,
                ),
              ),
            ),
          ),
          SizedBox(height: 12.h),

          // Cancel Button
          SizedBox(
            width: double.infinity,
            height: 56.h,
            child: OutlinedButton(
              onPressed: () {
                Navigator.of(context).pop();
                onCancel?.call();
              },
              style: OutlinedButton.styleFrom(
                side: BorderSide(width: 1, color: primaryColor),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5.r),
                ),
              ),
              child: Text(
                cancelText,
                style: TextStyle(
                  color: primaryColor,
                  fontSize: 16.sp,
                  fontFamily: 'Montserrat',
                  fontWeight: FontWeight.w600,
                  height: 1.50,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Helper method to show the bottom sheet
  static Future<void> show({
    required BuildContext context,
    required String title,
    required String subtitle,
    required String confirmText,
    String cancelText = 'Cancel',
    required VoidCallback onConfirm,
    VoidCallback? onCancel,
    Color? confirmButtonColor,
    Color? confirmTextColor,
    bool isDangerous = false,
    bool isDismissible = true,
    bool enableDrag = true,
  }) {
    return showModalBottomSheet(
      context: context,
      isDismissible: isDismissible,
      enableDrag: enableDrag,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      builder: (context) => ConfirmationBottomSheet(
        title: title,
        subtitle: subtitle,
        confirmText: confirmText,
        cancelText: cancelText,
        onConfirm: onConfirm,
        onCancel: onCancel,
        confirmButtonColor: confirmButtonColor,
        confirmTextColor: confirmTextColor,
        isDangerous: isDangerous,
      ),
    );
  }
}
