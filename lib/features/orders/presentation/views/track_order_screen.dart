import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:patria/core/config/api_keys.dart';
import 'package:patria/core/routing/routes.dart';
import 'package:patria/core/utils/launcher_utils.dart';
import 'package:patria/features/orders/presentation/manager/track_order_bloc.dart';
import 'package:patria/features/orders/presentation/manager/track_order_event.dart';
import 'package:patria/features/orders/presentation/manager/track_order_state.dart';

import 'widgets/track_order_eta_card.dart';
import 'widgets/track_order_status.dart';

class TrackOrderScreen extends StatefulWidget {
  final String orderNumber;
  final String orderId;
  final String estimatedArrival;
  final int minsAway;
  final String riderName;
  final int currentStep;

  const TrackOrderScreen({
    super.key,
    required this.orderNumber,
    required this.orderId,
    this.estimatedArrival = '',
    this.minsAway = 18,
    this.riderName = 'Mostafa',
    this.currentStep = 0,
  });

  @override
  State<TrackOrderScreen> createState() => _TrackOrderScreenState();
}

class _TrackOrderScreenState extends State<TrackOrderScreen> {
  late TrackOrderBloc _trackOrderBloc;
  Timer? _pollingTimer;

  // ✅ Map
  GoogleMapController? _mapController;

  // ✅ Both locations now come from the API (customer + driver). Null = unknown.
  LatLng? _userLocation; // customer / delivery location
  LatLng? _driverLocation; // driver location

  // ✅ Route points from Directions API
  List<LatLng> _routePoints = [];
  bool _isLoadingRoute = false;

  // ✅ PolylinePoints instance with API key
  late PolylinePoints _polylinePoints;

  // ✅ Map can only be shown when both points are known
  bool get _canShowMap => _userLocation != null && _driverLocation != null;

  @override
  void initState() {
    super.initState();
    _polylinePoints = PolylinePoints(apiKey: googleApiKey);
    _trackOrderBloc = TrackOrderBloc()..add(LoadTrackOrder(widget.orderId));
    _startPolling();
  }

  @override
  void dispose() {
    _trackOrderBloc.close();
    _pollingTimer?.cancel();
    _mapController?.dispose();
    super.dispose();
  }

  // ✅ Update both locations from API; only rebuild/refetch when something changed
  void _updateLocations({
    double? customerLat,
    double? customerLng,
    double? driverLat,
    double? driverLng,
  }) {
    LatLng? newUser;
    LatLng? newDriver;

    if (customerLat != null && customerLng != null) {
      newUser = LatLng(customerLat, customerLng);
    }
    if (driverLat != null && driverLng != null) {
      newDriver = LatLng(driverLat, driverLng);
    }

    final changed = newUser != _userLocation || newDriver != _driverLocation;
    if (!changed) return;

    setState(() {
      _userLocation = newUser;
      _driverLocation = newDriver;
    });

    _fitBothMarkers();
    _getRoute();
  }

  // ✅ Fetch road route using Routes API v2
  Future<void> _getRoute() async {
    if (_userLocation == null || _driverLocation == null) return;

    setState(() => _isLoadingRoute = true);

    try {
      final response = await _polylinePoints.getRouteBetweenCoordinatesV2(
        request: RoutesApiRequest(
          origin: PointLatLng(
            _driverLocation!.latitude,
            _driverLocation!.longitude,
          ),
          destination: PointLatLng(
            _userLocation!.latitude,
            _userLocation!.longitude,
          ),
          travelMode: TravelMode.driving,
        ),
      );

      if (response.routes.isNotEmpty && mounted) {
        final points = _polylinePoints.convertToLegacyResult(response).points;
        setState(() {
          _routePoints = points
              .map((p) => LatLng(p.latitude, p.longitude))
              .toList();
        });
      }
    } catch (_) {
      // fallback to straight line
    } finally {
      if (mounted) setState(() => _isLoadingRoute = false);
    }
  }

