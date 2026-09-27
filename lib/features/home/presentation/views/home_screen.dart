import 'dart:math' as math;

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:patria/core/helpers/responsive_helper.dart';
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

  // ✅ Changing this key forces HomeBannerSlider's State to be recreated
  // (initState runs again, refetching offers) on pull-to-refresh — it
  // has no Bloc of its own to dispatch a reload event to.
  int _bannerRefreshKey = 0;

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
        // ✅ Provided here (rather than locally inside _buildCategoriesRow)
        // so pull-to-refresh below can reach it via context.read to reload
        // categories too, not just products/favorites.
        BlocProvider(create: (_) => CategoriesBloc()..add(LoadCategories())),
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
        // ✅ Builder gives us a `context` that sits *below* the
        // MultiBlocProvider above, unlike _HomeState's own `context`
        // (the Home widget's element, which is an ANCESTOR of it). Reading
        // ProductsBloc/FavoritesBloc/CategoriesBloc from the wrong context
        // either silently finds a different, global instance (Products/
        // Favorites are also provided in main.dart) that the UI below
        // isn't watching, or finds nothing at all and throws
        // ProviderNotFoundException (CategoriesBloc, which is only
        // provided locally here) — both are bugs, only one of them crashes.
        child: Builder(
          builder: (context) {
            return Scaffold(
              backgroundColor: const Color(0xFFF7F7F7),
              body: SafeArea(
                bottom: false,
                child: RefreshIndicator(
                  color: const Color(0xFF3C4119),
                  onRefresh: () => _onRefresh(context),
                  child: SingleChildScrollView(
                    // Required for pull-to-refresh to trigger even when the
                    // content is short enough to not naturally overflow/scroll.
                    physics: const AlwaysScrollableScrollPhysics(),
                    // Cap content width on large screens (iPad landscape /
                    // iPad Pro) so the grid and banner don't stretch edge to
                    // edge — mirrors how larger tablet apps constrain
                    // their content.
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(
                          maxWidth: ResponsiveHelper.maxContentWidth,
                        ),
                        child: Padding(
                          padding: EdgeInsets.only(
                            left: 20.w,
                            right: 20.w,
                            top: 24.h,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(height: 16.h),
                              HomeHeader(),
                              SizedBox(height: 16.h),
                              const HomeSearchBar(),
                              SizedBox(height: 16.h),
                              HomeBannerSlider(
                                key: ValueKey(_bannerRefreshKey),
                              ),
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
              ),
            );
          },
        ),
      ),
    );
  }

  Future<void> _onRefresh(BuildContext context) async {
    final productsBloc = context.read<ProductsBloc>();
    final categoriesBloc = context.read<CategoriesBloc>();
    final favoritesBloc = context.read<FavoritesBloc>();

    // ✅ Keep whatever category filter is currently active instead of
    // silently resetting it to "All" on refresh.
    productsBloc.add(
      LoadProducts(category: _selectedFilter == 'All' ? null : _selectedFilter),
    );
    categoriesBloc.add(LoadCategories());
    favoritesBloc.add(FetchFavorites());

    // ✅ Force HomeBannerSlider to recreate its State (see the key comment
    // above), which re-runs initState and refetches the offers — it has
    // no Bloc to dispatch a reload event to like the other three do.
    setState(() => _bannerRefreshKey++);

    // ✅ Wait for each bloc to actually finish, so the pull indicator
    // stays visible for the real network calls instead of snapping back
    // before any data has arrived.
    //
    // Guarded with a timeout: FavoritesState uses Equatable, and bloc
    // silently skips emitting a state that's equal to the current one
    // (e.g. an empty favorites list refreshing to another empty list) —
    // so `.stream.firstWhere(...)` can wait forever for an event that
    // will never come. The timeout guarantees the refresh indicator
    // always dismisses, whether or not each bloc actually re-emits.
    try {
      await Future.wait([
        productsBloc.stream.firstWhere(
          (state) => state is ProductsLoaded || state is ProductsError,
        ),
        categoriesBloc.stream.firstWhere(
          (state) => state is CategoriesLoaded || state is CategoriesError,
        ),
        favoritesBloc.stream.firstWhere(
          (state) => state is FavoritesLoaded || state is FavoritesError,
        ),
      ]).timeout(const Duration(seconds: 8));
    } catch (_) {
      // Timed out, or a bloc never re-emitted because its new state was
      // unchanged — either way, let the indicator dismiss instead of
      // spinning forever.
    }
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
    // CategoriesBloc is provided by the MultiBlocProvider above (not here)
    // so pull-to-refresh can reach it via context.read to reload it too.
    return BlocBuilder<CategoriesBloc, CategoriesState>(
      builder: (context, state) {
          // On tablets, use a fixed circle size instead of ScreenUtil's
          // .w/.h — those are calibrated against a phone-sized design
          // canvas and scale width/height unevenly on iPad, so the same
          // circle came out a different size in portrait vs. landscape.
          // A fixed value keeps it identical in both orientations, and a
          // bit larger than phone since there's more screen to use.
          final isTablet = ResponsiveHelper.isTablet(context);
          final circleSize = isTablet ? 132.0 : math.min(100.w, 100.h);
          // Font size must also be fixed on tablet: .sp scales up on a
          // tall iPad screen (it's calibrated to a phone-height design
          // canvas), so leaving it as 13.sp made the label oversized
          // relative to the now-fixed circle above. That oversized font
          // fit fine for a single-word name (rendered at full size) but
          // forced FittedBox to shrink two-word/wrapped names to fit —
          // producing a visibly different "weight" between the two, and
          // pushing long words into ellipsis. A fixed size keeps both
          // cases consistent.
          final labelFontSize = isTablet ? 15.0 : 13.sp;

          if (state is CategoriesLoading) {
            return SizedBox(
              height: circleSize,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: 4,
                separatorBuilder: (_, __) => SizedBox(width: 12.w),
                itemBuilder: (_, __) => Shimmer.fromColors(
                  baseColor: Colors.grey.shade300,
                  highlightColor: Colors.grey.shade100,
                  child: Container(
                    width: circleSize,
                    height: circleSize,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(circleSize / 2),
                    ),
                  ),
                ),
              ),
            );
          }

          if (state is CategoriesError) {
            return SizedBox(
              height: circleSize,
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
            final textAreaWidth = circleSize - 12;
            return SizedBox(
              height: circleSize,
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
                      borderRadius: BorderRadius.circular(circleSize / 2),
                      child: Stack(
                        children: [
                          SafeNetworkImage(
                            imageUrl: category.image,
                            width: circleSize,
                            height: circleSize,
                            fit: BoxFit.cover,
                            fallbackAsset: 'assets/images/patria_icon.png',
                          ),
                          Container(
                            width: circleSize,
                            height: circleSize,
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? const Color(0x806B5E4B)
                                  : Colors.black45,
                            ),
                          ),
                          Positioned(
                            bottom: circleSize * 0.18,
                            left: 0,
                            right: 0,
                            child: SizedBox(
                              height: circleSize * 0.4,
                              child: Center(
                                child: Padding(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 6.w,
                                  ),
                                  // FittedBox shrinks the whole label instead
                                  // of letting a wrapped 2nd line overflow
                                  // this box, so it can never bleed into the
                                  // artwork above it (the App Store rejection
                                  // on iPad, where these scales up unevenly).
                                  child: FittedBox(
                                    fit: BoxFit.scaleDown,
                                    child: SizedBox(
                                      width: textAreaWidth,
                                      child: Text(
                                        category.name,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: labelFontSize,
                                          fontFamily: 'Montserrat',
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
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

              final columns = ResponsiveHelper.gridColumns(context);
              return GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: columns,
                  mainAxisSpacing: 18,
                  crossAxisSpacing: 18,
                  childAspectRatio: ResponsiveHelper.gridChildAspectRatio(
                    columns,
                  ),
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

class ProductsShimmer extends StatelessWidget {
  const ProductsShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    // Match the real grid's column count so the shimmer placeholder
    // doesn't jump/reflow once the actual products load in.
    final columns = ResponsiveHelper.gridColumns(context);
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: columns,
          mainAxisSpacing: 18,
          crossAxisSpacing: 18,
          childAspectRatio: ResponsiveHelper.gridChildAspectRatio(columns),
        ),
        itemCount: columns * 3,
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
