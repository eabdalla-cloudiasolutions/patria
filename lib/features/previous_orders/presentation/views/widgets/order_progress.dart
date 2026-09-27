import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class OrderProgress extends StatelessWidget {
  final String status;

  const OrderProgress({super.key, required this.status});

  int get _activeStep {
    switch (status.toLowerCase()) {
      case 'pending':
        return 0; // Order Placed only
      case 'confirmed':
        return 1; // Order Placed + Preparing
      case 'preparing':
        return 1; // Order Placed + Preparing
      case 'out for delivery':
      case 'on the way':
        return 2; // + On the Way
      case 'delivered':
        return 3; // All steps
      case 'cancelled':
        return -1; // Nothing
      default:
        return 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    final steps = [
      {
        'title': 'order_placed'.tr(),
        'activeImage': 'assets/images/order_placed_active.png',
        'inactiveImage': 'assets/images/order_placed_inactive.png',
      },
      {
        'title': 'preparing'.tr(),
        'activeImage': 'assets/images/preparing_active.png',
        'inactiveImage': 'assets/images/preparing_inactive.png',
      },
      {
        'title': 'on_the_way'.tr(),
        'activeImage': 'assets/images/on_the_way_active.png',
        'inactiveImage': 'assets/images/on_the_way_inactive.png',
      },
      {
        'title': 'delivered'.tr(),
        'activeImage': 'assets/images/delivered_active.png',
        'inactiveImage': 'assets/images/delivered_inactive.png',
      },
    ];

    final circleSize = 56.w;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F2ED),
        border: Border.all(color: const Color(0xFFE5E5E5)),
        borderRadius: BorderRadius.circular(15.r),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Row 1: circles + connectors
          Row(
            children: [
              for (int i = 0; i < steps.length; i++) ...[
                Expanded(
                  child: Center(
                    child: Container(
                      width: circleSize,
                      height: circleSize,
                      decoration: BoxDecoration(
                        color: _activeStep >= i
                            ? const Color(0xFF3C4119)
                            : Colors.white,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: _activeStep >= i
                              ? const Color(0xFF3C4119)
                              : const Color(0xFFE5E5E5),
                          width: 1,
                        ),
                      ),
                      child: Center(
                        child: Image.asset(
                          _activeStep >= i
                              ? steps[i]['activeImage'] as String
                              : steps[i]['inactiveImage'] as String,
                          width: 24.w,
                          height: 24.h,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                  ),
                ),
                if (i < steps.length - 1)
                  Expanded(
                    child: Container(
                      height: 2,
                      color: _activeStep > i
                          ? const Color(0xFF3C4119)
                          : const Color(0xFFCBBFA8),
                    ),
                  ),
              ],
            ],
          ),

          SizedBox(height: 6.h),

          // Row 2: labels only
          Row(
            children: [
              for (int i = 0; i < steps.length; i++) ...[
                Expanded(
                  child: Text(
                    steps[i]['title'] as String,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: _activeStep >= i
                          ? Colors.black
                          : const Color(0xFF8B8B8B),
                      fontSize: 9.sp,
                      fontFamily: 'Montserrat',
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                if (i < steps.length - 1) const Expanded(child: SizedBox()),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