  // ✅ Fit map to show both user and driver
  void _fitBothMarkers() {
    if (_mapController == null ||
        _userLocation == null ||
        _driverLocation == null)
      return;

    final bounds = LatLngBounds(
      southwest: LatLng(
        _userLocation!.latitude < _driverLocation!.latitude
            ? _userLocation!.latitude
            : _driverLocation!.latitude,
        _userLocation!.longitude < _driverLocation!.longitude
            ? _userLocation!.longitude
            : _driverLocation!.longitude,
      ),
      northeast: LatLng(
        _userLocation!.latitude > _driverLocation!.latitude
            ? _userLocation!.latitude
            : _driverLocation!.latitude,
        _userLocation!.longitude > _driverLocation!.longitude
            ? _userLocation!.longitude
            : _driverLocation!.longitude,
      ),
    );

    _mapController!.animateCamera(CameraUpdate.newLatLngBounds(bounds, 80));
  }

  // ✅ Road-following dashed polyline
  Set<Polyline> _buildPolylines() {
    if (_userLocation == null || _driverLocation == null) return {};

    final points = _routePoints.isNotEmpty
        ? _routePoints
        : [_driverLocation!, _userLocation!];

    return {
      Polyline(
        polylineId: const PolylineId('route'),
        points: points,
        color: const Color(0xFF28293D),
        width: 2,
        patterns: [PatternItem.dash(20), PatternItem.gap(10)],
      ),
    };
  }

