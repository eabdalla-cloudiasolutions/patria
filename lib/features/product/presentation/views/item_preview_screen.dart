import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:patria/core/widgets/safe_network_image.dart';
import 'package:patria/features/cart/presentation/manager/cart_bloc.dart';
import 'package:patria/features/cart/presentation/manager/cart_event.dart';
import 'package:patria/features/cart/presentation/manager/cart_state.dart';
import 'package:patria/features/home/data/models/product_model.dart';
import 'package:patria/features/product/presentation/views/widgets/product_size_selector.dart';
import 'package:patria/features/product/presentation/views/widgets/special_request_bottom_sheet.dart';

import 'widgets/product_bottom_bar.dart';

class ItemPreviewScreen extends StatefulWidget {
  final ProductModel product;
  final bool isEditing;
  final String? cartItemId;
  final int? initialQuantity;
  final Map<String, dynamic>? initialCustomization;
  final String? initialNotes;

  const ItemPreviewScreen({
    super.key,
    required this.product,
    this.isEditing = false,
    this.cartItemId,
    this.initialQuantity,
    this.initialCustomization,
    this.initialNotes,
  });

  factory ItemPreviewScreen.fromArguments(Map<String, dynamic> args) {
    return ItemPreviewScreen(
      product: args['product'] as ProductModel,
      isEditing: args['isEditing'] ?? false,
      cartItemId: args['cartItemId'],
      initialQuantity: args['initialQuantity'],
      initialCustomization: args['initialCustomization'],
      initialNotes: args['initialNotes'],
    );
  }

  @override
  State<ItemPreviewScreen> createState() => _ItemPreviewScreenState();
}

