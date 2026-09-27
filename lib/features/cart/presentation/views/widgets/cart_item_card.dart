import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:patria/core/widgets/safe_network_image.dart';

class CartItemCard extends StatelessWidget {
  final String name;
  final String imageUrl;
  final double price;
  final int quantity;
  final VoidCallback onIncrease;
  final VoidCallback onDecrease;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final String? specialRequests;
  final String? selectedVariants;

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
    this.specialRequests,
    this.selectedVariants,
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
          Expanded(
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8.r),
                  child: SafeNetworkImage(
                    imageUrl: imageUrl,
                    width: 75.w,
                    height: 75.h,
                    fit: BoxFit.fill,
                  ),
                ),
                SizedBox(width: 8.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
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
                                color: const Color(0xFF3C4119),
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

                      // ✅ selectedVariants — both SizedBox and Text inside if
                      if (selectedVariants != null &&
                          selectedVariants!.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          selectedVariants!,
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

                      // ✅ specialRequests — both SizedBox and Text inside if
                      if (specialRequests != null &&
                          specialRequests!.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        SizedBox(
                          width: 134.w,
                          child: Text(
                            specialRequests!,
                            maxLines: 3,
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 11,
                              fontFamily: 'Montserrat',
                              fontWeight: FontWeight.w400,
                              height: 1.40,
                              letterSpacing: 0.22,
                            ),
                          ),
                        ),
                      ],

                      SizedBox(height: 14.h),
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
                    child: quantity == 1
                        ? Image.asset(
                            'assets/images/trash-option.png',
                            height: 14,
                            width: 14,
                          )
                        : Icon(
                            Icons.remove,
                            size: 14,
                            color: quantity == 1
                                ? Colors.red
                                : const Color.fromARGB(255, 17, 16, 14),
                          ),
                    //  Icon(
                    //   quantity == 1 ? Icons.delete_outline : Icons.remove,
                    //   size: 14,
                    //   color: quantity == 1
                    //       ? Colors.red
                    //       : const Color.fromARGB(255, 17, 16, 14),
                    // ),
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
                      color: Color(0xFF3C4119),
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
