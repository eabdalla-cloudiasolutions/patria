import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class EditAddressTagsRow extends StatelessWidget {
  final String selectedTag;
  final void Function(String tag) onTagSelected;

  const EditAddressTagsRow({
    super.key,
    required this.selectedTag,
    required this.onTagSelected,
  });

  // ✅ keys only — never translated here
  static const List<Map<String, dynamic>> _tags = [
    {'key': 'Home', 'icon': Icons.home_outlined},
    {'key': 'Office', 'icon': Icons.business_outlined},
    {'key': 'Apartment', 'icon': Icons.apartment_outlined},
    {'key': 'Custom', 'icon': Icons.edit_outlined},
  ];

  // ✅ maps key → translated label
  String _translateTag(String key) {
    const map = {
      'Home': 'tag_home',
      'Office': 'tag_office',
      'Apartment': 'tag_apartment',
      'Custom': 'tag_custom',
    };
    return (map[key] ?? key).tr();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: _tags.map((tag) {
          final key = tag['key'] as String;
          final isSelected = selectedTag == key; // ✅ compare by key not label
          return Padding(
            padding: EdgeInsets.only(right: 8.w),
            child: GestureDetector(
              onTap: () =>
                  onTagSelected(key), // ✅ pass key not translated label
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 14.h),
                decoration: ShapeDecoration(
                  color: isSelected
                      ? const Color(0xFF6B5E4B)
                      : const Color(0xFFE5E5E5),
                  shape: RoundedRectangleBorder(
                    side: BorderSide(
                      width: isSelected ? 4.w : 1.5.w,
                      color: isSelected
                          ? const Color(0x194A3F33)
                          : const Color(0xFFCACBD4),
                      strokeAlign: isSelected
                          ? BorderSide.strokeAlignOutside
                          : BorderSide.strokeAlignInside,
                    ),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      tag['icon'] as IconData,
                      size: 18,
                      color: isSelected ? Colors.white : Colors.black,
                    ),
                    SizedBox(width: 8.w),
                    Text(
                      _translateTag(key), // ✅ translate only for display
                      style: TextStyle(
                        color: isSelected ? Colors.white : Colors.black,
                        fontSize: 14.sp,
                        fontFamily: 'Montserrat',
                        fontWeight:
                            isSelected ? FontWeight.w500 : FontWeight.w400,
                        letterSpacing: 0.28,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
