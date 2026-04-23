import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:erb/core/routing/routes.dart';
import 'package:erb/core/utils/launcher_utils.dart';
import 'package:erb/features/orders/presentation/manager/track_order_bloc.dart';
import 'package:erb/features/orders/presentation/manager/track_order_event.dart';
import 'package:erb/features/orders/presentation/manager/track_order_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'widgets/track_order_eta_card.dart';
import 'widgets/track_order_status.dart';

class TrackOrderScreen extends StatefulWidget {
  final String orderNumber;
  final String orderId;
  final String estimatedArrival;
  final int minsAway;
  final String riderName;
  final int currentStep;

  const TrackOrderScreen({
    super.key,
    required this.orderNumber,
    required this.orderId,
    this.estimatedArrival = '',
    this.minsAway = 18,
    this.riderName = 'Mostafa',
    this.currentStep = 0,
  });

  @override
  State<TrackOrderScreen> createState() => _TrackOrderScreenState();
}

class _TrackOrderScreenState extends State<TrackOrderScreen> {
  late TrackOrderBloc _trackOrderBloc;
  Timer? _pollingTimer;

  @override
  void initState() {
    super.initState();
    _trackOrderBloc = TrackOrderBloc()..add(LoadTrackOrder(widget.orderId));
    _startPolling();
  }

  @override
  void dispose() {
    _trackOrderBloc.close();
    _pollingTimer?.cancel();
    super.dispose();
  }

  // ─── Polling every 15s ───────────────────────────────────────
  void _startPolling() {
    _pollingTimer = Timer.periodic(const Duration(seconds: 15), (_) {
      if (mounted) {
        _trackOrderBloc.add(RefreshTrackOrder(widget.orderId));
      }
    });
  }

  // ─── Navigation ───────────────────────────────────────────────
  void _goToHome() {
    Navigator.of(context, rootNavigator: true).pushNamedAndRemoveUntil(
      Routes.baseLayer,
      (route) => false,
    );
  }

  // ─── Get Help Sheet ───────────────────────────────────────────
  void _showGetHelpSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (_) => Padding(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 24.h),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'get_help'.tr(),
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 18.sp,
                    fontFamily: 'Montserrat',
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.36,
                  ),
                ),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    width: 28.w,
                    height: 28.h,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.black, width: 1.5),
                    ),
                    child:
                        const Icon(Icons.close, size: 18, color: Colors.black),
                  ),
                ),
              ],
            ),
            SizedBox(height: 24.h),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      LauncherUtils.openWhatsAppSupport();
                    },
                    style: OutlinedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 14.h),
                      backgroundColor: const Color(0xFFF5F0EA),
                      side: const BorderSide(color: Color(0xFFE5E5E5)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                    ),
                    icon: Image.asset(
                      'assets/images/message_us.png',
                      width: 18.w,
                      height: 18.h,
                    ),
                    label: Text(
                      'message_us'.tr(),
                      style: TextStyle(
                        color: const Color(0xFF6B5E4B),
                        fontSize: 16,
                        fontFamily: 'Montserrat',
                        fontWeight: FontWeight.w600,
                        height: 1.50,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      LauncherUtils.callSupport();
                    },
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 14.h),
                      backgroundColor: const Color(0xFF6B5E4B),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      elevation: 0,
                    ),
                    icon: Image.asset(
                      'assets/images/call_us.png',
                      width: 18.w,
                      height: 18.h,
                    ),
                    label: Text(
                      'call_us'.tr(),
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontFamily: 'Montserrat',
                        fontWeight: FontWeight.w600,
                        height: 1.50,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 16.h),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _trackOrderBloc,
      child: WillPopScope(
        onWillPop: () async {
          _goToHome();
          return false;
        },
        child: Scaffold(
          backgroundColor: const Color(0xFFF7F7F7),
          appBar: AppBar(
            backgroundColor: const Color(0xFFF7F7F7),
            elevation: 0,
            automaticallyImplyLeading: false,
            leading: GestureDetector(
              onTap: _goToHome,
              child: const Icon(Icons.arrow_back, color: Colors.black),
            ),
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
          body: BlocBuilder<TrackOrderBloc, TrackOrderState>(
            builder: (context, state) {
              if (state is TrackOrderLoading) {
                return const Center(child: CircularProgressIndicator());
              }

              if (state is TrackOrderError) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline,
                          size: 48, color: Color(0xFFCACBD4)),
                      SizedBox(height: 12.h),
                      Text(
                        state.message,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: const Color(0xFF8B8B8B),
                          fontSize: 14.sp,
                          fontFamily: 'Montserrat',
                        ),
                      ),
                      SizedBox(height: 12.h),
                      ElevatedButton(
                        onPressed: () =>
                            _trackOrderBloc.add(LoadTrackOrder(widget.orderId)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF6B5E4B),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5.r),
                          ),
                        ),
                        child: Text(
                          'retry'.tr(),
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                );
              }

              if (state is TrackOrderLoaded) {
                final order = state.order;
                return RefreshIndicator(
                  color: const Color(0xFF6B5E4B),
                  onRefresh: () async {
                    _trackOrderBloc.add(RefreshTrackOrder(widget.orderId));
                    await Future.delayed(const Duration(milliseconds: 500));
                  },
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: EdgeInsets.symmetric(horizontal: 20.w),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 16.h),
                        TrackOrderEtaCard(
                          estimatedArrival:
                              order.estimatedArrival?.isNotEmpty == true
                                  ? order.estimatedArrival!
                                  : widget.estimatedArrival,
                        ),
                        SizedBox(height: 16.h),
                        TrackOrderStatus(
                          currentStep: order.currentStep,
                          isPending: order.currentStep < 3,
                        ),
                        SizedBox(height: 16.h),
                        // Container(
                        //   width: double.infinity,
                        //   padding: EdgeInsets.symmetric(
                        //       horizontal: 16.w, vertical: 10.h),
                        //   decoration: BoxDecoration(
                        //     color: const Color(0xFFF5F0EA),
                        //     borderRadius: BorderRadius.circular(8.r),
                        //   ),
                        //   child: Text(
                        //     order.status,
                        //     textAlign: TextAlign.center,
                        //     style: TextStyle(
                        //       color: const Color(0xFF6B5E4B),
                        //       fontSize: 14.sp,
                        //       fontFamily: 'Montserrat',
                        //       fontWeight: FontWeight.w600,
                        //     ),
                        //   ),
                        // ),
                        // SizedBox(height: 24.h),
                        _buildGetHelpButton(context),
                        SizedBox(height: 120.h),
                      ],
                    ),
                  ),
                );
              }

              return const SizedBox.shrink();
            },
          ),
        ),
      ),
    );
  }

  Widget _buildGetHelpButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 56.h,
      child: OutlinedButton.icon(
        onPressed: () => _showGetHelpSheet(context),
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
            color: const Color(0xFF6B5E4B),
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
