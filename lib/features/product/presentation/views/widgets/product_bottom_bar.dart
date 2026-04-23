import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ProductBottomBar extends StatefulWidget {
  final double price;
  final Function(int quantity) onAddToCart; // now receives quantity

  const ProductBottomBar({
    super.key,
    required this.price,
    required this.onAddToCart,
  });

  @override
  State<ProductBottomBar> createState() => _ProductBottomBarState();
}

class _ProductBottomBarState extends State<ProductBottomBar> {
  int _quantity = 1;

  double get _totalPrice => widget.price * _quantity;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding:
          EdgeInsets.only(top: 28.h, left: 20.w, right: 20.w, bottom: 36.h),
      decoration: ShapeDecoration(
        color: Color(0xFFFAFAF7),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20.r),
            topRight: Radius.circular(20.r),
          ),
        ),
        shadows: [
          BoxShadow(
            color: Color(0x26000000),
            blurRadius: 8,
            offset: Offset(1, 0),
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
                // Minus
                GestureDetector(
                  onTap: () {
                    if (_quantity > 1) setState(() => _quantity--);
                  },
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    child: const Icon(
                      Icons.remove,
                      size: 24,
                      color: Color(0xFF6B5E4B),
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
                // Plus
                GestureDetector(
                  onTap: () => setState(() => _quantity++),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    child: const Icon(
                      Icons.add,
                      size: 24,
                      color: Color(0xFF6B5E4B),
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 12.w),
          // Add to cart button
          Expanded(
            child: GestureDetector(
              onTap: () => widget.onAddToCart(_quantity), // pass quantity
              child: Container(
                height: 56.h,
                padding: const EdgeInsets.all(12),
                decoration: ShapeDecoration(
                  color: const Color(0xFF6B5E4B),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5.r),
                  ),
                ),
                child: Center(
                  child: Text(
                    'add_to_cart'.tr(args: [_totalPrice.toStringAsFixed(2)]),
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
        ],
      ),
    );
  }
}
