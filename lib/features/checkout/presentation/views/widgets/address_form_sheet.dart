import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:patria/core/utils/emoji_input_formatter.dart';
import 'package:patria/core/utils/validators.dart';
import 'package:patria/features/account/data/apis/addresses_api.dart';
import 'package:patria/features/account/data/models/address_model.dart';

class AddressFormSheet extends StatefulWidget {
  final void Function(AddressModel address, String zoneId) onSave;
  final LatLng? initialLocation;
  final String? detectedZoneName;

  const AddressFormSheet({
    super.key,
    required this.onSave,
    this.initialLocation,
    this.detectedZoneName,
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

  String? _selectedZoneId;
  String? _selectedZoneName;
  String _selectedTag = 'Home';
  bool _isDefault = false;
  bool _isLoading = false;
  String? _errorMessage;

  List<Map<String, dynamic>> get _tags => [
    {'key': 'Home', 'label': 'tag_home'.tr(), 'icon': Icons.home_outlined},
    {
      'key': 'Office',
      'label': 'tag_office'.tr(),
      'icon': Icons.business_outlined,
    },
    {
      'key': 'Apartment',
      'label': 'tag_apartment'.tr(),
      'icon': Icons.apartment_outlined,
    },
    {'key': 'Custom', 'label': 'tag_custom'.tr(), 'icon': Icons.edit_outlined},
  ];

  @override
  void initState() {
    super.initState();
    if (widget.detectedZoneName != null &&
        widget.detectedZoneName!.isNotEmpty) {
      _selectedZoneName = widget.detectedZoneName;
      _selectedZoneId = widget.detectedZoneName;
    }
  }

  @override
  void dispose() {
    _buildingController.dispose();
    _aptController.dispose();
    _floorController.dispose();
    _streetController.dispose();
    _nearbyController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  bool _validate() {
    if (_selectedZoneId == null || _selectedZoneId!.isEmpty) {
      setState(() => _errorMessage = 'Zone not detected. Please try again.');
      return false;
    }
    if (_streetController.text.trim().isEmpty) {
      setState(() => _errorMessage = 'Please enter street name');
      return false;
    }
    final phoneError = Validators.optionalPhone(_phoneController.text);
    if (phoneError != null) {
      setState(() => _errorMessage = phoneError);
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
      final createdAddress = await AddressesApi().addAddress(
        label: _selectedTag,
        street: _streetController.text.trim(),
        city: '',
        buildingName: _buildingController.text.trim(),
        apartmentNo: _aptController.text.trim().isEmpty
            ? null
            : _aptController.text.trim(),
        floor: _floorController.text.trim().isEmpty
            ? null
            : _floorController.text.trim(),
        nearbyTrademark: _nearbyController.text.trim().isEmpty
            ? null
            : _nearbyController.text.trim(),
        phone: _phoneController.text.trim().isEmpty
            ? null
            : _phoneController.text.trim(),
        zone: _selectedZoneName!,
        lat: widget.initialLocation?.latitude,
        lng: widget.initialLocation?.longitude,
        isDefault: _isDefault,
      );

      if (!mounted) return;

      widget.onSave(createdAddress, _selectedZoneId!);
    } catch (e) {
      if (mounted) {
        setState(() => _errorMessage = 'Failed to save address. Try again.');
      }
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
            Flexible(
              child: SingleChildScrollView(
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (widget.initialLocation != null)
                      Stack(
                        children: [
                          _buildStaticMap(widget.initialLocation!),
                          Positioned(
                            top: 28.h,
                            right: 28.w,
                            child: GestureDetector(
                              onTap: () => Navigator.pop(context),
                              child: Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                  boxShadow: const [
                                    BoxShadow(
                                      color: Color(0x1A000000),
                                      blurRadius: 4,
                                    ),
                                  ],
                                ),
                                child: const Icon(
                                  Icons.close,
                                  size: 18,
                                  color: Color(0xFF28293D),
                                ),
                              ),
                            ),
                          ),
                        ],
                      )
                    else ...[
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
                      Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: 16.w,
                          vertical: 16.h,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'confirm_address'.tr(),
                              style: TextStyle(
                                color: const Color(0xFF28293D),
                                fontSize: 16.sp,
                                fontFamily: 'Montserrat',
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            GestureDetector(
                              onTap: () => Navigator.pop(context),
                              child: const Icon(
                                Icons.close,
                                size: 24,
                                color: Color(0xFF28293D),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],

                    Padding(
                      padding: EdgeInsets.only(
                        left: 16.w,
                        right: 16.w,
                        bottom: 32.h,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(height: 16.h),

                          _buildZoneReadOnlyField(),
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
                                      () => _selectedTag = tag['key'] as String,
                                    ),
                                    child: Container(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 8.w,
                                        vertical: 14.h,
                                      ),
                                      decoration: ShapeDecoration(
                                        color: isSelected
                                            ? const Color(0xFFE5E8D3)
                                            : const Color(0xFFE5E5E5),
                                        shape: RoundedRectangleBorder(
                                          side: BorderSide(
                                            width: 1.5.w,
                                            color: isSelected
                                                ? const Color(0xFF3C4119)
                                                : const Color(0xFFCACBD4),
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            4.r,
                                          ),
                                        ),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(
                                            tag['icon'] as IconData,
                                            size: 18,
                                            color: isSelected
                                                ? const Color(0xFF3C4119)
                                                : Colors.black,
                                          ),
                                          SizedBox(width: 8.w),
                                          Text(
                                            tag['label'] as String,
                                            style: TextStyle(
                                              color: isSelected
                                                  ? const Color(0xFF3C4119)
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
                          _buildField(
                            'street_name'.tr(),
                            'street_name_hint'.tr(),
                            _streetController,
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

                          // Set as default
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
                                        ? const Color(0xFF3C4119)
                                        : Colors.transparent,
                                    shape: RoundedRectangleBorder(
                                      side: const BorderSide(
                                        color: Color(0xFF3C4119),
                                      ),
                                      borderRadius: BorderRadius.circular(6.r),
                                    ),
                                  ),
                                  child: _isDefault
                                      ? const Icon(
                                          Icons.check,
                                          size: 14,
                                          color: Colors.white,
                                        )
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
                                horizontal: 16.w,
                                vertical: 12.h,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFFEEEE),
                                borderRadius: BorderRadius.circular(8.r),
                                border: Border.all(color: Colors.red.shade200),
                              ),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.error_outline,
                                    color: Colors.red,
                                    size: 18,
                                  ),
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

                          SizedBox(
                            width: double.infinity,
                            height: 56.h,
                            child: ElevatedButton(
                              onPressed: _isLoading ? null : _onSave,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF3C4119),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(5.r),
                                ),
                              ),
                              child: _isLoading
                                  ? const CircularProgressIndicator(
                                      color: Colors.white,
                                    )
                                  : Text(
                                      'save_address'.tr(),
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

  Widget _buildZoneReadOnlyField() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
      clipBehavior: Clip.antiAlias,
      decoration: ShapeDecoration(
        color: Colors.white,
        shape: RoundedRectangleBorder(
          side: const BorderSide(width: 1, color: Color(0xFFE5E5E5)),
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Image.asset(
            'assets/images/map-marker-alt.png',
            height: 24,
            width: 24,
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'area'.tr(),
                  style: TextStyle(
                    color: const Color(0xFF8B8B8B),
                    fontSize: 14.sp,
                    fontFamily: 'Montserrat',
                    fontWeight: FontWeight.w500,
                    height: 1.07,
                    letterSpacing: 0.28,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  _selectedZoneName ?? 'detecting_zone'.tr(),
                  style: TextStyle(
                    color: const Color(0xFF8B8B8B),
                    fontSize: 13.sp,
                    fontFamily: 'Montserrat',
                    fontWeight: FontWeight.w400,
                    height: 1.40,
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
                color: const Color(0xFF3C4119),
                fontSize: 16.sp,
                fontFamily: 'Montserrat',
                fontWeight: FontWeight.w600,
                height: 1.40,
                letterSpacing: 0.32,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStaticMap(LatLng location) {
    return Padding(
      padding: EdgeInsets.only(left: 16.w, right: 16.w, top: 24.h),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12.r),
        child: SizedBox(
          height: 160.h,
          child: Stack(
            children: [
              GoogleMap(
                initialCameraPosition: CameraPosition(
                  target: location,
                  zoom: 15,
                ),
                markers: {
                  Marker(
                    markerId: const MarkerId('selected_location'),
                    position: location,
                  ),
                },
                zoomControlsEnabled: false,
                scrollGesturesEnabled: false,
                zoomGesturesEnabled: false,
                rotateGesturesEnabled: false,
                tiltGesturesEnabled: false,
                myLocationButtonEnabled: false,
                mapToolbarEnabled: false,
                liteModeEnabled: true,
              ),
              Positioned.fill(
                child: AbsorbPointer(
                  absorbing: true,
                  child: Container(color: Colors.transparent),
                ),
              ),
            ],
          ),
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
            inputFormatters: [EmojiInputFormatter()],
            style: TextStyle(
              fontSize: 16.sp,
              fontFamily: 'Montserrat',
              fontWeight: FontWeight.w400,
              color: const Color(0xFF28293D),
            ),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(
                color: const Color(0xFF8B8B8B),
                fontSize: 16.sp,
                fontFamily: 'Montserrat',
                fontWeight: FontWeight.w400,
              ),
              contentPadding: EdgeInsets.symmetric(
                horizontal: 18.w,
                vertical: 12.h,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
                borderSide: const BorderSide(color: Color(0xFFE5E5E5)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
                borderSide: const BorderSide(color: Color(0xFF3C4119)),
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
