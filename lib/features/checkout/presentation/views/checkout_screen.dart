import 'package:dio/dio.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:patria/core/routing/routes.dart';
import 'package:patria/core/services/user_service.dart';
import 'package:patria/core/utils/emoji_input_formatter.dart';
import 'package:patria/core/utils/validators.dart';
import 'package:patria/features/account/data/apis/addresses_api.dart';
import 'package:patria/features/account/data/models/address_model.dart';
import 'package:patria/features/cart/data/models/cart_model.dart';
import 'package:patria/features/cart/presentation/manager/cart_bloc.dart';
import 'package:patria/features/cart/presentation/manager/cart_event.dart';
import 'package:patria/features/checkout/data/apis/place_order_api.dart';
import 'package:patria/features/checkout/data/apis/zone_lookup_api.dart';
import 'package:patria/features/checkout/data/models/place_order_request.dart'
    as order;
import 'package:patria/features/checkout/data/repos/delivery_zones_repo.dart';
import 'package:patria/features/checkout/data/repos/place_order_repository.dart';
import 'package:patria/features/checkout/presentation/manager/checkout_preview_bloc.dart';
import 'package:patria/features/checkout/presentation/manager/checkout_preview_event.dart';
import 'package:patria/features/checkout/presentation/manager/checkout_preview_state.dart';
import 'package:patria/features/checkout/presentation/manager/delivery_zones_bloc.dart';
import 'package:patria/features/checkout/presentation/manager/delivery_zones_event.dart';
import 'package:patria/features/checkout/presentation/manager/delivery_zones_state.dart';
import 'package:patria/features/checkout/presentation/manager/place_order_bloc.dart';
import 'package:patria/features/checkout/presentation/manager/place_order_event.dart';
import 'package:patria/features/checkout/presentation/manager/place_order_state.dart';
import 'package:patria/features/checkout/presentation/views/new_address_screen.dart';
import 'package:patria/features/checkout/presentation/views/widgets/address_selection_sheet.dart';
import 'package:patria/features/checkout/presentation/views/widgets/app_bottom_action_bar.dart';
import 'package:patria/features/checkout/presentation/views/widgets/section_title.dart';
import 'package:patria/features/product/presentation/views/widgets/special_request_bottom_sheet.dart';

import '../../../../core/widgets/app_field_tile.dart';
import 'widgets/checkout_order_summary.dart';
import 'widgets/payment_option.dart';
import 'widgets/points_toggle.dart';

class CheckoutScreen extends StatefulWidget {
  final List<CartItem> cartItems;
  final double subtotal;
  final double discount;
  final String? voucherCode;
  final String? specialRequests;

  const CheckoutScreen({
    super.key,
    required this.cartItems,
    required this.subtotal,
    this.discount = 0,
    this.voucherCode,
    this.specialRequests,
  });

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  String _address = '';
  String _zoneId = '';
  String _zoneName = '';
  String _selectedAddressId = '';
  final TextEditingController _notesController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  late String _selectedPayment;
  bool _usePoints = false;
  int _pointsToRedeem = 0;
  bool _isAddressFromSaved = false;

  String _userName = '';
  String _userEmail = '';
  String _userPhone = '';
  bool _hasPhone = false;
  bool _isLoadingUser = true;

  double _deliveryFee = 0.0;
  int _pointsEarnedPreview = 0;

  // ✅ Store last preview state to access in PlaceOrderSuccess listener
  CheckoutPreviewLoaded? _lastPreviewState;

  // ✅ Zone validation
  bool _isValidatingZone = false;
  String? _zoneError;
  List<String> _availableZones = [];

  late CheckoutPreviewBloc _checkoutPreviewBloc;
  late DeliveryZonesBloc _deliveryZonesBloc;

