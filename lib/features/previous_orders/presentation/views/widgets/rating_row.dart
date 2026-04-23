import 'package:easy_localization/easy_localization.dart';
import 'package:erb/features/previous_orders/presentation/views/widgets/rate_order_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class OrderRatingRow extends StatelessWidget {
  final String orderId;
  final int currentRating; // current rating from the order (0 = not rated)
  final String productImage;
  final String productName;
  final Function(int newRating)
      onRatingChanged; // callback to update UI after return

  const OrderRatingRow({
    super.key,
    required this.orderId,
    required this.currentRating,
    required this.productImage,
    required this.productName,
    required this.onRatingChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      decoration: ShapeDecoration(
        color: const Color(0xFFF5F2ED),
        shape: RoundedRectangleBorder(
          side: const BorderSide(width: 1, color: Color(0xFFE5E5E5)),
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(16.r),
            bottomRight: Radius.circular(16.r),
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'rate'.tr(),
            style: TextStyle(
              color: const Color(0xFF28293D),
              fontSize: 13.sp,
              fontFamily: 'Montserrat',
              fontWeight: FontWeight.w500,
              letterSpacing: 0.26,
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            spacing: 8.w,
            children: List.generate(5, (index) {
              final isFilled = index < currentRating;
              return GestureDetector(
                onTap: () async {
                  // When a star is tapped, open the rating screen with that rating pre‑selected
                  final newRating = await Navigator.push<int>(
                    context,
                    MaterialPageRoute(
                      builder: (_) => RateOrderScreen(
                        productImage: productImage,
                        productName: productName,
                        initialRating: index + 1,
                        orderId: orderId, // pre‑fill the tapped rating
                      ),
                    ),
                  );
                  // If the user submitted a rating (newRating != null), update it
                  if (newRating != null && newRating != currentRating) {
                    onRatingChanged(newRating);
                  }
                },
                child: Icon(
                  isFilled ? Icons.star : Icons.star_border,
                  size: 17.22.w,
                  color: isFilled
                      ? const Color(0xFFFFB800)
                      : const Color(0xFFCACBD4),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}
