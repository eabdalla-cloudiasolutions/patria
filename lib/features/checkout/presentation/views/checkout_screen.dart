import 'package:easy_localization/easy_localization.dart';
import 'package:erb/core/routing/routes.dart';
import 'package:erb/core/services/user_service.dart';
import 'package:erb/features/account/data/apis/addresses_api.dart';
import 'package:erb/features/cart/presentation/manager/cart_bloc.dart';
import 'package:erb/features/cart/presentation/manager/cart_event.dart';
import 'package:erb/features/checkout/data/apis/place_order_api.dart';
import 'package:erb/features/checkout/data/models/place_order_request.dart';
import 'package:erb/features/checkout/data/repos/place_order_repository.dart';
import 'package:erb/features/checkout/presentation/manager/checkout_preview_bloc.dart';
import 'package:erb/features/checkout/presentation/manager/checkout_preview_event.dart';
import 'package:erb/features/checkout/presentation/manager/checkout_preview_state.dart';
import 'package:erb/features/checkout/presentation/manager/place_order_bloc.dart';
import 'package:erb/features/checkout/presentation/manager/place_order_event.dart';
import 'package:erb/features/checkout/presentation/manager/place_order_state.dart';
import 'package:erb/features/checkout/presentation/views/widgets/address_selection_sheet.dart';
import 'package:erb/features/checkout/presentation/views/widgets/app_bottom_action_bar.dart';
import 'package:erb/features/checkout/presentation/views/widgets/section_title.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/widgets/app_field_tile.dart';
import 'widgets/checkout_order_summary.dart';
import 'widgets/payment_option.dart';
import 'widgets/points_toggle.dart';

class CheckoutScreen extends StatefulWidget {
  final List<Map<String, dynamic>> cartItems;
  final double subtotal;
  final double discount;
  final String? voucherCode;
  final String? specialRequests; // 👈 added

  const CheckoutScreen({
    super.key,
    required this.cartItems,
    required this.subtotal,
    this.discount = 0,
    this.voucherCode,
    this.specialRequests, // 👈 added
  });

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  String _address = '';
  String _zoneId = '';
  final TextEditingController _notesController = TextEditingController();
  late String _selectedPayment;
  bool _usePoints = false;
  int _pointsToRedeem = 0;
  bool _isAddressFromSaved = false;

  String _userName = '';
  String _userEmail = '';
  String _userPhone = '';
  bool _isLoadingUser = true;

  final double _deliveryFee = 25.0;
  final double _serviceFee = 32.0;

  late CheckoutPreviewBloc _checkoutPreviewBloc;

  @override
  void initState() {
    super.initState();
    _checkoutPreviewBloc = CheckoutPreviewBloc();
    _fetchCheckoutPreview(pointsToRedeem: 0);
    _loadUserData();
    _loadDefaultAddress();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _selectedPayment = 'payment_cash'.tr();
  }

