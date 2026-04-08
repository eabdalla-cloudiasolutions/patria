import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:latlong2/latlong.dart';

class TrackOrderMap extends StatelessWidget {
  const TrackOrderMap({super.key});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16.r),
      child: SizedBox(
        height: 200.h,
        child: Stack(
          children: [
            FlutterMap(
              options: const MapOptions(
                initialCenter: LatLng(30.0444, 31.2357),
                initialZoom: 14,
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.example.erb',
                ),
                const MarkerLayer(
                  markers: [
                    Marker(
                      point: LatLng(30.0444, 31.2357),
                      child: Icon(
                        Icons.location_pin,
                        color: Color(0xFF6B5E4B),
                        size: 36,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            // Your Location badge
            Positioned(
              right: 12.w,
              top: 12.h,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8.r),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x19000000),
                      blurRadius: 3,
                      offset: Offset(0, 1),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.my_location, size: 11, color: Color(0xFF6B5E4B)),
                    SizedBox(width: 4.w),
                    Text(
                      'your_location'.tr(),
                      style: TextStyle(
                        color: Color(0xFF333333),
                        fontSize: 10.sp,
                        fontFamily: 'Montserrat',
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Rider pin
            Positioned(
              left: 60.w,
              top: 80.h,
              child: Icon(
                Icons.delivery_dining,
                color: Color(0xFF6B5E4B),
                size: 32,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
