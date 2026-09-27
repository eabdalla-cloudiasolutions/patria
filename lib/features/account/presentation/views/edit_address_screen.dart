import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:patria/core/utils/validators.dart';
import 'package:patria/features/account/data/apis/addresses_api.dart';
import 'package:patria/features/account/presentation/views/widgets/edit_address_form.dart';
import 'package:patria/features/account/presentation/views/widgets/edit_address_tags_row.dart';
import 'package:patria/features/checkout/presentation/views/new_address_screen.dart';

class EditAddressScreen extends StatefulWidget {
  final Map<String, dynamic> address;

  const EditAddressScreen({super.key, required this.address});

  @override
  State<EditAddressScreen> createState() => _EditAddressScreenState();
}

class _EditAddressScreenState extends State<EditAddressScreen> {
  late TextEditingController _buildingController;
  late TextEditingController _aptController;
  late TextEditingController _floorController;
  late TextEditingController _streetController;
  late TextEditingController _nearbyController;
  late TextEditingController _phoneController;
  late TextEditingController _cityController;

  String _selectedTag = 'Home';
  bool _isDefault = false;
  bool _isLoading = false;
  String? _selectedZoneName;
  String? _phoneError;

  // ✅ Map location
  LatLng? _mapLocation;
  bool _isGeocodingLocation = true;

  @override
  void initState() {
    super.initState();
    _selectedTag = widget.address['label'] ?? 'Home';
    _isDefault = widget.address['isDefault'] ?? false;

    _buildingController = TextEditingController(
      text: widget.address['buildingName'] ?? '',
    );
    _aptController = TextEditingController(
      text: widget.address['apartmentNo'] ?? '',
    );
    _floorController = TextEditingController(
      text: widget.address['floor'] ?? '',
    );
    _streetController = TextEditingController(
      text: widget.address['street'] ?? '',
    );
    _nearbyController = TextEditingController(
      text: widget.address['nearbyTrademark'] ?? '',
    );
    _phoneController = TextEditingController(
      text: widget.address['phone'] ?? '',
    );
    _cityController = TextEditingController(text: widget.address['city'] ?? '');

    _selectedZoneName = widget.address['zone']?.toString() ?? 'Unnamed zone';

    // ✅ Geocode address to get map coordinates
    _geocodeAddress();
  }

