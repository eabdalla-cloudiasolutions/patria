import 'package:easy_localization/easy_localization.dart';
import 'package:erb/core/routing/routes.dart';
import 'package:erb/core/services/notification_service.dart';
import 'package:erb/features/auth/data/repos/auth_repo.dart';
import 'package:erb/features/auth/presentation/manager/login_bloc.dart';
import 'package:erb/features/auth/presentation/manager/login_event.dart';
import 'package:erb/features/auth/presentation/manager/login_state.dart';
import 'package:erb/features/auth/presentation/views/widgets/custom_text_field.dart';
import 'package:erb/features/auth/presentation/views/widgets/forgot_password_bottom_sheet.dart';
import 'package:erb/features/auth/presentation/views/widgets/signUp_bottom_sheet.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';

class SignInBottomSheet extends StatefulWidget {
  const SignInBottomSheet({super.key});

  @override
  State<SignInBottomSheet> createState() => _SignInBottomSheetState();
}

class _SignInBottomSheetState extends State<SignInBottomSheet> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLoginSuccess() async {
    NotificationSettings settings =
        await FirebaseMessaging.instance.requestPermission();
    if (settings.authorizationStatus != AuthorizationStatus.authorized) {
      return;
    }
    String? token = await FirebaseMessaging.instance.getToken();
    print("FCCCM$token");

    if (token != null) {
      print(token);
      await NotificationService().registerToken(token);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => LoginBloc(AuthRepo()),
      child: Builder(builder: (context) {
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
                    'welcome_back'.tr(),
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
                    'sign_in_subtitle'.tr(),
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
                  ),
                  SizedBox(height: 16.h),
                  CustomTextField(
                    controller: _passwordController,
                    label: 'password'.tr(),
                    hint: 'password_hint'.tr(),
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
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                        showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          backgroundColor: Colors.transparent,
                          builder: (context) =>
                              const ForgotPasswordBottomSheet(),
                        );
                      },
                      child: Text(
                        'forgot_password'.tr(),
                        style: TextStyle(
                          color: const Color(0xFF6B5E4B),
                          fontSize: 12.sp,
                          fontFamily: 'Montserrat',
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.24,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 32.h),
                  BlocConsumer<LoginBloc, LoginState>(
                    listener: (context, state) {
                      if (state is LoginSuccess) {
                        _handleLoginSuccess();
                        Navigator.pushNamedAndRemoveUntil(
                          context,
                          Routes.baseLayer,
                          (route) => false,
                        );
                      }
                    },
                    builder: (context, state) {
                      String? errorMessage;
                      if (state is LoginFailure) {
                        errorMessage = state.error;
                      }
                      return Column(
                        children: [
                          if (errorMessage != null)
                            Container(
                              margin: EdgeInsets.only(bottom: 16.h),
                              padding: EdgeInsets.symmetric(
                                  vertical: 12.h, horizontal: 16.w),
                              decoration: BoxDecoration(
                                color: Colors.red.shade50,
                                borderRadius: BorderRadius.circular(8.r),
                                border: Border.all(color: Colors.red.shade200),
                              ),
                              child: Row(
                                children: [
                                  Icon(Icons.error_outline,
                                      color: Colors.red.shade700, size: 20.sp),
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
                            onPressed: state is LoginLoading
                                ? null
                                : () {
                                    context.read<LoginBloc>().add(
                                          LoginSubmitted(
                                            email: _emailController.text.trim(),
                                            password:
                                                _passwordController.text.trim(),
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
                                borderRadius: BorderRadius.circular(5.r),
                              ),
                            ),
                            child: state is LoginLoading
                                ? const CircularProgressIndicator(
                                    color: Colors.white,
                                  )
                                : Text(
                                    'sign_in'.tr(),
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
                  Center(
                    child: Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(
                            text: 'no_account'.tr(),
                            style: TextStyle(
                              color: const Color(0xFF6B5E4B),
                              fontSize: 16.sp,
                              fontFamily: 'Montserrat',
                              fontWeight: FontWeight.w400,
                              height: 1.40,
                              letterSpacing: 0.32,
                            ),
                          ),
                          TextSpan(
                            text: ' ${'sign_up'.tr()}',
                            recognizer: TapGestureRecognizer()
                              ..onTap = () {
                                Navigator.pop(context);
                                showModalBottomSheet(
                                  context: context,
                                  isScrollControlled: true,
                                  backgroundColor: Colors.transparent,
                                  builder: (context) =>
                                      const SignUpBottomSheet(),
                                );
                              },
                            style: TextStyle(
                              color: const Color(0xFF6B5E4B),
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
        );
      }),
    );
  }
}
