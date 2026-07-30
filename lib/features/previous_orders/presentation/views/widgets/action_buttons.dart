// ignore_for_file: use_build_context_synchronously

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:patria/features/cart/presentation/manager/cart_bloc.dart';
import 'package:patria/features/cart/presentation/manager/cart_event.dart';
import 'package:patria/features/cart/presentation/views/cart_screen.dart';
import 'package:patria/features/previous_orders/data/models/order_model.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';

class ActionButtons extends StatelessWidget {
  final String status;
  final OrderModel order;
  final VoidCallback? onTrackOrder;

  const ActionButtons({
    super.key,
    required this.status,
    required this.order,
    this.onTrackOrder,
  });

  bool get _isActiveOrder {
    final s = status.toLowerCase();
    return s == 'pending' ||
        s == 'confirmed' ||
        s == 'preparing' ||
        s == 'out for delivery' ||
        s == 'active';
  }

  bool get _isDelivered => status.toLowerCase() == 'delivered';

  Future<void> _onReorder(BuildContext context) async {
    BuildContext? dialogContext;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        dialogContext = ctx;
        return const Center(child: CircularProgressIndicator());
      },
    );

    try {
      final cartBloc = context.read<CartBloc>();

      for (final item in order.items) {
        cartBloc.add(
          AddToCart(
            productId: item.productId,
            quantity: item.quantity,
            notes: item.notes,
            // ✅ Convert selectedVariants to customization map (what backend expects)
            customization: item.selectedVariants.isNotEmpty
                ? Map.fromEntries(
                    item.selectedVariants.map(
                      (v) => MapEntry(v.group, v.option),
                    ),
                  )
                : null,
          ),
        );
        await Future.delayed(const Duration(milliseconds: 50));
      }

      await Future.delayed(const Duration(milliseconds: 500));

      if (dialogContext != null) {
        Navigator.of(dialogContext!).pop();
      }

      if (context.mounted) Navigator.pop(context);

      if (context.mounted) {
        PersistentNavBarNavigator.pushNewScreen(
          context,
          screen: CartScreen(fromNav: false, myTabIndex: 1),
          withNavBar: true,
          pageTransitionAnimation: PageTransitionAnimation.cupertino,
        );
      }
    } catch (e) {
      if (dialogContext != null) {
        Navigator.of(dialogContext!).pop();
      }
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'reorder_failed'.tr(),
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            backgroundColor: const Color(0xFFC90000),
            duration: const Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
          ),
        );
      }
    }
  }

  Widget _buildActiveButtons(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: () => Navigator.pop(context),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: Color(0xFF3C4119)),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(5.r),
              ),
              padding: EdgeInsets.symmetric(vertical: 16.h),
            ),
            child: Text(
              'close'.tr(),
              style: TextStyle(
                color: const Color(0xFF3C4119),
                fontSize: 16.sp,
                fontFamily: 'Montserrat',
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
        SizedBox(width: 24.w),
        Expanded(
          child: ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              onTrackOrder?.call();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF3C4119),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(5.r),
              ),
              padding: EdgeInsets.symmetric(vertical: 16.h),
              elevation: 0,
            ),
            child: Text(
              'track_order'.tr(),
              style: TextStyle(
                color: Colors.white,
                fontSize: 16.sp,
                fontFamily: 'Montserrat',
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDeliveredButtons(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: () => Navigator.pop(context),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: Color(0xFF3C4119)),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(5.r),
              ),
              padding: EdgeInsets.symmetric(vertical: 16.h),
            ),
            child: Text(
              'close'.tr(),
              style: TextStyle(
                color: const Color(0xFF3C4119),
                fontSize: 16.sp,
                fontFamily: 'Montserrat',
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
        SizedBox(width: 24.w),
        Expanded(
          child: ElevatedButton(
            onPressed: () => _onReorder(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF3C4119),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(5.r),
              ),
              padding: EdgeInsets.symmetric(vertical: 16.h),
              elevation: 0,
            ),
            child: Text(
              'reorder'.tr(),
              style: TextStyle(
                color: Colors.white,
                fontSize: 16.sp,
                fontFamily: 'Montserrat',
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isActiveOrder) return _buildActiveButtons(context);
    if (_isDelivered) return _buildDeliveredButtons(context);
    return const SizedBox.shrink();
  }
}
