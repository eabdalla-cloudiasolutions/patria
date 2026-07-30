import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:patria/core/routing/routes.dart';
import 'package:patria/core/widgets/empty_state_widget.dart';
import 'package:patria/core/widgets/safe_network_image.dart';
import 'package:patria/features/home/data/models/favorite_product_model.dart';
import 'package:patria/features/home/data/repos/favorites_repo.dart';
import 'package:patria/features/home/data/repos/products_repo.dart';
import 'package:patria/features/home/presentation/manager/favorites_bloc.dart';
import 'package:patria/features/home/presentation/manager/favorites_event.dart';
import 'package:patria/features/home/presentation/manager/favorites_state.dart';
import 'package:patria/features/home/presentation/views/widgets/favourites_search_delegate.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';
import 'package:shimmer/shimmer.dart';

class FavouritesScreen extends StatelessWidget {
  final PersistentTabController? controller;

  const FavouritesScreen({super.key, this.controller});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          FavoritesBloc(favoritesRepo: FavoritesRepo())..add(FetchFavorites()),
      child: Scaffold(
        backgroundColor: const Color(0xFFF7F7F7),
        body: SafeArea(
          child: BlocBuilder<FavoritesBloc, FavoritesState>(
            builder: (context, state) {
              return Column(
                children: [
                  // Header (always visible)
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: 20.w,
                      vertical: 12.h,
                    ),
                    child: Row(
                      children: [
                        GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            child: const Icon(Icons.arrow_back, size: 20),
                          ),
                        ),
                        const Spacer(),
                        Text(
                          'favourites'.tr(),
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 18.sp,
                            fontFamily: 'Montserrat',
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.36,
                          ),
                        ),
                        const Spacer(),
                        SizedBox(width: 44.w),
                      ],
                    ),
                  ),

                  // Search Bar (only visible when favorites are loaded and not empty)
                  if (state is FavoritesLoaded && state.favorites.isNotEmpty)
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20.w),
                      child: GestureDetector(
                        onTap: () {
                          final favouritesMap = state.favorites
                              .map((item) => item.toMap())
                              .toList();
                          showSearch(
                            context: context,
                            delegate: FavouritesSearchDelegate(favouritesMap),
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.all(14),
                          decoration: ShapeDecoration(
                            color: Colors.white,
                            shape: RoundedRectangleBorder(
                              side: const BorderSide(
                                width: 1,
                                color: Color(0xFFCACBD4),
                              ),
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.search,
                                color: Color(0xFF8B8B8B),
                                size: 20,
                              ),
                              SizedBox(width: 10.w),
                              Text(
                                'search_favourites_hint'.tr(),
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
                      ),
                    ),

                  if (state is FavoritesLoaded && state.favorites.isNotEmpty)
                    SizedBox(height: 18.h),

                  // Content area (changes based on state)
                  Expanded(child: _buildContent(state, context)),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildContent(FavoritesState state, BuildContext context) {
    if (state is FavoritesLoading) {
      // ✅ Show skeleton grid instead of a single spinner
      return Padding(
        padding: EdgeInsets.symmetric(horizontal: 20.w),
        child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 18,
            childAspectRatio: 167 / 255,
          ),
          itemCount: 6, // Show 6 skeleton items
          itemBuilder: (context, index) => const SkeletonProductCard(),
        ),
      );
    }

    if (state is FavoritesError) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Color(0xFFCACBD4)),
            SizedBox(height: 16.h),
            Text(
              state.message,
              style: TextStyle(
                color: const Color(0xFF8B8B8B),
                fontFamily: 'Montserrat',
                fontSize: 16.sp,
              ),
            ),
            SizedBox(height: 16.h),
            ElevatedButton(
              onPressed: () {
                context.read<FavoritesBloc>().add(FetchFavorites());
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF3C4119),
              ),
              child: Text('retry'.tr()),
            ),
          ],
        ),
      );
    }

    if (state is FavoritesLoaded && state.favorites.isEmpty) {
      return EmptyStateWidget(
        imagePath: 'assets/images/Empty Favourites.png',
        title: 'No favourites yet',
        subtitle:
            'You haven’t saved any favourites yet. Explore the menu and save what you love.',
        buttonText: 'browse_menu'.tr(),
        onButtonPressed: () {
          if (controller != null) {
            controller!.jumpToTab(0);
          } else {
            Navigator.pop(context);
          }
        },
      );
    }

    if (state is FavoritesLoaded && state.favorites.isNotEmpty) {
      return Padding(
        padding: EdgeInsets.symmetric(horizontal: 20.w),
        child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 18,
            childAspectRatio: 167 / 255,
          ),
          itemCount: state.favorites.length,
          itemBuilder: (context, index) {
            final favoriteItem = state.favorites[index];
            return ProductCard(
              favoriteItem: favoriteItem,
              onFavTap: () {
                context.read<FavoritesBloc>().add(
                  ToggleFavorite(
                    productId: favoriteItem.id,
                    isCurrentlyFavorite: true,
                  ),
                );
              },
            );
          },
        ),
      );
    }

    return const SizedBox.shrink();
  }
}

