import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:patria/core/utils/emoji_input_formatter.dart';

class SpecialRequestBottomSheet extends StatefulWidget {
  final String? initialText;
  final Function(String) onContinue;
  final String? title;
  final String? hint;

  const SpecialRequestBottomSheet({
    super.key,
    this.initialText,
    required this.onContinue,
    this.title,
    this.hint,
  });

  @override
  State<SpecialRequestBottomSheet> createState() =>
      _SpecialRequestBottomSheetState();
}

class _SpecialRequestBottomSheetState extends State<SpecialRequestBottomSheet> {
  late final TextEditingController _controller;
  late final FocusNode _focusNode;
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialText ?? '');
    _focusNode = FocusNode();
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
    final accentColor = const Color(0xFF3C4119);
    final textColor = _isFocused ? Colors.black : const Color(0xFF333333);
    final hintColor = _isFocused
        ? accentColor.withOpacity(0.7)
        : const Color(0xFF8B8B8B);
    final borderColor = _isFocused ? accentColor : const Color(0xFFCACBD4);
    final borderWidth = _isFocused ? 1.5.w : 1.w;

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.only(
          top: 16.h,
          left: 16.w,
          right: 16.w,
          bottom: 56.h,
        ),
        decoration: ShapeDecoration(
          color: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
          ),
          shadows: [
            BoxShadow(
              color: const Color(0x19000000),
              blurRadius: 15,
              offset: const Offset(0, 10),
              spreadRadius: -3,
            ),
            BoxShadow(
              color: const Color(0x19000000),
              blurRadius: 6,
              offset: const Offset(0, 4),
              spreadRadius: -4,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  widget.title ?? 'special_request_title'.tr(),
                  style: TextStyle(
                    color: const Color(0xFF333333),
                    fontSize: 18.sp,
                    fontFamily: 'Montserrat',
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.36,
                  ),
                ),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: const Icon(
                    Icons.cancel_outlined,
                    color: Color(0xFF333333),
                    size: 24,
                  ),
                ),
              ],
            ),

            SizedBox(height: 12.h),

            // Focus‑aware TextField
            TextField(
              controller: _controller,
              focusNode: _focusNode,
              maxLines: 3,
              inputFormatters: [EmojiInputFormatter()],
              style: TextStyle(
                color: textColor,
                fontSize: 16.sp,
                fontFamily: 'Montserrat',
                fontWeight: FontWeight.w400,
              ),
              decoration: InputDecoration(
                hintText: widget.hint ?? 'special_request_hint'.tr(),
                hintStyle: TextStyle(
                  color: hintColor,
                  fontSize: 16.sp,
                  fontFamily: 'Montserrat',
                  fontWeight: FontWeight.w400,
                  height: 1.38,
                ),
                contentPadding: const EdgeInsets.all(18),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.r),
                  borderSide: BorderSide(
                    width: borderWidth,
                    color: borderColor,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.r),
                  borderSide: const BorderSide(
                    color: Color(0xFF3C4119),
                    width: 1.5,
                  ),
                ),
                filled: true,
                fillColor: Colors.white,
              ),
            ),

            SizedBox(height: 12.h),

            // Continue button
            SizedBox(
              width: double.infinity,
              height: 56.h,
              child: ElevatedButton(
                onPressed: () {
                  widget.onContinue(_controller.text);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF3C4119),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5.r),
                  ),
                ),
                child: Text(
                  'continue'.tr(),
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16.sp,
                    fontFamily: 'Montserrat',
                    fontWeight: FontWeight.w600,
                    height: 1.50,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
