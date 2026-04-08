import 'package:easy_localization/easy_localization.dart';
import 'package:erb/features/account/data/repos/loyalty_repo.dart';
import 'package:erb/features/account/presentation/manager/loyalty/loyalty_bloc.dart';
import 'package:erb/features/account/presentation/manager/loyalty/loyalty_event.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class PointsCard extends StatelessWidget {
  const PointsCard({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          LoyaltyBloc(loyaltyRepo: LoyaltyRepo())..add(FetchLoyaltyPoints()),
      child: BlocBuilder<LoyaltyBloc, LoyaltyState>(
        builder: (context, state) {
          if (state is LoyaltyLoading) {
            return _buildLoadingCard();
          }

          if (state is LoyaltyError) {
            return _buildErrorCard(context);
          }

          if (state is LoyaltyLoaded) {
            final points = state.loyaltyData.points;

            // Your exact original UI - only points value is from API
            return Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
              decoration: ShapeDecoration(
                color: const Color(0xFF6B5E4B),
                image: const DecorationImage(
                  image: AssetImage('assets/images/Points Earned.png'),
                  fit: BoxFit.cover,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20.r),
                ),
              ),
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  // Divider (في الخلف)
                  Positioned(
                    top: 40.h,
                    left: 0.w,
                    right: 0.w,
                    child: Container(
                      height: 2.h,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(1.r),
                      ),
                    ),
                  ),
                  // المحتوى فوقه
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Padding(
                        padding: EdgeInsets.only(bottom: 20.h),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${state.loyaltyData.earnRate} pts = 1 EGP',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12.sp,
                                fontFamily: 'Changa',
                                fontWeight: FontWeight.w400,
                                letterSpacing: 0.24,
                              ),
                            ),
                            SizedBox(height: 12.h),
                            Text(
                              points.toString().replaceAllMapped(
                                    RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
                                    (m) => '${m[1]},',
                                  ),
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 24.sp,
                                fontFamily: 'Montserrat',
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.48,
                              ),
                            ),
                            Text(
                              'points_earned'.tr(),
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 13.sp,
                                fontFamily: 'Montserrat',
                                fontWeight: FontWeight.w500,
                                letterSpacing: 0.26,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Image.asset(
                        'assets/images/earn.png',
                        width: 120.w,
                        height: 120.h,
                        fit: BoxFit.contain,
                      ),
                    ],
                  ),
                ],
              ),
            );
          }

          return _buildLoadingCard();
        },
      ),
    );
  }

  // Loading card with same UI structure
  Widget _buildLoadingCard() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
      decoration: ShapeDecoration(
        color: const Color(0xFF6B5E4B),
        image: const DecorationImage(
          image: AssetImage('assets/images/Points Earned.png'),
          fit: BoxFit.cover,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.r),
        ),
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            top: 40.h,
            left: 0.w,
            right: 0.w,
            child: Container(
              height: 2.h,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.5),
                borderRadius: BorderRadius.circular(1.r),
              ),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Padding(
                padding: EdgeInsets.only(bottom: 20.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '10 pts = 1 EGP',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12.sp,
                        fontFamily: 'Changa',
                        fontWeight: FontWeight.w400,
                        letterSpacing: 0.24,
                      ),
                    ),
                    SizedBox(height: 12.h),
                    Container(
                      width: 80.w,
                      height: 24.h,
                      color: Colors.white.withOpacity(0.3),
                    ),
                    SizedBox(height: 4.h),
                    Container(
                      width: 100.w,
                      height: 16.h,
                      color: Colors.white.withOpacity(0.3),
                    ),
                  ],
                ),
              ),
              Image.asset(
                'assets/images/earn.png',
                width: 120.w,
                height: 120.h,
                fit: BoxFit.contain,
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Error card with retry button
  Widget _buildErrorCard(BuildContext context) {
    return GestureDetector(
      onTap: () {
        context.read<LoyaltyBloc>().add(RefreshLoyaltyPoints());
      },
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
        decoration: ShapeDecoration(
          color: const Color(0xFF6B5E4B),
          image: const DecorationImage(
            image: AssetImage('assets/images/Points Earned.png'),
            fit: BoxFit.cover,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.r),
          ),
        ),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Positioned(
              top: 40.h,
              left: 0.w,
              right: 0.w,
              child: Container(
                height: 2.h,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(1.r),
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Padding(
                  padding: EdgeInsets.only(bottom: 20.h),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '10 pts = 1 EGP',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12.sp,
                          fontFamily: 'Changa',
                          fontWeight: FontWeight.w400,
                          letterSpacing: 0.24,
                        ),
                      ),
                      SizedBox(height: 12.h),
                      Row(
                        children: [
                          const Icon(
                            Icons.error_outline,
                            color: Colors.white,
                            size: 20,
                          ),
                          SizedBox(width: 8.w),
                          Text(
                            'failed_to_load'.tr(),
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14.sp,
                              fontFamily: 'Montserrat',
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        'tap_to_retry'.tr(),
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.7),
                          fontSize: 12.sp,
                          fontFamily: 'Montserrat',
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ),
                Image.asset(
                  'assets/images/earn.png',
                  width: 120.w,
                  height: 120.h,
                  fit: BoxFit.contain,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
