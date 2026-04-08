import 'package:easy_localization/easy_localization.dart';
import 'package:erb/features/account/data/apis/addresses_api.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AddressFormSheet extends StatefulWidget {
  final String area;
  final void Function(String addressData) onSave;

  const AddressFormSheet({
    super.key,
    required this.area,
    required this.onSave,
  });

  @override
  State<AddressFormSheet> createState() => _AddressFormSheetState();
}

class _AddressFormSheetState extends State<AddressFormSheet> {
  final _buildingController = TextEditingController();
  final _aptController = TextEditingController();
  final _floorController = TextEditingController();
  final _streetController = TextEditingController();
  final _nearbyController = TextEditingController();
  final _phoneController = TextEditingController();
  final _cityController = TextEditingController(); // ✅ add city field

  String _selectedTag = 'Home';
  bool _isDefault = false; // ✅ add isDefault toggle
  bool _isLoading = false; // ✅ loading state
  String? _errorMessage; // ✅ inline error

  List<Map<String, dynamic>> get _tags => [
        {'key': 'Home', 'label': 'tag_home'.tr(), 'icon': Icons.home_outlined},
        {
          'key': 'Office',
          'label': 'tag_office'.tr(),
          'icon': Icons.business_outlined
        },
        {
          'key': 'Apartment',
          'label': 'tag_apartment'.tr(),
          'icon': Icons.apartment_outlined
        },
        {
          'key': 'Custom',
          'label': 'tag_custom'.tr(),
          'icon': Icons.edit_outlined
        },
      ];

  @override
  void dispose() {
    _buildingController.dispose();
    _aptController.dispose();
    _floorController.dispose();
    _streetController.dispose();
    _nearbyController.dispose();
    _phoneController.dispose();
    _cityController.dispose();
    super.dispose();
  }

  // ✅ Validate before saving
  bool _validate() {
    if (_streetController.text.trim().isEmpty) {
      setState(() => _errorMessage = 'Please enter street name');
      return false;
    }
    if (_cityController.text.trim().isEmpty) {
      setState(() => _errorMessage = 'Please enter city');
      return false;
    }
    return true;
  }

