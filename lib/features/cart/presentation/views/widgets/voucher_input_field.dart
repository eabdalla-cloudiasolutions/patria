import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';

class VoucherInputField extends StatefulWidget {
  final Function(String voucherCode) onApplyVoucher;
  final bool isLoading;
  final String? initialCode;
  final String? iconImagePath; // Add this for custom image
  final IconData? iconData; // Keep as fallback

  const VoucherInputField({
    super.key,
    required this.onApplyVoucher,
    this.isLoading = false,
    this.initialCode,
    this.iconImagePath,
    this.iconData,
  });

  @override
  State<VoucherInputField> createState() => _VoucherInputFieldState();
}

class _VoucherInputFieldState extends State<VoucherInputField> {
  late final TextEditingController _controller;
  final FocusNode _focusNode = FocusNode();
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialCode);
    _focusNode.addListener(() {
      setState(() {
        _isFocused = _focusNode.hasFocus;
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 12.h),
      decoration: ShapeDecoration(
        color: Colors.white,
        shape: RoundedRectangleBorder(
          side: BorderSide(
            width: 1.w,
            color:
                _isFocused ? const Color(0xFF6B5E4B) : const Color(0xFFE5E5E5),
          ),
          borderRadius: BorderRadius.circular(12.r),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Icon Section with Image support
          widget.iconImagePath != null
              ? SvgPicture.asset(
                  widget.iconImagePath!,
                  width: 24.w,
                  height: 24.h,
                  fit: BoxFit.contain,
                )
              : Icon(
                  widget.iconData ?? Icons.local_offer_outlined,
                  size: 16.sp,
                  color: const Color(0xFF6B5E4B),
                ),
          SizedBox(width: 12.w),

          // TextField
          Expanded(
            child: TextField(
              controller: _controller,
              focusNode: _focusNode,
              enabled: !widget.isLoading,
              textInputAction: TextInputAction.done,
              onSubmitted: (_) => _submitVoucher(),
              style: TextStyle(
                color: const Color(0xFF1D1E20),
                fontSize: 14.sp,
                fontFamily: 'Montserrat',
                fontWeight: FontWeight.w500,
                letterSpacing: 0.28,
              ),
              decoration: InputDecoration(
                hintText: 'Enter voucher code',
                hintStyle: TextStyle(
                  color: const Color(0xFF595959),
                  fontSize: 14.sp,
                  fontFamily: 'Montserrat',
                  fontWeight: FontWeight.w400,
                  letterSpacing: 0.28,
                ),
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ),

          // Submit Button
          GestureDetector(
            onTap: widget.isLoading ? null : _submitVoucher,
            child: widget.isLoading
                ? SizedBox(
                    width: 16.w,
                    height: 16.h,
                    child: const CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor:
                          AlwaysStoppedAnimation<Color>(Color(0xFF6B5E4B)),
                    ),
                  )
                : Text(
                    'submit'.tr(),
                    style: TextStyle(
                      color: const Color(0xFF6B5E4B),
                      fontSize: 14.sp,
                      fontFamily: 'Montserrat',
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.32,
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  void _submitVoucher() {
    final voucherCode = _controller.text.trim();
    if (voucherCode.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('enter_voucher_hint'.tr()),
          backgroundColor: const Color(0xFFE53935),
          duration: const Duration(seconds: 2),
        ),
      );
      return;
    }
    widget.onApplyVoucher(voucherCode);
  }
}