  @override
  void initState() {
    super.initState();
    _checkoutPreviewBloc = CheckoutPreviewBloc();
    _deliveryZonesBloc = DeliveryZonesBloc(DeliveryZonesRepo())
      ..add(FetchDeliveryZones());
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
    _deliveryZonesBloc.close();
    _notesController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<bool> _validateAndSetZone(String zoneName) async {
    setState(() {
      _isValidatingZone = true;
      _zoneError = null;
      _availableZones = [];
    });

    try {
      final result = await ZoneLookupApi().lookupZone(zoneName);
      setState(() {
        _zoneId = result.id;
        _deliveryFee = result.deliveryFee;
        _isValidatingZone = false;
      });
      _fetchCheckoutPreview(pointsToRedeem: _pointsToRedeem);
      return true;
    } on DioException catch (e) {
      final data = e.response?.data;
      String message = 'zone_not_available'.tr();
      List<String> available = [];

      if (data is Map<String, dynamic>) {
        message = data['message'] ?? message;
        if (data['availableZones'] is List) {
          available = List<String>.from(data['availableZones']);
        }
      }

      setState(() {
        _zoneError = message;
        _availableZones = available;
        _isValidatingZone = false;
        _deliveryFee = 0;
        _zoneId = '';
      });
      return false;
    } catch (_) {
      setState(() {
        _zoneError = 'zone_not_available'.tr();
        _isValidatingZone = false;
      });
      return false;
    }
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
      _hasPhone = phone.isNotEmpty;
      _isLoadingUser = false;
    });
  }

  Future<void> _applySelectedAddress(AddressModel addr) async {
    final parts = <String>[];
    if (addr.buildingName.isNotEmpty) parts.add(addr.buildingName);
    if (addr.street.isNotEmpty) parts.add(addr.street);
    if (addr.zone.isNotEmpty) parts.add(addr.zone);
    if (addr.city.isNotEmpty) parts.add(addr.city);
    setState(() {
      _address = parts.join(', ');
      _zoneName = addr.zone;
      _selectedAddressId = addr.id;
      _isAddressFromSaved = true;
    });
    if (_zoneName.isNotEmpty) {
      await _validateAndSetZone(_zoneName);
    }
  }

  Future<void> _loadDefaultAddress() async {
    try {
      final addresses = await AddressesApi().getAddresses();
      final defaultAddr = addresses.firstWhere(
        (a) => a.isDefault,
        orElse: () => addresses.first,
      );
      await _applySelectedAddress(defaultAddr);
    } catch (e) {
      print('Failed to load default address: $e');
    }
  }

  // ✅ Selects a specific address (e.g. one just created from checkout) by
  // id, regardless of its "set as default" flag, instead of requiring the
  // user to reopen the address list and pick it manually.
  Future<void> _loadAddressById(String addressId) async {
    try {
      final addresses = await AddressesApi().getAddresses();
      final addr = addresses.firstWhere(
        (a) => a.id == addressId,
        orElse: () => addresses.first,
      );
      await _applySelectedAddress(addr);
    } catch (e) {
      print('Failed to load selected address: $e');
      await _loadDefaultAddress();
    }
  }

  void _fetchCheckoutPreview({required int pointsToRedeem}) {
    _checkoutPreviewBloc.add(
      FetchCheckoutPreview(
        subtotal: widget.subtotal,
        deliveryFee: _deliveryFee,
        couponDiscount: widget.discount,
        pointsToRedeem: pointsToRedeem,
      ),
    );
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
      'title': 'payment_cash'.tr(),
      'subtitle': null,
      'image': 'assets/images/Cash.svg',
    },
  ];

  void _openAddressForm() async {
    try {
      final addresses = await AddressesApi().getAddresses();

      if (!mounted) return;

      if (addresses.isEmpty) {
        Navigator.of(context, rootNavigator: true)
            .push(MaterialPageRoute(builder: (_) => const NewAddressScreen()))
            .then((result) {
              if (!mounted) return;
              final addressId = result is Map
                  ? result['addressId'] as String?
                  : null;
              if (addressId != null) {
                _loadAddressById(addressId);
              } else {
                _loadDefaultAddress();
              }
            });
        return;
      }

      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (_) => BlocProvider.value(
          value: _deliveryZonesBloc,
          child: AddressSelectionSheet(
            selectedAddressId: _selectedAddressId,
            onAddressSelected:
                (fullAddress, addressId, deliveryZoneId, zoneName) async {
                  setState(() {
                    _address = fullAddress;
                    _selectedAddressId = addressId;
                    _zoneName = zoneName;
                    _isAddressFromSaved = true;
                  });
                  await _validateAndSetZone(zoneName);
                },
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      Navigator.of(context, rootNavigator: true)
          .push(MaterialPageRoute(builder: (_) => const NewAddressScreen()))
          .then((result) {
            if (!mounted) return;
            final addressId = result is Map
                ? result['addressId'] as String?
                : null;
            if (addressId != null) {
              _loadAddressById(addressId);
            } else {
              _loadDefaultAddress();
            }
          });
    }
  }

  void _openNotesDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => SpecialRequestBottomSheet(
        title: 'order_notes'.tr(),
        hint: 'notes_hint'.tr(),
        initialText: _notesController.text,
        onContinue: (text) {
          setState(() {
            _notesController.text = text;
          });
          Navigator.pop(context);
        },
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

  Future<void> _savePhoneIfNeeded() async {
    if (!_hasPhone && _phoneController.text.trim().isNotEmpty) {
      final userService = UserService();
      final id = await userService.getUserId();
      final role = await userService.getUserRole();
      final token = await userService.getUserToken();

      await userService.saveUser(
        id: id,
        name: _userName,
        email: _userEmail,
        phone: _phoneController.text.trim(),
        role: role,
        token: token,
      );

      setState(() {
        _userPhone = _phoneController.text.trim();
        _hasPhone = true;
      });
    }
  }

  order.PlaceOrderRequest _buildPlaceOrderRequest(
    CheckoutPreviewLoaded previewState,
  ) {
    final coupon = widget.voucherCode != null && widget.discount > 0
        ? order.Coupon(code: widget.voucherCode!, amount: widget.discount)
        : order.Coupon(code: '', amount: 0);

    final totalDiscount = widget.discount + previewState.data.pointsDiscountEGP;
    final phoneToUse = _hasPhone ? _userPhone : _phoneController.text.trim();

    final items = widget.cartItems.map((cartItem) {
      return order.OrderItem(
        product: cartItem.product.id,
        name: cartItem.product.name,
        quantity: cartItem.quantity,
        price: cartItem.price,
        notes: cartItem.notes ?? '',
        customization: order.Customization(
          roastLevel: cartItem.customization?['roastLevel'] ?? '',
          grindType: cartItem.customization?['grindType'] ?? '',
        ),
        selectedVariants: cartItem.selectedVariants
            .map(
              (v) => order.SelectedVariant(
                group: v.group,
                option: v.option,
                priceAdjustment: v.priceAdjustment,
              ),
            )
            .toList(),
      );
    }).toList();

    return order.PlaceOrderRequest(
      customer: order.Customer(
        name: _userName,
        email: _userEmail,
        phone: phoneToUse,
        address: _address,
        region: _zoneId,
      ),
      items: items,
      summary: order.OrderSummary(
        subtotal: widget.subtotal,
        deliveryFee: _deliveryFee,
        discount: totalDiscount,
        total: previewState.data.totals.totalAfterPoints,
        coupon: coupon,
      ),
      payment: order.Payment(method: _mapPaymentMethod(_selectedPayment)),
      orderType: 'Delivery',
      notes: _notesController.text,
      specialRequests: widget.specialRequests ?? '',
      pointsToRedeem: _pointsToRedeem,
    );
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: _checkoutPreviewBloc),
        BlocProvider.value(value: _deliveryZonesBloc),
        BlocProvider(
          create: (_) => PlaceOrderBloc(
            repository: PlaceOrderRepository(api: PlaceOrderApi()),
          ),
        ),
      ],
      child: BlocListener<DeliveryZonesBloc, DeliveryZonesState>(
        listener: (context, state) {},
        child: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          behavior: HitTestBehavior.opaque,
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
                  context.read<CartBloc>().add(ClearCart());

                  final cartItemsMaps = widget.cartItems
                      .map(
                        (item) => {
                          '_id': item.product.id,
                          'name': item.product.name,
                          'quantity': item.quantity,
                          'price': item.price,
                          'notes': item.notes,
                          'image': item.product.image,
                          'customization': item.customization,
                          'selectedVariants': item.selectedVariants
                              .map(
                                (v) => {
                                  'group': v.group,
                                  'option': v.option,
                                  'priceAdjustment': v.priceAdjustment,
                                },
                              )
                              .toList(),
                        },
                      )
                      .toList();

                  // ✅ Use _lastPreviewState to safely get points discount
                  final pointsDiscount =
                      _lastPreviewState?.data.pointsDiscountEGP ?? 0.0;
                  final totalDiscount = widget.discount + pointsDiscount;

                  Navigator.pushNamed(
                    context,
                    Routes.orderSummary,
                    arguments: {
                      'orderNumber': state.response.orderId,
                      'orderId': state.response.id,
                      'cartItems': cartItemsMaps,
                      'subtotal': widget.subtotal,
                      'deliveryFee': _deliveryFee,
                      'deliveryAddress': _address,
                      'paymentMethod': _mapPaymentMethod(_selectedPayment),
                      'pointsEarned': state.response.pointsEarned > 0
                          ? state.response.pointsEarned
                          : _pointsEarnedPreview,
                      'note': _notesController.text,
                      'discount': totalDiscount,
                    },
                  );
                } else if (state is PlaceOrderFailure) {
                  if (Navigator.canPop(context)) Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        state.error,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      backgroundColor: const Color(0xFFC90000),
                      duration: const Duration(seconds: 2),
                      behavior: SnackBarBehavior.floating,
                      margin: EdgeInsets.only(
                        left: 16.w,
                        right: 16.w,
                        bottom: 16.h,
                      ),
                      padding: EdgeInsets.symmetric(
                        horizontal: 16.w,
                        vertical: 8.h,
                      ),
                    ),
                  );
                }
              },
              builder: (context, placeOrderState) {
                return BlocBuilder<CheckoutPreviewBloc, CheckoutPreviewState>(
                  builder: (context, previewState) {
                    return AppBottomActionBar(
                      primaryText: 'place_order'.tr(),
                      secondaryText: 'add_items'.tr(),
                      onPrimaryTap: () async {
                        if (_isLoadingUser) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'loading_user_data'.tr(),
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              backgroundColor: const Color(0xFF3C4119),
                              duration: const Duration(seconds: 2),
                              behavior: SnackBarBehavior.floating,
                              margin: EdgeInsets.only(
                                left: 16.w,
                                right: 16.w,
                                bottom: 16.h,
                              ),
                              padding: EdgeInsets.symmetric(
                                horizontal: 16.w,
                                vertical: 8.h,
                              ),
                            ),
                          );
                          return;
                        }
                        final phoneValidationError = !_hasPhone
                            ? Validators.phone(_phoneController.text)
                            : null;
                        if (phoneValidationError != null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                phoneValidationError,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              backgroundColor: const Color(0xFFC90000),
                              duration: const Duration(seconds: 2),
                              behavior: SnackBarBehavior.floating,
                              margin: EdgeInsets.only(
                                left: 16.w,
                                right: 16.w,
                                bottom: 16.h,
                              ),
                              padding: EdgeInsets.symmetric(
                                horizontal: 16.w,
                                vertical: 8.h,
                              ),
                            ),
                          );
                          return;
                        }
                        if (_userName.isEmpty || _userEmail.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'user_data_missing'.tr(),
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              backgroundColor: const Color(0xFFC90000),
                              duration: const Duration(seconds: 2),
                              behavior: SnackBarBehavior.floating,
                              margin: EdgeInsets.only(
                                left: 16.w,
                                right: 16.w,
                                bottom: 16.h,
                              ),
                              padding: EdgeInsets.symmetric(
                                horizontal: 16.w,
                                vertical: 8.h,
                              ),
                            ),
                          );
                          return;
                        }
                        if (_address.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'please_select_address'.tr(),
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              backgroundColor: const Color(0xFFC90000),
                              duration: const Duration(seconds: 2),
                              behavior: SnackBarBehavior.floating,
                              margin: EdgeInsets.only(
                                left: 16.w,
                                right: 16.w,
                                bottom: 16.h,
                              ),
                              padding: EdgeInsets.symmetric(
                                horizontal: 16.w,
                                vertical: 8.h,
                              ),
                            ),
                          );
                          return;
                        }

                        if (_zoneError != null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                _zoneError!,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              backgroundColor: const Color(0xFFC90000),
                              duration: const Duration(seconds: 3),
                              behavior: SnackBarBehavior.floating,
                              margin: EdgeInsets.only(
                                left: 16.w,
                                right: 16.w,
                                bottom: 16.h,
                              ),
                              padding: EdgeInsets.symmetric(
                                horizontal: 16.w,
                                vertical: 8.h,
                              ),
                            ),
                          );
                          return;
                        }

                        if (_isValidatingZone) return;

                        if (previewState is CheckoutPreviewLoading) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'loading_order_summary'.tr(),
                                style: const TextStyle(fontWeight: FontWeight.w600),
                              ),
                              backgroundColor: const Color(0xFF3C4119),
                              duration: const Duration(seconds: 2),
                              behavior: SnackBarBehavior.floating,
                              margin: EdgeInsets.only(left: 16.w, right: 16.w, bottom: 16.h),
                              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                            ),
                          );
                          return;
                        }

                        if (previewState is CheckoutPreviewError) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                previewState.message,
                                style: const TextStyle(fontWeight: FontWeight.w600),
                              ),
                              backgroundColor: const Color(0xFFC90000),
                              duration: const Duration(seconds: 3),
                              behavior: SnackBarBehavior.floating,
                              margin: EdgeInsets.only(left: 16.w, right: 16.w, bottom: 16.h),
                              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                            ),
                          );
                          return;
                        }

                        if (previewState is! CheckoutPreviewLoaded) return;

                        await _savePhoneIfNeeded();
                        final request = _buildPlaceOrderRequest(previewState);
                        context.read<PlaceOrderBloc>().add(
                          PlaceOrderRequested(request),
                        );
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
                    SizedBox(height: 16.h),
                    _buildPhoneField(),
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
        ),
      ),
    );
  }

  Widget _buildPhoneField() {
    if (_isLoadingUser) return const SizedBox.shrink();
    if (_hasPhone) return const SizedBox.shrink();
    return _StyledPhoneField(
      controller: _phoneController,
      label: 'phone_number'.tr(),
      hint: '+20 1XX XXX XXXX',
      onChanged: (_) => setState(() {}),
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
                color: Color(0xFF3C4119),
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
            minRedeemPoints: state.data.minRedeemPoints,
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildOrderSummary() {
    return BlocBuilder<CheckoutPreviewBloc, CheckoutPreviewState>(
      builder: (context, state) {
        final pointsDiscount = state is CheckoutPreviewLoaded
            ? state.data.pointsDiscountEGP
            : 0.0;
        final totalAfterPoints = state is CheckoutPreviewLoaded
            ? state.data.totals.totalAfterPoints
            : null;
        final pointsEarned = state is CheckoutPreviewLoaded
            ? state.data.pointsEarnedIfOrderCompleted
            : 0;

        // ✅ Save latest preview state for use in PlaceOrderSuccess listener
        if (state is CheckoutPreviewLoaded) {
          _pointsEarnedPreview = state.data.pointsEarnedIfOrderCompleted;
          _lastPreviewState = state;
        }

        final itemsAsMaps = widget.cartItems
            .map(
              (item) => {
                '_id': item.product.id,
                'name': item.product.name,
                'quantity': item.quantity,
                'price': item.price,
                'notes': item.notes,
                'customization': item.customization,
                'selectedVariants': item.selectedVariants
                    .map(
                      (v) => {
                        'group': v.group,
                        'option': v.option,
                        'priceAdjustment': v.priceAdjustment,
                      },
                    )
                    .toList(),
              },
            )
            .toList();

        return CheckoutOrderSummary(
          cartItems: itemsAsMaps,
          deliveryFee: _deliveryFee,
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

        if (_isValidatingZone) ...[
          SizedBox(height: 8.h),
          Row(
            children: [
              SizedBox(
                width: 14.w,
                height: 14.h,
                child: const CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Color(0xFF3C4119),
                ),
              ),
              SizedBox(width: 8.w),
              Text(
                'checking_delivery_zone'.tr(),
                style: TextStyle(
                  color: const Color(0xFF3C4119),
                  fontSize: 12.sp,
                  fontFamily: 'Montserrat',
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
        ],

        if (_zoneError != null && !_isValidatingZone) ...[
          SizedBox(height: 8.h),
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
            decoration: BoxDecoration(
              color: const Color(0xFFFFEEEE),
              borderRadius: BorderRadius.circular(8.r),
              border: Border.all(color: Colors.red.shade200),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.error_outline,
                      color: Colors.red,
                      size: 16,
                    ),
                    SizedBox(width: 8.w),
                    Expanded(
                      child: Text(
                        _zoneError!,
                        style: TextStyle(
                          color: Colors.red,
                          fontSize: 12.sp,
                          fontFamily: 'Montserrat',
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
                if (_availableZones.isNotEmpty) ...[
                  SizedBox(height: 6.h),
                  Text(
                    '${'available_zones'.tr()}: ${_availableZones.join(', ')}',
                    style: TextStyle(
                      color: const Color(0xFF515151),
                      fontSize: 11.sp,
                      fontFamily: 'Montserrat',
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildOrderNotes() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionTitle(title: 'order_notes'.tr(), subtitle: 'optional'.tr()),
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

class _StyledPhoneField extends StatefulWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final Function(String)? onChanged;

  const _StyledPhoneField({
    required this.controller,
    required this.label,
    required this.hint,
    this.onChanged,
  });

  @override
  State<_StyledPhoneField> createState() => _StyledPhoneFieldState();
}

class _StyledPhoneFieldState extends State<_StyledPhoneField> {
  final FocusNode _focusNode = FocusNode();
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() {
      setState(() {
        _isFocused = _focusNode.hasFocus;
      });
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final accentColor = const Color(0xFF3C4119);
    final textColor = _isFocused ? Colors.black : const Color(0xFF8B8B8B);
    final hintColor = _isFocused
        ? accentColor.withOpacity(0.7)
        : const Color(0xFF8B8B8B);
    final iconColor = _isFocused ? accentColor : const Color(0xFF8B8B8B);
    final borderColor = _isFocused ? accentColor : const Color(0xFFE5E5E5);
    final borderWidth = _isFocused ? 1.5.w : 1.w;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionTitle(title: widget.label, subtitle: 'required'.tr()),
        SizedBox(height: 10.h),
        TextFormField(
          controller: widget.controller,
          focusNode: _focusNode,
          keyboardType: TextInputType.phone,
          inputFormatters: [EmojiInputFormatter()],
          onChanged: widget.onChanged,
          style: TextStyle(
            color: textColor,
            fontSize: 14.sp,
            fontFamily: 'Montserrat',
            fontWeight: FontWeight.w400,
          ),
          decoration: InputDecoration(
            hintText: widget.hint,
            hintStyle: TextStyle(
              color: hintColor,
              fontSize: 14.sp,
              fontFamily: 'Montserrat',
            ),
            prefixIcon: Icon(Icons.phone_outlined, color: iconColor, size: 20),
            contentPadding: EdgeInsets.symmetric(
              horizontal: 18.w,
              vertical: 14.h,
            ),
            filled: true,
            fillColor: Colors.white,
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide(color: borderColor, width: borderWidth),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: const BorderSide(
                color: Color(0xFF3C4119),
                width: 1.5,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: const BorderSide(color: Colors.red),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: const BorderSide(color: Colors.red),
            ),
          ),
        ),
      ],
    );
  }
}
