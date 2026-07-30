import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ProductBottomBar extends StatefulWidget {
  final double price;
  final Function(int quantity) onAddToCart;
  final bool isEnabled;
  final String? buttonText;

  const ProductBottomBar({
    super.key,
    required this.price,
    required this.onAddToCart,
    this.isEnabled = true,
    this.buttonText,
  });

  @override
  State<ProductBottomBar> createState() => _ProductBottomBarState();
}

class _ProductBottomBarState extends State<ProductBottomBar> {
  int _quantity = 1;

  double get _totalPrice => widget.price * _quantity;

  String formatPrice(double price) {
    if (price == price.truncateToDouble()) {
      return price.toInt().toString();
    }
    return price.toStringAsFixed(2);
  }

  @override
  Widget build(BuildContext context) {
    final baseText = widget.buttonText ?? 'add_to_cart'.tr();
    final buttonLabel = '$baseText ${formatPrice(_totalPrice)} EGP';

    return Container(
      padding: EdgeInsets.only(
        top: 28.h,
        left: 20.w,
        right: 20.w,
        bottom: 36.h,
      ),
      decoration: ShapeDecoration(
        color: const Color(0xFFFAFAF7),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20.r),
            topRight: Radius.circular(20.r),
          ),
        ),
        shadows: [
          BoxShadow(
            color: const Color(0x26000000),
            blurRadius: 8,
            offset: const Offset(1, 0),
          ),
        ],
      ),
      child: Row(
        children: [
          // Quantity selector
          Container(
            height: 56.h,
            decoration: ShapeDecoration(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.r),
              ),
            ),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () {
                    if (_quantity > 1) setState(() => _quantity--);
                  },
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    child: const Icon(
                      Icons.remove,
                      size: 24,
                      color: Color(0xFF3C4119),
                    ),
                  ),
                ),
                Text(
                  '$_quantity',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 16.sp,
                    fontFamily: 'Montserrat',
                    fontWeight: FontWeight.w600,
                  ),
                ),
                GestureDetector(
                  onTap: () => setState(() => _quantity++),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    child: const Icon(
                      Icons.add,
                      size: 24,
                      color: Color(0xFF3C4119),
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: GestureDetector(
              onTap: widget.isEnabled
                  ? () => widget.onAddToCart(_quantity)
                  : null,
              child: Container(
                height: 56.h,
                padding: const EdgeInsets.all(12),
                decoration: ShapeDecoration(
                  color: widget.isEnabled
                      ? const Color(0xFF3C4119)
                      : const Color(0xFFCACBD4),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5.r),
                  ),
                ),
                child: Center(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      buttonLabel,
                      maxLines: 1,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16.sp,
                        fontFamily: 'Montserrat',
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
