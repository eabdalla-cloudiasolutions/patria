import 'package:erb/core/widgets/safe_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class OrderCartItem extends StatelessWidget {
  final Map<String, dynamic> item;

  const OrderCartItem({
    super.key,
    required this.item,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(6.r),
            child: SafeNetworkImage(
              width: 70.w,
              height: 70.h,
              fit: BoxFit.cover,
              imageUrl: item['image'],
            ),
          ),
          SizedBox(width: 8.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item['name'] ?? '',
                  style: TextStyle(
                    color: Color(0xFF28293D),
                    fontSize: 14.sp,
                    fontFamily: 'Montserrat',
                    fontWeight: FontWeight.w500,
                    height: 1.40,
                  ),
                ),
                if (item['size'] != null) ...[
                  SizedBox(height: 4.h),
                  Text(
                    item['size'],
                    style: TextStyle(
                      color: Color(0xFF28293D),
                      fontSize: 12.sp,
                      fontFamily: 'Montserrat',
                      fontWeight: FontWeight.w400,
                      height: 1.40,
                    ),
                  ),
                ],
                SizedBox(height: 4.h),
                Text(
                  'Qty: ${item['quantity'] ?? 1}',
                  style: TextStyle(
                    color: Color(0xFF28293D),
                    fontSize: 12.sp,
                    fontFamily: 'Montserrat',
                    fontWeight: FontWeight.w400,
                    height: 1.40,
                  ),
                ),
              ],
            ),
          ),
          Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: 'EGP ',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 13.sp,
                    fontFamily: 'Montserrat',
                    fontWeight: FontWeight.w400,
                  ),
                ),
                TextSpan(
                  text: (item['price'] as double).toStringAsFixed(2),
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 13.sp,
                    fontFamily: 'Montserrat',
                    fontWeight: FontWeight.w600,
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
