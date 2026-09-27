// import 'dart:async';
// import 'dart:convert';

// import 'package:patria/core/config/mapbox_config.dart';
// import 'package:patria/core/models/map_state.dart';
// import 'package:patria/core/services/direction_service.dart';
// import 'package:patria/core/services/location_service.dart';
// import 'package:patria/core/services/search_service.dart';
// import 'package:flutter_riverpod/legacy.dart';
// import 'package:geolocator/geolocator.dart' as geo;
// import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';

// final mapProvider = StateNotifierProvider<MapNotifier, MapState>(
//   (ref) => MapNotifier(),
// );

// class MapNotifier extends StateNotifier<MapState> {
//   MapNotifier() : super(MapState());

//   MapboxMap? _mapboxMap;
//   geo.Position? _currentPosition;
//   PointAnnotationManager? _annotationManager;
//   PointAnnotation? _driverMarker;
//   StreamSubscription? _simulationSubscription;

//   final _searchService = SearchService();
//   final _directionsService = DirectionService();

//   static const String _routeSourceId = 'route-source';
//   static const String _routeLayerId = 'route-layer';

//   //Ma Ready
//   Future<void> onMapCreated(MapboxMap mapboxMap) async {
//     _annotationManager = await mapboxMap.annotations
//         .createPointAnnotationManager(id: 'driver-layer', below: '');
//     _mapboxMap = mapboxMap;

//     await mapboxMap.location.updateSettings(
//       LocationComponentSettings(
//         enabled: true,
//         pulsingEnabled: true,
//         showAccuracyRing: true,
//       ),
//     );
//     await initLocation();
//   }

//   //  location
//   Future<void> initLocation() async {
//     final position = await LocationService.getCurrentLocation();
//     if (position != null) {
//       _currentPosition = position;
//       await flyToLocation(position.longitude, position.latitude, zoom: 14);
//     }
//   }

//   //camera
//   Future<void> flyToLocation(double lng, double lat, {double zoom = 14}) async {
//     await _mapboxMap?.flyTo(
//       CameraOptions(
//         center: Point(coordinates: Position(lng, lat)),
//         zoom: zoom,
//         bearing: 0,
//         pitch: 0,
//       ),
//       MapAnimationOptions(duration: 1500),
//     );
//   }

//   // search

//   Future<void> onSearchChanged(String query) async {
//     if (query.length < 2) {
//       state = state.copyWith(suggestions: [], showSuggestions: false);
//       return;
//     }

//     final suggestions = await _searchService.getSuggestions(
//       query,
//       proximityLng: _currentPosition?.longitude,
//       proximityLat: _currentPosition?.latitude,
//     );
//     state = state.copyWith(
//       suggestions: suggestions,
//       showSuggestions: suggestions.isNotEmpty,
//     );
//   }

//   void hideSuggestions() {
//     state = state.copyWith(
//       suggestions: [],
//       showSuggestions: false,
//     );
//   }

// //style
//   Future<void> toggleStyle() async {
//     final isSatellite = state.currentStyle == MapboxConfig.styleSatellite;
//     final newStyle =
//         isSatellite ? MapboxConfig.styleStreet : MapboxConfig.styleSatellite;
//     state = state.copyWith(currentStyle: newStyle);
//     await _mapboxMap?.loadStyleURI(newStyle);
//   }

//   //suggestion selected
//   Future<void> onSuggestionSelected(PlaceSuggestion place) async {
//     state = state.copyWith(
//       showSuggestions: false,
//       suggestions: [],
//       isLoading: true,
//       selectedPlaceName: place.name,
//     );
//     await flyToLocation(place.longitude, place.latitude, zoom: 13);
//     if (_currentPosition == null) {
//       state = state.copyWith(isLoading: false);
//       return;
//     }
//     final route = await _directionsService.getRoute(
//       originLng: _currentPosition!.longitude,
//       originLat: _currentPosition!.latitude,
//       destinationLng: place.longitude,
//       destinationLat: place.latitude,
//     );

//     if (route != null) {
//       state = state.copyWith(currentRoute: route);
//       await _drawRoute(route);
//       // await _createDriverMarker(
//       //   route.coordinates[0][0],
//       //   route.coordinates[0][1],
//       // );
//       await _fitRouteBounds(route);
//     }
//     state = state.copyWith(isLoading: false);
//   }

//   // route
//   Future<void> _drawRoute(RouteResult route) async {
//     final map = _mapboxMap;
//     if (map == null) return;

//     final styleLoaded = await map.style.isStyleLoaded();
//     if (!styleLoaded) return;

//     await clearRoute(clearState: false);

//     final geoJson = {
//       'type': 'Feature',
//       'geometry': {'type': 'LineString', 'coordinates': route.coordinates},
//     };
//     await map.style.addSource(
//       GeoJsonSource(id: _routeSourceId, data: jsonEncode(geoJson)),
//     );

//     await map.style.addLayer(
//       LineLayer(
//         id: _routeLayerId,
//         sourceId: _routeSourceId,
//         lineColor: 0xFF4A90D9,
//         lineWidth: 5.0,
//         lineCap: LineCap.ROUND,
//         lineJoin: LineJoin.ROUND,
//       ),
//     );

//     // Recreate annotation manager above route layer

//     await _annotationManager?.deleteAll();
//     _annotationManager =
//         await _mapboxMap?.annotations.createPointAnnotationManager();
//   }

//   // clear route
//   Future<void> clearRoute({bool clearState = true}) async {
//     final map = _mapboxMap;
//     if (map == null) return;
//     try {
//       await map.style.removeStyleLayer(_routeLayerId);
//       await map.style.removeStyleSource(_routeSourceId);
//     } catch (_) {}
//     if (clearState) {
//       state = state.copyWith(clearRoute: true);
//     }
//   }

//   Future<void> _fitRouteBounds(RouteResult route) async {
//     if (route.coordinates.isEmpty) return;
//     double minLng = route.coordinates[0][0];
//     double maxLng = route.coordinates[0][0];
//     double minLat = route.coordinates[0][1];
//     double maxLat = route.coordinates[0][1];

//     for (final c in route.coordinates) {
//       if (c[0] < minLng) minLng = c[0];
//       if (c[0] > maxLng) maxLng = c[0];
//       if (c[0] < minLat) minLat = c[1];
//       if (c[0] > maxLat) maxLat = c[1];
//     }
//     await _mapboxMap
//         ?.cameraForCoordinateBounds(
//           CoordinateBounds(
//               southwest: Point(coordinates: Position(minLng, minLat)),
//               northeast: Point(coordinates: Position(maxLng, maxLat)),
//               infiniteBounds: false),
//           MbxEdgeInsets(top: 100, left: 50, bottom: 200, right: 50),
//           null,
//           null,
//           null,
//           null,
//         )
//         .then(
//           (camera) =>
//               _mapboxMap?.flyTo(camera, MapAnimationOptions(duration: 1500)),
//         );
//   }

// // recent location
//   Future<void> recentLoaction() async {
//     final pos = await LocationService.getCurrentLocation();
//     if (pos != null) {
//       _currentPosition = pos;
//       await flyToLocation(pos.longitude, pos.latitude, zoom: 15);
//     }
//   }

// // marke.
// }
