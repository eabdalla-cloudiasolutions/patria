import 'package:erb/core/routing/routes.dart';
import 'package:erb/features/checkout/presentation/views/new_address_screen.dart';
import 'package:erb/features/checkout/presentation/views/widgets/app_bottom_action_bar.dart';
import 'package:erb/features/checkout/presentation/views/widgets/section_title.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/widgets/app_field_tile.dart';
import 'widgets/checkout_order_summary.dart';
import 'widgets/payment_option.dart';
import 'widgets/points_toggle.dart';

class CheckoutScreen extends StatefulWidget {
  final List<Map<String, dynamic>> cartItems;
  final double subtotal;

  const CheckoutScreen({
    super.key,
    required this.cartItems,
    required this.subtotal,
  });

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  String _address = '';
  String _notes = '';
  late String _selectedPayment;
  bool _usePoints = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _selectedPayment = 'payment_cash'.tr(); // ✅ init after context ready
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

  void _navigateToAddressScreen() async {
    final selectedAddress = await Navigator.push<String>(
      context,
      MaterialPageRoute(builder: (_) => const NewAddressScreen()),
    );
    if (selectedAddress != null) {
      setState(() => _address = selectedAddress);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      bottomNavigationBar: AppBottomActionBar(
        primaryText: 'place_order'.tr(),
        secondaryText: 'add_items'.tr(),
        onPrimaryTap: () => Navigator.pushNamed(
          context,
          Routes.orderSummary,
          arguments: {
            'cartItems': widget.cartItems,
            'subtotal': widget.subtotal,
            'deliveryFee': 25.0,
            'serviceFee': 32.0,
            'deliveryAddress': _address,
            'paymentMethod': _selectedPayment,
            'orderNumber': '131630',
            'pointsEarned': 32,
          },
        ),
        onSecondaryTap: () => Navigator.pop(context),
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
              PointsToggle(
                isEnabled: _usePoints,
                points: 2450,
                pointsValue: 245,
                onToggle: () => setState(() => _usePoints = !_usePoints),
              ),
              SizedBox(height: 24.h),
              CheckoutOrderSummary(cartItems: widget.cartItems),
              SizedBox(height: 120.h),
            ],
          ),
        ),
      ),
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
          suffixIcon: Icons.arrow_forward_ios_outlined,
          onTap: _navigateToAddressScreen,
          onSuffixTap: _navigateToAddressScreen,
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
          text: _notes.isEmpty ? 'notes_hint'.tr() : _notes,
          prefixImage: 'assets/images/comment-alt-lines.svg',
          onTap: () {},
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