class _ItemPreviewScreenState extends State<ItemPreviewScreen> {
  final Map<String, String> _selectedLabels = {};
  String? specialRequest;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _initializeFromExistingData();
  }

  void _initializeFromExistingData() {
    if (widget.initialCustomization != null) {
      widget.initialCustomization!.forEach((key, value) {
        _selectedLabels[key] = value.toString();
      });
    }
    if (widget.initialNotes != null && widget.initialNotes!.isNotEmpty) {
      specialRequest = widget.initialNotes;
    }
  }

  bool get _areRequiredOptionsSelected {
    for (var group in widget.product.variantGroups) {
      if (group.required && _selectedLabels[group.name] == null) {
        return false;
      }
    }
    return true;
  }

  double get _totalPrice {
    double total = widget.product.price;
    for (var group in widget.product.variantGroups) {
      final selectedLabel = _selectedLabels[group.name];
      if (selectedLabel != null) {
        final option = group.options.firstWhere(
          (o) => o.label == selectedLabel,
          orElse: () => VariantOption(label: '', priceAdjustment: 0),
        );
        total += option.priceAdjustment;
      }
    }
    return total;
  }

  Map<String, dynamic> _buildCustomization() {
    final customization = <String, dynamic>{};
    for (var group in widget.product.variantGroups) {
      final selectedLabel = _selectedLabels[group.name];
      if (selectedLabel != null) {
        customization[group.name] = selectedLabel;
      }
    }
    return customization;
  }

  void _addToCart(int quantity) {
    if (_isLoading) return;
    if (!_areRequiredOptionsSelected) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'please_select_required_options'.tr(),
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
          backgroundColor: const Color(0xFFC90000),
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating, // ✅ removes safe area space
          padding: EdgeInsets.symmetric(
            horizontal: 16.w,
            vertical: 16.h, // ✅ reduce height
          ),
        ),
      );
      return;
    }

    setState(() => _isLoading = true);
    context.read<CartBloc>().add(
      AddToCart(
        productId: widget.product.id,
        quantity: quantity,
        notes: specialRequest,
        customization: _buildCustomization().isNotEmpty
            ? _buildCustomization()
            : null,
      ),
    );
  }

  void _updateCartItem(int quantity) {
    if (_isLoading) return;
    if (!_areRequiredOptionsSelected) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'please_select_required_options'.tr(),
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
          backgroundColor: const Color(0xFFC90000),
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating, // ✅ removes safe area space
          padding: EdgeInsets.symmetric(
            horizontal: 16.w,
            vertical: 16.h, // ✅ reduce height
          ),
        ),
      );
      return;
    }

    setState(() => _isLoading = true);
    context.read<CartBloc>().add(
      UpdateCartItem(
        itemId: widget.cartItemId!,
        quantity: quantity,
        customization: _buildCustomization().isNotEmpty
            ? _buildCustomization()
            : null,
        notes: specialRequest ?? '',
      ),
    );
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
          if (!_isLoading) return;

          // ✅ Clear any existing SnackBars to avoid hero conflicts
          ScaffoldMessenger.of(context).clearSnackBars();

          if (state is CartLoaded) {
            setState(() => _isLoading = false);

            final message = widget.isEditing
                ? 'item_updated_in_cart'.tr()
                : 'item_added_to_cart'.tr();

            // ✅ Clear snackbars, pop, then wait for animation to finish
            ScaffoldMessenger.of(context).clearSnackBars();
            Navigator.pop(context);

            Future.delayed(const Duration(milliseconds: 300), () {
              ScaffoldMessenger.of(context).clearSnackBars();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    message,
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  backgroundColor: const Color(0xFF3C4119),
                  duration: const Duration(seconds: 2),
                  behavior:
                      SnackBarBehavior.floating, // ✅ removes safe area space

                  padding: EdgeInsets.symmetric(
                    horizontal: 16.w,
                    vertical: 16.h, // ✅ reduce height
                  ),
                ),
              );
            });
          } else if (state is CartError) {
            setState(() => _isLoading = false);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  state.message,
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                backgroundColor: const Color(0xFFC90000),
                duration: const Duration(seconds: 2),
                behavior:
                    SnackBarBehavior.floating, // ✅ removes safe area space
                padding: EdgeInsets.symmetric(
                  horizontal: 16.w,
                  vertical: 16.h, // ✅ reduce height
                ),
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
                        horizontal: 20.w,
                        vertical: 16.h,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildProductHeader(),
                          SizedBox(height: 16.h),
                          _buildDescription(),
                          SizedBox(height: 12.h),
                          ...product.variantGroups.map(
                            (group) => Column(
                              children: [
                                if (group.options.isNotEmpty)
                                  ProductSizeSelector(
                                    options: group.options
                                        .map((o) => o.label)
                                        .toList(),
                                    customTitle: group.name,
                                    selectedOption: _selectedLabels[group.name],
                                    onSizeSelected: (value) {
                                      setState(() {
                                        _selectedLabels[group.name] = value;
                                      });
                                    },
                                  ),
                              ],
                            ),
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
        price: _totalPrice,
        onAddToCart: widget.isEditing ? _updateCartItem : _addToCart,
        buttonText: widget.isEditing ? 'update_cart'.tr() : null,
        isEnabled: _areRequiredOptionsSelected,
      ),
    );
  }

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
                colorFilter: const ColorFilter.mode(
                  Color(0xFF3C4119),
                  BlendMode.srcIn,
                ),
              ),
              SizedBox(width: 12.w),
              Text(
                specialRequest == null
                    ? 'special_requests'.tr()
                    : 'special_requests_added'.tr(),
                style: TextStyle(
                  color: const Color(0xFF3C4119),
                  fontSize: 16.sp,
                  fontFamily: 'Montserrat',
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        if (specialRequest != null) ...[
          SizedBox(height: 8.h),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 40.w),
            child: Text(
              specialRequest!,
              style: TextStyle(
                color: const Color(0xFF595959),
                fontSize: 13.sp,
                fontFamily: 'Montserrat',
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
        ],
      ],
    );
  }
}
