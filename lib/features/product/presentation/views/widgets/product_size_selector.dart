import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ProductSizeSelector extends StatefulWidget {
  final List<String> options;
  final Function(String) onSizeSelected;
  final String? customTitle;

  const ProductSizeSelector({
    super.key,
    required this.options,
    required this.onSizeSelected,
    this.customTitle,
  });

  @override
  State<ProductSizeSelector> createState() => _ProductSizeSelectorState();
}

class _ProductSizeSelectorState extends State<ProductSizeSelector> {
  late String _selectedOption;

  @override
  void initState() {
    super.initState();
    if (widget.options.isNotEmpty) {
      _selectedOption = widget.options.first;
      widget.onSizeSelected(_selectedOption);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Don't show anything if no options available
    if (widget.options.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Title with colored bar
        Row(
          children: [
            Container(
              width: 4.w,
              height: 18.h,
              decoration: BoxDecoration(
                color: const Color(0xFF6B5E4B),
                borderRadius: BorderRadius.circular(2.r),
              ),
            ),
            SizedBox(width: 8.w),
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

        // Subtitle (choose one)
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

        // 👇 Options in a SINGLE ROW (Horizontal)
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          child: Row(
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
                  padding:
                      EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
                  constraints: BoxConstraints(
                    minWidth: 80.w,
                  ),
                  margin: EdgeInsets.only(
                      right: 12.w), // 👈 spacing between options
                  decoration: BoxDecoration(
                    color: isSelected
                        ? const Color(0xFFF5F0EA)
                        : const Color(0xFFFAFAF7),
                    borderRadius: BorderRadius.zero,
                    border: Border.all(
                      width: isSelected ? 2.w : 1.w,
                      color: isSelected
                          ? const Color(0xFF6B5E4B)
                          : const Color(0xFFE5E5E5),
                    ),
                  ),
                  child: Center(
                    child: Text(
                      option,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: isSelected
                            ? const Color(0xFF6B5E4B)
                            : const Color(0xFF595959),
                        fontSize: 14.sp,
                        fontFamily: 'Montserrat',
                        fontWeight:
                            isSelected ? FontWeight.w600 : FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
        SizedBox(height: 24.h),
      ],
    );
  }
}
