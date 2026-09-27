import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:patria/features/auth/data/apis/auth_api.dart';
import 'package:patria/features/auth/presentation/views/widgets/custom_text_field.dart';
import 'package:patria/features/auth/presentation/views/widgets/signIn_bottom_sheet.dart';

class NewPasswordBottomSheet extends StatefulWidget {
  final String phoneNumber; // ✅
  final String otpCode; // ✅

  const NewPasswordBottomSheet({
    super.key,
    required this.phoneNumber,
    required this.otpCode,
  });

  @override
  State<NewPasswordBottomSheet> createState() => _NewPasswordBottomSheetState();
}

class _NewPasswordBottomSheetState extends State<NewPasswordBottomSheet> {
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _resetPassword() async {
    final password = _passwordController.text.trim();
    final confirm = _confirmPasswordController.text.trim();

    if (password.isEmpty) {
      setState(() => _errorMessage = 'Please enter a new password');
      return;
    }
    if (password.length < 6) {
      setState(() => _errorMessage = 'Password must be at least 6 characters');
      return;
    }
    if (password != confirm) {
      setState(() => _errorMessage = 'Passwords do not match');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await AuthApi().resetPassword(
        phone: widget.phoneNumber,
        code: widget.otpCode,
        newPassword: password,
      );

      if (!mounted) return;

      final rootNavigator = Navigator.of(context, rootNavigator: true);
      rootNavigator.pop();
      showModalBottomSheet(
        context: rootNavigator.context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        useRootNavigator: true,
        builder: (_) => const SignInBottomSheet(),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _errorMessage = 'Failed to reset password. Try again.');
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'new_password_title'.tr(),
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
                'new_password_subtitle'.tr(),
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
                controller: _passwordController,
                label: 'password'.tr(),
                hint: 'password_min_hint'.tr(),
                isPassword: true,
                obscureText: _obscurePassword,
                onToggleVisibility: () =>
                    setState(() => _obscurePassword = !_obscurePassword),
                prefixIcon: const Icon(
                  Icons.lock_outline,
                  color: Color(0xFF8B8B8B),
                  size: 24,
                ),
              ),
              SizedBox(height: 16.h),

              CustomTextField(
                controller: _confirmPasswordController,
                label: 'confirm_password'.tr(),
                hint: 'password_min_hint'.tr(),
                isPassword: true,
                obscureText: _obscureConfirmPassword,
                onToggleVisibility: () => setState(
                  () => _obscureConfirmPassword = !_obscureConfirmPassword,
                ),
                prefixIcon: const Icon(
                  Icons.lock_outline,
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

              // ✅ Continue button with loading
              ElevatedButton(
                onPressed: _isLoading ? null : _resetPassword,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF3C4119),
                  minimumSize: const Size(double.infinity, 56),
                  padding: EdgeInsets.symmetric(
                    horizontal: 30.w,
                    vertical: 16.h,
                  ),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5),
                  ),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Text(
                        'continue'.tr(),
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16.sp,
                          fontFamily: 'Montserrat',
                          fontWeight: FontWeight.w600,
                          height: 1.50,
                        ),
                      ),
              ),
              SizedBox(height: 12.h),

              Center(
                child: TextButton(
                  onPressed: () {
                    Navigator.popUntil(context, (route) => route.isFirst);
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      backgroundColor: Colors.transparent,
                      builder: (context) => const SignInBottomSheet(),
                    );
                  },
                  child: Text(
                    'return_to_sign_in'.tr(),
                    style: TextStyle(
                      color: Color(0xFF3C4119),
                      fontSize: 16.sp,
                      fontFamily: 'Montserrat',
                      fontWeight: FontWeight.w600,
                      height: 1.40,
                      letterSpacing: 0.32,
                    ),
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
