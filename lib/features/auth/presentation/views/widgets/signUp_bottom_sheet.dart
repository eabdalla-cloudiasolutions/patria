import 'package:easy_localization/easy_localization.dart';
import 'package:erb/features/auth/data/apis/auth_api.dart';
import 'package:erb/features/auth/data/repos/auth_repo.dart';
import 'package:erb/features/auth/presentation/manager/register_bloc.dart';
import 'package:erb/features/auth/presentation/manager/register_event.dart';
import 'package:erb/features/auth/presentation/manager/register_state.dart';
import 'package:erb/features/auth/presentation/views/widgets/otp_verification_bottom_sheet.dart';
import 'package:erb/features/auth/presentation/views/widgets/signIn_bottom_sheet.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';

class SignUpBottomSheet extends StatefulWidget {
  const SignUpBottomSheet({super.key});

  @override
  State<SignUpBottomSheet> createState() => _SignUpBottomSheetState();
}

class _SignUpBottomSheetState extends State<SignUpBottomSheet> {
  final _formKey = GlobalKey<FormState>(); // ✅
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
      create: (_) => RegisterBloc(AuthRepo()),
      child: Builder(builder: (context) {
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
              child: Form(
                // ✅ wrap with Form
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
                        color: Color(0xFF515151),
                        fontSize: 16.sp,
                        fontFamily: 'Montserrat',
                        fontWeight: FontWeight.w400,
                        height: 1.40,
                        letterSpacing: 0.32,
                      ),
                    ),
                    SizedBox(height: 24.h),

                    // Full Name
                    _buildLabel('full_name'.tr()),
                    SizedBox(height: 10.h),
                    _buildTextField(
                      controller: _nameController,
                      hint: 'full_name_hint'.tr(),
                      prefixIcon: const Icon(Icons.person_outline,
                          color: Color(0xFF8B8B8B), size: 24),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter your full name';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 16.h),

                    // Email
                    _buildLabel('email'.tr()),
                    SizedBox(height: 10.h),
                    _buildTextField(
                      controller: _emailController,
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
                        if (!RegExp(r'^[\w-.]+@([\w-]+\.)+[\w-]{2,4}$')
                            .hasMatch(value)) {
                          return 'Please enter a valid email';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 16.h),

                    // Phone
                    _buildLabel('phone_number'.tr()),
                    SizedBox(height: 10.h),
                    _buildTextField(
                      controller: _phoneController,
                      hint: 'phone_hint'.tr(),
                      keyboardType: TextInputType.phone,
                      prefixIcon: const Icon(Icons.phone_outlined,
                          color: Color(0xFF8B8B8B), size: 24),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter your phone number';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 16.h),

                    // Password
                    _buildLabel('password'.tr()),
                    SizedBox(height: 10.h),
                    _buildPasswordField(
                      controller: _passwordController,
                      hint: 'password_min_hint'.tr(),
                      obscure: _obscurePassword,
                      onToggle: () =>
                          setState(() => _obscurePassword = !_obscurePassword),
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
                    _buildLabel('confirm_password'.tr()),
                    SizedBox(height: 10.h),
                    _buildPasswordField(
                      controller: _confirmPasswordController,
                      hint: 'password_min_hint'.tr(),
                      obscure: _obscureConfirmPassword,
                      onToggle: () => setState(() =>
                          _obscureConfirmPassword = !_obscureConfirmPassword),
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
                              color: Color(0xFF28293D),
                              fontSize: 10.sp,
                              fontFamily: 'Montserrat',
                              fontWeight: FontWeight.w400,
                              letterSpacing: 0.20,
                            ),
                          ),
                          TextSpan(
                            text: 'terms_of_use'.tr(),
                            style: TextStyle(
                              color: Color(0xFF28293D),
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
                              color: Color(0xFF28293D),
                              fontSize: 10.sp,
                              fontFamily: 'Montserrat',
                              fontWeight: FontWeight.w400,
                              letterSpacing: 0.20,
                            ),
                          ),
                          TextSpan(
                            text: 'privacy_policy'.tr(),
                            style: TextStyle(
                              color: Color(0xFF28293D),
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

                    // Create Account Button
                    BlocConsumer<RegisterBloc, RegisterState>(
                      listener: (context, state) {
                        if (state is RegisterSuccess) {
                          final phone = _phoneController.text.trim();

                          // ✅ Capture root navigator BEFORE anything happens
                          final rootNavigator =
                              Navigator.of(context, rootNavigator: true);

                          AuthApi().sendVerification(phone).then((_) {
                            rootNavigator.pop(); // ✅ close sign up sheet
                            showModalBottomSheet(
                              context:
                                  rootNavigator.context, // ✅ use root context
                              isScrollControlled: true,
                              backgroundColor: Colors.transparent,
                              useRootNavigator: true,
                              builder: (_) => OtpVerificationBottomSheet(
                                phoneNumber: phone,
                              ),
                            );
                          }).catchError((e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(e.toString()),
                                backgroundColor: Colors.red,
                              ),
                            );
                          });
                        }
                        if (state is RegisterFailure) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(state.error),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      },
                      builder: (context, state) {
                        return ElevatedButton(
                          onPressed: state is RegisterLoading
                              ? null
                              : () {
                                  // ✅ Validate before calling API
                                  if (!_formKey.currentState!.validate()) {
                                    return;
                                  }
                                  context.read<RegisterBloc>().add(
                                        RegisterSubmitted(
                                          name: _nameController.text.trim(),
                                          email: _emailController.text.trim(),
                                          password:
                                              _passwordController.text.trim(),
                                          phone: _phoneController.text.trim(),
                                          role: 'user',
                                        ),
                                      );
                                },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF6B5E4B),
                            minimumSize: Size(double.infinity, 56.h),
                            padding: EdgeInsets.symmetric(
                                horizontal: 30.w, vertical: 16.h),
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(5),
                            ),
                          ),
                          child: state is RegisterLoading
                              ? const CircularProgressIndicator(
                                  color: Colors.white)
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
                                color: Color(0xFF6B5E4B),
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
                                color: Color(0xFF6B5E4B),
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
      }),
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: TextStyle(
        color: Colors.black,
        fontSize: 12.sp,
        fontFamily: 'Montserrat',
        fontWeight: FontWeight.w500,
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required Widget prefixIcon,
    TextInputType keyboardType = TextInputType.text,
    required String? Function(String?) validator, // ✅
  }) {
    return TextFormField(
      // ✅
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      style: TextStyle(
        color: Color(0xFF8B8B8B),
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
        prefixIcon: prefixIcon,
        contentPadding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 12.h),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide(width: 1.w, color: Color(0xFFE5E5E5)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide(width: 1.w, color: Color(0xFF6B5E4B)),
        ),
        errorBorder: OutlineInputBorder(
          // ✅
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide(width: 1.w, color: Colors.red),
        ),
        focusedErrorBorder: OutlineInputBorder(
          // ✅
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide(width: 1.w, color: Colors.red),
        ),
        filled: true,
        fillColor: Colors.white,
      ),
    );
  }

  Widget _buildPasswordField({
    required TextEditingController controller,
    required String hint,
    required bool obscure,
    required VoidCallback onToggle,
    required String? Function(String?) validator, // ✅
  }) {
    return TextFormField(
      // ✅
      controller: controller,
      obscureText: obscure,
      validator: validator,
      style: TextStyle(
        color: Color(0xFF8B8B8B),
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
        prefixIcon:
            const Icon(Icons.lock_outline, color: Color(0xFF8B8B8B), size: 24),
        suffixIcon: IconButton(
          icon: Icon(
            obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined,
            color: const Color(0xFF8B8B8B),
            size: 24,
          ),
          onPressed: onToggle,
        ),
        contentPadding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 12.h),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide(width: 1.w, color: Color(0xFFE5E5E5)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide(width: 1.w, color: Color(0xFF6B5E4B)),
        ),
        errorBorder: OutlineInputBorder(
          // ✅
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide(width: 1.w, color: Colors.red),
        ),
        focusedErrorBorder: OutlineInputBorder(
          // ✅
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide(width: 1.w, color: Colors.red),
        ),
        filled: true,
        fillColor: Colors.white,
      ),
    );
  }
}
