import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:patria/core/routing/routes.dart';
import 'package:patria/core/widgets/safe_network_image.dart';
import 'package:patria/features/cart/presentation/manager/cart_bloc.dart';
import 'package:patria/features/cart/presentation/manager/cart_event.dart';
import 'package:patria/features/cart/presentation/manager/cart_state.dart';
import 'package:patria/features/home/data/models/product_model.dart';
import 'package:patria/features/home/data/repos/favorites_repo.dart';
import 'package:patria/features/home/data/repos/products_repo.dart';
import 'package:patria/features/home/presentation/manager/categories_bloc.dart';
import 'package:patria/features/home/presentation/manager/categories_event.dart';
import 'package:patria/features/home/presentation/manager/categories_state.dart';
import 'package:patria/features/home/presentation/manager/favorites_bloc.dart';
import 'package:patria/features/home/presentation/manager/favorites_event.dart';
import 'package:patria/features/home/presentation/manager/favorites_state.dart';
import 'package:patria/features/home/presentation/manager/products_bloc.dart';
import 'package:patria/features/home/presentation/manager/products_event.dart';
import 'package:patria/features/home/presentation/manager/products_state.dart';
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
  final Set<String> _addingToCartIds = {};

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => ProductsBloc(ProductsRepo())..add(LoadProducts()),
        ),
        BlocProvider(
          create: (_) =>
              FavoritesBloc(favoritesRepo: FavoritesRepo())
                ..add(FetchFavorites()),
        ),
      ],
      // ✅ React to the REAL result of the add-to-cart request.
      // CartBloc is provided globally (main.dart), so we can listen here.
      child: MultiBlocListener(
        listeners: [
          BlocListener<CartBloc, CartState>(
            // Only react when WE triggered an add from this screen, and only to
            // terminal states (ignore the intermediate CartLoading).
            listenWhen: (prev, curr) =>
                _addingToCartIds.isNotEmpty &&
                (curr is CartLoaded || curr is CartError),
            listener: (context, state) {
              if (state is CartLoaded) {
                _showCartSnack(
                  'item_added_to_cart'.tr(),
                  const Color(0xFF3C4119),
                );
              } else if (state is CartError) {
                // ✅ Show the exact message that came from the API.
                // ApiErrorHandler already extracts response['message'],
                // so for a 401 this shows e.g. "Not authorized, no token".
                _showCartSnack(state.message, const Color(0xFFC90000));
              }

              // ✅ Clear the loading state for the card(s) once we have a result.
              if (mounted) {
                setState(() => _addingToCartIds.clear());
              }
            },
          ),
          // ✅ Surface the backend message when a favorite add/remove fails
          // (e.g. 401 "غير مصرح — لا يوجد رمز مصادقة"). FavoritesBloc restores
          // FavoritesLoaded right after FavoritesError, so the builder below
          // never sees the error state — this listener is what surfaces it.
          BlocListener<FavoritesBloc, FavoritesState>(
            listenWhen: (prev, curr) => curr is FavoritesError,
            listener: (context, state) {
              if (state is FavoritesError) {
                _showCartSnack(state.message, const Color(0xFFC90000));
              }
            },
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
                child: Text(
                  state.message,
                  style: TextStyle(color: Colors.red, fontSize: 12.sp),
                ),
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
                      context.read<ProductsBloc>().add(
                        LoadProducts(category: category.name),
                      );
                    },
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(100.r),
                      child: Stack(
                        children: [
                          SafeNetworkImage(
                            imageUrl: category.image,
                            width: 100.w,
                            height: 100.h,
                            fit: BoxFit.cover,
                            fallbackAsset: 'assets/images/bakery.png',
                          ),
                          Container(
                            width: 100.w,
                            height: 100.h,
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? const Color(0x806B5E4B)
                                  : Colors.black45,
                            ),
                          ),
                          Positioned(
                            bottom: 20.h,
                            left: 0,
                            right: 0,
                            child: SizedBox(
                              height: 40.h, // ← fixed height fits 2 lines
                              child: Align(
                                alignment: Alignment
                                    .topCenter, // ← text starts from top of this box
                                child: Padding(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 6.w,
                                  ),
                                  child: Text(
                                    category.name,
                                    maxLines: 2,
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 13.sp,
                                      fontFamily: 'Montserrat',
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                              ),
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
                const Icon(
                  Icons.error_outline,
                  size: 48,
                  color: Color(0xFFCACBD4),
                ),
                SizedBox(height: 12.h),
                Text(
                  state.message,
                  style: TextStyle(
                    color: const Color(0xFF8B8B8B),
                    fontSize: 14.sp,
                  ),
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
                child: Text(
                  'no_products_in_category'.tr(),
                  style: TextStyle(
                    color: const Color(0xFF28293D) /* Text-neutral */,
                    fontSize: 14,
                    fontFamily: 'Montserrat',
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.28,
                  ),
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
                  final isFavActionLoading =
                      favState is FavoritesActionLoading &&
                      favState.productId == product.id;
                  final isAddingToCart = _addingToCartIds.contains(product.id);

                  return GestureDetector(
                    onTap: () {
                      Navigator.of(
                        context,
                        rootNavigator: true,
                      ).pushNamed(Routes.itemPreview, arguments: product);
                    },
                    child: HomeProductCard(
                      name: product.name,
                      price: '${product.price} EGP',
                      imageUrl: product.imageUrl,
                      isFav: isFav,
                      isFavActionLoading: isFavActionLoading,
                      isAddingToCart: isAddingToCart,
                      onFavTap: () {
                        context.read<FavoritesBloc>().add(
                          ToggleFavorite(
                            productId: product.id,
                            isCurrentlyFavorite: isFav,
                          ),
                        );
                      },
                      onAddTap: () {
                        if (product.haveCustomizationOption) {
                          // Ingredient: navigate to item preview
                          Navigator.of(
                            context,
                            rootNavigator: true,
                          ).pushNamed(Routes.itemPreview, arguments: product);
                        } else {
                          // Add to cart
                          _addToCart(product);
                        }
                      },
                      rate: product.rate,
                      reviewCount: product.reviewCount,
                      isIngredient: product.haveCustomizationOption,
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

  // ✅ Just dispatch the event. Success/failure is handled by the
  // BlocListener above, based on what the bloc actually emits.
  void _addToCart(ProductModel product) {
    if (_addingToCartIds.contains(product.id)) return;

    setState(() => _addingToCartIds.add(product.id));

    context.read<CartBloc>().add(AddToCart(productId: product.id, quantity: 1));
  }

  // ✅ Shared snackbar helper.
  void _showCartSnack(String message, Color color, {SnackBarAction? action}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(
            message,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          backgroundColor: color,
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
          action: action,
        ),
      );
  }
}

// Products Shimmer (unchanged)
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
