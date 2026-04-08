import 'package:easy_localization/easy_localization.dart';
import 'package:erb/core/widgets/safe_network_image.dart';
import 'package:erb/features/home/data/repos/favorites_repo.dart';
import 'package:erb/features/home/presentation/manager/favorites_bloc.dart';
import 'package:erb/features/home/presentation/manager/favorites_event.dart';
import 'package:erb/features/home/presentation/manager/favorites_state.dart';
import 'package:erb/features/home/presentation/views/widgets/favourites_search_delegate.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class FavouritesScreen extends StatelessWidget {
  const FavouritesScreen({super.key});

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
                  // Header
                  Padding(
                    padding:
                        EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
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

                  // Search Bar
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20.w),
                    child: GestureDetector(
                      onTap: () {
                        if (state is FavoritesLoaded) {
                          final favouritesMap = state.favorites
                              .map((item) => item.toMap())
                              .toList();
                          showSearch(
                            context: context,
                            delegate: FavouritesSearchDelegate(favouritesMap),
                          );
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.all(14),
                        decoration: ShapeDecoration(
                          color: Colors.white,
                          shape: RoundedRectangleBorder(
                            side: const BorderSide(
                                width: 1, color: Color(0xFFCACBD4)),
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.search,
                                color: Color(0xFF8B8B8B), size: 20),
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

                  SizedBox(height: 18.h),

                  // State handling
                  if (state is FavoritesLoading)
                    const Expanded(
                      child: Center(child: CircularProgressIndicator()),
                    ),

                  if (state is FavoritesError)
                    Expanded(
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.error_outline,
                                size: 64, color: Color(0xFFCACBD4)),
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
                                context
                                    .read<FavoritesBloc>()
                                    .add(FetchFavorites());
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF6B5E4B),
                              ),
                              child: Text('retry'.tr()),
                            ),
                          ],
                        ),
                      ),
                    ),

                  if (state is FavoritesLoaded && state.favorites.isEmpty)
                    Expanded(
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.favorite_border,
                                size: 64, color: Color(0xFFCACBD4)),
                            SizedBox(height: 16.h),
                            Text(
                              'no_favourites_yet'.tr(),
                              style: TextStyle(
                                color: const Color(0xFF8B8B8B),
                                fontFamily: 'Montserrat',
                                fontSize: 16.sp,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                  if (state is FavoritesLoaded && state.favorites.isNotEmpty)
                    Expanded(
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 20.w),
                        child: GridView.builder(
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 16,
                            mainAxisSpacing: 18,
                            childAspectRatio: 167 / 255,
                          ),
                          itemCount: state.favorites.length,
                          itemBuilder: (context, index) {
                            final item = state.favorites[index];
                            return ProductCard(
                              item: item.toMap(),
                              productId: item.id,
                              onFavTap: () {
                                context.read<FavoritesBloc>().add(
                                      ToggleFavorite(
                                        productId: item.id,
                                        isCurrentlyFavorite: true,
                                      ),
                                    );
                              },
                            );
                          },
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class ProductCard extends StatelessWidget {
  final Map<String, String> item;
  final String productId;
  final VoidCallback? onFavTap;

  const ProductCard({
    super.key,
    required this.item,
    required this.productId,
    this.onFavTap,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FavoritesBloc, FavoritesState>(
      builder: (context, state) {
        final isActionLoading =
            state is FavoritesActionLoading && state.productId == productId;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image + Favourite button
            SizedBox(
              height: 123.h,
              child: Stack(
                children: [
                  // Product Image with rounded corners
                  ClipRRect(
                    borderRadius: BorderRadius.circular(5),
                    child: SafeNetworkImage(
                      imageUrl: item['image'],
                      width: double.infinity,
                      height: 140.h,
                      fit: BoxFit.cover,
                    ),
                  ),
                  // Favorite button
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

            // Info section (same as before)
            Expanded(
              child: Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
                      item['name'] ?? '',
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
                        const Icon(Icons.star,
                            color: Color(0xFFFFB800), size: 12),
                        SizedBox(width: 2.w),
                        Text(
                          item['rate'] ?? '0',
                          style: TextStyle(
                            color: const Color(0xFF333333),
                            fontSize: 10.sp,
                            fontFamily: 'Montserrat',
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        SizedBox(width: 2.w),
                        Text(
                          '(${item['reviews'] ?? '0'})',
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
                                text: '${item['price'] ?? '0'} ',
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
                            color: const Color(0xFF6B5E4B),
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
        );
      },
    );
  }
}
