// import 'package:patria/core/services/direction_service.dart';
// import 'package:patria/core/services/search_service.dart';

// class MapState {
//   final bool isLoading;
//   final bool isSimulating;
//   final bool showSuggestions;
//   final String currentStyle;
//   final List<PlaceSuggestion> suggestions;
//   final RouteResult? currentRoute;
//   final String selectedPlaceName;
//   final String remainingDistance;
//   final String remainingDuration;

//   const MapState({
//     this.isLoading = false,
//     this.isSimulating = false,
//     this.showSuggestions = false,
//     this.currentStyle = 'mapbox://styles/mapbox/streets-v12',
//     this.suggestions = const [],
//     this.currentRoute,
//     this.selectedPlaceName = '',
//     this.remainingDistance = '',
//     this.remainingDuration = '',
//   });

//   MapState copyWith({
//     bool? isLoading,
//     bool? isSimulating,
//     bool? showSuggestions,
//     String? currentStyle,
//     List<PlaceSuggestion>? suggestions,
//     RouteResult? currentRoute,
//     bool clearRoute = false,
//     String? selectedPlaceName,
//     String? remainingDistance,
//     String? remainingDuration,
//   }) {
//     return MapState(
//       isLoading: isLoading ?? this.isLoading,
//       isSimulating: isSimulating ?? this.isSimulating,
//       showSuggestions: showSuggestions ?? this.showSuggestions,
//       suggestions: suggestions ?? this.suggestions,
//       currentRoute: clearRoute ? null : currentRoute ?? this.currentRoute,
//       selectedPlaceName: selectedPlaceName ?? this.selectedPlaceName,
//       remainingDistance: remainingDistance ?? this.remainingDistance,
//       remainingDuration: remainingDuration ?? this.remainingDuration,
//     );
//   }
// }
