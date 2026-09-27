import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:patria/core/widgets/safe_network_image.dart';
import 'package:patria/features/previous_orders/data/models/order_model.dart';

class ItemsOrderedSection extends StatelessWidget {
  final List<OrderItemModel> items;

  const ItemsOrderedSection({super.key, required this.items});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'items_ordered'.tr(),
          style: TextStyle(
            color: const Color(0xFF595959),
            fontSize: 11.sp,
            fontFamily: 'Montserrat',
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 6.h),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: const Color(0xFFE5E5E5)),
            borderRadius: BorderRadius.circular(15.r),
          ),
          child: Column(
            children: items.map((item) => _buildItemRow(item)).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildItemRow(OrderItemModel item) {
    final customizations = item.selectedVariants
        .map((v) => v.displayString)
        .join(', ');
    final hasCustomizations = customizations.isNotEmpty;
    final hasNotes = item.notes != null && item.notes!.isNotEmpty;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: const Color(0xFFE5E5E5), width: 1),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(4.r),
            child: SafeNetworkImage(
              imageUrl: item.imageUrl,
              width: 70.w,
              height: 70.h,
              fit: BoxFit.cover,
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
                  style: TextStyle(
                    color: const Color(0xFF28293D),
                    fontSize: 14.sp,
                    fontFamily: 'Montserrat',
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 4.h),
                if (hasCustomizations)
                  Text(
                    customizations,
                    style: TextStyle(
                      color: const Color(0xFF8B8B8B),
                      fontSize: 11.sp,
                      fontFamily: 'Montserrat',
                      fontWeight: FontWeight.w400,
                      height: 1.40,
                      letterSpacing: 0.22,
                    ),
                  ),
                if (hasNotes)
                  Padding(
                    padding: EdgeInsets.only(top: 4.h),
                    child: Text(
                      '${item.notes}',
                      style: TextStyle(
                        color: const Color(0xFF3C4119),
                        fontSize: 11.sp,
                        fontFamily: 'Montserrat',
                        fontWeight: FontWeight.w400,
                        height: 1.40,
                      ),
                    ),
                  ),
                Text(
                  'Qty: ${item.quantity}',
                  style: TextStyle(
                    color: const Color(0xFF28293D),
                    fontSize: 12.sp,
                    fontFamily: 'Montserrat',
                    fontWeight: FontWeight.w400,
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
                    fontSize: 13.sp,
                    fontFamily: 'Montserrat',
                    fontWeight: FontWeight.w400,
                  ),
                ),
                TextSpan(
                  text: item.price.toStringAsFixed(2),
                  style: TextStyle(
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
