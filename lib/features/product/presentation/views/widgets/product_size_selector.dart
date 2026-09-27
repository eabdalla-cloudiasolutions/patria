import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ProductSizeSelector extends StatefulWidget {
  final List<String> options;
  final Function(String) onSizeSelected;
  final String? customTitle;
  final String? selectedOption; // 👈 externally controlled selection

  const ProductSizeSelector({
    super.key,
    required this.options,
    required this.onSizeSelected,
    this.customTitle,
    this.selectedOption,
  });

  @override
  State<ProductSizeSelector> createState() => _ProductSizeSelectorState();
}

class _ProductSizeSelectorState extends State<ProductSizeSelector> {
  late String? _selectedOption;

  @override
  void initState() {
    super.initState();
    _selectedOption =
        widget.selectedOption; // start with external value (null by default)
    // Do NOT auto-select first option
  }

  @override
  void didUpdateWidget(ProductSizeSelector oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selectedOption != oldWidget.selectedOption) {
      setState(() {
        _selectedOption = widget.selectedOption;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.options.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              widget.customTitle ?? 'choose_options'.tr(),
              style: TextStyle(
                color: const Color(0xFF28293D),
                fontSize: 16.sp,
                fontFamily: 'Montserrat',
                fontWeight: FontWeight.w700,
                letterSpacing: 0.32,
              ),
            ),
          ],
        ),
        SizedBox(height: 12.h),
        Text(
          'choose_one'.tr(),
          style: TextStyle(
            color: const Color(0xFF8B8B8B),
            fontSize: 12.sp,
            fontFamily: 'Montserrat',
            fontWeight: FontWeight.w500,
            letterSpacing: 0.24,
            height: 1.40,
          ),
        ),
        SizedBox(height: 12.h),
        Wrap(
          spacing: 12.w,
          runSpacing: 12.h,
          children: widget.options.map((option) {
            final isSelected = _selectedOption == option;
            return GestureDetector(
              onTap: () {
                setState(() {
                  _selectedOption = option;
                  widget.onSizeSelected(option);
                });
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
                constraints: BoxConstraints(minWidth: 80.w),
                decoration: BoxDecoration(
                  color: isSelected
                      ? const Color(0xFFE5E8D3)
                      : const Color(0xFFFAFAF7),
                  borderRadius: BorderRadius.zero,
                  border: Border.all(
                    width: isSelected ? 2.w : 1.w,
                    color: isSelected
                        ? const Color(0xFF3C4119)
                        : const Color(0xFFE5E5E5),
                  ),
                ),
                // ✅ Removed Center — items now shrink to content width
                child: Text(
                  option,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: isSelected
                        ? const Color(0xFF3C4119)
                        : const Color(0xFF595959),
                    fontSize: 14.sp,
                    fontFamily: 'Montserrat',
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
        SizedBox(height: 24.h),
      ],
    );
  }
}
