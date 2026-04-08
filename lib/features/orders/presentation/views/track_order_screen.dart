import 'package:easy_localization/easy_localization.dart';
import 'package:erb/core/utils/launcher_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'widgets/track_order_eta_card.dart';
import 'widgets/track_order_map.dart';
import 'widgets/track_order_rider_card.dart';
import 'widgets/track_order_status.dart';

class TrackOrderScreen extends StatelessWidget {
  final String orderNumber;
  final String estimatedArrival;
  final int minsAway;
  final String riderName;
  final int currentStep;

  const TrackOrderScreen({
    super.key,
    required this.orderNumber,
    this.estimatedArrival = '02:45 PM - 1:10 PM',
    this.minsAway = 18,
    this.riderName = 'Mostafa',
    this.currentStep = 2,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF7F7F7),
        elevation: 0,
        leading: const BackButton(color: Colors.black),
        title: Text(
          'track_order'.tr(),
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
            SizedBox(height: 16.h),
            const TrackOrderMap(),
            SizedBox(height: 16.h),
            TrackOrderEtaCard(
              estimatedArrival: estimatedArrival,
              minsAway: minsAway.toString(),
            ),
            SizedBox(height: 16.h),
            TrackOrderStatus(currentStep: currentStep),
            SizedBox(height: 16.h),
            TrackOrderRiderCard(riderName: riderName),
            SizedBox(height: 24.h),
            _buildGetHelpButton(context),
            SizedBox(height: 120.h),
          ],
        ),
      ),
    );
  }

  Widget _buildGetHelpButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 56.h,
      child: OutlinedButton.icon(
        onPressed: () => LauncherUtils.openWhatsAppSupport(),
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: Color(0xFF6B5E4B)),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(5.r),
          ),
        ),
        icon: const Icon(
          Icons.help_outline,
          color: Color(0xFF6B5E4B),
          size: 18,
        ),
        label: Text(
          'get_help'.tr(),
          style: TextStyle(
            color: Color(0xFF6B5E4B),
            fontSize: 16.sp,
            fontFamily: 'Montserrat',
            fontWeight: FontWeight.w600,
            height: 1.50,
          ),
        ),
      ),
    );
  }
}