  @override
  void dispose() {
    _checkoutPreviewBloc.close();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _loadUserData() async {
    final userService = UserService();
    final name = await userService.getUserName();
    final email = await userService.getUserEmail();
    final phone = await userService.getUserPhone();
    setState(() {
      _userName = name;
      _userEmail = email;
      _userPhone = phone;
      _isLoadingUser = false;
    });
  }

  Future<void> _loadDefaultAddress() async {
    try {
      final addresses = await AddressesApi().getAddresses();
      final defaultAddr = addresses.firstWhere((a) => a.isDefault);
      setState(() {
        _address =
            '${defaultAddr.street}, ${defaultAddr.area}, ${defaultAddr.city}';
        _zoneId = defaultAddr.id ?? '';
        _isAddressFromSaved = true;
      });
    } catch (e) {
      print('Failed to load default address: $e');
    }
  }

  void _fetchCheckoutPreview({required int pointsToRedeem}) {
    _checkoutPreviewBloc.add(FetchCheckoutPreview(
      subtotal: widget.subtotal,
      deliveryFee: _deliveryFee,
      serviceFee: _serviceFee,
      couponDiscount: widget.discount,
      pointsToRedeem: pointsToRedeem,
    ));
  }

  void _onTogglePoints(CheckoutPreviewLoaded state) {
    final newValue = !_usePoints;
    setState(() {
      _usePoints = newValue;
      _pointsToRedeem = newValue ? state.data.maxPointsRedeemableThisOrder : 0;
    });
    _fetchCheckoutPreview(pointsToRedeem: _pointsToRedeem);
  }

  List<Map<String, dynamic>> get _paymentOptions => [
        {
          'title': 'payment_apple_pay'.tr(),
          'subtitle': null,
          'image': 'assets/images/Apple Pay.svg'
        },
        {
          'title': 'payment_visa'.tr(),
          'subtitle': '***20932',
          'image': 'assets/images/visa.svg'
        },
        {
          'title': 'payment_debit'.tr(),
          'subtitle': '**** 9572',
          'image': 'assets/images/mastercard.svg'
        },
        {
          'title': 'payment_cash'.tr(),
          'subtitle': null,
          'image': 'assets/images/Cash.svg'
        },
        {
          'title': 'payment_add_card'.tr(),
          'subtitle': null,
          'image': 'assets/images/plus.svg'
        },
      ];

  void _openAddressForm() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) =>
          AddressSelectionSheet(onAddressSelected: (fullAddress, zoneId) {
        setState(() {
          _address = fullAddress;
          _zoneId = zoneId;
          _isAddressFromSaved = true;
        });
      }),
    );
  }

  void _openNotesDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('order_notes'.tr()),
        content: TextField(
          controller: _notesController,
          maxLines: 3,
          decoration: InputDecoration(
            hintText: 'notes_hint'.tr(),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.r),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('cancel'.tr()),
          ),
          TextButton(
            onPressed: () {
              setState(() {});
              Navigator.pop(context);
            },
            child: Text('save'.tr()),
          ),
        ],
      ),
    );
  }

  String _mapPaymentMethod(String selected) {
    final lower = selected.toLowerCase();
    if (lower.contains('cash')) return 'Cash on Delivery';
    if (lower.contains('apple')) return 'Apple Pay';
    if (lower.contains('visa')) return 'Visa';
    if (lower.contains('master') || lower.contains('debit')) {
      return 'Mastercard';
    }
    return 'Card';
  }

  PlaceOrderRequest _buildPlaceOrderRequest(
      CheckoutPreviewLoaded previewState) {
    final coupon = widget.voucherCode != null && widget.discount > 0
        ? Coupon(code: widget.voucherCode!, amount: widget.discount)
        : Coupon(code: '', amount: 0);

    final totalDiscount = widget.discount + previewState.data.pointsDiscountEGP;

    final items = widget.cartItems.map((item) {
      final productId = item['_id'] ?? '';
      return OrderItem(
        product: productId,
        name: item['name'] ?? '',
        quantity: item['quantity'] ?? 1,
        price: (item['price'] ?? 0).toDouble(),
        notes: item['notes'] ?? '', // 👈 per-item note
        customization: Customization(
          roastLevel: item['customization']?['roastLevel'] ?? '',
          grindType: item['customization']?['grindType'] ?? '',
        ),
      );
    }).toList();

    return PlaceOrderRequest(
      customer: Customer(
        name: _userName,
        email: _userEmail,
        phone: _userPhone,
        address: _address,
        region: _zoneId,
      ),
      items: items,
      summary: OrderSummary(
        subtotal: widget.subtotal,
        deliveryFee: _deliveryFee,
        surcharges: _serviceFee,
        discount: totalDiscount,
        total: previewState.data.totals.totalAfterPoints,
        coupon: coupon,
      ),
      payment: Payment(
        method: _mapPaymentMethod(_selectedPayment),
      ),
      orderType: 'Delivery',
      notes: _notesController.text,
      specialRequests: widget.specialRequests ?? '', // 👈 order-level
      pointsToRedeem: _pointsToRedeem,
    );
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: _checkoutPreviewBloc),
        BlocProvider(
          create: (_) => PlaceOrderBloc(
            repository: PlaceOrderRepository(
              api: PlaceOrderApi(),
            ),
          ),
        ),
      ],
      child: Scaffold(
        backgroundColor: const Color(0xFFF7F7F7),
        bottomNavigationBar: BlocConsumer<PlaceOrderBloc, PlaceOrderState>(
          listener: (context, state) {
            if (state is PlaceOrderLoading) {
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (_) =>
                    const Center(child: CircularProgressIndicator()),
              );
            } else if (state is PlaceOrderSuccess) {
              if (Navigator.canPop(context)) Navigator.pop(context);
              // 👇 Clear cart after successful order
              context.read<CartBloc>().add(ClearCart());
              Navigator.pushNamed(
                context,
                Routes.orderSummary,
                arguments: {
                  'orderNumber':
                      state.response.orderId, // 👈 "ORD-777619" for display
                  'orderId': state.response.id,
                  'cartItems': widget.cartItems,
                  'subtotal': widget.subtotal,
                  'deliveryFee': _deliveryFee,
                  'serviceFee': _serviceFee,
                  'deliveryAddress': _address,
                  'paymentMethod': _mapPaymentMethod(_selectedPayment),
                  'pointsEarned': state.response.pointsEarned,
                },
              );
            } else if (state is PlaceOrderFailure) {
              if (Navigator.canPop(context)) Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.error)),
              );
            }
          },
          builder: (context, placeOrderState) {
            return BlocBuilder<CheckoutPreviewBloc, CheckoutPreviewState>(
              builder: (context, previewState) {
                return AppBottomActionBar(
                  primaryText: 'place_order'.tr(),
                  secondaryText: 'add_items'.tr(),
                  onPrimaryTap: () {
                    if (_isLoadingUser) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('loading_user_data'.tr())),
                      );
                      return;
                    }
                    if (_userName.isEmpty ||
                        _userEmail.isEmpty ||
                        _userPhone.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('user_data_missing'.tr())),
                      );
                      return;
                    }
                    if (_address.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('please_select_address'.tr())),
                      );
                      return;
                    }
                    if (_zoneId.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('please_select_zone'.tr())),
                      );
                      return;
                    }
                    if (previewState is! CheckoutPreviewLoaded) return;
                    final request = _buildPlaceOrderRequest(previewState);
                    context
                        .read<PlaceOrderBloc>()
                        .add(PlaceOrderRequested(request));
                  },
                  onSecondaryTap: () => Navigator.pop(context),
                );
              },
            );
          },
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 24.h),
                _buildHeader(),
                SizedBox(height: 24.h),
                _buildDeliveryAddress(),
                SizedBox(height: 20.h),
                _buildOrderNotes(),
                SizedBox(height: 24.h),
                _buildPaymentSection(),
                SizedBox(height: 21.h),
                _buildPointsToggle(),
                SizedBox(height: 24.h),
                _buildOrderSummary(),
                SizedBox(height: 120.h),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPointsToggle() {
    return BlocBuilder<CheckoutPreviewBloc, CheckoutPreviewState>(
      builder: (context, state) {
        if (state is CheckoutPreviewLoading) {
          return Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: const Color(0xFFDCDCDC)),
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: const Center(
              child: CircularProgressIndicator(
                color: Color(0xFF6B5E4B),
                strokeWidth: 2,
              ),
            ),
          );
        }
        if (state is CheckoutPreviewLoaded) {
          return PointsToggle(
            isEnabled: _usePoints && state.data.canRedeem,
            canRedeem: state.data.canRedeem,
            points: state.data.pointsBalance,
            pointsValue: state.data.redeemableEGP.toInt(),
            redeemDisplayLabel: state.data.redeemRule.displayLabel,
            onToggle: () => _onTogglePoints(state),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildOrderSummary() {
    return BlocBuilder<CheckoutPreviewBloc, CheckoutPreviewState>(
      builder: (context, state) {
        final pointsDiscount =
            state is CheckoutPreviewLoaded ? state.data.pointsDiscountEGP : 0.0;
        final totalAfterPoints = state is CheckoutPreviewLoaded
            ? state.data.totals.totalAfterPoints
            : null;
        final pointsEarned = state is CheckoutPreviewLoaded
            ? state.data.pointsEarnedIfOrderCompleted
            : 0;

        return CheckoutOrderSummary(
          cartItems: widget.cartItems,
          deliveryFee: _deliveryFee,
          serviceFee: _serviceFee,
          couponDiscount: widget.discount,
          pointsDiscount: pointsDiscount,
          totalOverride: totalAfterPoints,
          rewardPoints: pointsEarned,
        );
      },
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            padding: const EdgeInsets.all(10),
            child: const Icon(Icons.arrow_back, size: 20, color: Colors.black),
          ),
        ),
        Expanded(
          child: Text(
            'checkout'.tr(),
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
        SizedBox(width: 44.w),
      ],
    );
  }

  Widget _buildDeliveryAddress() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionTitle(title: 'delivery_address'.tr()),
        SizedBox(height: 10.h),
        AppFieldTile(
          text: _address.isEmpty ? 'address_hint'.tr() : _address,
          prefixImage: 'assets/images/pin.svg',
          suffixIcon: _isAddressFromSaved
              ? Icons.edit
              : Icons.arrow_forward_ios_outlined,
          suffixText: _isAddressFromSaved ? 'change'.tr() : null,
          onTap: _openAddressForm,
        ),
      ],
    );
  }

  Widget _buildOrderNotes() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionTitle(
          title: 'order_notes'.tr(),
          subtitle: 'optional'.tr(),
        ),
        SizedBox(height: 10.h),
        AppFieldTile(
          text: _notesController.text.isEmpty
              ? 'notes_hint'.tr()
              : _notesController.text,
          prefixImage: 'assets/images/comment-alt-lines.svg',
          onTap: _openNotesDialog,
        ),
      ],
    );
  }

  Widget _buildPaymentSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionTitle(title: 'pay_with'.tr(), fontSize: 16.sp),
        SizedBox(height: 16.h),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _paymentOptions.length,
          separatorBuilder: (_, __) => SizedBox(height: 12.h),
          itemBuilder: (_, index) {
            final option = _paymentOptions[index];
            return PaymentOption(
              title: option['title'],
              subtitle: option['subtitle'],
              image: option['image'],
              isSelected: _selectedPayment == option['title'],
              onTap: () => setState(() => _selectedPayment = option['title']),
            );
          },
        ),
      ],
    );
  }
}
