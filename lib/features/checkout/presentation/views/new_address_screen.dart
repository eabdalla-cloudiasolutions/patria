import 'package:dio/dio.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_places_flutter/google_places_flutter.dart';
import 'package:google_places_flutter/model/prediction.dart';
import 'package:patria/core/config/api_keys.dart';
import 'package:patria/core/utils/emoji_input_formatter.dart';
import 'package:patria/features/account/data/models/address_model.dart';
import 'package:patria/features/checkout/presentation/views/widgets/address_form_sheet.dart';

class NewAddressScreen extends StatefulWidget {
  final bool locationPickerOnly;

  const NewAddressScreen({
    super.key,
    this.locationPickerOnly = false, // default false = normal add address flow
  });

  @override
  State<NewAddressScreen> createState() => _NewAddressScreenState();
}

class _NewAddressScreenState extends State<NewAddressScreen> {
  GoogleMapController? _mapController;
  // ✅ Alexandria center — this app's service area. Used as the search-bias
  // anchor until GPS resolves; a Cairo default (220km away) made the
  // location bias useless for disambiguating Alexandria neighborhoods,
  // causing Google to substitute a more prominent nearby name for the one
  // actually searched (e.g. "Sidi Gabir" → "Officer's Housing").
  LatLng _currentCenter = const LatLng(31.2001, 29.9187);
  bool _isMapMoving = false;
  // ✅ Set right before we programmatically animate the camera after a
  // search selection. The zone is already resolved correctly from the
  // Places result at that point — onCameraIdle must not re-run native
  // reverse-geocoding and clobber it (iOS's CLGeocoder disagrees with
  // Google Places' naming for the same coordinates; Android's Geocoder
  // happens to agree, which is why this only ever showed up on iOS).
  bool _skipNextAreaUpdate = false;
  bool _isLoadingLocation = true;
  String _currentArea = '';

