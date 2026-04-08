import 'package:easy_localization/easy_localization.dart';
import 'package:erb/core/routing/routes.dart';
import 'package:erb/core/widgets/delete_overlay.dart';
import 'package:erb/core/widgets/empty_state_widget.dart';
import 'package:erb/features/cart/data/apis/coupon_api.dart';
import 'package:erb/features/cart/data/repos/coupon_repository.dart';
import 'package:erb/features/cart/presentation/manager/coupon_bloc.dart';
import 'package:erb/features/cart/presentation/manager/coupon_event.dart';
import 'package:erb/features/cart/presentation/manager/coupon_state.dart';
import 'package:erb/features/cart/presentation/views/widgets/cart_item_card.dart';
import 'package:erb/features/cart/presentation/views/widgets/order_summary.dart';
import 'package:erb/features/cart/presentation/views/widgets/voucher_input_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';

class CartScreen extends StatefulWidget {
  final PersistentTabController? controller;
  final List<Map<String, dynamic>>? initialCartItems;
  final bool fromNav;

  const CartScreen({
    super.key,
    this.controller,
    this.initialCartItems,
    this.fromNav = false,
  });

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  late List<Map<String, dynamic>> _cartItems;
  late PersistentTabController _controller;
  late CouponBloc _couponBloc;

  // Local UI state for coupon
  double _discount = 0;
  String? _appliedCouponCode;
  String? _discountType;
  double? _discountValue;

  final double _deliveryFee = 35.00;
  final double _serviceFee = 32.00;

  @override
  void initState() {
    super.initState();
    _cartItems = widget.initialCartItems != null
        ? List.from(widget.initialCartItems!)
        : [];
    _controller = widget.controller ?? PersistentTabController(initialIndex: 2);
    _couponBloc = CouponBloc(repository: CouponRepository(api: CouponApi()));
  }

  @override
  void dispose() {
    _couponBloc.close();
    super.dispose();
  }

  double get _subtotal => _cartItems.fold(
        0,
        (sum, item) => sum + (item['price'] * item['quantity']),
      );

  double get _total => _subtotal - _discount + _deliveryFee + _serviceFee;

  void _increaseQuantity(int index) {
    setState(() {
      _cartItems[index]['quantity']++;
    });
  }

  void _decreaseQuantity(int index) {
    if (_cartItems[index]['quantity'] > 1) {
      setState(() {
        _cartItems[index]['quantity']--;
      });
    } else {
      _removeItem(index);
    }
  }

