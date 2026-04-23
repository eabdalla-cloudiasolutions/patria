import 'package:easy_localization/easy_localization.dart';
import 'package:erb/features/home/data/models/favorite_product_model.dart';
import 'package:erb/features/home/presentation/views/favourites_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class FavouritesSearchDelegate extends SearchDelegate {
  final List<Map<String, String>> favourites;

  FavouritesSearchDelegate(this.favourites);

  @override
  String get searchFieldLabel => 'Search favourites...';

  @override
  ThemeData appBarTheme(BuildContext context) {
    return Theme.of(context).copyWith(
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFFFAFAF7),
        elevation: 0,
        iconTheme: IconThemeData(color: Color(0xFF6B5E4B)),
      ),
      inputDecorationTheme: const InputDecorationTheme(
        border: InputBorder.none,
        hintStyle: TextStyle(
          fontFamily: 'Montserrat',
          color: Color(0xFF8B8B8B),
        ),
      ),
    );
  }

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      if (query.isNotEmpty)
        IconButton(
          icon: const Icon(Icons.clear, color: Color(0xFF6B5E4B)),
          onPressed: () => query = '',
        ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back, color: Color(0xFF6B5E4B)),
      onPressed: () => close(context, null),
    );
  }

  List<Map<String, String>> get _filtered {
    if (query.isEmpty) return [];
    return favourites
        .where((p) => p['name']!.toLowerCase().contains(query.toLowerCase()))
        .toList();
  }

  @override
  Widget buildResults(BuildContext context) => _buildList(context);

  @override
  Widget buildSuggestions(BuildContext context) => _buildList(context);

  Widget _buildList(BuildContext context) {
    if (query.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.search, size: 64, color: Color(0xFFCACBD4)),
            SizedBox(height: 16.h),
            Text(
              'search_in_favourites_hint'.tr(),
              style: TextStyle(
                color: const Color(0xFF8B8B8B),
                fontFamily: 'Montserrat',
                fontSize: 16.sp,
              ),
            ),
          ],
        ),
      );
    }

    if (_filtered.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.search_off, size: 64, color: Color(0xFFCACBD4)),
            SizedBox(height: 16.h),
            Text(
              'no_favourites_found_for'.tr(namedArgs: {'query': query}),
              style: TextStyle(
                color: const Color(0xFF8B8B8B),
                fontFamily: 'Montserrat',
                fontSize: 16.sp,
              ),
            ),
          ],
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 18,
        childAspectRatio: 167 / 255,
      ),
      itemCount: _filtered.length,
      itemBuilder: (context, index) {
        final map = _filtered[index];
        final favoriteItem = FavoriteProductModel(
          id: map['id'] ?? '',
          name: map['name'] ?? '',
          price: map['price'] ?? '0',
          rate: map['rate'] ?? '0',
          reviews: map['reviews'] ?? '0',
          image: map['image'] ?? '',
          isFavorite: true,
        );
        return ProductCard(
          favoriteItem: favoriteItem,
          onFavTap: () {
            // Close search after tapping favorite (optional)
            close(context, null);
          },
        );
      },
    );
  }
}
