import 'package:easy_localization/easy_localization.dart';
import 'package:erb/core/routing/routes.dart';
import 'package:erb/features/home/data/models/product_model.dart';
import 'package:erb/features/home/data/repos/products_repo.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class HomeSearchBar extends StatelessWidget {
  const HomeSearchBar({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        showSearch(
          context: context,
          delegate: ProductSearchDelegate(productsRepo: ProductsRepo()),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: ShapeDecoration(
          color: Colors.white,
          shape: RoundedRectangleBorder(
            side: BorderSide(width: 1.w, color: const Color(0xFFCACBD4)),
            borderRadius: BorderRadius.circular(8.r),
          ),
        ),
        child: Row(
          children: [
            Image.asset("assets/images/search.png"),
            SizedBox(width: 10.w),
            Text(
              'search_hint'.tr(),
              style: TextStyle(
                color: const Color(0xFF8B8B8B),
                fontSize: 16.sp,
                fontFamily: 'Montserrat',
                fontWeight: FontWeight.w400,
                letterSpacing: 0.32,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ProductSearchDelegate extends SearchDelegate {
  final ProductsRepo productsRepo;

  ProductSearchDelegate({required this.productsRepo});

  @override
  String get searchFieldLabel => 'search_hint'.tr();

  @override
  TextStyle get searchFieldStyle => TextStyle(
        fontFamily: 'Montserrat',
        fontSize: 16.sp,
        color: const Color(0xFF333333),
      );

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

  @override
  Widget buildResults(BuildContext context) => _buildSearchResults();

  @override
  Widget buildSuggestions(BuildContext context) => _buildSearchResults();

  Widget _buildSearchResults() {
    // ✅ Show empty state when nothing typed yet
    if (query.trim().isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.search, size: 64, color: Color(0xFFCACBD4)),
            SizedBox(height: 16.h),
            Text(
              'search_hint'.tr(),
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

    // ✅ FutureBuilder calls the real API on every query change
    return FutureBuilder<List<ProductModel>>(
      future: productsRepo.getProducts(search: query.trim()),
      builder: (context, snapshot) {
        // Loading
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(color: Color(0xFF6B5E4B)),
          );
        }

        // Error
        if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline,
                    size: 48, color: Color(0xFFCACBD4)),
                SizedBox(height: 12.h),
                Text(
                  snapshot.error.toString(),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: const Color(0xFF8B8B8B),
                    fontFamily: 'Montserrat',
                    fontSize: 14.sp,
                  ),
                ),
              ],
            ),
          );
        }

        final products = snapshot.data ?? [];

        // No results
        if (products.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.search_off,
                    size: 64, color: Color(0xFFCACBD4)),
                SizedBox(height: 16.h),
                Text(
                  'no_results_for'.tr(namedArgs: {'query': query}),
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

        // ✅ Results list
        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: products.length,
          separatorBuilder: (_, __) =>
              const Divider(height: 1, color: Color(0xFFE5E5E5)),
          itemBuilder: (context, index) {
            final product = products[index];
            return ListTile(
              contentPadding:
                  EdgeInsets.symmetric(horizontal: 8.w, vertical: 8.h),
              leading: ClipRRect(
                borderRadius: BorderRadius.circular(8.r),
                child: product.imageUrl != null
                    ? Image.network(
                        product.imageUrl,
                        width: 56.w,
                        height: 56.h,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => _placeholderImage(),
                      )
                    : _placeholderImage(),
              ),
              title: Text(
                product.name,
                style: TextStyle(
                  color: const Color(0xFF333333),
                  fontFamily: 'Montserrat',
                  fontWeight: FontWeight.w500,
                  fontSize: 14.sp,
                ),
              ),
              subtitle: Text(
                '${product.price} EGP',
                style: TextStyle(
                  color: const Color(0xFF6B5E4B),
                  fontFamily: 'Montserrat',
                  fontWeight: FontWeight.w600,
                  fontSize: 13.sp,
                ),
              ),
              trailing: const Icon(
                Icons.arrow_forward_ios,
                size: 14,
                color: Color(0xFF8B8B8B),
              ),
              onTap: () {
                close(context, null);
                Navigator.of(context, rootNavigator: true).pushNamed(
                  Routes.itemPreview,
                  arguments: product,
                );
              },
            );
          },
        );
      },
    );
  }

  Widget _placeholderImage() {
    return Container(
      width: 56.w,
      height: 56.h,
      decoration: BoxDecoration(
        color: const Color(0xFFF5F0EA),
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: const Icon(Icons.fastfood_outlined, color: Color(0xFF6B5E4B)),
    );
  }
}
