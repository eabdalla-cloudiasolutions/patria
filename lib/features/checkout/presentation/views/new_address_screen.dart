import 'package:easy_localization/easy_localization.dart';
import 'package:erb/features/checkout/presentation/views/widgets/address_form_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

class NewAddressScreen extends StatefulWidget {
  const NewAddressScreen({super.key});

  @override
  State<NewAddressScreen> createState() => _NewAddressScreenState();
}

class _NewAddressScreenState extends State<NewAddressScreen> {
  final MapController _mapController = MapController();
  LatLng _currentCenter = const LatLng(30.0444, 31.2357);
  bool _isMapMoving = false;
  bool _isLoadingLocation = true;
  late String _currentArea;
  bool _autoLocate = true;

  @override
  void initState() {
    super.initState();
    _currentArea = 'locating'.tr();
    _initUserLocation();
  }

  Future<void> _initUserLocation() async {
    final position = await _getUserLocation();
    if (position != null && mounted) {
      setState(() {
        _currentCenter = LatLng(position.latitude, position.longitude);
        _isLoadingLocation = false;
      });
      _mapController.move(_currentCenter, 15);
      await _updateAreaName(_currentCenter);
    } else {
      setState(() => _isLoadingLocation = false);
    }
  }

  Future<void> _updateAreaName(LatLng position) async {
    try {
      final placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );
      if (placemarks.isNotEmpty && mounted) {
        setState(() {
          _currentArea = placemarks.first.subLocality ??
              placemarks.first.locality ??
              'unknown_area'.tr();
        });
      }
    } catch (_) {
      setState(() => _currentArea = 'unknown_area'.tr());
    }
  }

  Future<Position?> _getUserLocation() async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) return null;
      }
      if (permission == LocationPermission.deniedForever) return null;
      return await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );
    } catch (_) {
      return null;
    }
  }

  void _showAddressFormSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (_) => AddressFormSheet(
        onSave: (String addressData, String zoneId) {
          // added zoneId
          print('✅ Zone ID received: $zoneId');

          Navigator.pop(context);
          Navigator.pop(context, addressData);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFAFAF7),
        elevation: 0,
        leading: const BackButton(color: Colors.black),
        title: Text(
          'new_address'.tr(),
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
          // ── Map section ──
          Expanded(
            child: Stack(
              alignment: Alignment.center,
              children: [
                if (_isLoadingLocation)
                  const Center(
                    child: CircularProgressIndicator(
                      color: Color(0xFF6B5E4B),
                    ),
                  ),

                FlutterMap(
                  mapController: _mapController,
                  options: MapOptions(
                    initialCenter: _currentCenter,
                    initialZoom: 15,
                    onMapEvent: (event) async {
                      if (event is MapEventMoveStart) {
                        setState(() => _isMapMoving = true);
                      } else if (event is MapEventMoveEnd ||
                          event is MapEventFlingAnimationEnd) {
                        setState(() {
                          _isMapMoving = false;
                          _currentCenter = _mapController.camera.center;
                        });
                        await _updateAreaName(_currentCenter);
                      }
                    },
                  ),
                  children: [
                    TileLayer(
                      urlTemplate:
                          'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'com.example.erb',
                    ),
                  ],
                ),

                // ── Center pin ──
                if (!_isLoadingLocation)
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 8.w, vertical: 5.h),
                        decoration: ShapeDecoration(
                          color: Colors.white,
                          shape: RoundedRectangleBorder(
                            side: const BorderSide(color: Color(0xFF6B5E4B)),
                            borderRadius: BorderRadius.circular(6.r),
                          ),
                          shadows: const [
                            BoxShadow(
                              color: Color(0x1A000000),
                              blurRadius: 6,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Text(
                          'move_to_edit_location'.tr(),
                          style: TextStyle(
                            color: Color(0xFF28293D),
                            fontSize: 12.sp,
                            fontFamily: 'Montserrat',
                            fontWeight: FontWeight.w500,
                            letterSpacing: 0.24,
                          ),
                        ),
                      ),
                      SizedBox(height: 4.h),
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 150),
                        transform: Matrix4.translationValues(
                            0, _isMapMoving ? -8 : 0, 0),
                        child: const Icon(
                          Icons.location_pin,
                          color: Color(0xFF6B5E4B),
                          size: 40,
                        ),
                      ),
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 150),
                        width: _isMapMoving ? 16.w : 10.w,
                        height: _isMapMoving ? 4.h : 6.h,
                        decoration: BoxDecoration(
                          color: Colors.black26,
                          borderRadius: BorderRadius.circular(10.r),
                        ),
                      ),
                    ],
                  ),

                // ── My location FAB ──
                Positioned(
                  right: 16.w,
                  bottom: 16.h,
                  child: GestureDetector(
                    onTap: _initUserLocation,
                    child: Container(
                      width: 56.w,
                      height: 56.h,
                      decoration: ShapeDecoration(
                        color: const Color(0xFF6B5E4B),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                      ),
                      child: const Icon(
                        Icons.my_location,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ── Bottom panel ──
          Container(
            width: double.infinity,
            padding: EdgeInsets.only(
                top: 20.h, left: 20.w, right: 20.w, bottom: 32.h),
            decoration: ShapeDecoration(
              color: Color(0xFFFAFAF7),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(22.r),
                  topRight: Radius.circular(22.r),
                ),
              ),
              shadows: [
                BoxShadow(
                  color: Color(0x26000000),
                  blurRadius: 8,
                  offset: Offset(1, 0),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GestureDetector(
                  onTap: () {
                    setState(() => _autoLocate = !_autoLocate);
                    if (_autoLocate) {
                      _initUserLocation(); // ✅ re-locate when enabled
                    }
                  },
                  child: Row(
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: 20.w,
                        height: 20.h,
                        decoration: ShapeDecoration(
                          color: _autoLocate
                              ? const Color(0xFF6B5E4B)
                              : Colors.transparent,
                          shape: RoundedRectangleBorder(
                            side: const BorderSide(color: Color(0xFF6B5E4B)),
                            borderRadius: BorderRadius.circular(6.r),
                          ),
                        ),
                        child: _autoLocate
                            ? const Icon(Icons.check,
                                size: 14, color: Colors.white)
                            : null,
                      ),
                      SizedBox(width: 6.w),
                      Text(
                        'auto_locate'.tr(),
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
                SizedBox(height: 12.h),
                Divider(color: Color(0xFFCACBD4), height: 1.h),
                SizedBox(height: 12.h),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE5E5E5),
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.location_on_outlined,
                          size: 24, color: Color(0xFF6B5E4B)),
                      SizedBox(width: 8.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'allow_location_access'.tr(),
                              style: TextStyle(
                                color: Color(0xFF333333),
                                fontSize: 16.sp,
                                fontFamily: 'Montserrat',
                                fontWeight: FontWeight.w500,
                                letterSpacing: 0.32,
                              ),
                            ),
                            SizedBox(height: 4.h),
                            Text(
                              'allow_location_desc'.tr(),
                              style: TextStyle(
                                color: Color(0xFF28293D),
                                fontSize: 12.sp,
                                fontFamily: 'Montserrat',
                                fontWeight: FontWeight.w400,
                                letterSpacing: 0.24,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 16.h),
                SizedBox(
                  width: double.infinity,
                  height: 56.h,
                  child: ElevatedButton(
                    onPressed: () => _showAddressFormSheet(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF6B5E4B),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5.r),
                      ),
                    ),
                    child: Text(
                      'confirm_add_details'.tr(),
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16.sp,
                        fontFamily: 'Montserrat',
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 8.h),
                Center(
                  child: Container(
                    width: 140.w,
                    height: 4.h,
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(100.r),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
