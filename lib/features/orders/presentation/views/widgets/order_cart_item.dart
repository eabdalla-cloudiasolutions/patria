import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:patria/core/widgets/safe_network_image.dart';

class OrderCartItem extends StatelessWidget {
  final Map<String, dynamic> item;

  const OrderCartItem({super.key, required this.item});

  String? get _formattedCustomization {
    final selectedVariants = item['selectedVariants'];
    if (selectedVariants is List && selectedVariants.isNotEmpty) {
      final options = selectedVariants
          .map((v) => v['option']?.toString() ?? '')
          .where((s) => s.isNotEmpty)
          .toList();
      if (options.isNotEmpty) return options.join(', ');
    }
    final customization = item['customization'];
    if (customization is Map) {
      final entries = customization.entries
          .where((e) => e.value != null && e.value.toString().isNotEmpty)
          .map((e) => e.value.toString())
          .toList();
      if (entries.isNotEmpty) return entries.join(', ');
    }
    return null;
  }

  String? get _notes {
    final notes = item['notes'];
    if (notes == null || notes.toString().isEmpty) return null;
    return notes.toString();
  }

  String _formatPrice(double price) {
    if (price == price.truncateToDouble()) {
      return price.toInt().toString();
    }
    return price.toStringAsFixed(2);
  }

  @override
  Widget build(BuildContext context) {
    final double unitPrice = (item['price'] as double);
    final int quantity = (item['quantity'] as int? ?? 1);
    final double totalPrice = unitPrice * quantity;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
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
                    color: const Color(0xFF28293D),
                    fontSize: 14.sp,
                    fontFamily: 'Montserrat',
                    fontWeight: FontWeight.w500,
                    height: 1.40,
                  ),
                ),

                if (_formattedCustomization != null) ...[
                  SizedBox(height: 3.h),
                  Text(
                    _formattedCustomization!,
                    style: TextStyle(
                      color: const Color(0xFF8B8B8B),
                      fontSize: 11,
                      fontFamily: 'Montserrat',
                      fontWeight: FontWeight.w400,
                      height: 1.40,
                      letterSpacing: 0.22,
                    ),
                  ),
                ],

                if (_notes != null) ...[
                  SizedBox(height: 3.h),
                  Text(
                    _notes!,
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 11,
                      fontFamily: 'Montserrat',
                      fontWeight: FontWeight.w400,
                      height: 1.40,
                      letterSpacing: 0.22,
                    ),
                  ),
                ],

                SizedBox(height: 4.h),
                Text(
                  'Qty: $quantity',
                  style: TextStyle(
                    color: const Color(0xFF28293D),
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
                  text: _formatPrice(totalPrice),
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
