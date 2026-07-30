import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:patria/core/utils/validators.dart';
import 'package:patria/features/auth/data/apis/auth_api.dart';
import 'package:patria/features/auth/presentation/views/widgets/custom_text_field.dart';
import 'package:patria/features/auth/presentation/views/widgets/forgot_password_otp_bottom_sheet.dart';

class ForgotPasswordBottomSheet extends StatefulWidget {
  const ForgotPasswordBottomSheet({super.key});

  @override
  State<ForgotPasswordBottomSheet> createState() =>
      _ForgotPasswordBottomSheetState();
}

class _ForgotPasswordBottomSheetState extends State<ForgotPasswordBottomSheet> {
  final _phoneController = TextEditingController();
  bool _isLoading = false; // ✅
  String? _errorMessage; // ✅

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  // ✅ API call
  Future<void> _sendOtp() async {
    final phone = _phoneController.text.trim();
    final validationError = Validators.phone(phone);
    if (validationError != null) {
      setState(() => _errorMessage = validationError);
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await AuthApi().forgotPassword(phone);
      if (!mounted) return;

      final rootNavigator = Navigator.of(context, rootNavigator: true);
      rootNavigator.pop(); // ✅ close this sheet

      showModalBottomSheet(
        context: rootNavigator.context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        useRootNavigator: true,
        builder: (_) => ForgotPasswordOtpBottomSheet(
          phoneNumber: phone, // ✅ pass real phone
        ),
      );
    } catch (e) {
      if (!mounted) return;
      print('❌ Forgot password error: $e'); // ✅ add this
      setState(() => _errorMessage = e.toString()); // ✅ show real error instead
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
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
          color: Color(0xFFFAFAF7),
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
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 90.w,
                height: 90.h,
                decoration: BoxDecoration(
                  color: const Color(0xFFE5E8D3),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: const Color(0x194A3F33),
                    width: 4.w,
                  ),
                ),
                child: Image.asset('assets/images/key.png'),
              ),
              SizedBox(height: 32.h),

              Text(
                'reset_password'.tr(),
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 20.sp,
                  fontFamily: 'Montserrat',
                  fontWeight: FontWeight.w600,
                  height: 1.07,
                  letterSpacing: 0.40,
                ),
              ),
              SizedBox(height: 6.h),

              Text(
                'reset_password_subtitle'.tr(),
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color(0xFF515151),
                  fontSize: 16.sp,
                  fontFamily: 'Montserrat',
                  fontWeight: FontWeight.w400,
                  height: 1.40,
                  letterSpacing: 0.32,
                ),
              ),
              SizedBox(height: 32.h),

              CustomTextField(
                controller: _phoneController,
                label: 'phone_number'.tr(),
                hint: 'phone_hint'.tr(),
                keyboardType: TextInputType.phone,
                prefixIcon: const Icon(
                  Icons.phone_outlined,
                  color: Color(0xFF8B8B8B),
                  size: 24,
                ),
              ),

              // ✅ Inline error
              if (_errorMessage != null) ...[
                SizedBox(height: 12.h),
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(
                    horizontal: 16.w,
                    vertical: 12.h,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFEEEE),
                    borderRadius: BorderRadius.circular(8.r),
                    border: Border.all(color: Colors.red.shade200),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.error_outline,
                        color: Colors.red,
                        size: 18,
                      ),
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

              // ✅ Button with loading
              ElevatedButton(
                onPressed: _isLoading ? null : _sendOtp,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF3C4119),
                  minimumSize: const Size(double.infinity, 56),
                  padding: EdgeInsets.symmetric(
                    horizontal: 30.w,
                    vertical: 16.h,
                  ),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5.r),
                  ),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Text(
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
