import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class SpecialRequestBottomSheet extends StatefulWidget {
  final String? initialText;
  final Function(String) onContinue;

  const SpecialRequestBottomSheet({
    super.key,
    this.initialText,
    required this.onContinue,
  });

  @override
  State<SpecialRequestBottomSheet> createState() =>
      _SpecialRequestBottomSheetState();
}

class _SpecialRequestBottomSheetState extends State<SpecialRequestBottomSheet> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialText ?? '');
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
                  'special_request_title'.tr(),
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

            // Text field
            TextField(
              controller: _controller,
              maxLines: 3,
              style: TextStyle(
                color: const Color(0xFF333333),
                fontSize: 16.sp,
                fontFamily: 'Montserrat',
                fontWeight: FontWeight.w400,
              ),
              decoration: InputDecoration(
                hintText: 'special_request_hint'.tr(),
                hintStyle: TextStyle(
                  color: const Color(0xFF8B8B8B),
                  fontSize: 16.sp,
                  fontFamily: 'Montserrat',
                  fontWeight: FontWeight.w400,
                  height: 1.38,
                ),
                contentPadding: const EdgeInsets.all(18),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.r),
                  borderSide: BorderSide(
                    width: 1.w,
                    color: const Color(0xFFCACBD4),
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.r),
                  borderSide: BorderSide(
                    width: 1.w,
                    color: const Color(0xFF6B5E4B),
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
                  backgroundColor: const Color(0xFF6B5E4B),
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
