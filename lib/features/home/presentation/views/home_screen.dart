import 'package:easy_localization/easy_localization.dart';
import 'package:erb/core/routing/routes.dart';
import 'package:erb/features/home/data/repos/favorites_repo.dart';
import 'package:erb/features/home/data/repos/products_repo.dart';
import 'package:erb/features/home/presentation/manager/categories_bloc.dart';
import 'package:erb/features/home/presentation/manager/categories_event.dart';
import 'package:erb/features/home/presentation/manager/categories_state.dart';
import 'package:erb/features/home/presentation/manager/favorites_bloc.dart';
import 'package:erb/features/home/presentation/manager/favorites_event.dart';
import 'package:erb/features/home/presentation/manager/favorites_state.dart';
import 'package:erb/features/home/presentation/manager/products_bloc.dart';
import 'package:erb/features/home/presentation/manager/products_event.dart';
import 'package:erb/features/home/presentation/manager/products_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shimmer/shimmer.dart';

import 'widgets/home_banner_slider.dart';
import 'widgets/home_header.dart';
import 'widgets/home_product_card.dart';
import 'widgets/home_search_bar.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  String _selectedFilter = 'All';

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        // ✅ ProductsBloc at top level so both categories and grid share it
        BlocProvider(
          create: (_) => ProductsBloc(ProductsRepo())..add(LoadProducts()),
        ),
        BlocProvider(
          create: (_) => FavoritesBloc(favoritesRepo: FavoritesRepo())
            ..add(FetchFavorites()),
        ),
      ],
      child: Scaffold(
        backgroundColor: const Color(0xFFF7F7F7),
        body: SafeArea(
          bottom: false,
          child: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.only(left: 20.w, right: 20.w, top: 24.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 16.h),
                  HomeHeader(),
                  SizedBox(height: 16.h),
                  const HomeSearchBar(),
                  SizedBox(height: 16.h),
                  const HomeBannerSlider(),
                  SizedBox(height: 18.h),
                  _buildSectionTitle('home_categories'.tr()),
                  SizedBox(height: 12.h),
                  _buildCategoriesRow(),
                  SizedBox(height: 32.h),
                  _buildProductsGrid(),
                  SizedBox(height: 6.h),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        color: const Color(0xFF28293D),
        fontSize: 18.sp,
        fontFamily: 'Montserrat',
        fontWeight: FontWeight.w600,
        letterSpacing: 0.36,
      ),
    );
  }

  Widget _buildCategoriesRow() {
    return BlocProvider(
      create: (_) => CategoriesBloc()..add(LoadCategories()),
      child: BlocBuilder<CategoriesBloc, CategoriesState>(
        builder: (context, state) {
          if (state is CategoriesLoading) {
            return SizedBox(
              height: 100.h,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: 4,
                separatorBuilder: (_, __) => SizedBox(width: 12.w),
                itemBuilder: (_, __) => Shimmer.fromColors(
                  baseColor: Colors.grey.shade300,
                  highlightColor: Colors.grey.shade100,
                  child: Container(
                    width: 100.w,
                    height: 100.h,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(100.r),
                    ),
                  ),
                ),
              ),
            );
          }

          if (state is CategoriesError) {
            return SizedBox(
              height: 100.h,
              child: Center(
                child: Text(state.message,
                    style: TextStyle(color: Colors.red, fontSize: 12.sp)),
              ),
            );
          }

          if (state is CategoriesLoaded) {
            final categories = state.categories;
            return SizedBox(
              height: 100.h,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: categories.length,
                separatorBuilder: (_, __) => SizedBox(width: 12.w),
                itemBuilder: (_, index) {
                  final category = categories[index];
                  final isSelected = _selectedFilter == category.id;

                  return GestureDetector(
                    onTap: () {
                      setState(() => _selectedFilter = category.id);
                      print(
                          '🔍 Selected category name: ${category.name}'); // ✅ add this
                      context.read<ProductsBloc>().add(
                            LoadProducts(category: category.name),
                          );
                    },
                    child: Container(
                      width: 100.w,
                      height: 100.h,
                      padding: const EdgeInsets.all(6.67),
                      decoration: ShapeDecoration(
                        image: DecorationImage(
                          image: category.image != null
                              ? NetworkImage(category.image!) as ImageProvider
                              : const AssetImage('assets/images/bakery.png'),
                          fit: BoxFit.cover,
                          colorFilter: ColorFilter.mode(
                            isSelected
                                ? const Color(0x806B5E4B)
                                : Colors.black45,
                            BlendMode.darken,
                          ),
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(100.r),
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text(
                            category.name,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 13.sp,
                              fontFamily: 'Montserrat',
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildProductsGrid() {
    // ✅ No BlocProvider here — using top level ProductsBloc
    return BlocBuilder<ProductsBloc, ProductsState>(
      builder: (context, state) {
        if (state is ProductsLoading) {
          return const ProductsShimmer();
        }

        if (state is ProductsError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline,
                    size: 48, color: Color(0xFFCACBD4)),
                SizedBox(height: 12.h),
                Text(
                  state.message,
                  style: TextStyle(
                      color: const Color(0xFF8B8B8B), fontSize: 14.sp),
                ),
                SizedBox(height: 12.h),
                ElevatedButton(
                  onPressed: () {
                    context.read<ProductsBloc>().add(LoadProducts());
                  },
                  child: Text('retry'.tr()),
                ),
              ],
            ),
          );
        }

        if (state is ProductsLoaded) {
          final products = state.products;

          if (products.isEmpty) {
            return SizedBox(
              height: 300.h,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.fastfood_outlined,
                        size: 48, color: Color(0xFFCACBD4)),
                    SizedBox(height: 12.h),
                    Text(
                      'no_products'.tr(args: [_selectedFilter]),
                      style: TextStyle(
                        color: const Color(0xFF8B8B8B),
                        fontFamily: 'Montserrat',
                        fontSize: 14.sp,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          return BlocBuilder<FavoritesBloc, FavoritesState>(
            builder: (context, favState) {
              Set<String> favoriteIds = {};
              if (favState is FavoritesLoaded) {
                favoriteIds = favState.favorites.map((item) => item.id).toSet();
              }

              return GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 18,
                  crossAxisSpacing: 18,
                  childAspectRatio: 0.68,
                ),
                itemCount: products.length,
                itemBuilder: (_, index) {
                  final product = products[index];
                  final isFav = favoriteIds.contains(product.id);
                  final isActionLoading = favState is FavoritesActionLoading &&
                      favState.productId == product.id;

                  return GestureDetector(
                    onTap: () {
                      Navigator.of(context, rootNavigator: true).pushNamed(
                        Routes.itemPreview,
                        arguments: product,
                      );
                    },
                    child: HomeProductCard(
                      name: product.name,
                      price: '${product.price} EGP',
                      imageUrl: product.imageUrl,
                      isFav: isFav,
                      isActionLoading: isActionLoading,
                      onFavTap: () {
                        context.read<FavoritesBloc>().add(
                              ToggleFavorite(
                                productId: product.id,
                                isCurrentlyFavorite: isFav,
                              ),
                            );
                      },
                      onAddTap: () {},
                      rate: product.rate,
                      reviewCount: product.reviewCount,
                    ),
                  );
                },
              );
            },
          );
        }

        return const SizedBox.shrink();
      },
    );
  }
}

// Products Shimmer
class ProductsShimmer extends StatelessWidget {
  const ProductsShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 18,
          crossAxisSpacing: 18,
          childAspectRatio: 0.68,
        ),
        itemCount: 6,
        itemBuilder: (_, __) => Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24.r),
          ),
        ),
      ),
    );
  }
}