  // ✅ Convert address to LatLng for map display
  Future<void> _geocodeAddress() async {
    try {
      final street = widget.address['street'] ?? '';
      final city = widget.address['city'] ?? '';
      final zone = widget.address['zone'] ?? '';
      final query = '$street, $zone, $city';

      final locations = await locationFromAddress(query);
      if (locations.isNotEmpty && mounted) {
        setState(() {
          _mapLocation = LatLng(
            locations.first.latitude,
            locations.first.longitude,
          );
          _isGeocodingLocation = false;
        });
      } else {
        // ✅ Fallback to Cairo center
        if (mounted) {
          setState(() {
            _mapLocation = const LatLng(30.0444, 31.2357);
            _isGeocodingLocation = false;
          });
        }
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _mapLocation = const LatLng(30.0444, 31.2357);
          _isGeocodingLocation = false;
        });
      }
    }
  }

  // ✅ Open NewAddressScreen to change zone
  void _changeLocation() async {
    final result = await Navigator.of(context, rootNavigator: true).push(
      MaterialPageRoute(
        builder: (_) => const NewAddressScreen(
          locationPickerOnly: true, // ✅ just pick location, no address form
        ),
      ),
    );

    if (result != null && result is Map) {
      setState(() {
        if (result['zoneName'] != null) {
          _selectedZoneName = result['zoneName'];
        }
        if (result['lat'] != null && result['lng'] != null) {
          _mapLocation = LatLng(result['lat'], result['lng']);
        }
      });
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
    _cityController.dispose();
    super.dispose();
  }

  void _deleteAddress() {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: Text(
          'delete_address'.tr(),
          style: TextStyle(
            fontFamily: 'Montserrat',
            fontWeight: FontWeight.w600,
            fontSize: 16.sp,
          ),
        ),
        content: Text(
          'delete_address_message'.tr(),
          style: TextStyle(
            fontFamily: 'Montserrat',
            fontWeight: FontWeight.w400,
            fontSize: 14.sp,
            color: const Color(0xFF515151),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(
              'cancel'.tr(),
              style: const TextStyle(
                color: Color(0xFF3C4119),
                fontFamily: 'Montserrat',
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              Navigator.pop(context, {'deleted': true});
            },
            child: Text(
              'delete'.tr(),
              style: const TextStyle(
                color: Color(0xFFC90000),
                fontFamily: 'Montserrat',
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _saveChanges() async {
    final phoneError = Validators.optionalPhone(_phoneController.text);
    setState(() => _phoneError = phoneError);
    if (phoneError != null) return;

    final id = widget.address['_id']?.toString() ?? '';

    if (id.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Invalid address ID',
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          backgroundColor: const Color(0xFFC90000),
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
          margin: EdgeInsets.only(left: 16.w, right: 16.w, bottom: 16.h),
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      await AddressesApi().updateAddress(
        id: id,
        label: _selectedTag,
        street: _streetController.text.trim(),
        city: _cityController.text.trim(),
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
        lat: _mapLocation?.latitude, // ✅
        lng: _mapLocation?.longitude, // ✅
        isDefault: _isDefault,
      );

      if (!mounted) return;
      Navigator.pop(context, {'updated': true});
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            e.toString(),
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          backgroundColor: const Color(0xFFC90000),
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
          margin: EdgeInsets.only(left: 16.w, right: 16.w, bottom: 16.h),
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF7F7F7),
        elevation: 0,
        leading: const BackButton(color: Colors.black),
        title: Text(
          'edit_address'.tr(),
          style: TextStyle(
            color: Colors.black,
            fontSize: 18.sp,
            fontFamily: 'Montserrat',
            fontWeight: FontWeight.w600,
            letterSpacing: 0.36,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ✅ Static map at top
                  _buildStaticMap(),

                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20.w),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 16.h),

                        // ✅ Zone field — same UI as AddressFormSheet
                        _buildZoneField(),
                        SizedBox(height: 16.h),

                        EditAddressTagsRow(
                          selectedTag: _selectedTag,
                          onTagSelected: (tag) =>
                              setState(() => _selectedTag = tag),
                        ),
                        SizedBox(height: 16.h),

                        EditAddressForm(
                          buildingController: _buildingController,
                          aptController: _aptController,
                          floorController: _floorController,
                          streetController: _streetController,
                          nearbyController: _nearbyController,
                          phoneController: _phoneController,
                          phoneErrorText: _phoneError,
                          // cityController: _cityController,
                        ),
                        SizedBox(height: 16.h),

                        // Set as default
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
                        SizedBox(height: 32.h),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ✅ Save button
          Container(
            padding: EdgeInsets.only(
              left: 20.w,
              right: 20.w,
              bottom: 32.h,
              top: 16.h,
            ),
            color: const Color(0xFFF7F7F7),
            child: SizedBox(
              width: double.infinity,
              height: 56.h,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _saveChanges,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF3C4119),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5),
                  ),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Text(
                        'save_changes'.tr(),
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16.sp,
                          fontFamily: 'Montserrat',
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ✅ Static non-interactive map — same style as AddressFormSheet
  Widget _buildStaticMap() {
    return Padding(
      padding: EdgeInsets.only(left: 20.w, right: 20.w, top: 16.h),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12.r),
        child: SizedBox(
          height: 160.h,
          child: _isGeocodingLocation
              ? Container(
                  color: const Color(0xFFE5E5E5),
                  child: const Center(
                    child: CircularProgressIndicator(color: Color(0xFF3C4119)),
                  ),
                )
              : Stack(
                  children: [
                    GoogleMap(
                      initialCameraPosition: CameraPosition(
                        target: _mapLocation!,
                        zoom: 15,
                      ),
                      markers: {
                        Marker(
                          markerId: const MarkerId('address_location'),
                          position: _mapLocation!,
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
                    // ✅ Block all touch
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

  // ✅ Zone field — same UI as AddressFormSheet
  Widget _buildZoneField() {
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

          // Label + Value
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

          // ✅ Change → open NewAddressScreen
          GestureDetector(
            onTap: _changeLocation,
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
}
