import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:patria/core/routing/routes.dart';
import 'package:patria/core/services/user_service.dart';
import 'package:patria/core/widgets/delete_overlay.dart';
import 'package:patria/core/widgets/empty_state_widget.dart';
import 'package:patria/features/cart/data/apis/coupon_api.dart';
import 'package:patria/features/cart/data/models/cart_model.dart';
import 'package:patria/features/cart/data/repos/coupon_repository.dart';
import 'package:patria/features/cart/presentation/manager/cart_bloc.dart';
import 'package:patria/features/cart/presentation/manager/cart_event.dart';
import 'package:patria/features/cart/presentation/manager/cart_state.dart';
import 'package:patria/features/cart/presentation/manager/coupon_bloc.dart';
import 'package:patria/features/cart/presentation/manager/coupon_event.dart';
import 'package:patria/features/cart/presentation/manager/coupon_state.dart';
import 'package:patria/features/cart/presentation/views/widgets/cart_item_card.dart';
import 'package:patria/features/cart/presentation/views/widgets/order_summary.dart';
import 'package:patria/features/cart/presentation/views/widgets/voucher_input_field.dart';
import 'package:patria/features/home/data/apis/products_api.dart';
import 'package:patria/features/home/data/models/product_model.dart';
import 'package:patria/main.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';
import 'package:shimmer/shimmer.dart';

class CartScreen extends StatefulWidget {
  final PersistentTabController? controller;
  final bool fromNav;
  final int myTabIndex;

  const CartScreen({
    super.key,
    this.controller,
    this.fromNav = false,
    required this.myTabIndex,
  });

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> with RouteAware {
  late PersistentTabController _controller;
  late CartBloc _cartBloc;
  late CouponBloc _couponBloc;
  final UserService _userService = UserService();

  double _discount = 0;
  String? _appliedCouponCode;
  String? _discountType;
  double? _discountValue;
  bool _isTabSelected = false;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? PersistentTabController(initialIndex: 2);
    _couponBloc = CouponBloc(repository: CouponRepository(api: CouponApi()));
    _controller.addListener(_onTabChanged);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _cartBloc = context.read<CartBloc>();
    _cartBloc.add(LoadCart());

    final route = ModalRoute.of(context);
    if (route != null) {
      routeObserver.subscribe(this, route);
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_onTabChanged);
    routeObserver.unsubscribe(this);
    _couponBloc.close();
    super.dispose();
  }

  void _onTabChanged() {
    if (_controller.index == widget.myTabIndex && !_isTabSelected) {
      _isTabSelected = true;
      _refreshCart();
    } else if (_controller.index != widget.myTabIndex) {
      _isTabSelected = false;
    }
  }

  @override
  void didPopNext() {
    _refreshCart();
  }

  void _refreshCart() {
    if (_cartBloc.state is CartLoaded) {
      _cartBloc.add(LoadCart());
    }
  }

  Future<bool> _isUserLoggedIn() async {
    final token = await _userService.getUserToken();
    final email = await _userService.getUserEmail();
    return token.isNotEmpty && email.isNotEmpty;
  }

  double _subtotal(List<CartItem> items) =>
      items.fold(0, (sum, item) => sum + (item.price * item.quantity));

  double _total(double subtotal) => subtotal - _discount;

  void _increaseQuantity(CartItem item) {
    _cartBloc.add(
      UpdateCartItemQuantity(itemId: item.id, quantity: item.quantity + 1),
    );
  }

  void _decreaseQuantity(CartItem item) {
    if (item.quantity > 1) {
      _cartBloc.add(
        UpdateCartItemQuantity(itemId: item.id, quantity: item.quantity - 1),
      );
    } else {
      _removeItem(item);
    }
  }

