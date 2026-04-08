import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class LanguageBottomSheet extends StatefulWidget {
  final String currentLanguage;
  final Function(String) onLanguageSelected;

  const LanguageBottomSheet({
    super.key,
    required this.currentLanguage,
    required this.onLanguageSelected,
  });

  @override
  State<LanguageBottomSheet> createState() => _LanguageBottomSheetState();
}

class _LanguageBottomSheetState extends State<LanguageBottomSheet> {
  late String _selected;

  @override
  void initState() {
    super.initState();
    _selected = widget.currentLanguage;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding:
          EdgeInsets.only(top: 20.h, left: 20.w, right: 20.w, bottom: 32.h),
      decoration: ShapeDecoration(
        color: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
        ),
        shadows: [
          BoxShadow(
            color: Color(0x19000000),
            blurRadius: 15,
            offset: Offset(0, -4),
            spreadRadius: -3,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Title row with X button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'language'.tr(),
                style: TextStyle(
                  color: Color(0xFF333333),
                  fontSize: 18.sp,
                  fontFamily: 'Montserrat',
                  fontWeight: FontWeight.w600,
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
          SizedBox(height: 20.h),

          // English option
          _LanguageOption(
            label: 'language_english'.tr(),
            value: 'en',
            selected: _selected == 'en',
            onTap: () => setState(() => _selected = 'en'),
          ),
          SizedBox(height: 20.h),

          // Arabic option
          _LanguageOption(
            label: 'language_arabic'.tr(),
            value: 'ar',
            selected: _selected == 'ar',
            onTap: () => setState(() => _selected = 'ar'),
          ),
          SizedBox(height: 32.h),

          // Confirm button
          SizedBox(
            width: double.infinity,
            height: 52.h,
            child: ElevatedButton(
              onPressed: () {
                widget.onLanguageSelected(_selected);
                Navigator.of(context).pop(); // ✅ only pop, no setLocale here
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6B5E4B),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
                elevation: 0,
              ),
              child: Text(
                'confirm'.tr(),
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16.sp,
                  fontFamily: 'Montserrat',
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LanguageOption extends StatelessWidget {
  final String label;
  final String value;
  final bool selected;
  final VoidCallback onTap;

  const _LanguageOption({
    required this.label,
    required this.value,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: Color(0xFF333333),
              fontSize: 15.sp,
              fontFamily: 'Montserrat',
              fontWeight: FontWeight.w400,
            ),
          ),
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 22.w,
            height: 22.h,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(5.r),
              border: Border.all(
                color: selected
                    ? const Color(0xFF6B5E4B)
                    : const Color(0xFFCACBD4),
                width: 1.5.w,
              ),
              color: selected ? const Color(0xFF6B5E4B) : Colors.white,
            ),
            child: selected
                ? const Icon(Icons.check, color: Colors.white, size: 14)
                : null,
          ),
        ],
      ),
    );
  }
}
