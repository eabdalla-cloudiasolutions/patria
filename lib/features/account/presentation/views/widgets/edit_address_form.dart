import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:patria/core/utils/emoji_input_formatter.dart';

class EditAddressForm extends StatelessWidget {
  final TextEditingController buildingController;
  final TextEditingController aptController;
  final TextEditingController floorController;
  final TextEditingController streetController;
  final TextEditingController nearbyController;
  final TextEditingController phoneController;
  final String? phoneErrorText;

  const EditAddressForm({
    super.key,
    required this.buildingController,
    required this.aptController,
    required this.floorController,
    required this.streetController,
    required this.nearbyController,
    required this.phoneController,
    this.phoneErrorText,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _StyledFormField(
          label: 'building_name'.tr(),
          hint: 'building_name_hint'.tr(),
          controller: buildingController,
        ),
        SizedBox(height: 16.h),
        Row(
          children: [
            Expanded(
              child: _StyledFormField(
                label: 'apt_no'.tr(),
                hint: 'apt_no_hint'.tr(),
                controller: aptController,
                keyboardType: TextInputType.number,
              ),
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: _StyledFormField(
                label: 'floor'.tr(),
                hint: 'floor_hint'.tr(),
                controller: floorController,
                keyboardType: TextInputType.number,
              ),
            ),
          ],
        ),
        SizedBox(height: 16.h),
        _StyledFormField(
          label: 'street_name'.tr(),
          hint: 'street_name_hint'.tr(),
          controller: streetController,
        ),
        SizedBox(height: 16.h),
        _StyledFormField(
          label: 'nearby_trademark'.tr(),
          hint: 'nearby_trademark_hint'.tr(),
          controller: nearbyController,
        ),
        SizedBox(height: 16.h),
        _StyledFormField(
          label: 'phone_number'.tr(),
          hint: 'phone_number'.tr(),
          controller: phoneController,
          keyboardType: TextInputType.phone,
          errorText: phoneErrorText,
        ),
      ],
    );
  }
}

// ========== Focus‑aware Styled Form Field ==========
class _StyledFormField extends StatefulWidget {
  final String label;
  final String hint;
  final TextEditingController controller;
  final TextInputType keyboardType;
  final String? errorText;

  const _StyledFormField({
    required this.label,
    required this.hint,
    required this.controller,
    this.keyboardType = TextInputType.text,
    this.errorText,
  });

  @override
  State<_StyledFormField> createState() => _StyledFormFieldState();
}

class _StyledFormFieldState extends State<_StyledFormField> {
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isFocused = _focusNode.hasFocus;
    final bool hasError = widget.errorText != null;
    final Color textColor = isFocused ? Colors.black : const Color(0xFF8B8B8B);
    final Color hintColor = isFocused
        ? const Color(0xFF3C4119).withOpacity(0.7)
        : const Color(0xFF8B8B8B);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label,
          style: TextStyle(
            color: Colors.black,
            fontSize: 12.sp,
            fontFamily: 'Montserrat',
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: 10.h),
        TextField(
          controller: widget.controller,
          focusNode: _focusNode,
          keyboardType: widget.keyboardType,
          inputFormatters: [EmojiInputFormatter()],
          style: TextStyle(
            fontSize: 16.sp,
            fontFamily: 'Montserrat',
            fontWeight: FontWeight.w400,
            color: textColor,
          ),
          decoration: InputDecoration(
            hintText: widget.hint,
            hintStyle: TextStyle(
              color: hintColor,
              fontSize: 16.sp,
              fontFamily: 'Montserrat',
              fontWeight: FontWeight.w400,
            ),
            contentPadding: EdgeInsets.symmetric(
              horizontal: 18.w,
              vertical: 12.h,
            ),
            errorText: widget.errorText,
            isDense: true,
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide(
                color: hasError ? Colors.red : const Color(0xFFE5E5E5),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide(
                color: hasError ? Colors.red : const Color(0xFF3C4119),
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
