import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:patria/core/utils/emoji_input_formatter.dart';
import 'package:patria/features/auth/data/apis/auth_api.dart';
import 'package:patria/features/auth/presentation/views/widgets/signIn_bottom_sheet.dart';

class OtpVerificationBottomSheet extends StatefulWidget {
  final String phoneNumber;
  const OtpVerificationBottomSheet({
    super.key,
    this.phoneNumber = '+20 xxx xxx xxxx',
  });

  @override
  State<OtpVerificationBottomSheet> createState() =>
      _OtpVerificationBottomSheetState();
}

class _OtpVerificationBottomSheetState
    extends State<OtpVerificationBottomSheet> {
  final List<TextEditingController> _controllers = List.generate(
    4,
    (_) => TextEditingController(),
  );
  final List<FocusNode> _focusNodes = List.generate(4, (_) => FocusNode());

  int _secondsRemaining = 119;
  Timer? _timer;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining == 0) {
        timer.cancel();
      } else {
        setState(() => _secondsRemaining--);
      }
    });
  }

  void _resendCode() {
    if (_secondsRemaining == 0) {
      AuthApi()
          .sendVerification(widget.phoneNumber)
          .then((_) {
            setState(() {
              _secondsRemaining = 119;
              _errorMessage = null;
            });
            _startTimer();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'otp_resent_successfully'.tr(),
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                backgroundColor: const Color(0xFF3C4119),
                duration: const Duration(seconds: 2),
                behavior:
                    SnackBarBehavior.floating, // ✅ removes safe area space

                padding: EdgeInsets.symmetric(
                  horizontal: 16.w,
                  vertical: 16.h, // ✅ reduce height
                ),
              ),
            );
          })
          .catchError((e) {
            setState(() => _errorMessage = 'Failed to resend code. Try again.');
          });
    }
  }

  Future<void> _verifyOtp() async {
    final otp = _controllers.map((c) => c.text).join();

    if (otp.length < 4) {
      setState(() => _errorMessage = 'Please enter the complete code');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await AuthApi().verifyOtp(widget.phoneNumber, otp);
      if (!mounted) return;

      final navigator = Navigator.of(context);
      navigator.pop();
      showModalBottomSheet(
        context: navigator.context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        useRootNavigator: true,
        builder: (_) => const SignInBottomSheet(),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = 'Invalid verification code';
      });
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  String get _timerText {
    final minutes = _secondsRemaining ~/ 60;
    final seconds = _secondsRemaining % 60;
    return '${minutes.toString().padLeft(1, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  void dispose() {
    for (var c in _controllers) {
      c.dispose();
    }
    for (var f in _focusNodes) {
      f.dispose();
    }
    _timer?.cancel();
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
                child: Image.asset('assets/images/phone 1.png'),
              ),
              SizedBox(height: 32.h),
              Text(
                'otp_title'.tr(),
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
              Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: 'otp_subtitle'.tr(),
                      style: TextStyle(
                        color: Color(0xFF515151),
                        fontSize: 16.sp,
                        fontFamily: 'Montserrat',
                        fontWeight: FontWeight.w400,
                        height: 1.40,
                        letterSpacing: 0.32,
                      ),
                    ),
                    TextSpan(
                      text: widget.phoneNumber,
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 16.sp,
                        fontFamily: 'Montserrat',
                        fontWeight: FontWeight.w400,
                        height: 1.40,
                        letterSpacing: 0.32,
                      ),
                    ),
                  ],
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 32.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  4,
                  (index) => _OtpField(
                    controller: _controllers[index],
                    focusNode: _focusNodes[index],
                    autofocus: index == 0,
                    onChanged: (value) {
                      if (_errorMessage != null) {
                        setState(() => _errorMessage = null);
                      }
                      if (value.isNotEmpty && index < 3) {
                        _focusNodes[index + 1].requestFocus();
                      } else if (value.isEmpty && index > 0) {
                        _focusNodes[index - 1].requestFocus();
                      }
                    },
                  ),
                ),
              ),
              SizedBox(height: 12.h),
              GestureDetector(
                onTap: _secondsRemaining == 0 ? _resendCode : null,
                child: Text(
                  _secondsRemaining > 0
                      ? '${'resend_code'.tr()} $_timerText'
                      : 'resend_code'.tr(),
                  style: TextStyle(
                    color: _secondsRemaining > 0
                        ? const Color(0xFF8B8B8B)
                        : const Color(0xFF3C4119),
                    fontSize: 12.sp,
                    fontFamily: 'Montserrat',
                    fontWeight: FontWeight.w600,
                    height: 1.40,
                    letterSpacing: 0.24,
                  ),
                ),
              ),
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
              ElevatedButton(
                onPressed: _isLoading ? null : _verifyOtp,
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
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Text(
                        'verify'.tr(),
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

// ========== Focus‑aware OTP Field ==========
class _OtpField extends StatefulWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final bool autofocus;
  final Function(String) onChanged;

  const _OtpField({
    required this.controller,
    required this.focusNode,
    this.autofocus = false,
    required this.onChanged,
  });

  @override
  State<_OtpField> createState() => _OtpFieldState();
}

class _OtpFieldState extends State<_OtpField> {
  late final FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _focusNode = widget.focusNode;
    _focusNode.addListener(() => setState(() {}));
    if (widget.autofocus) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _focusNode.requestFocus();
      });
    }
  }

  @override
  void dispose() {
    // focus node is disposed by parent
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isFocused = _focusNode.hasFocus;
    final Color fillColor = isFocused ? Colors.white : const Color(0xFFE5E5E5);
    final Color borderColor = isFocused
        ? const Color(0xFF3C4119)
        : const Color(0xFFE5E5E5);
    final double borderWidth = 1.5.w;

    return Container(
      width: 65.w,
      height: 75.h,
      margin: EdgeInsets.symmetric(horizontal: 6.w),
      child: TextField(
        controller: widget.controller,
        focusNode: _focusNode,
        textAlign: TextAlign.center,
        keyboardType: TextInputType.number,
        maxLength: 1,
        inputFormatters: [EmojiInputFormatter()],
        style: TextStyle(
          fontSize: 24.sp,
          fontFamily: 'Montserrat',
          fontWeight: FontWeight.w600,
          color: Colors.black,
        ),
        decoration: InputDecoration(
          counterText: '',
          filled: true,
          fillColor: fillColor,
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.r),
            borderSide: BorderSide(width: borderWidth, color: borderColor),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.r),
            borderSide: const BorderSide(width: 1.5, color: Color(0xFF3C4119)),
          ),
        ),
        onChanged: widget.onChanged,
      ),
    );
  }
}
