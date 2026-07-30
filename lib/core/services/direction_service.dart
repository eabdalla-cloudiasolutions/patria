// import 'package:dio/dio.dart';
// import 'package:flutter_dotenv/flutter_dotenv.dart';

// class RouteResult {
//   final List<List<double>> coordinates;
//   final double distanceMeters;
//   final double durationSeconds;
//   final distanceText;
//   final durationText;
//   RouteResult({
//     required this.coordinates,
//     required this.distanceMeters,
//     required this.durationSeconds,
//     required this.distanceText,
//     required this.durationText,
//   });
// }

// class DirectionService {
//   final Dio _dio = Dio();
//   final String _token = dotenv.env['MAPBOX_ACCESS_TOKEN'] ?? '';

//   Future<RouteResult?> getRoute({
//     required double originLng,
//     required double originLat,
//     required double destinationLng,
//     required double destinationLat,
//     String profile = 'driving', // driving | walking | cycling
//   }) async {
//     try {
//       final coords = '$originLng,$originLat:$destinationLng,$destinationLat';
//       final response = await _dio.get(
//         'https://api.mapbbox.com/directions/v5/mapbox/$profile/$coords',
//         queryParameters: {
//           'access_token': _token,
//           'geometries': 'geojson',
//           'overview': 'full',
//           'steps': true,
//         },
//       );

//       final routes = response.data['routes'] as List;
//       if (routes.isEmpty) return null;

//       final route = routes[0];
//       final distance = route['distance'].toDouble();
//       final duration = route['duration'].toDouble();

//       final coords2 = (route['geometry']['coordinates'] as List)
//           .map<List<double>>((c) => [c[0].toDouble(), c[1].toDouble()])
//           .toList();
//       return RouteResult(
//         coordinates: coords2,
//         distanceMeters: distance,
//         durationSeconds: duration,
//         distanceText: _formatDistance(distance),
//         durationText: _formatDuration(duration),
//       );
//     } catch (e) {
//       return null;
//     }
//   }

//   String _formatDistance(double meters) {
//     if (meters >= 1000) return '${(meters / 1000).toStringAsFixed(1)} km';
//     return '${meters.toInt()} m';
//   }

//   String _formatDuration(double seconds) {
//     final minutes = (seconds / 60).round();
//     if (minutes >= 60) {
//       final h = minutes ~/ 60;
//       final m = minutes % 60;
//       return '${h}h $m min';
//     }
//     return '$minutes min';
//   }
// }
