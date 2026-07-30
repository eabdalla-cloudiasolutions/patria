// import 'package:dio/dio.dart';
// import 'package:flutter_dotenv/flutter_dotenv.dart';

// class PlaceSuggestion {
//   final String id;
//   final String name;
//   final String fullAddress;
//   final double latitude;
//   final double longitude;

//   PlaceSuggestion(
//       {required this.id,
//       required this.name,
//       required this.fullAddress,
//       required this.latitude,
//       required this.longitude});
// }

// class SearchService {
//   final Dio _dio = Dio();
//   final String _token = dotenv.env['MAPBOX_ACCESS_TOKEN'] ?? '';
//   Future<List<PlaceSuggestion>> getSuggestions(
//     String query, {
//     double? proximityLng,
//     double? proximityLat,
//   }) async {
//     if (query.isEmpty) return [];
//     try {
//       final proximity = (proximityLng != null && proximityLat != null)
//           ? '$proximityLng,$proximityLat'
//           : null;

//       final response = await _dio.get(
//         'https://api.mapbox.com/geocoding/v5/mapbox.places/${Uri.encodeComponent(query)}.json',
//         queryParameters: {
//           'access_token': _token,
//           'autocomplete': true,
//           'limit': 5,
//           if (proximity != null) 'proximity': proximity,
//         },
//       );
//       final features = response.data['features'] as List;
//       return features.map((f) {
//         final coords = f['geometry']['coordinates'];
//         return PlaceSuggestion(
//           id: f['id'],
//           name: f['text'],
//           fullAddress: f['place_name'],
//           longitude: coords[0].toDouble(),
//           latitude: coords[1].toDouble(),
//         );
//       }).toList();
//     } catch (e) {
//       return [];
//     }
//   }
// }