  void _removeItem(CartItem item) {
    final itemName = item.product.name;
    _cartBloc.add(RemoveCartItem(itemId: item.id));
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'item_removed_from_cart'.tr(namedArgs: {'item': itemName}),
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
          backgroundColor: const Color(0xFF3C4119),
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating, // ✅ removes safe area space

          padding: EdgeInsets.symmetric(
            horizontal: 16.w,
            vertical: 16.h, // ✅ reduce height
          ),
        ),
      );
    }
  }

  void _clearCart() {
    final itemCount = _cartBloc.state is CartLoaded
        ? (_cartBloc.state as CartLoaded).cart.items.length
        : 0;
    if (itemCount == 0) return;

    ConfirmationBottomSheet.show(
      context: context,
      title: 'clear_cart_title'.tr(),
      subtitle: 'clear_cart_subtitle'.tr(
        namedArgs: {'count': itemCount.toString()},
      ),
      confirmText: 'clear_cart_confirm'.tr(),
      cancelText: 'cancel'.tr(),
      onConfirm: () {
        _cartBloc.add(ClearCart());
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'cart_cleared_successfully'.tr(),
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              backgroundColor: const Color(0xFF3C4119),
              duration: const Duration(seconds: 2),
              behavior: SnackBarBehavior.floating, // ✅ removes safe area space

              padding: EdgeInsets.symmetric(
                horizontal: 16.w,
                vertical: 16.h, // ✅ reduce height
              ),
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
    final subtotal = _cartBloc.state is CartLoaded
        ? _subtotal((_cartBloc.state as CartLoaded).cart.items)
        : 0.0;
    _couponBloc.add(ApplyCoupon(code, subtotal));
  }

  void _removeVoucher() => _couponBloc.add(RemoveCoupon());

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [BlocProvider.value(value: _couponBloc)],
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
                final msg =
                    state.coupon.message ??
                    'voucher_applied'.tr(
                      namedArgs: {'amount': _discount.toStringAsFixed(2)},
                    );
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      msg,
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
              } else if (state is CouponError) {
                setState(() {
                  _discount = 0;
                  _appliedCouponCode = null;
                  _discountType = null;
                  _discountValue = null;
                });
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
              } else if (state is CouponRemoved) {
                setState(() {
                  _discount = 0;
                  _appliedCouponCode = null;
                  _discountType = null;
                  _discountValue = null;
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'voucher_removed'.tr(),
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
              }
            },
            child: BlocBuilder<CartBloc, CartState>(
              builder: (context, cartState) {
                return FutureBuilder<bool>(
                  future: _isUserLoggedIn(),
                  builder: (context, snapshot) {
                    final isLoggedIn = snapshot.data ?? false;

                    if (!isLoggedIn) {
                      return _buildGuestEmptyState();
                    }

                    if (cartState is CartLoading) {
                      return _buildSkeletonLoading();
                    }

                    if (cartState is CartError) {
                      final errorMsg = cartState.message.toLowerCase();
                      if (errorMsg.contains('unauthorized') ||
                          errorMsg.contains('401') ||
                          errorMsg.contains('token') ||
                          errorMsg.contains('authenticate')) {
                        return _buildGuestEmptyState();
                      }
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.error_outline,
                              size: 48,
                              color: Color(0xFFCACBD4),
                            ),
                            SizedBox(height: 12.h),
                            Text(
                              cartState.message,
                              style: const TextStyle(color: Color(0xFF8B8B8B)),
                            ),
                            SizedBox(height: 12.h),
                            ElevatedButton(
                              onPressed: () => _cartBloc.add(LoadCart()),
                              child: Text('retry'.tr()),
                            ),
                          ],
                        ),
                      );
                    }

                    if (cartState is CartLoaded) {
                      final cart = cartState.cart;
                      if (cart.items.isEmpty) return _buildEmptyCart();
                      return _buildCart(cart);
                    }

                    return const SizedBox.shrink();
                  },
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  // ─── Guest Empty State ────────────────────────────────────────────────
  Widget _buildGuestEmptyState() {
    return EmptyStateWidget(
      imagePath: 'assets/images/Empty Cart.png',
      title: 'sign_in_required'.tr(),
      subtitle: 'please_sign_in_to_view_cart'.tr(),
      buttonText: 'sign_in'.tr(),
      imagePadding: const EdgeInsets.all(16),
      onButtonPressed: () {
        Navigator.of(
          context,
          rootNavigator: true,
        ).pushNamed(Routes.splashScreen).then((_) {
          _refreshCart();
        });
      },
    );
  }

  // ─── Skeleton Loading ────────────────────────────────────────────────
  Widget _buildSkeletonLoading() {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 24.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _shimmpatriaox(width: 40.w, height: 40.h, radius: 8),
              _shimmpatriaox(width: 120.w, height: 20.h, radius: 4),
              _shimmpatriaox(width: 70.w, height: 36.h, radius: 5),
            ],
          ),
          SizedBox(height: 24.h),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: 3,
            separatorBuilder: (_, __) => SizedBox(height: 12.h),
            itemBuilder: (_, __) => _buildCartItemSkeleton(),
          ),
          SizedBox(height: 18.h),
          _shimmpatriaox(width: double.infinity, height: 56.h, radius: 8),
          SizedBox(height: 24.h),
          _shimmpatriaox(width: double.infinity, height: 180.h, radius: 12),
          SizedBox(height: 24.h),
          _shimmpatriaox(width: double.infinity, height: 56.h, radius: 5),
          SizedBox(height: 100.h),
        ],
      ),
    );
  }

  Widget _buildCartItemSkeleton() {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      child: Container(
        padding: EdgeInsets.all(12.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Row(
          children: [
            Container(
              width: 80.w,
              height: 80.h,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8.r),
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: double.infinity,
                    height: 14.h,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(4.r),
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Container(
                    width: 80.w,
                    height: 12.h,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(4.r),
                    ),
                  ),
                  SizedBox(height: 12.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        width: 80.w,
                        height: 32.h,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                      ),
                      Container(
                        width: 60.w,
                        height: 14.h,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(4.r),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _shimmpatriaox({
    required double width,
    required double height,
    double radius = 8,
  }) {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(radius.r),
        ),
      ),
    );
  }

  // ─── Build Cart when loaded ─────────────────────────────────────────
  Widget _buildCart(CartResponse cart) {
    final subtotal = _subtotal(cart.items);
    final total = _total(subtotal);

    return BlocBuilder<CouponBloc, CouponState>(
      builder: (context, couponState) {
        final isLoading = couponState is CouponLoading;
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
                            child: const Icon(
                              Icons.arrow_back,
                              size: 20,
                              color: Colors.black,
                            ),
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
                              horizontal: 16,
                              vertical: 10,
                            ),
                            decoration: ShapeDecoration(
                              color: const Color(0xFFC90000),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(5),
                              ),
                            ),
                            child: Text(
                              'clear_cart'.tr(),
                              style: TextStyle(
                                color: Colors.white,
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
                      itemCount: cart.items.length,
                      separatorBuilder: (_, __) => SizedBox(height: 12.h),
                      itemBuilder: (_, index) {
                        final item = cart.items[index];
                        return CartItemCard(
                          name: item.product.name,
                          imageUrl: item.product.image ?? '',
                          price: item.price,
                          quantity: item.quantity,
                          onIncrease: () => _increaseQuantity(item),
                          onDecrease: () => _decreaseQuantity(item),
                          onDelete: () => _removeItem(item),
                          onEdit: () async {
                            final scaffoldMessenger = ScaffoldMessenger.of(
                              context,
                            );
                            try {
                              final response = await ProductsApi()
                                  .getProductById(item.product.id);
                              final fullProduct = ProductModel.fromJson(
                                response.data,
                              );

                              final customizationMap = <String, String>{};
                              for (var variant in item.selectedVariants) {
                                customizationMap[variant.group] =
                                    variant.option;
                              }

                              if (!mounted) return;

                              Navigator.of(
                                context,
                                rootNavigator: true,
                              ).pushNamed(
                                Routes.itemPreview,
                                arguments: {
                                  'product': fullProduct,
                                  'isEditing': true,
                                  'cartItemId': item.id,
                                  'initialQuantity': item.quantity,
                                  'initialCustomization': customizationMap,
                                  'initialNotes': item.notes,
                                },
                              );
                            } catch (e) {
                              print('Error loading product: $e');
                              scaffoldMessenger.showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'failed_to_load_product_details'.tr(
                                      namedArgs: {'error': e.toString()},
                                    ),
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  backgroundColor: const Color(0xFFC90000),
                                  duration: const Duration(seconds: 2),
                                  behavior: SnackBarBehavior
                                      .floating, // ✅ removes safe area space
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 16.w,
                                    vertical: 16.h, // ✅ reduce height
                                  ),
                                ),
                              );
                            }
                          },
                          specialRequests:
                              (item.notes != null && item.notes!.isNotEmpty)
                              ? item.notes
                              : null,
                          selectedVariants: item.selectedVariants.isEmpty
                              ? null
                              : item.selectedVariants
                                    .map((v) => v.option)
                                    .join(', '),
                        );
                      },
                    ),
                    SizedBox(height: 18.h),

                    // Save on your order
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

                    // Voucher
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
                    OrderSummary(subtotal: subtotal, discount: _discount),
                    SizedBox(height: 24.h),

                    // Proceed to checkout
                    SizedBox(
                      width: double.infinity,
                      height: 56.h,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          // ✅ PASS FULL List<CartItem> (typed)
                          Navigator.of(context, rootNavigator: true).pushNamed(
                            Routes.checkoutScreen,
                            arguments: {
                              'cartItems': cart.items, // List<CartItem>
                              'subtotal': subtotal,
                              'discount': _discount,
                              'voucherCode': _appliedCouponCode,
                              'total': total,
                              'specialRequests': cart.specialRequests ?? '',
                            },
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF3C4119),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5.r),
                          ),
                        ),
                        iconAlignment: IconAlignment.end,
                        icon: const Icon(
                          Icons.arrow_forward,
                          color: Colors.white,
                          size: 20,
                        ),
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
              const Icon(
                Icons.check_circle,
                color: Color(0xFF059B5A),
                size: 20,
              ),
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
                child: const Icon(
                  Icons.close,
                  size: 16,
                  color: Color(0xFF8B8B8B),
                ),
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
              color: const Color(0xFFE5E8D3),
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
              backgroundColor: const Color(0xFF3C4119),
              elevation: 0,
              padding: EdgeInsets.symmetric(horizontal: 32.w, vertical: 16.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(5.r),
              ),
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
