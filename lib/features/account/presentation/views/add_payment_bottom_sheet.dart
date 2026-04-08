import 'package:easy_localization/easy_localization.dart';
import 'package:erb/features/account/data/apis/payment_api.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AddPaymentBottomSheet extends StatefulWidget {
  const AddPaymentBottomSheet({super.key});

  @override
  State<AddPaymentBottomSheet> createState() => _AddPaymentBottomSheetState();
}

class _AddPaymentBottomSheetState extends State<AddPaymentBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  final _cardNumberController = TextEditingController();
  final _cardHolderController = TextEditingController();
  final _expiryController = TextEditingController();
  final _cvvController = TextEditingController();

  bool _isDefault = false;
  bool _isLoading = false;
  String? _errorMessage;

  String _getCardType(String number) {
    final clean = number.replaceAll(' ', '');
    if (clean.startsWith('4')) return 'Visa';
    if (clean.startsWith('5')) return 'Mastercard';
    if (clean.startsWith('3')) return 'Amex';
    return 'Visa';
  }

  @override
  void dispose() {
    _cardNumberController.dispose();
    _cardHolderController.dispose();
    _expiryController.dispose();
    _cvvController.dispose();
    super.dispose();
  }

  Future<void> _saveCard() async {
    if (!_formKey.currentState!.validate()) return;

    final expiry = _expiryController.text.trim();
    final parts = expiry.split('/');
    if (parts.length != 2) {
      setState(() => _errorMessage = 'Invalid expiry format (MM/YY)');
      return;
    }

    final expiryMonth = parts[0].trim();
    final expiryYear = parts[1].trim();
    final clean = _cardNumberController.text.replaceAll(' ', '');
    final last4 = clean.length >= 4 ? clean.substring(clean.length - 4) : clean;
    final cardType = _getCardType(clean);

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await PaymentApi().addPaymentMethod(
        cardType: cardType,
        last4: last4,
        cardholderName: _cardHolderController.text.trim(),
        expiryMonth: expiryMonth,
        expiryYear: expiryYear,
        isDefault: _isDefault,
      );

      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      setState(() => _errorMessage = 'Failed to save card. Try again.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.6, // ✅ starts at 60%
      minChildSize: 0.6, // ✅ minimum 60%
      maxChildSize: 0.92, // ✅ expands to 92% when keyboard opens
      expand: false,
      builder: (context, scrollController) {
        return GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: Container(
            padding: EdgeInsets.only(
              top: 16.h,
              left: 16.w,
              right: 16.w,
              bottom: MediaQuery.of(context).viewInsets.bottom + 32.h, // ✅
            ),
            decoration: ShapeDecoration(
              color: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20.r),
                  topRight: Radius.circular(20.r),
                ),
              ),
            ),
            child: Form(
              key: _formKey,
              child: ListView(
                // ✅ use ListView instead of SingleChildScrollView
                controller: scrollController,
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                children: [
                  _buildHeader(),
                  SizedBox(height: 16.h),
                  _buildTextField(
                    label: 'card_number'.tr(),
                    controller: _cardNumberController,
                    hint: '000 0000 0000 0000',
                    keyboardType: TextInputType.number,
                    suffixIcon: Icons.credit_card_outlined,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter card number';
                      }
                      final clean = value.replaceAll(' ', '');
                      if (clean.length < 16) {
                        return 'Card number must be 16 digits';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 16.h),
                  _buildTextField(
                    label: 'cardholder_name'.tr(),
                    controller: _cardHolderController,
                    hint: 'cardholder_name_hint'.tr(),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter cardholder name';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 16.h),
                  Row(
                    children: [
                      Expanded(
                        child: _buildTextField(
                          label: 'expiry_date'.tr(),
                          controller: _expiryController,
                          hint: 'MM/YY',
                          keyboardType: TextInputType.datetime,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Please enter expiry date';
                            }
                            if (!value.contains('/')) {
                              return 'Format: MM/YY';
                            }
                            return null;
                          },
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: _buildTextField(
                          label: 'cvv'.tr(),
                          controller: _cvvController,
                          hint: 'cvv_hint'.tr(),
                          keyboardType: TextInputType.number,
                          obscureText: true,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Please enter CVV';
                            }
                            return null;
                          },
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16.h),

                  // Set as default toggle
                  GestureDetector(
                    onTap: () => setState(() => _isDefault = !_isDefault),
                    child: Row(
                      children: [
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          width: 20.w,
                          height: 20.h,
                          decoration: ShapeDecoration(
                            color: _isDefault
                                ? const Color(0xFF6B5E4B)
                                : Colors.transparent,
                            shape: RoundedRectangleBorder(
                              side: const BorderSide(color: Color(0xFF6B5E4B)),
                              borderRadius: BorderRadius.circular(6.r),
                            ),
                          ),
                          child: _isDefault
                              ? const Icon(Icons.check,
                                  size: 14, color: Colors.white)
                              : null,
                        ),
                        SizedBox(width: 8.w),
                        Text(
                          'set_as_default'.tr(),
                          style: TextStyle(
                            color: Color(0xFF333333),
                            fontSize: 13.sp,
                            fontFamily: 'Montserrat',
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Inline error
                  if (_errorMessage != null) ...[
                    SizedBox(height: 12.h),
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.symmetric(
                          horizontal: 16.w, vertical: 12.h),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFEEEE),
                        borderRadius: BorderRadius.circular(8.r),
                        border: Border.all(color: Colors.red.shade200),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.error_outline,
                              color: Colors.red, size: 18),
                          SizedBox(width: 8.w),
                          Expanded(
                            child: Text(
                              _errorMessage!,
                              style: TextStyle(
                                color: Colors.red,
                                fontSize: 13.sp,
                                fontFamily: 'Montserrat',
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],

                  SizedBox(height: 32.h),
                  _buildSaveButton(),
                  SizedBox(height: 16.h),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'new_payment_method'.tr(),
          style: TextStyle(
            color: Color(0xFF28293D),
            fontSize: 16.sp,
            fontFamily: 'Montserrat',
            fontWeight: FontWeight.w500,
            letterSpacing: 0.32,
          ),
        ),
        GestureDetector(
          onTap: () => Navigator.pop(context),
          child: const Icon(Icons.close, size: 24, color: Colors.black),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    required String hint,
    TextInputType keyboardType = TextInputType.text,
    IconData? suffixIcon,
    bool obscureText = false,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.black,
            fontSize: 12.sp,
            fontFamily: 'Montserrat',
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: 10.h),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          obscureText: obscureText,
          validator: validator,
          style: TextStyle(
            color: Colors.black,
            fontSize: 16.sp,
            fontFamily: 'Montserrat',
            fontWeight: FontWeight.w400,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
              color: Color(0xFF8B8B8B),
              fontSize: 16.sp,
              fontFamily: 'Montserrat',
              fontWeight: FontWeight.w400,
            ),
            suffixIcon: suffixIcon != null
                ? Icon(suffixIcon, size: 20, color: const Color(0xFF8B8B8B))
                : null,
            contentPadding:
                EdgeInsets.symmetric(horizontal: 18.w, vertical: 14.h),
            filled: true,
            fillColor: Colors.white,
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: const BorderSide(color: Color(0xFFE5E5E5)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: const BorderSide(color: Color(0xFF6B5E4B)),
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

  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      height: 56.h,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _saveCard,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF6B5E4B),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(5),
          ),
        ),
        child: _isLoading
            ? const CircularProgressIndicator(color: Colors.white)
            : Text(
                'save_card'.tr(),
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16.sp,
                  fontFamily: 'Montserrat',
                  fontWeight: FontWeight.w600,
                ),
              ),
      ),
    );
  }
}
