import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:patria/core/routing/routes.dart';
import 'package:patria/features/auth/data/services/oauth_service.dart';
import 'package:patria/features/auth/presentation/views/widgets/signIn_bottom_sheet.dart';
import 'package:patria/features/auth/presentation/views/widgets/signUp_bottom_sheet.dart';
import 'package:patria/features/auth/presentation/views/widgets/social_button.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  bool _isGoogleLoading = false;
  bool _isAppleLoading = false;
  bool _isFacebookLoading = false;

  Future<void> _handleGoogleSignIn(BuildContext context) async {
    setState(() => _isGoogleLoading = true);
    try {
      final result = await OAuthService().signInWithGoogle();
      if (result == null || !context.mounted) return;
      if (!context.mounted) return;
      Navigator.of(
        context,
        rootNavigator: true,
      ).pushNamedAndRemoveUntil(Routes.baseLayer, (_) => false);
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'google_sign_in_failed'.tr(namedArgs: {'error': e.toString()}),
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
          backgroundColor: const Color(0xFFC90000),
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating, // ✅ removes safe area space
          padding: EdgeInsets.symmetric(
            horizontal: 16.w,
            vertical: 16.h, // ✅ reduce height
          ),
        ),
      );
    } finally {
      if (mounted) setState(() => _isGoogleLoading = false);
    }
  }

  Future<void> _handleAppleSignIn(BuildContext context) async {
    setState(() => _isAppleLoading = true);
    try {
      final result = await OAuthService().signInWithApple();
      if (result == null || !context.mounted) return;
      Navigator.of(
        context,
        rootNavigator: true,
      ).pushNamedAndRemoveUntil(Routes.baseLayer, (_) => false);
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'apple_sign_in_failed'.tr(namedArgs: {'error': e.toString()}),
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
          backgroundColor: const Color(0xFFC90000),
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating, // ✅ removes safe area space
          padding: EdgeInsets.symmetric(
            horizontal: 16.w,
            vertical: 16.h, // ✅ reduce height
          ),
        ),
      );
    } finally {
      if (mounted) setState(() => _isAppleLoading = false);
    }
  }

  Future<void> _handleFacebookSignIn(BuildContext context) async {
    setState(() => _isFacebookLoading = true);
    try {
      final result = await OAuthService().signInWithFacebook();
      if (result == null || !context.mounted) return;
      Navigator.of(
        context,
        rootNavigator: true,
      ).pushNamedAndRemoveUntil(Routes.baseLayer, (_) => false);
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'facebook_sign_in_failed'.tr(namedArgs: {'error': e.toString()}),
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
          backgroundColor: const Color(0xFFC90000),
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating, // ✅ removes safe area space
          padding: EdgeInsets.symmetric(
            horizontal: 16.w,
            vertical: 16.h, // ✅ reduce height
          ),
        ),
      );
    } finally {
      if (mounted) setState(() => _isFacebookLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment(0.50, -0.00),
            end: Alignment(0.50, 1.00),
            colors: [Colors.white, Color(0xFFE5E8D3)],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Padding(
                        padding: EdgeInsets.only(top: 80.h),
                        child: SizedBox(
                          width: 150.w,
                          height: 185.h,
                          child: Image.asset(
                            "assets/images/patria_icon.png",
                            fit: BoxFit.contain,
                          ),
                        ),
                      )
                      .animate()
                      .fadeIn(delay: 0.ms, duration: 600.ms)
                      .slideY(
                        begin: 0.3,
                        end: 0,
                        delay: 0.ms,
                        duration: 600.ms,
                        curve: Curves.easeOutCubic,
                      ),
                  SizedBox(height: 30.h),
                  Text(
                        'splash_title'.tr(),
                        maxLines: 2,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: const Color(0xFF3C4119),
                          fontSize: 24.sp,
                          fontFamily: 'Montserrat',
                          fontWeight: FontWeight.w800,
                          height: 1.07,
                          letterSpacing: 0.48,
                        ),
                      )
                      .animate()
                      .fadeIn(delay: 200.ms, duration: 600.ms)
                      .slideY(
                        begin: 0.3,
                        end: 0,
                        delay: 200.ms,
                        duration: 600.ms,
                        curve: Curves.easeOutCubic,
                      ),
                  SizedBox(height: 6.h),
                  Text(
                        'splash_subtitle'.tr(),
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: const Color(0xFF515151),
                          fontSize: 14.sp,
                          fontFamily: 'Montserrat',
                          fontWeight: FontWeight.w400,
                          height: 1.40,
                          letterSpacing: 0.28,
                        ),
                      )
                      .animate()
                      .fadeIn(delay: 400.ms, duration: 600.ms)
                      .slideY(
                        begin: 0.3,
                        end: 0,
                        delay: 400.ms,
                        duration: 600.ms,
                        curve: Curves.easeOutCubic,
                      ),
                  SizedBox(height: 24.h),
                  ElevatedButton(
                        onPressed: () {
                          showModalBottomSheet(
                            context: context,
                            isScrollControlled: true,
                            backgroundColor: Colors.transparent,
                            builder: (context) => const SignUpBottomSheet(),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF3C4119),
                          minimumSize: const Size(double.infinity, 56),
                          padding: EdgeInsets.symmetric(
                            horizontal: 30.w,
                            vertical: 16.h,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5.r),
                          ),
                        ),
                        child: Text(
                          'create_account'.tr(),
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16.sp,
                            fontFamily: 'Montserrat',
                            fontWeight: FontWeight.w600,
                            height: 1.50,
                          ),
                        ),
                      )
                      .animate()
                      .fadeIn(delay: 600.ms, duration: 600.ms)
                      .slideY(
                        begin: 0.3,
                        end: 0,
                        delay: 600.ms,
                        duration: 600.ms,
                        curve: Curves.easeOutCubic,
                      ),
                  SizedBox(height: 12.h),
                  OutlinedButton(
                        onPressed: () {
                          showModalBottomSheet(
                            context: context,
                            isScrollControlled: true,
                            backgroundColor: Colors.transparent,
                            builder: (context) => const SignInBottomSheet(),
                          );
                        },
                        style: OutlinedButton.styleFrom(
                          minimumSize: const Size(double.infinity, 56),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 30,
                            vertical: 16,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5),
                          ),
                          side: const BorderSide(
                            width: 1,
                            color: Color(0xFF3C4119),
                          ),
                        ),
                        child: Text(
                          'sign_in'.tr(),
                          style: const TextStyle(
                            color: Color(0xFF3C4119),
                            fontSize: 16,
                            fontFamily: 'Montserrat',
                            fontWeight: FontWeight.w600,
                            height: 1.50,
                          ),
                        ),
                      )
                      .animate()
                      .fadeIn(delay: 800.ms, duration: 600.ms)
                      .slideY(
                        begin: 0.3,
                        end: 0,
                        delay: 800.ms,
                        duration: 600.ms,
                        curve: Curves.easeOutCubic,
                      ),
                  SizedBox(height: 32.h),
                  Row(
                        children: [
                          const Expanded(
                            child: Divider(
                              color: Color(0xFF3C4119),
                              thickness: 1,
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 12.w),
                            child: Text(
                              'or_continue_with'.tr(),
                              style: TextStyle(
                                color: const Color(0xFF3C4119),
                                fontSize: 14.sp,
                                fontFamily: 'Montserrat',
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          const Expanded(
                            child: Divider(
                              color: Color(0xFF3C4119),
                              thickness: 1,
                            ),
                          ),
                        ],
                      )
                      .animate()
                      .fadeIn(delay: 1000.ms, duration: 600.ms)
                      .slideY(
                        begin: 0.3,
                        end: 0,
                        delay: 1000.ms,
                        duration: 600.ms,
                        curve: Curves.easeOutCubic,
                      ),
                  SizedBox(height: 24.h),
                  SocialButton(
                        label: 'sign_up_google'.tr(),
                        iconPath: 'assets/images/google_icon.svg',
                        isLoading: _isGoogleLoading,
                        onPressed: _isGoogleLoading
                            ? null
                            : () => _handleGoogleSignIn(context),
                      )
                      .animate()
                      .fadeIn(delay: 1200.ms, duration: 600.ms)
                      .slideY(
                        begin: 0.3,
                        end: 0,
                        delay: 1200.ms,
                        duration: 600.ms,
                        curve: Curves.easeOutCubic,
                      ),
                  SizedBox(height: 16.h),
                  // SocialButton(
                  //   label: 'sign_up_facebook'.tr(),
                  //   iconPath: 'assets/images/facebook_icon.svg',
                  //   isLoading: _isFacebookLoading,
                  //   onPressed: _isFacebookLoading
                  //       ? null
                  //       : () => _handleFacebookSignIn(context),
                  // ).animate().fadeIn(delay: 1400.ms, duration: 600.ms).slideY(
                  //     begin: 0.3,
                  //     end: 0,
                  //     delay: 1400.ms,
                  //     duration: 600.ms,
                  //     curve: Curves.easeOutCubic),
                  // SizedBox(height: 16.h),
                  SocialButton(
                        label: 'sign_up_apple'.tr(),
                        iconPath: 'assets/images/apple_icon.svg',
                        isLoading: _isAppleLoading,
                        onPressed: _isAppleLoading
                            ? null
                            : () => _handleAppleSignIn(context),
                      )
                      .animate()
                      .fadeIn(delay: 1600.ms, duration: 600.ms)
                      .slideY(
                        begin: 0.3,
                        end: 0,
                        delay: 1600.ms,
                        duration: 600.ms,
                        curve: Curves.easeOutCubic,
                      ),
                  SizedBox(height: 16.h),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
