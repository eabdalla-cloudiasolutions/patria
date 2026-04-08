import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class EditAddressForm extends StatelessWidget {
  final TextEditingController buildingController;
  final TextEditingController aptController;
  final TextEditingController floorController;
  final TextEditingController streetController;
  final TextEditingController nearbyController;
  final TextEditingController phoneController;
  final TextEditingController cityController; // ✅ add this

  const EditAddressForm({
    super.key,
    required this.buildingController,
    required this.aptController,
    required this.floorController,
    required this.streetController,
    required this.nearbyController,
    required this.phoneController,
    required this.cityController, // ✅ add this
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildField(
          context,
          'building_name'.tr(),
          'building_name_hint'.tr(),
          buildingController,
        ),
        SizedBox(height: 16.h),
        Row(
          children: [
            Expanded(
              child: _buildField(
                context,
                'apt_no'.tr(),
                'apt_no_hint'.tr(),
                aptController,
                keyboardType: TextInputType.number,
              ),
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: _buildField(
                context,
                'floor'.tr(),
                'floor_hint'.tr(),
                floorController,
                keyboardType: TextInputType.number,
              ),
            ),
          ],
        ),
        SizedBox(height: 16.h),
        _buildField(
          context,
          'street_name'.tr(),
          'street_name_hint'.tr(),
          streetController,
        ),
        SizedBox(height: 16.h),
        // ✅ City field
        _buildField(
          context,
          'city'.tr(),
          'city_hint'.tr(),
          cityController,
        ),
        SizedBox(height: 16.h),
        _buildField(
          context,
          'nearby_trademark'.tr(),
          'nearby_trademark_hint'.tr(),
          nearbyController,
        ),
        SizedBox(height: 16.h),
        _buildField(
          context,
          'phone_number'.tr(),
          'phone_number'.tr(),
          phoneController,
          keyboardType: TextInputType.phone,
        ),
      ],
    );
  }

  Widget _buildField(
    BuildContext context,
    String label,
    String hint,
    TextEditingController controller, {
    TextInputType keyboardType = TextInputType.text,
  }) {
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
        SizedBox(
          height: 50.h,
          child: TextField(
            controller: controller,
            keyboardType: keyboardType,
            style: TextStyle(
              fontSize: 16.sp,
              fontFamily: 'Montserrat',
              fontWeight: FontWeight.w400,
              color: Colors.black,
            ),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(
                color: Color(0xFF8B8B8B),
                fontSize: 16.sp,
                fontFamily: 'Montserrat',
                fontWeight: FontWeight.w400,
              ),
              contentPadding:
                  EdgeInsets.symmetric(horizontal: 18.w, vertical: 12.h),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
                borderSide: const BorderSide(color: Color(0xFFE5E5E5)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
                borderSide: const BorderSide(color: Color(0xFF6B5E4B)),
              ),
              filled: true,
              fillColor: Colors.white,
            ),
          ),
        ),
      ],
    );
  }
}
