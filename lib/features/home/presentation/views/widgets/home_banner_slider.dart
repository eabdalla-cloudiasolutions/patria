import 'package:carousel_slider/carousel_slider.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:erb/features/home/data/models/offer_model.dart';
import 'package:erb/features/home/data/repos/offers_repo.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'home_banner_item.dart';

class HomeBannerSlider extends StatefulWidget {
  const HomeBannerSlider({super.key});

  @override
  State<HomeBannerSlider> createState() => _HomeBannerSliderState();
}

class _HomeBannerSliderState extends State<HomeBannerSlider> {
  int _currentIndex = 0;
  final CarouselSliderController _controller = CarouselSliderController();

  List<OfferModel> _offers = [];
  bool _isLoading = true;
  String _errorMessage = '';

  final OffersRepo _offersRepo = OffersRepo();

  @override
  void initState() {
    super.initState();
    print('🔵🔵🔵 HomeBannerSlider INIT STATE CALLED 🔵🔵🔵');
    _loadOffers();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    print('🟣 HomeBannerSlider didChangeDependencies');
  }

  Future<void> _loadOffers() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final offers = await _offersRepo.getActiveOffers();
      setState(() {
        _offers = offers;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return _buildShimmer();
    }

    if (_errorMessage.isNotEmpty) {
      return _buildErrorWidget();
    }

    if (_offers.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      children: [
        CarouselSlider(
          carouselController: _controller,
          options: CarouselOptions(
            height: 154.h,
            viewportFraction: 1.0,
            enlargeCenterPage: false,
            autoPlay: true,
            autoPlayInterval: const Duration(seconds: 4),
            autoPlayAnimationDuration: const Duration(milliseconds: 600),
            autoPlayCurve: Curves.easeInOut,
            onPageChanged: (index, reason) =>
                setState(() => _currentIndex = index),
          ),
          items: _offers.map((offer) {
            return HomeBannerItem(
              title: offer.title,
              subtitle: offer.description,
              imageUrl: offer.imageUrl,
              discountPercent: offer.discountPercent, // "-20%" or null
            );
          }).toList(),
        ),
        SizedBox(height: 12.h),

        // Dots indicator
        if (_offers.length > 1)
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              _offers.length,
              (index) => GestureDetector(
                onTap: () => _controller.animateToPage(index),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  margin: EdgeInsets.symmetric(horizontal: 4.w),
                  width: _currentIndex == index ? 32.w : 8.w,
                  height: 8.h,
                  decoration: BoxDecoration(
                    color: _currentIndex == index
                        ? const Color(0xFF6B5E4B)
                        : const Color(0xFFCACBD4),
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildShimmer() {
    return Column(
      children: [
        Container(
          width: double.infinity,
          height: 154.h,
          decoration: BoxDecoration(
            color: Colors.grey.shade300,
            borderRadius: BorderRadius.circular(16.r),
          ),
        ),
        SizedBox(height: 12.h),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            3,
            (index) => Container(
              margin: EdgeInsets.symmetric(horizontal: 4.w),
              width: index == 0 ? 32.w : 8.w,
              height: 8.h,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(10.r),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildErrorWidget() {
    return Container(
      width: double.infinity,
      height: 154.h,
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.error_outline,
            size: 40,
            color: Color(0xFFCACBD4),
          ),
          SizedBox(height: 8.h),
          Text(
            'failed_to_load_offers'.tr(),
            style: TextStyle(
              color: const Color(0xFF8B8B8B),
              fontSize: 12.sp,
            ),
          ),
          SizedBox(height: 8.h),
          TextButton(
            onPressed: _loadOffers,
            child: Text(
              'retry'.tr(),
              style: TextStyle(
                color: const Color(0xFF6B5E4B),
                fontSize: 12.sp,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
