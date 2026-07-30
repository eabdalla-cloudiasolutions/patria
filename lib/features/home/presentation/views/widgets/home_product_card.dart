import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:patria/core/widgets/safe_network_image.dart';

class HomeProductCard extends StatelessWidget {
  final String name;
  final String price;
  final String imageUrl;
  final double rate;
  final int reviewCount;
  final bool isFav;
  final bool isFavActionLoading;
  final bool isAddingToCart; // 👈 new: loading state for add button
  final VoidCallback onFavTap;
  final VoidCallback onAddTap;
  final bool isIngredient;

  const HomeProductCard({
    super.key,
    required this.name,
    required this.price,
    required this.imageUrl,
    required this.rate,
    required this.reviewCount,
    this.isFav = false,
    this.isFavActionLoading = false,
    this.isAddingToCart = false, // 👈 default false
    required this.onFavTap,
    required this.onAddTap,
    required this.isIngredient,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 167.w,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image section
          SizedBox(
            height: 123.h,
            child: Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(5.r),
                    topRight: Radius.circular(5.r),
                  ),
                  child: SafeNetworkImage(
                    imageUrl: imageUrl,
                    width: double.infinity,
                    height: 123.h,
                    fit: BoxFit.cover,
                  ),
                ),
                // Fav button
                Positioned(
                  top: 9.h,
                  right: 9.w,
                  child: GestureDetector(
                    onTap: isFavActionLoading ? null : onFavTap,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 6.r,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: isFavActionLoading
                          ? SizedBox(
                              width: 14,
                              height: 14,
                              child: const CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.red,
                              ),
                            )
                          : Icon(
                              isFav ? Icons.favorite : Icons.favorite_border,
                              size: 14,
                              color: isFav
                                  ? Colors.red
                                  : const Color(0xFF8B8B8B),
                            ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Info section
          Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          name,
                          style: TextStyle(
                            color: const Color(0xFF333333),
                            fontSize: 14.sp,
                            fontFamily: 'Montserrat',
                            fontWeight: FontWeight.w500,
                            letterSpacing: 0.28,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: price.replaceAll(' EGP', ''),
                              style: TextStyle(
                                color: const Color(0xFF28293D),
                                fontSize: 14.sp,
                                fontFamily: 'Montserrat',
                                fontWeight: FontWeight.w500,
                                letterSpacing: 0.28,
                              ),
                            ),
                            const TextSpan(text: ' '),
                            TextSpan(
                              text: 'EGP',
                              style: TextStyle(
                                color: const Color(0xFF28293D),
                                fontSize: 14.sp,
                                fontFamily: 'Montserrat',
                                fontWeight: FontWeight.w400,
                                letterSpacing: 0.28,
                              ),
                            ),
                          ],
                        ),
                      ),
                      GestureDetector(
                        onTap: isAddingToCart ? null : onAddTap,
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: ShapeDecoration(
                            color: const Color(0xFF3C4119),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(6.r),
                            ),
                          ),
                          child: isAddingToCart
                              ? SizedBox(
                                  width: 14,
                                  height: 14,
                                  child: const CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : Icon(
                                  isIngredient
                                      ? Icons.arrow_forward_ios_outlined
                                      : Icons.add,
                                  size: 14,
                                  color: Colors.white,
                                ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
