import 'package:flutter/material.dart';

/// Small helpers for adapting layouts to tablets (iPad) vs phones.
///
/// `shortestSide` (the smaller of width/height) is used instead of raw
/// width/height because it stays constant when the device rotates —
/// unlike width/height, which swap between portrait and landscape and
/// previously caused the same screen to look different in each orientation.
class ResponsiveHelper {
  ResponsiveHelper._();

  /// Phones are typically < 600 logical pixels on their shortest side;
  /// iPads and other tablets are >= 600 in both orientations.
  static bool isTablet(BuildContext context) {
    return MediaQuery.sizeOf(context).shortestSide >= 600;
  }

  /// Number of product-grid columns for the current screen:
  /// - phone: 2 columns (unchanged from the original design)
  /// - tablet, narrower side (e.g. iPad portrait): 3 columns
  /// - tablet, wide side (e.g. iPad landscape / iPad Pro): 4 columns
  static int gridColumns(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    if (width >= 900) return 4;
    if (width >= 600) return 3;
    return 2;
  }

  /// Product card aspect ratio tuned per column count — narrower columns
  /// need a taller (smaller) ratio to comfortably fit the same card content.
  static double gridChildAspectRatio(int columns) {
    switch (columns) {
      case 4:
        return 0.8;
      case 3:
        return 0.74;
      default:
        return 0.68;
    }
  }

  /// Caps how wide the page content grows on very large screens (e.g. a
  /// 13" iPad in landscape), so cards and banners don't stretch edge to
  /// edge into an unusably wide layout.
  static const double maxContentWidth = 1000;
}