  void _startPolling() {
    _pollingTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      if (mounted) {
        _trackOrderBloc.add(RefreshTrackOrder(widget.orderId));
      }
    });
  }

  void _goToHome() {
    Navigator.of(
      context,
      rootNavigator: true,
    ).pushNamedAndRemoveUntil(Routes.baseLayer, (route) => false);
  }

  void _showGetHelpSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (_) => Padding(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 24.h),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'get_help'.tr(),
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 18.sp,
                    fontFamily: 'Montserrat',
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.36,
                  ),
                ),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    width: 28.w,
                    height: 28.h,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.black, width: 1.5),
                    ),
                    child: const Icon(
                      Icons.close,
                      size: 18,
                      color: Colors.black,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 24.h),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      LauncherUtils.openWhatsAppSupport();
                    },
                    style: OutlinedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 14.h),
                      backgroundColor: const Color(0xFFE5E8D3),
                      side: const BorderSide(color: Color(0xFFE5E5E5)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                    ),
                    icon: Image.asset(
                      'assets/images/message_us.png',
                      width: 18.w,
                      height: 18.h,
                    ),
                    label: Text(
                      'message_us'.tr(),
                      style: TextStyle(
                        color: const Color(0xFF3C4119),
                        fontSize: 16,
                        fontFamily: 'Montserrat',
                        fontWeight: FontWeight.w600,
                        height: 1.50,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      LauncherUtils.callSupport();
                    },
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 14.h),
                      backgroundColor: const Color(0xFF3C4119),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      elevation: 0,
                    ),
                    icon: Image.asset(
                      'assets/images/call_us.png',
                      width: 18.w,
                      height: 18.h,
                    ),
                    label: Text(
                      'call_us'.tr(),
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontFamily: 'Montserrat',
                        fontWeight: FontWeight.w600,
                        height: 1.50,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 16.h),
          ],
        ),
      ),
    );
  }

  // ✅ Build tracking map (only called when both locations are known)
  Widget _buildTrackingMap() {
    final initialTarget = _userLocation!;

    final Set<Marker> markers = {
      Marker(
        markerId: const MarkerId('driver'),
        position: _driverLocation!,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange),
        infoWindow: InfoWindow(title: 'driver'.tr()),
      ),
      Marker(
        markerId: const MarkerId('user'),
        position: _userLocation!,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
        infoWindow: InfoWindow(title: 'your_location'.tr()),
      ),
    };

    return ClipRRect(
      borderRadius: BorderRadius.circular(16.r),
      child: SizedBox(
        height: 220.h,
        child: Stack(
          children: [
            GoogleMap(
              initialCameraPosition: CameraPosition(
                target: initialTarget,
                zoom: 20,
              ),
              onMapCreated: (controller) {
                _mapController = controller;
                _fitBothMarkers();
              },
              markers: markers,
              polylines: _buildPolylines(),
              zoomControlsEnabled: false,
              myLocationButtonEnabled: false,
              mapToolbarEnabled: false,
            ),

            // ✅ Loading indicator while fetching route
            if (_isLoadingRoute)
              Positioned(
                top: 8.h,
                right: 8.w,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8.r),
                    boxShadow: const [
                      BoxShadow(color: Color(0x1A000000), blurRadius: 4),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        width: 12.w,
                        height: 12.h,
                        child: const CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Color(0xFF3C4119),
                        ),
                      ),
                      SizedBox(width: 6.w),
                      Text(
                        'loading_route'.tr(),
                        style: TextStyle(
                          fontSize: 10.sp,
                          fontFamily: 'Montserrat',
                          color: const Color(0xFF3C4119),
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

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _trackOrderBloc,
      child: WillPopScope(
        onWillPop: () async {
          _goToHome();
          return false;
        },
        child: Scaffold(
          backgroundColor: const Color(0xFFF7F7F7),
          appBar: AppBar(
            backgroundColor: const Color(0xFFF7F7F7),
            elevation: 0,
            automaticallyImplyLeading: false,
            leading: GestureDetector(
              onTap: _goToHome,
              child: const Icon(Icons.arrow_back, color: Colors.black),
            ),
            title: Text(
              'track_order'.tr(),
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
          body: BlocConsumer<TrackOrderBloc, TrackOrderState>(
            listener: (context, state) {
              // ✅ Pull user (customer) + driver locations from the API
              if (state is TrackOrderLoaded) {
                final order = state.order;
                _updateLocations(
                  customerLat: order.customerLat,
                  customerLng: order.customerLng,
                  driverLat: order.driverLat,
                  driverLng: order.driverLng,
                );
              }
            },
            builder: (context, state) {
              if (state is TrackOrderLoading) {
                return const Center(child: CircularProgressIndicator());
              }

              if (state is TrackOrderError) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.error_outline,
                        size: 48,
                        color: Color(0xFFCACBD4),
                      ),
                      SizedBox(height: 12.h),
                      Text(
                        state.message,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: const Color(0xFF8B8B8B),
                          fontSize: 14.sp,
                          fontFamily: 'Montserrat',
                        ),
                      ),
                      SizedBox(height: 12.h),
                      ElevatedButton(
                        onPressed: () =>
                            _trackOrderBloc.add(LoadTrackOrder(widget.orderId)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF3C4119),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5.r),
                          ),
                        ),
                        child: Text(
                          'retry'.tr(),
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                );
              }

              if (state is TrackOrderLoaded) {
                final order = state.order;

                return RefreshIndicator(
                  color: const Color(0xFF3C4119),
                  onRefresh: () async {
                    _trackOrderBloc.add(RefreshTrackOrder(widget.orderId));
                    await Future.delayed(const Duration(milliseconds: 500));
                  },
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: EdgeInsets.symmetric(horizontal: 20.w),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 16.h),

                        // ✅ Only show the map when BOTH customer & driver
                        // coordinates are available (no const fallback).
                        if (_canShowMap) ...[
                          _buildTrackingMap(),
                          SizedBox(height: 16.h),
                        ],

                        TrackOrderEtaCard(
                          estimatedArrival:
                              order.estimatedArrival?.isNotEmpty == true
                              ? order.estimatedArrival!
                              : widget.estimatedArrival,
                        ),
                        SizedBox(height: 16.h),
                        TrackOrderStatus(
                          currentStep: order.currentStep,
                          isPending: order.currentStep < 3,
                        ),
                        SizedBox(height: 16.h),
                        _buildGetHelpButton(context),
                        SizedBox(height: 120.h),
                      ],
                    ),
                  ),
                );
              }

              return const SizedBox.shrink();
            },
          ),
        ),
      ),
    );
  }

  Widget _buildGetHelpButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 56.h,
      child: OutlinedButton.icon(
        onPressed: () => _showGetHelpSheet(context),
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: Color(0xFF3C4119)),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(5.r),
          ),
        ),
        icon: const Icon(
          Icons.help_outline,
          color: Color(0xFF3C4119),
          size: 18,
        ),
        label: Text(
          'get_help'.tr(),
          style: TextStyle(
            color: const Color(0xFF3C4119),
            fontSize: 16.sp,
            fontFamily: 'Montserrat',
            fontWeight: FontWeight.w600,
            height: 1.50,
          ),
        ),
      ),
    );
  }
}
