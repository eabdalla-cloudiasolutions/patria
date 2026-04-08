import 'package:easy_localization/easy_localization.dart';
import 'package:erb/features/orders/presentation/views/track_order_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';

import 'widgets/order_cart_item.dart';
import 'widgets/order_confirmation_card.dart';
import 'widgets/order_delivery_info_card.dart';
import 'widgets/order_points_earned_card.dart';
import 'widgets/order_price_summary_card.dart';

class OrderSummaryScreen extends StatelessWidget {
  final List<Map<String, dynamic>> cartItems;
  final double subtotal;
  final double deliveryFee;
  final double serviceFee;
  final String deliveryAddress;
  final String paymentMethod;
  final String orderNumber;
  final int pointsEarned;

  const OrderSummaryScreen({
    super.key,
    required this.cartItems,
    required this.subtotal,
    required this.deliveryFee,
    required this.serviceFee,
    required this.deliveryAddress,
    required this.paymentMethod,
    required this.orderNumber,
    required this.pointsEarned,
  });

  @override
  Widget build(BuildContext context) {
    // ✅ Dynamic date & time using the current locale
    final locale = context.locale.toString(); // e.g., 'en_US', 'ar'
    final now = DateTime.now();
    final formatter = DateFormat("MMMM d, yyyy 'at' hh:mm a", locale);
    final formattedDateTime = formatter.format(now);

    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF7F7F7),
        elevation: 0,
        leading: const BackButton(color: Colors.black),
        title: Text(
          'order_summary'.tr(),
          style: TextStyle(
            color: Colors.black,
            fontSize: 18.sp,
            fontFamily: 'Montserrat',
            fontWeight: FontWeight.w600,
            letterSpacing: 0.36,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 20.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 24.h),
            OrderConfirmationCard(orderNumber: orderNumber),
            SizedBox(height: 16.h),
            _buildOrderDetailsSection(context, formattedDateTime),
            SizedBox(height: 16.h),
            OrderPriceSummaryCard(
              subtotal: subtotal,
              deliveryFee: deliveryFee,
              serviceFee: serviceFee,
            ),
            SizedBox(height: 16.h),
            OrderPointsEarnedCard(pointsEarned: pointsEarned),
            SizedBox(height: 16.h),
            OrderDeliveryInfoCard(
              deliveryAddress: deliveryAddress,
              paymentMethod: paymentMethod,
            ),
            SizedBox(height: 24.h),
            _buildTrackOrderButton(context),
            SizedBox(height: 32.h),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderDetailsSection(
      BuildContext context, String formattedDateTime) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'order_details'.tr(),
          style: TextStyle(
            color: Colors.black,
            fontSize: 14.sp,
            fontFamily: 'Montserrat',
            fontWeight: FontWeight.w500,
            letterSpacing: 0.28,
          ),
        ),
        SizedBox(height: 6.h),
        Text(
          formattedDateTime, // ✅ Dynamic date & time
          style: TextStyle(
            color: const Color(0xFF515151),
            fontSize: 12.sp,
            fontFamily: 'Montserrat',
            fontWeight: FontWeight.w400,
            letterSpacing: 0.24,
          ),
        ),
        SizedBox(height: 16.h),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15.r),
          ),
          child: ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: cartItems.length,
            separatorBuilder: (_, __) =>
                Divider(color: const Color(0xFFE5E5E5), height: 1.h),
            itemBuilder: (_, index) => OrderCartItem(item: cartItems[index]),
          ),
        ),
      ],
    );
  }

  Widget _buildTrackOrderButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 56.h,
      child: ElevatedButton.icon(
        onPressed: () => PersistentNavBarNavigator.pushNewScreen(
          context,
          screen: TrackOrderScreen(
            orderNumber: orderNumber,
            estimatedArrival: '02:45 PM - 1:10 PM',
            minsAway: 18,
            riderName: 'Mostafa',
            currentStep: 2,
          ),
          withNavBar: true,
          pageTransitionAnimation: PageTransitionAnimation.cupertino,
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF6B5E4B),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(5.r),
          ),
        ),
        icon: const Icon(Icons.location_on_outlined,
            color: Colors.white, size: 18),
        label: Text(
          'track_order'.tr(),
          style: TextStyle(
            color: Colors.white,
            fontSize: 16.sp,
            fontFamily: 'Montserrat',
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
