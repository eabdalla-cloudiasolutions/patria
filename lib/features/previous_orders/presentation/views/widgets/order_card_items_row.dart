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
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Item images (max 3)
        ...imageUrls.take(3).map((url) => Padding(
              padding: EdgeInsets.only(right: 9.w),
              child: Container(
                width: 36.w,
                height: 36.h,
                clipBehavior: Clip.antiAlias,
                decoration: ShapeDecoration(
                  image: DecorationImage(
                    image: AssetImage(url),
                    fit: BoxFit.cover,
                  ),
                  shape: RoundedRectangleBorder(
                    side: BorderSide(width: 2.w, color: Colors.white),
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                ),
              ),
            )),

        // Item names + count
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                itemNames,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: Color(0xFF333333),
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
                  color: Color(0xFF8B8B8B),
                  fontSize: 10.sp,
                  fontFamily: 'Montserrat',
                  fontWeight: FontWeight.w400,
                  letterSpacing: 0.20,
                ),
              ),
            ],
          ),
        ),

        // Total
        Text(
          'order_total'.tr(args: [total.toStringAsFixed(2)]),
          style: TextStyle(
            color: Color(0xFF28293D),
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
