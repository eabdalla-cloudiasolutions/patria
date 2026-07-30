import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CuisinesSection extends StatelessWidget {
  final List<CuisineItem> cuisines;
  final Function(String)? onCuisineTap;
  final String title;
  final Widget? titleTrailing; // ← add this

  const CuisinesSection({
    super.key,
    required this.cuisines,
    this.onCuisineTap,
    required this.title,
    this.titleTrailing, // ← add this
  });

  @override
  Widget build(BuildContext context) {
    final isArabic = context.locale.languageCode == 'ar';
    final double spacing = isArabic ? 18.w : 12.w;
    final double runSpacing = isArabic ? 18.h : 12.h;
    final double chipPadding = isArabic ? 16 : 12;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ✅ Title row with optional trailing widget
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: TextStyle(
                color: const Color(0xFF28293D),
                fontSize: 16.sp,
                fontFamily: 'Montserrat',
                fontWeight: FontWeight.w600,
                letterSpacing: 0.32,
              ),
            ),
            ?titleTrailing,
          ],
        ),
        SizedBox(height: 16.h),
        Wrap(
          spacing: spacing,
          runSpacing: runSpacing,
          children: cuisines.map((cuisine) {
            return _buildChip(cuisine, padding: chipPadding);
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildChip(CuisineItem cuisine, {required double padding}) {
    return GestureDetector(
      onTap: () => onCuisineTap?.call(cuisine.name),
      child: Container(
        padding: EdgeInsets.all(padding),
        decoration: ShapeDecoration(
          color: const Color(0xFFE5E5E5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(5.r),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              cuisine.name,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: const Color(0xFF23252A),
                fontSize: 14.sp,
                fontFamily: 'Montserrat',
                fontWeight: FontWeight.w500,
                height: 1.40,
                letterSpacing: 0.28,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Data model for a cuisine item (unchanged)
class CuisineItem {
  final String name;
  final String? iconUrl;
  final String? iconAsset;

  CuisineItem({required this.name, this.iconUrl, this.iconAsset});
}
