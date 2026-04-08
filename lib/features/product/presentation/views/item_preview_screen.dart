import 'package:easy_localization/easy_localization.dart';
import 'package:erb/core/routing/routes.dart';
import 'package:erb/core/widgets/safe_network_image.dart';
import 'package:erb/features/home/data/models/product_model.dart';
import 'package:erb/features/product/presentation/views/widgets/product_size_selector.dart';
import 'package:erb/features/product/presentation/views/widgets/special_request_bottom_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';

import 'widgets/product_bottom_bar.dart';

class ItemPreviewScreen extends StatelessWidget {
  final ProductModel product;

  const ItemPreviewScreen({
    super.key,
    required this.product,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            margin: const EdgeInsets.all(8),
            padding: const EdgeInsets.all(8),
            decoration: ShapeDecoration(
              color: const Color(0xFFFAFAF7),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(100.r)),
              ),
            ),
            child: const Icon(
              Icons.arrow_back,
              color: Colors.black,
              size: 24,
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Product image
                  SafeNetworkImage(
                    imageUrl: product.imageUrl,
                    width: double.infinity,
                    height: 320.h,
                    fit: BoxFit.cover,
                  ),

                  Padding(
                    padding:
                        EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Name + Rating row
                        _buildProductHeader(),

                        SizedBox(height: 16.h),

                        // Description
                        _buildDescription(),

                        SizedBox(height: 24.h),

                        // ========== DYNAMIC SECTIONS WITH CUSTOM TITLES ==========

                        // Section 1: Sizes (if exists)
                        if (_hasSizes)
                          ProductSizeSelector(
                            options: product.sizes ?? [],
                            customTitle: 'choose_size'.tr(), // 👈 عنوان مخصص
                            onSizeSelected: (selectedSize) {
                              print('Selected size: $selectedSize');
                            },
                          ),

                        // Section 2: Roast Levels (if exists)
                        if (_hasRoastLevels)
                          ProductSizeSelector(
                            options:
                                product.customizationOptions?.roastLevels ?? [],
                            customTitle: 'roast_levels'.tr(), // 👈 عنوان مخصص
                            onSizeSelected: (selectedRoast) {
                              print('Selected roast level: $selectedRoast');
                            },
                          ),

                        // Section 3: Grind Types (if exists)
                        if (_hasGrindTypes)
                          ProductSizeSelector(
                            options:
                                product.customizationOptions?.grindTypes ?? [],
                            customTitle: 'grind_types'.tr(), // 👈 عنوان مخصص
                            onSizeSelected: (selectedGrind) {
                              print('Selected grind type: $selectedGrind');
                            },
                          ),

                        // Section 4: Any other options (if exists)
                        if (_hasOtherOptions)
                          ProductSizeSelector(
                            options: product.otherOptions ?? [],
                            customTitle: 'other_options'.tr(), // 👈 عنوان مخصص
                            onSizeSelected: (selectedOption) {
                              print('Selected option: $selectedOption');
                            },
                          ),

                        SizedBox(height: 32.h),

                        // Special requests
                        _buildSpecialRequests(context),

                        SizedBox(height: 100.h),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: ProductBottomBar(
        price: product.price,
        onAddToCart: () {
          final cartItem = {
            'name': product.name,
            'price': product.price,
            'image': product.imageUrl,
            'quantity': 1,
          };

          Navigator.pushNamed(
            context,
            Routes.cartScreen,
            arguments: {
              'initialCartItems': [cartItem],
            },
          );
        },
      ),
    );
  }

  // Getters to check what sections to show
  bool get _hasSizes => product.sizes != null && product.sizes!.isNotEmpty;
  bool get _hasRoastLevels =>
      product.customizationOptions?.roastLevels != null &&
      product.customizationOptions!.roastLevels!.isNotEmpty;
  bool get _hasGrindTypes =>
      product.customizationOptions?.grindTypes != null &&
      product.customizationOptions!.grindTypes!.isNotEmpty;
  bool get _hasOtherOptions =>
      product.otherOptions != null && product.otherOptions!.isNotEmpty;

  // Widget: Product Header
  Widget _buildProductHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                product.name,
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 20.sp,
                  fontFamily: 'Montserrat',
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.40,
                ),
              ),
              SizedBox(height: 8.h),
              Text(
                'product_reviews'.tr(args: [product.reviewCount.toString()]),
                style: TextStyle(
                  color: const Color(0xFF8B8B8B),
                  fontSize: 14.sp,
                  fontFamily: 'Montserrat',
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.32,
                ),
              ),
            ],
          ),
        ),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
          decoration: ShapeDecoration(
            color: const Color(0xFFF5F0EA),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.r),
            ),
          ),
          child: Row(
            children: [
              Image.asset(
                'assets/images/star.png',
                width: 18.w,
                height: 18.h,
                fit: BoxFit.cover,
              ),
              SizedBox(width: 4.w),
              Text(
                product.rate.toString(),
                style: TextStyle(
                  color: const Color(0xFF28293D),
                  fontSize: 14.sp,
                  fontFamily: 'Montserrat',
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.24,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Widget: Description
  Widget _buildDescription() {
    return Text(
      product.description,
      style: TextStyle(
        color: const Color(0xFF595959),
        fontSize: 15.sp,
        fontFamily: 'Montserrat',
        fontWeight: FontWeight.w500,
        height: 1.50,
        letterSpacing: 0.32,
      ),
    );
  }

  // Widget: Special Requests
  Widget _buildSpecialRequests(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 4.w,
              height: 18.h,
              decoration: BoxDecoration(
                color: const Color(0xFF6B5E4B),
                borderRadius: BorderRadius.circular(2.r),
              ),
            ),
            SizedBox(width: 8.w),
            Text(
              'special_requests'.tr(),
              style: TextStyle(
                color: const Color(0xFF28293D),
                fontSize: 16.sp,
                fontFamily: 'Montserrat',
                fontWeight: FontWeight.w700,
                letterSpacing: 0.32,
              ),
            ),
          ],
        ),
        SizedBox(height: 12.h),
        GestureDetector(
          onTap: () {
            showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              useRootNavigator: true,
              backgroundColor: Colors.transparent,
              builder: (_) => SpecialRequestBottomSheet(
                onContinue: (text) {
                  print('Special request: $text');
                },
              ),
            );
          },
          child: Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
            decoration: BoxDecoration(
              color: const Color(0xFFFAFAF7),
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(
                color: const Color(0xFFE5E5E5),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                SvgPicture.asset(
                  'assets/images/edit.svg',
                  height: 24.h,
                  width: 24.w,
                  colorFilter: const ColorFilter.mode(
                      Color(0xFF6B5E4B), BlendMode.srcIn),
                ),
                SizedBox(width: 12.w),
                Text(
                  'add_special_request'.tr(),
                  style: TextStyle(
                    color: const Color(0xFF6B5E4B),
                    fontSize: 14.sp,
                    fontFamily: 'Montserrat',
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.32,
                  ),
                ),
                const Spacer(),
                Icon(
                  Icons.arrow_forward_ios,
                  size: 16.sp,
                  color: const Color(0xFF6B5E4B),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
