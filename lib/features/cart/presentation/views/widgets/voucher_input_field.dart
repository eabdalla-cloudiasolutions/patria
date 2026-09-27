import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:patria/core/utils/emoji_input_formatter.dart';

class VoucherInputField extends StatefulWidget {
  final Function(String voucherCode) onApplyVoucher;
  final bool isLoading;
  final String? initialCode;
  final String? iconImagePath; // custom image (SVG)
  final IconData? iconData; // fallback icon

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
    final Color accentColor = const Color(0xFF3C4119);
    final Color hintColor = _isFocused
        ? accentColor.withOpacity(0.7)
        : const Color(0xFF595959);
    final Color iconColor = _isFocused
        ? accentColor
        : const Color(0xFF3C4119); // icon always has some colour

    // Build icon widget with optional tinting for SVG
    Widget? iconWidget;
    if (widget.iconImagePath != null) {
      iconWidget = _isFocused
          ? ColorFiltered(
              colorFilter: ColorFilter.mode(accentColor, BlendMode.srcIn),
              child: SvgPicture.asset(
                widget.iconImagePath!,
                width: 24.w,
                height: 24.h,
                fit: BoxFit.contain,
              ),
            )
          : SvgPicture.asset(
              widget.iconImagePath!,
              width: 24.w,
              height: 24.h,
              fit: BoxFit.contain,
            );
    } else {
      iconWidget = Icon(
        widget.iconData ?? Icons.local_offer_outlined,
        size: 16.sp,
        color: iconColor,
      );
    }

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 12.h),
      decoration: ShapeDecoration(
        color: Colors.white,
        shape: RoundedRectangleBorder(
          side: BorderSide(
            width: 1.w,
            color: _isFocused ? accentColor : const Color(0xFFE5E5E5),
          ),
          borderRadius: BorderRadius.circular(12.r),
        ),
      ),
      child: Row(
        children: [
          // Icon
          iconWidget,
          SizedBox(width: 12.w),

          // TextField
          Expanded(
            child: TextField(
              controller: _controller,
              focusNode: _focusNode,
              enabled: !widget.isLoading,
              textInputAction: TextInputAction.done,
              inputFormatters: [EmojiInputFormatter()],
              onSubmitted: (_) => _submitVoucher(),
              style: TextStyle(
                color: const Color(0xFF1D1E20),
                fontSize: 14.sp,
                fontFamily: 'Montserrat',
                fontWeight: FontWeight.w500,
                letterSpacing: 0.28,
              ),
              decoration: InputDecoration(
                hintText: 'enter_voucher_code'.tr(),
                hintStyle: TextStyle(
                  color: hintColor,
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

          // Submit button
          GestureDetector(
            onTap: widget.isLoading ? null : _submitVoucher,
            child: widget.isLoading
                ? SizedBox(
                    width: 16.w,
                    height: 16.h,
                    child: const CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Color(0xFF3C4119),
                      ),
                    ),
                  )
                : Text(
                    'submit'.tr(),
                    style: TextStyle(
                      color: accentColor,
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
          content: Text(
            'enter_voucher_hint'.tr(),
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
      return;
    }
    widget.onApplyVoucher(voucherCode);
  }
}
