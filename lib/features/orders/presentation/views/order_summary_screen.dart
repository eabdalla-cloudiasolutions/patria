import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:patria/core/routing/routes.dart';

import 'widgets/order_cart_item.dart';
import 'widgets/order_confirmation_card.dart';
import 'widgets/order_delivery_info_card.dart';
import 'widgets/order_points_earned_card.dart';
import 'widgets/order_price_summary_card.dart';

class OrderSummaryScreen extends StatelessWidget {
  final List<Map<String, dynamic>> cartItems;
  final double subtotal;
  final double deliveryFee;
  final double discount;
  final String deliveryAddress;
  final String paymentMethod;
  final String orderNumber;
  final String orderId;
  final String status;
  final String? note;
  final int pointsEarned;

  const OrderSummaryScreen({
    super.key,
    required this.cartItems,
    required this.subtotal,
    required this.deliveryFee,
    this.discount = 0,
    required this.deliveryAddress,
    required this.paymentMethod,
    required this.orderNumber,
    required this.orderId,
    this.status = 'Pending',
    required this.pointsEarned,
    this.note,
  });

  bool get _isActiveOrder {
    final s = status.toLowerCase();
    return s == 'pending' ||
        s == 'confirmed' ||
        s == 'preparing' ||
        s == 'active' ||
        s == 'out for delivery';
  }

  void _goToHome(BuildContext context) {
    Navigator.of(
      context,
      rootNavigator: true,
    ).pushNamedAndRemoveUntil(Routes.baseLayer, (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    final locale = context.locale.toString();
    final now = DateTime.now();
    final formatter = DateFormat("MMMM d, yyyy 'at' hh:mm a", locale);
    final formattedDateTime = formatter.format(now);

    return WillPopScope(
      onWillPop: () async {
        _goToHome(context);
        return false;
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF7F7F7),
        appBar: AppBar(
          backgroundColor: const Color(0xFFF7F7F7),
          elevation: 0,
          automaticallyImplyLeading: false,
          leading: GestureDetector(
            onTap: () => _goToHome(context),
            child: const Icon(Icons.arrow_back, color: Colors.black),
          ),
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
                discount: discount,
              ),
              SizedBox(height: 16.h),
              if (note != null && note!.trim().isNotEmpty)
                _buildOrderNotesSection(note!),
              SizedBox(height: 16.h),
              OrderPointsEarnedCard(pointsEarned: pointsEarned),
              SizedBox(height: 16.h),
              OrderDeliveryInfoCard(
                deliveryAddress: deliveryAddress,
                paymentMethod: paymentMethod,
              ),
              SizedBox(height: 24.h),
              if (_isActiveOrder) _buildTrackOrderButton(context),
              SizedBox(height: 32.h),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOrderDetailsSection(
    BuildContext context,
    String formattedDateTime,
  ) {
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
          formattedDateTime,
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
            padding: EdgeInsets.zero,
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
        onPressed: () => Navigator.of(context, rootNavigator: true).pushNamed(
          Routes.trackOrder,
          arguments: {
            'orderNumber': orderNumber,
            'orderId': orderId,
            'estimatedArrival': '30 min - 60 min',
            'currentStep': 0,
          },
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF3C4119),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(5.r),
          ),
        ),
        icon: const Icon(
          Icons.location_on_outlined,
          color: Colors.white,
          size: 18,
        ),
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

  Widget _buildOrderNotesSection(String notes) {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15.r),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Image.asset('assets/images/order_note.png', height: 20, width: 20),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'order_notes'.tr(),
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontFamily: 'Montserrat',
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  notes,
                  style: TextStyle(
                    color: const Color(0xFF23252A),
                    fontSize: 14.sp,
                    fontFamily: 'Montserrat',
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
