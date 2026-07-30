import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:patria/core/utils/emoji_input_formatter.dart';
import 'package:patria/core/utils/validators.dart';
import 'package:patria/features/auth/presentation/views/widgets/otp_verification_bottom_sheet.dart';

class PhoneVerificationBottomSheet extends StatefulWidget {
  const PhoneVerificationBottomSheet({super.key});

  @override
  State<PhoneVerificationBottomSheet> createState() =>
      _PhoneVerificationBottomSheetState();
}

class _PhoneVerificationBottomSheetState
    extends State<PhoneVerificationBottomSheet> {
  final _phoneController = TextEditingController();
  String? _phoneError;

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 32.h),
        clipBehavior: Clip.antiAlias,
        decoration: ShapeDecoration(
          color: const Color(0xFFFAFAF7),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(30.r),
              topRight: Radius.circular(30.r),
            ),
          ),
        ),
        child: SingleChildScrollView(
          physics: const ClampingScrollPhysics(),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'welcome_to_patria'.tr(),
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 20.sp,
                  fontFamily: 'Montserrat',
                  fontWeight: FontWeight.w700,
                  height: 1.07,
                  letterSpacing: 0.40,
                ),
              ),
              SizedBox(height: 6.h),
              Text(
                'enter_phone_for_otp'.tr(),
                style: TextStyle(
                  color: const Color(0xFF515151),
                  fontSize: 16.sp,
                  fontFamily: 'Montserrat',
                  fontWeight: FontWeight.w400,
                  height: 1.40,
                  letterSpacing: 0.32,
                ),
              ),
              SizedBox(height: 24.h),
              _StyledPhoneField(
                controller: _phoneController,
                label: 'phone_number'.tr(),
                hint: '+20 1XX XXX XXXX',
                errorText: _phoneError,
              ),
              SizedBox(height: 32.h),
              ElevatedButton(
                onPressed: () {
                  final error = Validators.phone(_phoneController.text);
                  if (error != null) {
                    setState(() => _phoneError = error);
                    return;
                  }
                  setState(() => _phoneError = null);
                  Navigator.pop(context);
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: Colors.transparent,
                    builder: (context) => OtpVerificationBottomSheet(
                      phoneNumber: _phoneController.text.trim(),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF3C4119),
                  minimumSize: Size(double.infinity, 56.h),
                  padding: EdgeInsets.symmetric(
                    horizontal: 30.w,
                    vertical: 16.h,
                  ),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5.r),
                  ),
                ),
                child: Text(
                  'send_otp'.tr(),
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16.sp,
                    fontFamily: 'Montserrat',
                    fontWeight: FontWeight.w600,
                    height: 1.50,
                  ),
                ),
              ),
              SizedBox(height: 8.h),
            ],
          ),
        ),
      ),
    );
  }
}

// ========== Focus‑aware Phone Field ==========
class _StyledPhoneField extends StatefulWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final String? errorText;

  const _StyledPhoneField({
    required this.controller,
    required this.label,
    required this.hint,
    this.errorText,
  });

  @override
  State<_StyledPhoneField> createState() => _StyledPhoneFieldState();
}

class _StyledPhoneFieldState extends State<_StyledPhoneField> {
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isFocused = _focusNode.hasFocus;
    final Color textColor = isFocused ? Colors.black : const Color(0xFF8B8B8B);
    final Color hintColor = isFocused
        ? const Color(0xFF3C4119).withOpacity(0.7)
        : const Color(0xFF8B8B8B);
    final Color iconColor = isFocused
        ? const Color(0xFF3C4119)
        : const Color(0xFF8B8B8B);
    final Color borderColor = isFocused
        ? const Color(0xFF3C4119)
        : const Color(0xFFE5E5E5);
    final bool hasError = widget.errorText != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label,
          style: TextStyle(
            color: Colors.black,
            fontSize: 12.sp,
            fontFamily: 'Montserrat',
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: 10.h),
        TextField(
          controller: widget.controller,
          focusNode: _focusNode,
          keyboardType: TextInputType.phone,
          inputFormatters: [EmojiInputFormatter()],
          style: TextStyle(
            color: textColor,
            fontSize: 16.sp,
            fontFamily: 'Montserrat',
            fontWeight: FontWeight.w400,
          ),
          decoration: InputDecoration(
            hintText: widget.hint,
            hintStyle: TextStyle(
              color: hintColor,
              fontSize: 16.sp,
              fontFamily: 'Montserrat',
              fontWeight: FontWeight.w400,
            ),
            prefixIcon: Icon(Icons.phone_outlined, color: iconColor, size: 24),
            contentPadding: EdgeInsets.symmetric(
              horizontal: 18.w,
              vertical: 12.h,
            ),
            errorText: widget.errorText,
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide(
                width: 1.w,
                color: hasError ? Colors.red : borderColor,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide(
                width: 1.5,
                color: hasError ? Colors.red : const Color(0xFF3C4119),
              ),
            ),
            filled: true,
            fillColor: Colors.white,
          ),
        ),
      ],
    );
  }
}
