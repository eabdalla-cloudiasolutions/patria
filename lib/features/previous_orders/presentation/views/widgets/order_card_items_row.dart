import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class OrderCardItemsRow extends StatelessWidget {
  final List<String> imageUrls;
  final String itemNames;
  final int itemCount;
  final double total;

  const OrderCardItemsRow({
    super.key,
    required this.imageUrls,
    required this.itemNames,
    required this.itemCount,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    final List<String> displayUrls = imageUrls.take(3).toList();
    final int imageCount = displayUrls.length;

    // Stack configuration
    final double imageWidth = 36.w;
    final double imageHeight = 36.h;
    final double overlapOffset =
        24.w; // Each next image shifts by 24 (overlaps by 12)
    final double totalStackWidth =
        imageCount > 0 ? imageWidth + overlapOffset * (imageCount - 1) : 0;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Stacked product images (overlapping)
        if (imageCount > 0)
          SizedBox(
            width: totalStackWidth,
            height: imageHeight, // ✅ Explicit height fixes the assertion
            child: Stack(
              clipBehavior: Clip.none,
              children: List.generate(imageCount, (index) {
                return Positioned(
                  left: overlapOffset * index,
                  child: Container(
                    width: imageWidth,
                    height: imageHeight,
                    clipBehavior: Clip.antiAlias,
                    decoration: ShapeDecoration(
                      image: DecorationImage(
                        image: NetworkImage(displayUrls[index]),
                        fit: BoxFit.cover,
                      ),
                      shape: RoundedRectangleBorder(
                        side: BorderSide(width: 2.w, color: Colors.white),
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),

        // Item names + count
        Expanded(
          child: Padding(
            padding: EdgeInsets.only(left: imageCount > 0 ? 12.w : 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  itemNames,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: const Color(0xFF333333),
                    fontSize: 13.sp,
                    fontFamily: 'Montserrat',
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0.26,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  'item_count'.tr(args: [itemCount.toString()]),
                  style: TextStyle(
                    color: const Color(0xFF8B8B8B),
                    fontSize: 10.sp,
                    fontFamily: 'Montserrat',
                    fontWeight: FontWeight.w400,
                    letterSpacing: 0.20,
                  ),
                ),
              ],
            ),
          ),
        ),

        // Total
        Text(
          'order_total'.tr(args: [total.toStringAsFixed(2)]),
          style: TextStyle(
            color: const Color(0xFF28293D),
            fontSize: 14.sp,
            fontFamily: 'Montserrat',
            fontWeight: FontWeight.w700,
            letterSpacing: 0.28,
          ),
        ),
      ],
    );
  }
}