// Skeleton product card for loading state
class SkeletonProductCard extends StatelessWidget {
  const SkeletonProductCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image placeholder
          Container(
            height: 123.h,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(5),
            ),
          ),
          // Info section placeholder
          Expanded(
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: const ShapeDecoration(
                color: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(24),
                    bottomRight: Radius.circular(24),
                  ),
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Name placeholder
                  Container(
                    width: double.infinity,
                    height: 14.h,
                    color: Colors.white,
                  ),
                  SizedBox(height: 4.h),
                  // Rating placeholder
                  Row(
                    children: [
                      Container(width: 12, height: 12, color: Colors.white),
                      SizedBox(width: 2.w),
                      Container(width: 30, height: 10, color: Colors.white),
                      SizedBox(width: 2.w),
                      Container(width: 30, height: 10, color: Colors.white),
                    ],
                  ),
                  SizedBox(height: 8.h),
                  // Price placeholder
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(width: 60, height: 14, color: Colors.white),
                      Container(width: 30, height: 30, color: Colors.white),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ProductCard widget (must stay in the same file)
class ProductCard extends StatelessWidget {
  final FavoriteProductModel favoriteItem;
  final VoidCallback? onFavTap;

  const ProductCard({super.key, required this.favoriteItem, this.onFavTap});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FavoritesBloc, FavoritesState>(
      builder: (context, state) {
        final isActionLoading =
            state is FavoritesActionLoading &&
            state.productId == favoriteItem.id;

        return GestureDetector(
          onTap: () async {
            final fullProduct = await ProductsRepo().getProductById(
              favoriteItem.id,
            );
            if (context.mounted) {
              Navigator.of(
                context,
                rootNavigator: true,
              ).pushNamed(Routes.itemPreview, arguments: fullProduct);
            }
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image + Favorite button
              SizedBox(
                height: 123.h,
                child: Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(5),
                      child: SafeNetworkImage(
                        imageUrl: favoriteItem.image,
                        width: double.infinity,
                        height: 140.h,
                        fit: BoxFit.cover,
                      ),
                    ),
                    Positioned(
                      right: 8,
                      top: 8,
                      child: GestureDetector(
                        onTap: isActionLoading ? null : onFavTap,
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Color(0x19000000),
                                blurRadius: 6,
                                offset: Offset(0, 4),
                                spreadRadius: -1,
                              ),
                            ],
                          ),
                          child: isActionLoading
                              ? SizedBox(
                                  width: 14,
                                  height: 14,
                                  child: const CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.red,
                                  ),
                                )
                              : const Icon(
                                  Icons.favorite,
                                  color: Colors.red,
                                  size: 14,
                                ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // Info section
              Expanded(
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  decoration: const ShapeDecoration(
                    color: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(24),
                        bottomRight: Radius.circular(24),
                      ),
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        favoriteItem.name,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: const Color(0xFF333333),
                          fontSize: 14.sp,
                          fontFamily: 'Montserrat',
                          fontWeight: FontWeight.w500,
                          height: 1.07,
                          letterSpacing: 0.28,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Row(
                        children: [
                          const Icon(
                            Icons.star,
                            color: Color(0xFFFFB800),
                            size: 12,
                          ),
                          SizedBox(width: 2.w),
                          Text(
                            favoriteItem.rate,
                            style: TextStyle(
                              color: const Color(0xFF333333),
                              fontSize: 10.sp,
                              fontFamily: 'Montserrat',
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          SizedBox(width: 2.w),
                          Text(
                            '(${favoriteItem.reviews})',
                            style: TextStyle(
                              color: const Color(0xFF515151),
                              fontSize: 10.sp,
                              fontFamily: 'Montserrat',
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 8.h),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text.rich(
                            TextSpan(
                              children: [
                                TextSpan(
                                  text: '${favoriteItem.price} ',
                                  style: TextStyle(
                                    color: const Color(0xFF28293D),
                                    fontSize: 14.sp,
                                    fontFamily: 'Montserrat',
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                TextSpan(
                                  text: 'EGP',
                                  style: TextStyle(
                                    color: const Color(0xFF28293D),
                                    fontSize: 14.sp,
                                    fontFamily: 'Montserrat',
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: ShapeDecoration(
                              color: const Color(0xFF3C4119),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(5.71),
                              ),
                            ),
                            child: const Icon(
                              Icons.arrow_forward_ios_rounded,
                              color: Colors.white,
                              size: 14,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