  // ✅ Call API
  Future<void> _onSave() async {
    if (!_validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await AddressesApi().addAddress(
        label: _selectedTag,
        street: _streetController.text.trim(),
        city: _cityController.text.trim(),
        area: widget.area,
        isDefault: _isDefault,
      );

      if (!mounted) return;

      final address =
          '${_streetController.text}, ${widget.area}, ${_buildingController.text}';
      widget.onSave(address); // ✅ notify parent
    } catch (e) {
      if (!mounted) return;
      setState(() => _errorMessage = 'Failed to save address. Try again.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedPadding(
      duration: const Duration(milliseconds: 150),
      curve: Curves.easeOut,
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(height: 12.h),
            Center(
              child: Container(
                width: 40.w,
                height: 4.h,
                decoration: BoxDecoration(
                  color: const Color(0xFFCACBD4),
                  borderRadius: BorderRadius.circular(100.r),
                ),
              ),
            ),
            SizedBox(height: 16.h),
            Flexible(
              child: SingleChildScrollView(
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                padding: EdgeInsets.only(left: 16.w, right: 16.w, bottom: 32.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'confirm_address'.tr(),
                          style: TextStyle(
                            color: Color(0xFF28293D),
                            fontSize: 16.sp,
                            fontFamily: 'Montserrat',
                            fontWeight: FontWeight.w500,
                            letterSpacing: 0.32,
                          ),
                        ),
                        GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: const Icon(Icons.close,
                              size: 24, color: Color(0xFF28293D)),
                        ),
                      ],
                    ),
                    SizedBox(height: 16.h),

                    // Area tile
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.symmetric(
                          horizontal: 18.w, vertical: 12.h),
                      decoration: ShapeDecoration(
                        color: Colors.white,
                        shape: RoundedRectangleBorder(
                          side: const BorderSide(color: Color(0xFFE5E5E5)),
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.location_on_outlined,
                              size: 24, color: Color(0xFF6B5E4B)),
                          SizedBox(width: 12.w),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'area'.tr(),
                                  style: TextStyle(
                                    color: Color(0xFF333333),
                                    fontSize: 14.sp,
                                    fontFamily: 'Montserrat',
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: 0.28,
                                  ),
                                ),
                                SizedBox(height: 4.h),
                                Text(
                                  widget.area,
                                  style: TextStyle(
                                    color: Color(0xFF8B8B8B),
                                    fontSize: 13.sp,
                                    fontFamily: 'Montserrat',
                                    fontWeight: FontWeight.w400,
                                    letterSpacing: 0.26,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          GestureDetector(
                            onTap: () => Navigator.pop(context),
                            child: Text(
                              'change'.tr(),
                              style: TextStyle(
                                color: Color(0xFF6B5E4B),
                                fontSize: 16.sp,
                                fontFamily: 'Montserrat',
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0.32,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 16.h),

                    // Tags row
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: _tags.map((tag) {
                          final isSelected = _selectedTag == tag['key'];
                          return Padding(
                            padding: EdgeInsets.only(right: 8.w),
                            child: GestureDetector(
                              onTap: () => setState(
                                  () => _selectedTag = tag['key'] as String),
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 8.w, vertical: 14.h),
                                decoration: ShapeDecoration(
                                  color: isSelected
                                      ? const Color(0xFFF5F0EA)
                                      : const Color(0xFFE5E5E5),
                                  shape: RoundedRectangleBorder(
                                    side: BorderSide(
                                      width: 1.5.w,
                                      color: isSelected
                                          ? const Color(0xFF6B5E4B)
                                          : const Color(0xFFCACBD4),
                                    ),
                                    borderRadius: BorderRadius.circular(4.r),
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      tag['icon'] as IconData,
                                      size: 18,
                                      color: isSelected
                                          ? const Color(0xFF6B5E4B)
                                          : Colors.black,
                                    ),
                                    SizedBox(width: 8.w),
                                    Text(
                                      tag['label'] as String,
                                      style: TextStyle(
                                        color: isSelected
                                            ? const Color(0xFF6B5E4B)
                                            : Colors.black,
                                        fontSize: 14.sp,
                                        fontFamily: 'Montserrat',
                                        fontWeight: isSelected
                                            ? FontWeight.w600
                                            : FontWeight.w400,
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
                    ),
                    SizedBox(height: 16.h),

                    _buildField(
                      'building_name'.tr(),
                      'building_name_hint'.tr(),
                      _buildingController,
                    ),
                    SizedBox(height: 16.h),

                    Row(
                      children: [
                        Expanded(
                          child: _buildField(
                            'apt_no'.tr(),
                            'apt_no_hint'.tr(),
                            _aptController,
                            keyboardType: TextInputType.number,
                          ),
                        ),
                        SizedBox(width: 16.w),
                        Expanded(
                          child: _buildField(
                            'floor'.tr(),
                            'floor_hint'.tr(),
                            _floorController,
                            keyboardType: TextInputType.number,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 16.h),

                    // ✅ Street field
                    _buildField(
                      'street_name'.tr(),
                      'street_name_hint'.tr(),
                      _streetController,
                    ),
                    SizedBox(height: 16.h),

                    // ✅ City field
                    _buildField(
                      'city'.tr(),
                      'city_hint'.tr(),
                      _cityController,
                    ),
                    SizedBox(height: 16.h),

                    _buildField(
                      'nearby_trademark'.tr(),
                      'nearby_trademark_hint'.tr(),
                      _nearbyController,
                    ),
                    SizedBox(height: 16.h),

                    _buildField(
                      'phone_number'.tr(),
                      'phone_number'.tr(),
                      _phoneController,
                      keyboardType: TextInputType.phone,
                    ),
                    SizedBox(height: 16.h),

                    // ✅ Set as default toggle
                    GestureDetector(
                      onTap: () => setState(() => _isDefault = !_isDefault),
                      child: Row(
                        children: [
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            width: 20.w,
                            height: 20.h,
                            decoration: ShapeDecoration(
                              color: _isDefault
                                  ? const Color(0xFF6B5E4B)
                                  : Colors.transparent,
                              shape: RoundedRectangleBorder(
                                side:
                                    const BorderSide(color: Color(0xFF6B5E4B)),
                                borderRadius: BorderRadius.circular(6.r),
                              ),
                            ),
                            child: _isDefault
                                ? const Icon(Icons.check,
                                    size: 14, color: Colors.white)
                                : null,
                          ),
                          SizedBox(width: 8.w),
                          Text(
                            'set_as_default'.tr(),
                            style: TextStyle(
                              color: Color(0xFF333333),
                              fontSize: 13.sp,
                              fontFamily: 'Montserrat',
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.26,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 16.h),

                    // ✅ Inline error message
                    if (_errorMessage != null) ...[
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.symmetric(
                            horizontal: 16.w, vertical: 12.h),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFEEEE),
                          borderRadius: BorderRadius.circular(8.r),
                          border: Border.all(color: Colors.red.shade200),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.error_outline,
                                color: Colors.red, size: 18),
                            SizedBox(width: 8.w),
                            Expanded(
                              child: Text(
                                _errorMessage!,
                                style: TextStyle(
                                  color: Colors.red,
                                  fontSize: 13.sp,
                                  fontFamily: 'Montserrat',
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 16.h),
                    ],

                    // ✅ Save button with loading
                    SizedBox(
                      width: double.infinity,
                      height: 56.h,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _onSave,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF6B5E4B),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5.r),
                          ),
                        ),
                        child: _isLoading
                            ? const CircularProgressIndicator(
                                color: Colors.white)
                            : Text(
                                'save_address'.tr(),
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
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildField(
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
              color: Color(0xFF28293D),
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
