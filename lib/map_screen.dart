// import 'package:patria/core/config/mapbox_config.dart';
// import 'package:patria/core/providers/map_provider.dart';
// import 'package:patria/core/widgets/search_bar_widget.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';

// class MapScreen extends ConsumerWidget {
//   const MapScreen({super.key});

//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     final mapState = ref.watch(mapProvider);
//     final notifier = ref.read(mapProvider.notifier);
//     final topPadding = MediaQuery.of(context).padding.top;
//     return Scaffold(
//       backgroundColor: Colors.white,
//       body: Stack(children: [
//         MapWidget(
//           key: ValueKey('mapWidget'),
//           styleUri: mapState.currentStyle,
//           cameraOptions: CameraOptions(
//               center: Point(
//                   coordinates:
//                       Position(29.993364386528633, 31.260937296330766)),
//               zoom: 12),
//           onMapCreated: notifier.onMapCreated,
//         ),
//         //Search bar
//         Positioned(
//             top: topPadding + 10,
//             left: 16,
//             right: 16,
//             child: SearchBarWidget(
//                 textValue: mapState.selectedPlaceName,
//                 onChanged: notifier.onSearchChanged,
//                 onClear: () {
//                   notifier.hideSuggestions();
//                   notifier.clearRoute();
//                 })),
//         // suggestion
//         if (mapState.showSuggestions)
//           Positioned(
//               top: topPadding + 70,
//               left: 16,
//               right: 16,
//               child: SuggestionsListWidget(
//                 suggestions: mapState.suggestions,
//                 onSelected: notifier.onSuggestionSelected,
//               )),

//         // my location
//         Positioned(
//             bottom: mapState.currentRoute != null ? 190 : 110,
//             right: 16,
//             child: FloatingActionButton(
//               elevation: 3,
//               heroTag: 'location',
//               backgroundColor: Colors.white,
//               foregroundColor: Colors.blue,
//               onPressed: notifier.recentLoaction,
//               child: Icon(Icons.my_location),
//             )),
//         //SATLITE TOGGLE
//         Positioned(
//             bottom: mapState.currentRoute != null ? 130 : 50,
//             right: 16,
//             child: FloatingActionButton(
//                 heroTag: 'style',
//                 backgroundColor:
//                     mapState.currentStyle == MapboxConfig.styleSatellite
//                         ? Colors.blue
//                         : Colors.white,
//                 foregroundColor:
//                     mapState.currentStyle == MapboxConfig.styleSatellite
//                         ? Colors.white
//                         : Colors.black87,
//                 onPressed: notifier.toggleStyle,
//                 child: const Icon(
//                   Icons.satellite_alt,
//                   size: 20,
//                 )))
//       ]),
//     );
//   }
// }
