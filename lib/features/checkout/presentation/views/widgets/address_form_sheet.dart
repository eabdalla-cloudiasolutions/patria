import 'package:easy_localization/easy_localization.dart';
import 'package:erb/features/account/data/apis/addresses_api.dart';
import 'package:erb/features/checkout/data/repos/delivery_zones_repo.dart';
import 'package:erb/features/checkout/presentation/manager/delivery_zones_bloc.dart';
import 'package:erb/features/checkout/presentation/manager/delivery_zones_event.dart';
import 'package:erb/features/checkout/presentation/manager/delivery_zones_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AddressFormSheet extends StatefulWidget {
  final void Function(String addressData, String zoneId) onSave; // ✅ updated

  const AddressFormSheet({
    super.key,
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
  final _cityController = TextEditingController();

  String? _selectedZoneId;
  String? _selectedZoneName;
  String _selectedTag = 'Home';
  bool _isDefault = false;
  bool _isLoading = false;
  String? _errorMessage;
  bool _isZoneDropdownOpen = false;

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

  bool _validate() {
    if (_selectedZoneId == null) {
      setState(() => _errorMessage = 'Please select zone/area');
      return false;
    }
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
        area: _selectedZoneName!,
        isDefault: _isDefault,
      );

      if (!mounted) return;

      if (_selectedZoneId == null) {
        setState(() =>
            _errorMessage = 'Zone ID missing. Please select a zone again.');
        return;
      }

      final address =
          '${_streetController.text}, $_selectedZoneName, ${_buildingController.text}';

      // Call the callback – this will trigger the pop from the parent
      widget.onSave(address, _selectedZoneId!);

      // DO NOT pop here – let the parent handle closing the sheet
    } catch (e, stackTrace) {
      if (mounted) {
        setState(() => _errorMessage = 'Failed to save address. Try again.');
      }
      print('❌ AddressFormSheet error: $e');
      print(stackTrace);
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          DeliveryZonesBloc(DeliveryZonesRepo())..add(FetchDeliveryZones()),
      child: BlocBuilder<DeliveryZonesBloc, DeliveryZonesState>(
        builder: (context, state) {
          return AnimatedPadding(
            duration: const Duration(milliseconds: 150),
            curve: Curves.easeOut,
            padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom),
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
                      padding: EdgeInsets.only(
                          left: 16.w, right: 16.w, bottom: 32.h),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Header
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'confirm_address'.tr(),
                                style: TextStyle(
                                  color: const Color(0xFF28293D),
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

                          // Zone container (tappable)
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                _isZoneDropdownOpen = !_isZoneDropdownOpen;
                              });
                            },
                            child: Container(
                              width: double.infinity,
                              height: 50.h,
                              padding: EdgeInsets.symmetric(
                                  horizontal: 18.w, vertical: 12.h),
                              decoration: ShapeDecoration(
                                color: Colors.white,
                                shape: RoundedRectangleBorder(
                                  side: const BorderSide(
                                      width: 1, color: Color(0xFFE5E5E5)),
                                  borderRadius: BorderRadius.circular(12.r),
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    _selectedZoneName ?? 'select_zone'.tr(),
                                    style: TextStyle(
                                      color: _selectedZoneName == null
                                          ? const Color(0xFF8B8B8B)
                                          : const Color(0xFF28293D),
                                      fontSize: 16.sp,
                                      fontFamily: 'Montserrat',
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                  Icon(
                                    _isZoneDropdownOpen
                                        ? Icons.arrow_drop_up
                                        : Icons.arrow_drop_down,
                                    color: const Color(0xFF8B8B8B),
                                    size: 24.w,
                                  ),
                                ],
                              ),
                            ),
                          ),

                          // Inline dropdown list based on API state
                          if (_isZoneDropdownOpen)
                            Container(
                              margin: EdgeInsets.only(top: 8.h),
                              width: double.infinity,
                              padding: EdgeInsets.symmetric(
                                  horizontal: 14.w, vertical: 6.h),
                              decoration: ShapeDecoration(
                                color: const Color(0xFFFAFAF7),
                                shape: RoundedRectangleBorder(
                                  side: const BorderSide(
                                      width: 1, color: Color(0xFFE5E5E5)),
                                  borderRadius: BorderRadius.circular(16.r),
                                ),
                              ),
                              child: _buildZoneList(context, state),
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
                                    onTap: () => setState(() =>
                                        _selectedTag = tag['key'] as String),
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
                                          borderRadius:
                                              BorderRadius.circular(4.r),
                                        ),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(tag['icon'] as IconData,
                                              size: 18,
                                              color: isSelected
                                                  ? const Color(0xFF6B5E4B)
                                                  : Colors.black),
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

                          _buildField('building_name'.tr(),
                              'building_name_hint'.tr(), _buildingController),
                          SizedBox(height: 16.h),
                          Row(
                            children: [
                              Expanded(
                                  child: _buildField('apt_no'.tr(),
                                      'apt_no_hint'.tr(), _aptController,
                                      keyboardType: TextInputType.number)),
                              SizedBox(width: 16.w),
                              Expanded(
                                  child: _buildField('floor'.tr(),
                                      'floor_hint'.tr(), _floorController,
                                      keyboardType: TextInputType.number)),
                            ],
                          ),
                          SizedBox(height: 16.h),
                          _buildField('street_name'.tr(),
                              'street_name_hint'.tr(), _streetController),
                          SizedBox(height: 16.h),
                          _buildField(
                              'city'.tr(), 'city_hint'.tr(), _cityController),
                          SizedBox(height: 16.h),
                          _buildField('nearby_trademark'.tr(),
                              'nearby_trademark_hint'.tr(), _nearbyController),
                          SizedBox(height: 16.h),
                          _buildField('phone_number'.tr(), 'phone_number'.tr(),
                              _phoneController,
                              keyboardType: TextInputType.phone),
                          SizedBox(height: 16.h),

                          // Set as default toggle
                          GestureDetector(
                            onTap: () =>
                                setState(() => _isDefault = !_isDefault),
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
                                      side: const BorderSide(
                                          color: Color(0xFF6B5E4B)),
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
                                    color: const Color(0xFF333333),
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
                                      child: Text(_errorMessage!,
                                          style: TextStyle(
                                              color: Colors.red,
                                              fontSize: 13.sp,
                                              fontFamily: 'Montserrat',
                                              fontWeight: FontWeight.w500))),
                                ],
                              ),
                            ),
                            SizedBox(height: 16.h),
                          ],

                          SizedBox(
                            width: double.infinity,
                            height: 56.h,
                            child: ElevatedButton(
                              onPressed: _isLoading ? null : _onSave,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF6B5E4B),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(5.r)),
                              ),
                              child: _isLoading
                                  ? const CircularProgressIndicator(
                                      color: Colors.white)
                                  : Text('save_address'.tr(),
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 16.sp,
                                          fontFamily: 'Montserrat',
                                          fontWeight: FontWeight.w600)),
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
        },
      ),
    );
  }

  Widget _buildZoneList(BuildContext context, DeliveryZonesState state) {
    if (state is DeliveryZonesLoading) {
      return const Center(
          child: Padding(
        padding: EdgeInsets.all(16.0),
        child: CircularProgressIndicator(),
      ));
    } else if (state is DeliveryZonesError) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(state.message, style: TextStyle(color: Colors.red)),
        ),
      );
    } else if (state is DeliveryZonesLoaded) {
      final zones = state.zones;
      if (zones.isEmpty) {
        return Center(
            child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text('No zones available'),
        ));
      }
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: zones.map((zone) {
          final isSelected = _selectedZoneId == zone.id;
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              GestureDetector(
                onTap: () {
                  print('🔵 Tapped zone: id=${zone.id}, name=${zone.name}');

                  setState(() {
                    _selectedZoneId = zone.id;
                    _selectedZoneName = zone.name;
                    _isZoneDropdownOpen = false;
                  });
                },
                child: Container(
                  width: double.infinity,
                  padding:
                      EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
                  decoration: ShapeDecoration(
                    color: isSelected
                        ? const Color(0xFF6B5E4B)
                        : Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16.r),
                    ),
                  ),
                  child: Text(
                    zone.name,
                    style: TextStyle(
                      color:
                          isSelected ? Colors.white : const Color(0xFF333333),
                      fontSize: 13.sp,
                      fontFamily: 'Montserrat',
                      fontWeight: FontWeight.w500,
                      letterSpacing: 0.26,
                    ),
                  ),
                ),
              ),
              if (zone != zones.last)
                Divider(
                  height: 0,
                  thickness: 1,
                  color: const Color(0xFFCACBD4),
                ),
            ],
          );
        }).toList(),
      );
    }
    return const SizedBox.shrink();
  }

  Widget _buildField(
      String label, String hint, TextEditingController controller,
      {TextInputType keyboardType = TextInputType.text}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: TextStyle(
                color: Colors.black,
                fontSize: 12.sp,
                fontFamily: 'Montserrat',
                fontWeight: FontWeight.w500)),
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
                color: const Color(0xFF28293D)),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(
                  color: const Color(0xFF8B8B8B),
                  fontSize: 16.sp,
                  fontFamily: 'Montserrat',
                  fontWeight: FontWeight.w400),
              contentPadding:
                  EdgeInsets.symmetric(horizontal: 18.w, vertical: 12.h),
              enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                  borderSide: const BorderSide(color: Color(0xFFE5E5E5))),
              focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                  borderSide: const BorderSide(color: Color(0xFF6B5E4B))),
              filled: true,
              fillColor: Colors.white,
            ),
          ),
        ),
      ],
    );
  }
}
