import 'package:easy_localization/easy_localization.dart';
import 'package:erb/core/routing/routes.dart';
import 'package:erb/core/services/user_service.dart';
import 'package:erb/features/home/presentation/views/favourites_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';

class HomeHeader extends StatefulWidget {
  const HomeHeader({super.key});

  @override
  State<HomeHeader> createState() => _HomeHeaderState();
}

class _HomeHeaderState extends State<HomeHeader> with RouteAware {
  final UserService _userService = UserService();
  bool _isLoggedIn = false;
  String _userName = 'Guest';

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadUser();
  }

  Future<void> _loadUser() async {
    final loggedIn = await _userService.isLoggedIn();
    final name = loggedIn ? await _userService.getUserName() : 'Guest';
    if (mounted) {
      setState(() {
        _isLoggedIn = loggedIn;
        _userName = name;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Logged-in: title + favorites icon in one row ──
        if (_isLoggedIn)
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'greeting_with_name'
                          .tr(namedArgs: {'userName': _userName}),
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 20.sp,
                        fontFamily: 'Montserrat',
                        fontWeight: FontWeight.w700,
                        height: 1.07,
                        letterSpacing: 0.40,
                      ),
                    ),
                    SizedBox(
                      height: 6,
                    ),
                    Text(
                      'home_subtitle'.tr(),
                      style: TextStyle(
                        color: const Color(0xFF515151),
                        fontSize: 14.sp,
                        fontFamily: 'Montserrat',
                        fontWeight: FontWeight.w500,
                        height: 1.40,
                        letterSpacing: 0.32,
                      ),
                    ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: () => PersistentNavBarNavigator.pushNewScreen(
                  context,
                  screen: const FavouritesScreen(),
                  withNavBar: true,
                  pageTransitionAnimation: PageTransitionAnimation.cupertino,
                ),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: ShapeDecoration(
                    color: const Color(0xFFF5F0EA),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(100),
                    ),
                  ),
                  child: const Icon(Icons.favorite_outline_rounded),
                ),
              ),
            ],
          )

        // ── Guest: title, subtitle, then full-width Sign In button ──
        else ...[
          Text(
            'discover_erb'.tr(),
            style: TextStyle(
              color: Colors.black,
              fontSize: 20.sp,
              fontFamily: 'Montserrat',
              fontWeight: FontWeight.w700,
              height: 1.07,
              letterSpacing: 0.40,
            ),
          ),
          SizedBox(
            height: 6,
          ),
          Text(
            'sign_in_to_unlock'.tr(),
            style: TextStyle(
              color: const Color(0xFF515151),
              fontSize: 14.sp,
              fontFamily: 'Montserrat',
              fontWeight: FontWeight.w500,
              height: 1.40,
              letterSpacing: 0.32,
            ),
          ),
          SizedBox(height: 12.h),
          SizedBox(
            width: double.infinity,
            height: 52.h,
            child: ElevatedButton(
              onPressed: () {
                Navigator.of(context, rootNavigator: true)
                    .pushNamed(Routes.splashScreen)
                    .then((_) => _loadUser());
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6B5E4B),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5.r),
                ),
                elevation: 0,
              ),
              child: Text(
                'sign_in'.tr(),
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16.sp,
                  fontFamily: 'Montserrat',
                  fontWeight: FontWeight.w600,
                  height: 1.50,
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }
}
