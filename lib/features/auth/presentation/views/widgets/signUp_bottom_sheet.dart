import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:patria/core/utils/validators.dart';
import 'package:patria/features/auth/data/apis/auth_api.dart';
import 'package:patria/features/auth/data/repos/auth_repo.dart';
import 'package:patria/features/auth/presentation/manager/register_bloc.dart';
import 'package:patria/features/auth/presentation/manager/register_event.dart';
import 'package:patria/features/auth/presentation/manager/register_state.dart';
import 'package:patria/features/auth/presentation/views/widgets/custom_text_field.dart'; // ✅ added
import 'package:patria/features/auth/presentation/views/widgets/otp_verification_bottom_sheet.dart';
import 'package:patria/features/auth/presentation/views/widgets/signIn_bottom_sheet.dart';

class SignUpBottomSheet extends StatefulWidget {
  const SignUpBottomSheet({super.key});

  @override
  State<SignUpBottomSheet> createState() => _SignUpBottomSheetState();
}

class _SignUpBottomSheetState extends State<SignUpBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => Registpatrialoc(AuthRepo()),
      child: Builder(
        builder: (context) {
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
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title
                      Text(
                        'create_account'.tr(),
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

                      // Subtitle
                      Text(
                        'sign_up_subtitle'.tr(),
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

                      // Full Name
                      CustomTextField(
                        controller: _nameController,
                        label: 'full_name'.tr(),
                        hint: 'full_name_hint'.tr(),
                        prefixIcon: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 12.w),
                          child: SvgPicture.asset(
                            'assets/images/user.svg',
                            height: 24.h,
                            width: 24.w,
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter your full name';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 16.h),

                      // Email
                      CustomTextField(
                        controller: _emailController,
                        label: 'email'.tr(),
                        hint: 'email_hint'.tr(),
                        keyboardType: TextInputType.emailAddress,
                        prefixIcon: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 12.w),
                          child: SvgPicture.asset(
                            'assets/images/email.svg',
                            height: 24.h,
                            width: 24.w,
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter your email';
                          }
                          if (!RegExp(
                            r'^[\w-.]+@([\w-]+\.)+[\w-]{2,4}$',
                          ).hasMatch(value)) {
                            return 'Please enter a valid email';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 16.h),

                      // Phone
                      CustomTextField(
                        controller: _phoneController,
                        label: 'phone_number_whatsapp'.tr(),
                        hint: 'phone_hint'.tr(),
                        keyboardType: TextInputType.phone,
                        prefixIcon: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 12.w),
                          child: SvgPicture.asset(
                            'assets/images/phone.svg',
                            height: 24.h,
                            width: 24.w,
                          ),
                        ),
                        validator: Validators.phone,
                      ),
                      SizedBox(height: 16.h),

                      // Password
                      CustomTextField(
                        controller: _passwordController,
                        label: 'password'.tr(),
                        hint: 'password_min_hint'.tr(),
                        isPassword: true,
                        obscureText: _obscurePassword,
                        onToggleVisibility: () => setState(
                          () => _obscurePassword = !_obscurePassword,
                        ),
                        prefixIcon: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 12.w),
                          child: SvgPicture.asset(
                            'assets/images/lock.svg',
                            height: 24.h,
                            width: 24.w,
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter your password';
                          }
                          if (value.length < 6) {
                            return 'Password must be at least 6 characters';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 16.h),

                      // Confirm Password
                      CustomTextField(
                        controller: _confirmPasswordController,
                        label: 'confirm_password'.tr(),
                        hint: 'password_min_hint'.tr(),
                        isPassword: true,
                        obscureText: _obscureConfirmPassword,
                        onToggleVisibility: () => setState(
                          () => _obscureConfirmPassword =
                              !_obscureConfirmPassword,
                        ),
                        prefixIcon: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 12.w),
                          child: SvgPicture.asset(
                            'assets/images/lock.svg',
                            height: 24.h,
                            width: 24.w,
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please confirm your password';
                          }
                          if (value != _passwordController.text) {
                            return 'Passwords do not match';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 12.h),

                      // Terms & Privacy
                      Text.rich(
                        TextSpan(
                          children: [
                            TextSpan(
                              text: 'terms_agree'.tr(),
                              style: TextStyle(
                                color: const Color(0xFF28293D),
                                fontSize: 10.sp,
                                fontFamily: 'Montserrat',
                                fontWeight: FontWeight.w400,
                                letterSpacing: 0.20,
                              ),
                            ),
                            TextSpan(
                              text: 'terms_of_use'.tr(),
                              style: TextStyle(
                                color: const Color(0xFF28293D),
                                fontSize: 10.sp,
                                fontFamily: 'Montserrat',
                                fontWeight: FontWeight.w700,
                                decoration: TextDecoration.underline,
                                letterSpacing: 0.20,
                              ),
                            ),
                            TextSpan(
                              text: 'and'.tr(),
                              style: TextStyle(
                                color: const Color(0xFF28293D),
                                fontSize: 10.sp,
                                fontFamily: 'Montserrat',
                                fontWeight: FontWeight.w400,
                                letterSpacing: 0.20,
                              ),
                            ),
                            TextSpan(
                              text: 'privacy_policy'.tr(),
                              style: TextStyle(
                                color: const Color(0xFF28293D),
                                fontSize: 10.sp,
                                fontFamily: 'Montserrat',
                                fontWeight: FontWeight.w700,
                                decoration: TextDecoration.underline,
                                letterSpacing: 0.20,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 32.h),

                      // Create Account Button with inline error
                      BlocConsumer<Registpatrialoc, RegisterState>(
                        listener: (context, state) {
                          if (state is RegisterSuccess) {
                            final phone = _phoneController.text.trim();

                            final rootNavigator = Navigator.of(
                              context,
                              rootNavigator: true,
                            );

                            AuthApi()
                                .sendVerification(phone)
                                .then((_) {
                                  rootNavigator.pop();
                                  showModalBottomSheet(
                                    context: rootNavigator.context,
                                    isScrollControlled: true,
                                    backgroundColor: Colors.transparent,
                                    useRootNavigator: true,
                                    builder: (_) => OtpVerificationBottomSheet(
                                      phoneNumber: phone,
                                    ),
                                  );
                                })
                                .catchError((e) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        e.toString(),
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
                                });
                          }
                        },
                        builder: (context, state) {
                          String? errorMessage;
                          if (state is RegisterFailure) {
                            errorMessage = state.error;
                          }

                          return Column(
                            children: [
                              if (errorMessage != null)
                                Container(
                                  margin: EdgeInsets.only(bottom: 16.h),
                                  padding: EdgeInsets.symmetric(
                                    vertical: 12.h,
                                    horizontal: 16.w,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.red.shade50,
                                    borderRadius: BorderRadius.circular(8.r),
                                    border: Border.all(
                                      color: Colors.red.shade200,
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.error_outline,
                                        color: Colors.red.shade700,
                                        size: 20.sp,
                                      ),
                                      SizedBox(width: 8.w),
                                      Expanded(
                                        child: Text(
                                          errorMessage,
                                          style: TextStyle(
                                            color: Colors.red.shade700,
                                            fontSize: 14.sp,
                                            fontFamily: 'Montserrat',
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ElevatedButton(
                                onPressed: state is RegisterLoading
                                    ? null
                                    : () {
                                        if (!_formKey.currentState!
                                            .validate()) {
                                          return;
                                        }
                                        context.read<Registpatrialoc>().add(
                                          RegisterSubmitted(
                                            name: _nameController.text.trim(),
                                            email: _emailController.text.trim(),
                                            password: _passwordController.text
                                                .trim(),
                                            phone: _phoneController.text.trim(),
                                            role: 'user',
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
                                child: state is RegisterLoading
                                    ? const CircularProgressIndicator(
                                        color: Colors.white,
                                      )
                                    : Text(
                                        'create_account'.tr(),
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 16.sp,
                                          fontFamily: 'Montserrat',
                                          fontWeight: FontWeight.w600,
                                          height: 1.50,
                                        ),
                                      ),
                              ),
                            ],
                          );
                        },
                      ),
                      SizedBox(height: 12.h),

                      // Already have an account
                      Center(
                        child: Text.rich(
                          TextSpan(
                            children: [
                              TextSpan(
                                text: 'have_account'.tr(),
                                style: TextStyle(
                                  color: const Color(0xFF3C4119),
                                  fontSize: 16.sp,
                                  fontFamily: 'Montserrat',
                                  fontWeight: FontWeight.w400,
                                  height: 1.40,
                                  letterSpacing: 0.32,
                                ),
                              ),
                              TextSpan(
                                text: ' ${'sign_in'.tr()}',
                                recognizer: TapGestureRecognizer()
                                  ..onTap = () {
                                    Navigator.pop(context);
                                    showModalBottomSheet(
                                      context: context,
                                      isScrollControlled: true,
                                      backgroundColor: Colors.transparent,
                                      builder: (context) =>
                                          const SignInBottomSheet(),
                                    );
                                  },
                                style: TextStyle(
                                  color: const Color(0xFF3C4119),
                                  fontSize: 16.sp,
                                  fontFamily: 'Montserrat',
                                  fontWeight: FontWeight.w600,
                                  height: 1.40,
                                  letterSpacing: 0.32,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: 8.h),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
