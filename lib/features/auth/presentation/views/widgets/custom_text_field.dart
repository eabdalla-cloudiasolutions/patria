import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CustomTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final Widget? prefixIcon;
  final bool isPassword;
  final bool obscureText;
  final VoidCallback? onToggleVisibility;
  final TextInputType keyboardType;
  final String? Function(String?)? validator; // ✅ add this

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
    this.validator, // ✅ add this
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.black,
            fontSize: 12.sp,
            fontFamily: 'Montserrat',
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: 10.h),
        TextFormField(
          // ✅ changed from TextField to TextFormField
          controller: controller,
          keyboardType: keyboardType,
          obscureText: obscureText,
          validator: validator, // ✅ add this
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
            suffixIcon: isPassword
                ? IconButton(
                    icon: Icon(
                      obscureText
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                      color: const Color(0xFF8B8B8B),
                      size: 24,
                    ),
                    onPressed: onToggleVisibility,
                  )
                : null,
            contentPadding:
                EdgeInsets.symmetric(horizontal: 18.w, vertical: 12.h),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide(
                width: 1.w,
                color: Color(0xFFE5E5E5),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide(
                width: 1.w,
                color: Color(0xFFE5E5E5),
              ),
            ),
            errorBorder: OutlineInputBorder(
              // ✅ red border on error
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide(
                width: 1.w,
                color: Colors.red,
              ),
            ),
            focusedErrorBorder: OutlineInputBorder(
              // ✅ red border on error focused
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide(
                width: 1.w,
                color: Colors.red,
              ),
            ),
            filled: true,
            fillColor: Colors.white,
          ),
        ),
      ],
    );
  }
}
