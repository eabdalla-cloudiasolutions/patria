import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:patria/core/utils/emoji_input_formatter.dart';

class CustomTextField extends StatefulWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final Widget? prefixIcon;
  final bool isPassword;
  final bool obscureText;
  final VoidCallback? onToggleVisibility;
  final TextInputType keyboardType;
  final String? Function(String?)? validator;
  final Color focusColor;

  const CustomTextField({
    super.key,
    required this.controller,
    required this.label,
    required this.hint,
    this.prefixIcon,
    this.isPassword = false,
    this.obscureText = false,
    this.onToggleVisibility,
    this.keyboardType = TextInputType.text,
    this.validator,
    this.focusColor = const Color(0xFF3C4119),
  });

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  late final FocusNode _focusNode;

  bool get _hasText => widget.controller.text.isNotEmpty;

  void _listener() => setState(() {});

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    _focusNode.addListener(_listener);
    widget.controller.addListener(_listener);
  }

  @override
  void dispose() {
    _focusNode.removeListener(_listener);
    _focusNode.dispose();
    widget.controller.removeListener(_listener);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isFocused = _focusNode.hasFocus;
    final bool isActive = isFocused || _hasText;

    // ✅ Black when has text, accent when focused, grey when empty
    final Color iconColor = _hasText
        ? Colors.black
        : isFocused
        ? widget.focusColor
        : const Color(0xFF8B8B8B);

    final Color textColor = isActive ? Colors.black : const Color(0xFF8B8B8B);
    final Color hintColor = isFocused ? Colors.black : const Color(0xFF8B8B8B);
    final Color labelColor = isActive ? Colors.black : const Color(0xFF8B8B8B);
    final Color borderColor = _hasText
        ? widget.focusColor
        : const Color(0xFFE5E5E5);

    Widget? coloredPrefixIcon;
    if (widget.prefixIcon != null) {
      coloredPrefixIcon = ColorFiltered(
        colorFilter: ColorFilter.mode(iconColor, BlendMode.srcIn),
        child: widget.prefixIcon!,
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label,
          style: TextStyle(
            color: labelColor,
            fontSize: 12.sp,
            fontFamily: 'Montserrat',
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: 10.h),
        TextFormField(
          controller: widget.controller,
          focusNode: _focusNode,
          keyboardType: widget.keyboardType,
          obscureText: widget.obscureText,
          validator: widget.validator,
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
            prefixIcon: coloredPrefixIcon,
            suffixIcon: widget.isPassword
                ? IconButton(
                    icon: Icon(
                      widget.obscureText
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                      color: iconColor,
                      size: 24,
                    ),
                    onPressed: widget.onToggleVisibility,
                  )
                : null,
            contentPadding: EdgeInsets.symmetric(
              horizontal: 18.w,
              vertical: 12.h,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide(width: 1.w, color: borderColor),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide(width: 1.w, color: widget.focusColor),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide(width: 1.w, color: Colors.red),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide(width: 1.w, color: Colors.red),
            ),
            // Some validation messages (e.g. the phone format one) are long,
            // so let them wrap instead of being cut off after one line.
            errorMaxLines: 3,
            filled: true,
            fillColor: Colors.white,
          ),
        ),
      ],
    );
  }
}
