import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:timelines_plus/timelines_plus.dart';

class TrackOrderStatus extends StatefulWidget {
  final int currentStep;
  final bool isPending;
  final String? riderName;
  final String? riderMessage;

  const TrackOrderStatus({
    super.key,
    required this.currentStep,
    this.isPending = false,
    this.riderName,
    this.riderMessage,
  });

  @override
  State<TrackOrderStatus> createState() => _TrackOrderStatusState();
}

class _TrackOrderStatusState extends State<TrackOrderStatus>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  List<Map<String, String>> _steps(BuildContext context) => [
        {
          'title': 'step_order_placed'.tr(),
          'subtitle': 'step_order_placed_sub'.tr(),
        },
        {
          'title': 'step_being_prepared'.tr(),
          'subtitle': 'step_being_prepared_sub'.tr(),
        },
        {
          'title': 'step_out_for_delivery'.tr(),
          'subtitle': 'step_out_for_delivery_sub'.tr(),
        },
        {
          'title': 'step_delivered'.tr(),
          'subtitle': 'step_delivered_sub'.tr(),
        },
      ];

  @override
  Widget build(BuildContext context) {
    final steps = _steps(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'order_status'.tr(),
          style: TextStyle(
            color: Colors.black,
            fontSize: 14.sp,
            fontFamily: 'Montserrat',
            fontWeight: FontWeight.w600,
            letterSpacing: 0.28,
          ),
        ),
        SizedBox(height: 16.h),

        Container(
          width: double.infinity,
          padding:
              const EdgeInsets.only(top: 0, bottom: 12, left: 12, right: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15.r),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: FixedTimeline.tileBuilder(
            theme: TimelineThemeData(
              nodePosition: 0,
              connectorTheme: const ConnectorThemeData(thickness: 1),
            ),
            builder: TimelineTileBuilder.connected(
              itemCount: steps.length,
              contentsAlign:
                  ContentsAlign.basic, // content to the right, top-aligned
              connectorBuilder: (_, index, __) {
                final isDone = index < widget.currentStep;
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  width: 1, // vertical line
                  color: isDone
                      ? const Color(0xFF6B5E4B)
                      : const Color(0xFFCACBD4),
                );
              },
              indicatorBuilder: (_, index) {
                final isDone = index <
                    widget.currentStep; // 👈 fixed: only fully done steps
                final isCurrent = index == widget.currentStep;
                final isPendingStep =
                    widget.isPending && isCurrent; // 👈 pulse on current step

                if (isPendingStep) {
                  return AnimatedBuilder(
                    animation: _pulseController,
                    builder: (context, child) {
                      return Container(
                        width: 20,
                        height: 20,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: const Color(0xFF6B5E4B).withOpacity(0.3),
                        ),
                        child: Container(
                          margin:
                              EdgeInsets.all(4 * (1 - _pulseController.value)),
                          decoration: const BoxDecoration(
                            color: Color(0xFF6B5E4B),
                            shape: BoxShape.circle,
                          ),
                        ),
                      );
                    },
                  );
                } else if (isDone) {
                  return Container(
                    width: 20,
                    height: 20,
                    decoration: const BoxDecoration(
                      color: Color(0xFF6B5E4B),
                      shape: BoxShape.circle,
                    ),
                    child:
                        const Icon(Icons.check, size: 12, color: Colors.white),
                  );
                } else {
                  return const OutlinedDotIndicator(
                    size: 20,
                    color: Color(0xFFCACBD4),
                    borderWidth: 1,
                  );
                }
              },
              contentsBuilder: (_, index) {
                final isDone = index <=
                    widget.currentStep; // 👈 current + done = dark text
                final step = steps[index];
                // Keep bottom padding for vertical spacing between steps
                return Padding(
                  padding: EdgeInsets.only(left: 12.w, bottom: 16.h, top: 24.h),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      AnimatedDefaultTextStyle(
                        duration: const Duration(milliseconds: 300),
                        style: TextStyle(
                          color: isDone
                              ? const Color(0xFF333333)
                              : const Color(0xFFCACBD4),
                          fontSize: 13.sp,
                          fontFamily: 'Montserrat',
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.26,
                        ),
                        child: Text(step['title']!),
                      ),
                      SizedBox(height: 4.h),
                      AnimatedDefaultTextStyle(
                        duration: const Duration(milliseconds: 300),
                        style: TextStyle(
                          color: isDone
                              ? const Color(0xFF8B8B8B)
                              : const Color(0xFFCACBD4),
                          fontSize: 11.sp,
                          fontFamily: 'Montserrat',
                          fontWeight: FontWeight.w400,
                          letterSpacing: 0.22,
                          height: 1.40,
                        ),
                        child: Text(step['subtitle']!),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),

        // Rider card
        if (widget.currentStep >= 2 && widget.riderName != null)
          Padding(
            padding: EdgeInsets.only(top: 16.h),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15.r),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  const CircleAvatar(
                    radius: 24,
                    backgroundColor: Color(0xFFF5F2ED),
                    child:
                        Icon(Icons.delivery_dining, color: Color(0xFF6B5E4B)),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'your_delivery_rider'.tr(),
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: const Color(0xFF8B8B8B),
                            fontFamily: 'Montserrat',
                          ),
                        ),
                        Text(
                          widget.riderName!,
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w600,
                            fontFamily: 'Montserrat',
                          ),
                        ),
                        if (widget.riderMessage != null)
                          Text(
                            widget.riderMessage!,
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: const Color(0xFF6B5E4B),
                              fontFamily: 'Montserrat',
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}