  void _removeItem(int index) {
    final item = _cartItems[index];
    final itemName = item['name'];

    ConfirmationBottomSheet.show(
      context: context,
      title: "Remove $itemName?",
      subtitle:
          "Are you sure you want to remove $itemName from your cart? This action cannot be undone.",
      confirmText: "Remove",
      cancelText: "Cancel",
      onConfirm: () {
        setState(() {
          _cartItems.removeAt(index);
          if (_cartItems.isEmpty) _resetVoucher();
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                  'item_removed_from_cart'.tr(namedArgs: {'item': itemName})),
              duration: const Duration(seconds: 2),
              backgroundColor: const Color(0xFF6B5E4B),
            ),
          );
        }
      },
      isDangerous: true,
      isDismissible: true,
      enableDrag: true,
    );
  }

  void _clearCart() {
    if (_cartItems.isEmpty) return;

    ConfirmationBottomSheet.show(
      context: context,
      title: "Clear Cart?",
      subtitle:
          "Are you sure you want to clear your entire cart? All ${_cartItems.length} items will be permanently removed.",
      confirmText: "Clear Cart",
      cancelText: "Cancel",
      onConfirm: () {
        setState(() {
          _cartItems.clear();
          _resetVoucher();
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('cart_cleared_successfully'.tr()),
              duration: const Duration(seconds: 2),
              backgroundColor: const Color(0xFF6B5E4B),
            ),
          );
        }
      },
      isDangerous: true,
      isDismissible: true,
      enableDrag: true,
    );
  }

  void _applyVoucher(String code) {
    _appliedCouponCode = code;
    _couponBloc.add(ApplyCoupon(code, _subtotal));
  }

  void _removeVoucher() {
    _couponBloc.add(RemoveCoupon());
  }

  void _resetVoucher() {
    setState(() {
      _discount = 0;
      _appliedCouponCode = null;
      _discountType = null;
      _discountValue = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _couponBloc,
      child: Scaffold(
        backgroundColor: const Color(0xFFF7F7F7),
        body: SafeArea(
          child: BlocListener<CouponBloc, CouponState>(
            listener: (context, state) {
              if (state is CouponApplied) {
                setState(() {
                  _discount = state.coupon.discountAmount;
                  _appliedCouponCode = state.coupon.code;
                  _discountType = state.coupon.discountType;
                  _discountValue = state.coupon.discountValue;
                });
                final msg = state.coupon.message ??
                    'voucher_applied'.tr(
                        namedArgs: {'amount': _discount.toStringAsFixed(2)});
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(msg),
                    backgroundColor: const Color(0xFF059B5A),
                    duration: const Duration(seconds: 3),
                  ),
                );
              } else if (state is CouponError) {
                setState(() {
                  _discount = 0;
                  _appliedCouponCode = null;
                  _discountType = null;
                  _discountValue = null;
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(state.message),
                    backgroundColor: const Color(0xFFE53935),
                    duration: const Duration(seconds: 2),
                  ),
                );
              } else if (state is CouponRemoved) {
                _resetVoucher();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('voucher_removed'.tr()),
                    backgroundColor: const Color(0xFF6B5E4B),
                    duration: const Duration(seconds: 2),
                  ),
                );
              }
            },
            child: _cartItems.isEmpty
                ? EmptyStateWidget(
                    imagePath: 'assets/images/Empty Cart.png',
                    title: 'empty_cart_message'.tr(),
                    subtitle: 'ready_to_order'.tr(),
                    buttonText: 'browse_menu'.tr(),
                    onButtonPressed: () => _controller.jumpToTab(0),
                  )
                : _buildCart(),
          ),
        ),
      ),
    );
  }

  Widget _buildCart() {
    return BlocBuilder<CouponBloc, CouponState>(
      builder: (context, state) {
        final isLoading = state is CouponLoading;
        return Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 20.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 24.h),

                    // Header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        GestureDetector(
                          onTap: () {
                            if (widget.fromNav) {
                              _controller.jumpToTab(0);
                            } else {
                              Navigator.of(context).pop();
                            }
                          },
                          child: Container(
                            padding: const EdgeInsets.all(10),
                            child: const Icon(Icons.arrow_back,
                                size: 20, color: Colors.black),
                          ),
                        ),
                        Expanded(
                          child: Text(
                            'nav_cart'.tr(),
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 18.sp,
                              fontFamily: 'Montserrat',
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.36,
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: _clearCart,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 10),
                            decoration: ShapeDecoration(
                              color: const Color(0xFFFFF0F0),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(5),
                              ),
                            ),
                            child: Text(
                              'clear_cart'.tr(),
                              style: TextStyle(
                                color: const Color(0xFFC90000),
                                fontSize: 12.sp,
                                fontFamily: 'Montserrat',
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 24.h),

                    // Cart items
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _cartItems.length,
                      separatorBuilder: (_, __) => SizedBox(height: 12.h),
                      itemBuilder: (_, index) {
                        final item = _cartItems[index];
                        return CartItemCard(
                          name: item['name'],
                          imageUrl: item['image'],
                          price: item['price'].toDouble(),
                          quantity: item['quantity'],
                          onIncrease: () => _increaseQuantity(index),
                          onDecrease: () => _decreaseQuantity(index),
                          onDelete: () => _removeItem(index),
                          onEdit: () {},
                        );
                      },
                    ),
                    SizedBox(height: 18.h),

                    // "Save on your order"
                    Text(
                      'save_on_your_order'.tr(),
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 14.sp,
                        fontFamily: 'Montserrat',
                        fontWeight: FontWeight.w400,
                        letterSpacing: 0.28,
                      ),
                    ),
                    SizedBox(height: 12.h),

                    // Voucher input or applied card
                    if (_appliedCouponCode == null)
                      VoucherInputField(
                        onApplyVoucher: _applyVoucher,
                        isLoading: isLoading,
                        iconImagePath: 'assets/images/Voucher.svg',
                      )
                    else
                      _buildAppliedVoucherCard(isLoading: isLoading),

                    SizedBox(height: 24.h),

                    // Order summary
                    if (_cartItems.isNotEmpty) ...[
                      OrderSummary(
                        subtotal: _subtotal,
                        discount: _discount,
                        deliveryFee: _deliveryFee,
                        serviceFee: _serviceFee,
                      ),
                      SizedBox(height: 24.h),

                      // Proceed to checkout
                      SizedBox(
                        width: double.infinity,
                        height: 56.h,
                        child: ElevatedButton.icon(
                          onPressed: () {
                            Navigator.of(context, rootNavigator: true)
                                .pushNamed(
                              Routes.checkoutScreen,
                              arguments: {
                                'cartItems': _cartItems,
                                'subtotal': _subtotal,
                                'discount': _discount,
                                'voucherCode': _appliedCouponCode,
                                'total': _total,
                              },
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF6B5E4B),
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(5.r),
                            ),
                          ),
                          iconAlignment: IconAlignment.end,
                          icon: const Icon(Icons.arrow_forward,
                              color: Colors.white, size: 20),
                          label: Text(
                            'proceed_checkout'.tr(),
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16.sp,
                              fontFamily: 'Montserrat',
                              fontWeight: FontWeight.w600,
                              height: 1.50,
                            ),
                          ),
                        ),
                      ),
                    ],
                    SizedBox(height: 100.h),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildAppliedVoucherCard({required bool isLoading}) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: const Color(0xFFEDF8F0),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: const Color(0xFF059B5A), width: 1),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              const Icon(Icons.check_circle,
                  color: Color(0xFF059B5A), size: 20),
              SizedBox(width: 12.w),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _discountType == 'Percentage (%)'
                        ? '${_discountValue?.toInt()}% Discount Applied'
                        : 'Fixed Discount Applied',
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: const Color(0xFF059B5A),
                      fontWeight: FontWeight.w600,
                      fontFamily: 'Montserrat',
                    ),
                  ),
                  Text(
                    '$_appliedCouponCode - Save ${_discount.toStringAsFixed(2)} EGP',
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: const Color(0xFF1D1E20),
                      fontWeight: FontWeight.w500,
                      fontFamily: 'Montserrat',
                    ),
                  ),
                ],
              ),
            ],
          ),
          if (isLoading)
            SizedBox(
              width: 20.w,
              height: 20.h,
              child: const CircularProgressIndicator(strokeWidth: 2),
            )
          else
            GestureDetector(
              onTap: _removeVoucher,
              child: Container(
                padding: EdgeInsets.all(8.w),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(5.r),
                ),
                child:
                    const Icon(Icons.close, size: 16, color: Color(0xFF8B8B8B)),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildEmptyCart() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 142.w,
            height: 142.h,
            padding: const EdgeInsets.all(6.79),
            clipBehavior: Clip.antiAlias,
            decoration: ShapeDecoration(
              color: const Color(0xFFF5F0EA),
              shape: RoundedRectangleBorder(
                side: BorderSide(width: 4, color: const Color(0x194A3F33)),
                borderRadius: BorderRadius.circular(84.91.r),
              ),
            ),
            child: Image.asset("assets/images/Empty Cart.png"),
          ),
          SizedBox(height: 16.h),
          Text(
            'empty_cart_message'.tr(),
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.black,
              fontSize: 18.sp,
              fontFamily: 'Montserrat',
              fontWeight: FontWeight.w600,
              height: 1.07,
              letterSpacing: 0.36,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'ready_to_order'.tr(),
            textAlign: TextAlign.center,
            style: TextStyle(
              color: const Color(0xFF8B8B8B),
              fontSize: 14.sp,
              fontFamily: 'Montserrat',
              fontWeight: FontWeight.w400,
              height: 1.40,
              letterSpacing: 0.28,
            ),
          ),
          SizedBox(height: 16.h),
          ElevatedButton(
            onPressed: () => _controller.jumpToTab(0),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6B5E4B),
              elevation: 0,
              padding: EdgeInsets.symmetric(horizontal: 32.w, vertical: 16.h),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5.r)),
            ),
            child: Text(
              'browse_menu'.tr(),
              style: TextStyle(
                color: Colors.white,
                fontSize: 16.sp,
                fontFamily: 'Montserrat',
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
