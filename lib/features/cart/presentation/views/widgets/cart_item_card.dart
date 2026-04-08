import 'package:easy_localization/easy_localization.dart';
import 'package:erb/core/widgets/safe_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';

class CartItemCard extends StatelessWidget {
  final String name;
  final String imageUrl;
  final double price;
  final int quantity;
  final VoidCallback onIncrease;
  final VoidCallback onDecrease;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const CartItemCard({
    super.key,
    required this.name,
    required this.imageUrl,
    required this.price,
    required this.quantity,
    required this.onIncrease,
    required this.onDecrease,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 16.h),
      decoration: ShapeDecoration(
        color: Colors.white,
        shape: RoundedRectangleBorder(
          side: BorderSide(width: 1.w, color: const Color(0xFFE5E5E5)),
          borderRadius: BorderRadius.circular(5.r),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Image + Info
          Expanded(
            child: Row(
              children: [
                // Image
                ClipRRect(
                  borderRadius: BorderRadius.circular(4.r),
                  child: SafeNetworkImage(
                    imageUrl: imageUrl,
                    width: 70.w,
                    height: 70.h,
                    fit: BoxFit.fill,
                  ),
                ),
                SizedBox(width: 8.w),

                // Name + Edit + Price
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Name
                      Text(
                        name,
                        style: TextStyle(
                          color: const Color(0xFF1D1E20),
                          fontSize: 14.sp,
                          fontFamily: 'Montserrat',
                          fontWeight: FontWeight.w600,
                          height: 1.40,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),

                      // Edit button
                      GestureDetector(
                        onTap: onEdit,
                        child: Row(
                          children: [
                            SvgPicture.asset(
                              'assets/images/EditPen.svg',
                              width: 15.w,
                              height: 15.h,
                            ),
                            SizedBox(width: 6.w),
                            Text(
                              'edit'.tr(),
                              style: TextStyle(
                                color: const Color(0xFF6B5E4B),
                                fontSize: 12.sp,
                                fontFamily: 'Montserrat',
                                fontWeight: FontWeight.w600,
                                height: 1.40,
                                letterSpacing: 0.24,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 14.h),

                      // Price
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
                                height: 1.10,
                              ),
                            ),
                            TextSpan(
                              text: (price * quantity).toStringAsFixed(2),
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 13.sp,
                                fontFamily: 'Montserrat',
                                fontWeight: FontWeight.w600,
                                height: 1.10,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Quantity controller (minus/plus) – minus becomes delete when quantity == 1
          Container(
            padding: const EdgeInsets.all(8),
            decoration: ShapeDecoration(
              color: const Color(0xFFF5F2ED),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.r),
              ),
            ),
            child: Row(
              children: [
                // Minus button (delete when quantity == 1)
                GestureDetector(
                  onTap: quantity == 1 ? onDelete : onDecrease,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: ShapeDecoration(
                      color: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(3.r),
                      ),
                    ),
                    child: Icon(
                      quantity == 1 ? Icons.delete_outline : Icons.remove,
                      size: 14,
                      color: quantity == 1
                          ? Colors.red
                          : Color.fromARGB(255, 17, 16, 14),
                    ),
                  ),
                ),
                SizedBox(width: 12.w),

                Text(
                  '$quantity',
                  style: TextStyle(
                    color: const Color(0xFF28293D),
                    fontSize: 14.sp,
                    fontFamily: 'Montserrat',
                    fontWeight: FontWeight.w400,
                    letterSpacing: 0.28,
                  ),
                ),
                SizedBox(width: 12.w),

                // Plus button
                GestureDetector(
                  onTap: onIncrease,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: ShapeDecoration(
                      color: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(3.r),
                      ),
                    ),
                    child: const Icon(
                      Icons.add,
                      size: 14,
                      color: Color(0xFF6B5E4B),
                    ),
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
