import 'package:easy_localization/easy_localization.dart';
import 'package:erb/core/widgets/safe_network_image.dart';
import 'package:erb/features/cart/presentation/manager/cart_bloc.dart';
import 'package:erb/features/cart/presentation/manager/cart_event.dart';
import 'package:erb/features/cart/presentation/manager/cart_state.dart';
import 'package:erb/features/home/data/models/product_model.dart';
import 'package:erb/features/product/presentation/views/widgets/product_size_selector.dart';
import 'package:erb/features/product/presentation/views/widgets/special_request_bottom_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';

import 'widgets/product_bottom_bar.dart';

class ItemPreviewScreen extends StatefulWidget {
  final ProductModel product;

  const ItemPreviewScreen({
    super.key,
    required this.product,
  });

  @override
  State<ItemPreviewScreen> createState() => _ItemPreviewScreenState();
}

class _ItemPreviewScreenState extends State<ItemPreviewScreen> {
  String? selectedSize;
  String? selectedRoastLevel;
  String? selectedGrindType;
  String? selectedOtherOption;
  String? specialRequest; // 👈 this is passed as `notes` (per-item)

  bool _isAdding = false;
  bool _expectingAdd = false;

  void _addToCart(int quantity) async {
    if (_isAdding) return;

    setState(() {
      _isAdding = true;
      _expectingAdd = true;
    });

    final customization = <String, dynamic>{};
    if (selectedSize != null) customization['size'] = selectedSize;
    if (selectedRoastLevel != null) {
      customization['roastLevel'] = selectedRoastLevel;
    }
    if (selectedGrindType != null) {
      customization['grindType'] = selectedGrindType;
    }
    if (selectedOtherOption != null) {
      customization['other'] = selectedOtherOption;
    }

    context.read<CartBloc>().add(AddToCart(
          productId: widget.product.id,
          quantity: quantity,
          notes:
              specialRequest, // 👈 per-item note → maps to items[].notes in API
          customization: customization.isNotEmpty ? customization : null,
        ));
  }

  @override
  Widget build(BuildContext context) {
    final product = widget.product;

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
            child: const Icon(Icons.arrow_back, color: Colors.black, size: 24),
          ),
        ),
      ),
      body: BlocListener<CartBloc, CartState>(
        listener: (context, state) {
          if (!_expectingAdd) return;

          if (state is CartLoaded) {
            setState(() {
              _isAdding = false;
              _expectingAdd = false;
            });
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('item_added_to_cart'.tr()),
                backgroundColor: const Color(0xFF059B5A),
                duration: const Duration(seconds: 2),
              ),
            );
            Navigator.pop(context);
          } else if (state is CartError) {
            setState(() {
              _isAdding = false;
              _expectingAdd = false;
            });
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: const Color(0xFFE53935),
                duration: const Duration(seconds: 3),
              ),
            );
          }
        },
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SafeNetworkImage(
                      imageUrl: product.imageUrl,
                      width: double.infinity,
                      height: 320.h,
                      fit: BoxFit.cover,
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(
                          horizontal: 20.w, vertical: 16.h),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildProductHeader(),
                          SizedBox(height: 16.h),
                          _buildDescription(),
                          SizedBox(height: 24.h),
                          if (_hasSizes)
                            ProductSizeSelector(
                              options: product.sizes ?? [],
                              customTitle: 'choose_size'.tr(),
                              selectedOption: selectedSize,
                              onSizeSelected: (value) =>
                                  setState(() => selectedSize = value),
                            ),
                          if (_hasRoastLevels)
                            ProductSizeSelector(
                              options:
                                  product.customizationOptions?.roastLevels ??
                                      [],
                              customTitle: 'roast_levels'.tr(),
                              selectedOption: selectedRoastLevel,
                              onSizeSelected: (value) =>
                                  setState(() => selectedRoastLevel = value),
                            ),
                          if (_hasGrindTypes)
                            ProductSizeSelector(
                              options:
                                  product.customizationOptions?.grindTypes ??
                                      [],
                              customTitle: 'grind_types'.tr(),
                              selectedOption: selectedGrindType,
                              onSizeSelected: (value) =>
                                  setState(() => selectedGrindType = value),
                            ),
                          if (_hasOtherOptions)
                            ProductSizeSelector(
                              options: product.otherOptions ?? [],
                              customTitle: 'other_options'.tr(),
                              selectedOption: selectedOtherOption,
                              onSizeSelected: (value) =>
                                  setState(() => selectedOtherOption = value),
                            ),
                          SizedBox(height: 32.h),
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
      ),
      bottomNavigationBar: ProductBottomBar(
        price: product.price,
        onAddToCart: _addToCart,
      ),
    );
  }

  bool get _hasSizes =>
      widget.product.sizes != null && widget.product.sizes!.isNotEmpty;
  bool get _hasRoastLevels =>
      widget.product.customizationOptions?.roastLevels != null &&
      widget.product.customizationOptions!.roastLevels!.isNotEmpty;
  bool get _hasGrindTypes =>
      widget.product.customizationOptions?.grindTypes != null &&
      widget.product.customizationOptions!.grindTypes!.isNotEmpty;
  bool get _hasOtherOptions =>
      widget.product.otherOptions != null &&
      widget.product.otherOptions!.isNotEmpty;

  Widget _buildProductHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Text(
            widget.product.name,
            style: TextStyle(
              color: Colors.black,
              fontSize: 20.sp,
              fontFamily: 'Montserrat',
              fontWeight: FontWeight.w700,
              letterSpacing: 0.40,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDescription() {
    return Text(
      widget.product.description,
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

  Widget _buildSpecialRequests(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: () async {
            final result = await showModalBottomSheet<String>(
              context: context,
              isScrollControlled: true,
              useRootNavigator: true,
              backgroundColor: Colors.transparent,
              builder: (_) => SpecialRequestBottomSheet(
                initialText: specialRequest,
                onContinue: (text) => Navigator.pop(context, text),
              ),
            );
            if (result != null) {
              setState(() {
                specialRequest = result.isEmpty ? null : result;
              });
            }
          },
          child: Row(
            children: [
              SvgPicture.asset(
                'assets/images/edit.svg',
                height: 24.h,
                width: 24.w,
                colorFilter:
                    const ColorFilter.mode(Color(0xFF6B5E4B), BlendMode.srcIn),
              ),
              SizedBox(width: 12.w),
              Text(
                specialRequest == null
                    ? 'special_requests'.tr()
                    : 'special_requests_added'.tr(),
                style: TextStyle(
                  color: const Color(0xFF6B5E4B),
                  fontSize: 16,
                  fontFamily: 'Montserrat',
                  fontWeight: FontWeight.w600,
                  height: 1.40,
                  letterSpacing: 0.32,
                ),
              ),
            ],
          ),
        ),

        // 👇 Show entered text below the button
        if (specialRequest != null) ...[
          SizedBox(height: 8.h),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              specialRequest!,
              style: TextStyle(
                color: const Color(0xFF595959),
                fontSize: 13.sp,
                fontFamily: 'Montserrat',
                fontWeight: FontWeight.w400,
                height: 1.5,
              ),
            ),
          ),
        ],
      ],
    );
  }
}
