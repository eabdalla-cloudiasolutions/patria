import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:timelines_plus/timelines_plus.dart';

class TrackOrderStatus extends StatelessWidget {
  final int currentStep;

  const TrackOrderStatus({
    super.key,
    required this.currentStep,
  });

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
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15.r),
          ),
          child: FixedTimeline.tileBuilder(
            theme: TimelineThemeData(
              nodePosition: 0,
              connectorTheme: const ConnectorThemeData(thickness: 1),
            ),
            builder: TimelineTileBuilder.connected(
              itemCount: steps.length,
              contentsAlign: ContentsAlign.basic,
              connectorBuilder: (_, index, __) {
                final isDone = index < currentStep;
                return SolidLineConnector(
                  color: isDone
                      ? const Color(0xFF6B5E4B)
                      : const Color(0xFFCACBD4),
                  thickness: 1,
                  indent: 2,
                  endIndent: 2,
                );
              },
              indicatorBuilder: (_, index) {
                final isDone = index <= currentStep;
                final isCurrent = index == currentStep;
                if (isDone) {
                  return DotIndicator(
                    size: 20,
                    color: const Color(0xFF6B5E4B),
                    border: isCurrent
                        ? Border.all(
                            color: const Color(0x19624F1C),
                            width: 2.w,
                            strokeAlign: BorderSide.strokeAlignOutside,
                          )
                        : null,
                    child: const Icon(
                      Icons.check,
                      size: 12,
                      color: Colors.white,
                    ),
                  );
                }
                return const OutlinedDotIndicator(
                  size: 20,
                  color: Color(0xFF8B8B8B),
                  borderWidth: 1,
                );
              },
              contentsBuilder: (_, index) {
                final isDone = index <= currentStep;
                final step = steps[index];
                return Padding(
                  padding: EdgeInsets.only(left: 14.w, bottom: 16.h),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        step['title']!,
                        style: TextStyle(
                          color: isDone
                              ? const Color(0xFF333333)
                              : const Color(0xFFCACBD4),
                          fontSize: 13.sp,
                          fontFamily: 'Montserrat',
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.26,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        step['subtitle']!,
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
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}