  // ✅ Tracks whether reverse-geocoding has produced a final result.
  // We gate the confirm button on THIS, not on a translated string,
  // so Android (where geocoding can return empty / throw) never gets stuck.
  bool _areaResolved = false;

  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _currentArea = 'locating'.tr();
    _initUserLocation();
    _searchController.addListener(_stripEmojiFromSearch);
  }

  void _stripEmojiFromSearch() {
    final filtered = EmojiInputFormatter.stripEmoji(_searchController.text);
    if (filtered != _searchController.text) {
      final offset = filtered.length;
      _searchController.value = _searchController.value.copyWith(
        text: filtered,
        selection: TextSelection.collapsed(offset: offset),
      );
    }
  }

  @override
  void dispose() {
    _searchController.removeListener(_stripEmojiFromSearch);
    _mapController?.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _initUserLocation() async {
    final position = await _getUserLocation();
    if (position != null && mounted) {
      setState(() {
        _currentCenter = LatLng(position.latitude, position.longitude);
        _isLoadingLocation = false;
      });
      _mapController?.animateCamera(
        CameraUpdate.newLatLngZoom(_currentCenter, 15),
      );
      await _updateAreaName(_currentCenter);
    } else {
      // ✅ No GPS fix (permission denied / location off — more common on
      // Android). Still resolve an area from the current map center so the
      // user isn't blocked forever.
      if (mounted) {
        setState(() => _isLoadingLocation = false);
        await _updateAreaName(_currentCenter);
      }
    }
  }

  // ✅ Google's own reverse-geocoding, same database the search box's Places
  // Autocomplete draws from. Used instead of the phone's native OS geocoder
  // so pin-drag and search selection can never disagree on a place's name
  // (Apple's CLGeocoder vs Android's Geocoder was the source of the
  // iOS/Android mismatches reported earlier).
  Future<String?> _reverseGeocodeWithGoogle(LatLng position) async {
    try {
      final response = await Dio().get(
        'https://maps.googleapis.com/maps/api/geocode/json',
        queryParameters: {
          'latlng': '${position.latitude},${position.longitude}',
          'key': googleApiKey,
          'language': 'en',
        },
      );
      final results = response.data['results'] as List?;
      if (results != null && results.isNotEmpty) {
        return results.first['formatted_address'] as String?;
      }
    } catch (_) {
      // ✅ Network/parsing failure — caller falls back to the native
      // geocoder rather than leaving _currentArea stuck.
    }
    return null;
  }

  Future<void> _updateAreaName(LatLng position) async {
    final googleAddress = await _reverseGeocodeWithGoogle(position);
    if (!mounted) return;
    if (googleAddress != null && googleAddress.isNotEmpty) {
      setState(() {
        _currentArea = googleAddress;
        _areaResolved = true;
      });
      return;
    }

    try {
      final placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );
      if (!mounted) return;

      // ✅ Android's native Geocoder frequently returns an EMPTY list
      // (instead of throwing) when its geocoding backend is unavailable.
      // Fall back to 'unknown_area' rather than leaving _currentArea stuck.
      String name = 'unknown_area'.tr();
      if (placemarks.isNotEmpty) {
        final p = placemarks.first;
        final parts = [
          p.street,
          p.subLocality,
          p.locality,
          p.administrativeArea,
          p.country,
        ].where((part) => part != null && part.trim().isNotEmpty).toSet();
        if (parts.isNotEmpty) {
          name = parts.join(', ');
        }
      }

      setState(() {
        _currentArea = name;
        _areaResolved = true; // ✅ unblock confirm
      });
    } catch (_) {
      // ✅ Geocoder threw (e.g. "grpc failed: Service not Available" on
      // Android). Don't trap the user — fall back and let them proceed.
      if (mounted) {
        setState(() {
          _currentArea = 'unknown_area'.tr();
          _areaResolved = true;
        });
      }
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

  void _dismissKeyboard() {
    SystemChannels.textInput.invokeMethod('TextInput.hide');
  }

  void _showAddressFormSheet(BuildContext context) {
    _dismissKeyboard();

    // ✅ Block only while geocoding is still in progress (boolean flag),
    // instead of comparing against a translated 'locating' string.
    if (!_areaResolved) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('please_wait_detecting_location'.tr()),
          backgroundColor: const Color(0xFF3C4119),
          behavior: SnackBarBehavior.floating,
          margin: EdgeInsets.only(left: 16.w, right: 16.w, bottom: 16.h),
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
        ),
      );
      return;
    }

    // ✅ If opened from EditAddressScreen — just return location, don't open sheet
    if (widget.locationPickerOnly) {
      Navigator.pop(context, {
        'zoneName': _currentArea,
        'lat': _currentCenter.latitude,
        'lng': _currentCenter.longitude,
      });
      return;
    }

    // ✅ Normal flow — open AddressFormSheet
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (_) => AddressFormSheet(
        initialLocation: _currentCenter,
        detectedZoneName: _currentArea,
        onSave: (AddressModel address, String zoneId) {
          Navigator.pop(context);
          Navigator.pop(context, {
            'zoneName': _currentArea,
            'lat': _currentCenter.latitude,
            'lng': _currentCenter.longitude,
            'addressId': address.id,
          });
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
                // ── Google Map ──
                GestureDetector(
                  onTap: _dismissKeyboard,
                  child: GoogleMap(
                    initialCameraPosition: CameraPosition(
                      target: _currentCenter,
                      zoom: 15,
                    ),
                    onMapCreated: (controller) {
                      _mapController = controller;
                      if (!_isLoadingLocation) {
                        controller.animateCamera(
                          CameraUpdate.newLatLngZoom(_currentCenter, 15),
                        );
                      }
                    },
                    onCameraMove: (position) {
                      _dismissKeyboard(); // ✅ dismiss when map moves
                      setState(() {
                        _isMapMoving = true;
                        _currentCenter = position.target;
                      });
                    },
                    onCameraIdle: () async {
                      setState(() => _isMapMoving = false);
                      if (_skipNextAreaUpdate) {
                        _skipNextAreaUpdate = false;
                        return;
                      }
                      await _updateAreaName(_currentCenter);
                    },
                    myLocationEnabled: false,
                    myLocationButtonEnabled: false,
                    zoomControlsEnabled: false,
                    mapToolbarEnabled: false,
                  ),
                ),

                // ── Loading indicator ──
                if (_isLoadingLocation)
                  const Center(
                    child: CircularProgressIndicator(color: Color(0xFF3C4119)),
                  ),

                // ── Center pin ──
                if (!_isLoadingLocation)
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 8.w,
                          vertical: 5.h,
                        ),
                        decoration: ShapeDecoration(
                          color: Colors.white,
                          shape: RoundedRectangleBorder(
                            side: const BorderSide(color: Color(0xFF3C4119)),
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
                            color: const Color(0xFF28293D),
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
                          0,
                          _isMapMoving ? -8 : 0,
                          0,
                        ),
                        child: const Icon(
                          Icons.location_pin,
                          color: Color(0xFF3C4119),
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
                    onTap: () {
                      _dismissKeyboard();
                      _initUserLocation();
                    },
                    child: Container(
                      width: 56.w,
                      height: 56.h,
                      decoration: ShapeDecoration(
                        color: const Color(0xFF3C4119),
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

                // ✅ Search with autocomplete
                Positioned(
                  top: 16.h,
                  left: 16.w,
                  right: 16.w,
                  child: GooglePlaceAutoCompleteTextField(
                    textEditingController: _searchController,
                    googleAPIKey: googleApiKey,
                    inputDecoration: InputDecoration(
                      hintText: 'search_location'.tr(),
                      hintStyle: TextStyle(
                        color: const Color(0xFF8B8B8B),
                        fontSize: 16.sp,
                        fontFamily: 'Montserrat',
                        fontWeight: FontWeight.w400,
                        letterSpacing: 0.32,
                      ),
                      prefixIcon: Padding(
                        padding: const EdgeInsets.all(14),
                        child: Image.asset(
                          'assets/images/search.png',
                          width: 20.w,
                          height: 20.h,
                        ),
                      ),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(
                                Icons.close,
                                size: 18,
                                color: Color(0xFF8B8B8B),
                              ),
                              onPressed: () {
                                _searchController.clear();
                                _dismissKeyboard();
                                setState(() {});
                              },
                            )
                          : null,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.r),
                        borderSide: BorderSide(
                          width: 1.w,
                          color: const Color(0xFFCACBD4),
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.r),
                        borderSide: BorderSide(
                          width: 1.w,
                          color: const Color(0xFFCACBD4),
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.r),
                        borderSide: BorderSide(
                          width: 1.w,
                          color: const Color(0xFF3C4119),
                        ),
                      ),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 16.w,
                        vertical: 14.h,
                      ),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                    debounceTime: 400,
                    countries: const ['eg'],
                    isLatLngRequired: true,
                    latitude: _currentCenter.latitude,
                    longitude: _currentCenter.longitude,
                    radius: 20000,
                    itemClick: (Prediction prediction) {
                      _searchController.text = prediction.description ?? '';
                      _searchController.selection = TextSelection.fromPosition(
                        TextPosition(offset: _searchController.text.length),
                      );
                      _dismissKeyboard(); // ✅
                    },
                    getPlaceDetailWithLatLng: (Prediction prediction) async {
                      _dismissKeyboard(); // ✅

                      if (prediction.lat != null && prediction.lng != null) {
                        final lat = double.parse(prediction.lat!);
                        final lng = double.parse(prediction.lng!);
                        final newLatLng = LatLng(lat, lng);

                        // ✅ Zone = the full text of whatever the user picked
                        // from the search dropdown, verbatim. Not re-derived
                        // from the native OS geocoder (which was the source
                        // of the iOS-only naming mismatch) and not matched
                        // against the backend zone list.
                        final placeName = prediction.description ?? '';

                        _skipNextAreaUpdate = true;
                        setState(() {
                          _currentCenter = newLatLng;
                          _searchController.text = prediction.description ?? '';
                          _currentArea = placeName;
                          _areaResolved = true;
                        });

                        _mapController?.animateCamera(
                          CameraUpdate.newLatLngZoom(newLatLng, 15),
                        );
                      }
                    },
                    seperatedBuilder: Divider(
                      height: 1.h,
                      color: const Color(0xFFE5E5E5),
                    ),
                    containerHorizontalPadding: 0,
                    itemBuilder: (context, index, Prediction prediction) {
                      return Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 16.w,
                          vertical: 10.h,
                        ),
                        color: Colors.white,
                        child: Row(
                          children: [
                            const Icon(
                              Icons.location_on_outlined,
                              size: 16,
                              color: Color(0xFF3C4119),
                            ),
                            SizedBox(width: 8.w),
                            Expanded(
                              child: Text(
                                prediction.description ?? '',
                                style: TextStyle(
                                  color: const Color(0xFF28293D),
                                  fontSize: 13.sp,
                                  fontFamily: 'Montserrat',
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                    isCrossBtnShown: true,
                    boxDecoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12.r),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x1A000000),
                          blurRadius: 8,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                  ),
                ),

                // ✅ Detected area label
                if (!_isLoadingLocation && _currentArea.isNotEmpty)
                  Positioned(
                    top: 76.h,
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        maxWidth: MediaQuery.of(context).size.width - 40.w,
                      ),
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 12.w,
                          vertical: 6.h,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20.r),
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0x1A000000),
                              blurRadius: 6,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: EdgeInsets.only(top: 2.h),
                              child: const Icon(
                                Icons.location_on,
                                size: 14,
                                color: Color(0xFF6B5E4B),
                              ),
                            ),
                            SizedBox(width: 4.w),
                            Flexible(
                              child: Text(
                                _currentArea,
                                softWrap: true,
                                style: TextStyle(
                                  color: const Color(0xFF28293D),
                                  fontSize: 12.sp,
                                  fontFamily: 'Montserrat',
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
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
              top: 10.h,
              left: 20.w,
              right: 20.w,
              bottom: 32.h,
            ),
            decoration: ShapeDecoration(
              color: const Color(0xFFFAFAF7),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(22.r),
                  topRight: Radius.circular(22.r),
                ),
              ),
              shadows: const [
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
                SizedBox(height: 16.h),
                SizedBox(
                  width: double.infinity,
                  height: 56.h,
                  child: ElevatedButton(
                    onPressed: () => _showAddressFormSheet(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF3C4119),
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
                SizedBox(height: 24.h),
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
