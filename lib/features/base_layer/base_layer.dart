import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:patria/core/helpers/responsive_helper.dart';
import 'package:patria/features/account/presentation/views/account_screen.dart';
import 'package:patria/features/cart/presentation/manager/cart_bloc.dart';
import 'package:patria/features/cart/presentation/manager/cart_event.dart';
import 'package:patria/features/cart/presentation/manager/cart_state.dart';
import 'package:patria/features/cart/presentation/views/cart_screen.dart';
import 'package:patria/features/home/presentation/views/home_screen.dart';
import 'package:patria/features/previous_orders/presentation/views/previous_orders_screen.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';

class BaseLayer extends StatefulWidget {
  const BaseLayer({super.key});

  @override
  State<BaseLayer> createState() => _BaseLayerState();
}

class _BaseLayerState extends State<BaseLayer> {
  final PersistentTabController _controller = PersistentTabController(
    initialIndex: 0,
  );
  bool _isHomeTabSelected = false;

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onTabChanged);
  }

  @override
  void dispose() {
    _controller.removeListener(_onTabChanged);
    super.dispose();
  }

  void _onTabChanged() {
    // Refresh cart when Home tab becomes visible (index 0)
    if (_controller.index == 0 && !_isHomeTabSelected) {
      _isHomeTabSelected = true;
      context.read<CartBloc>().add(LoadCart());
    } else if (_controller.index != 0) {
      _isHomeTabSelected = false;
    }
  }

  List<Widget> _screens() {
    return [
      const Home(),
      CartScreen(controller: _controller, fromNav: true, myTabIndex: 1),
      PreviousOrdersScreen(controller: _controller, myTabIndex: 2),
      AccountScreen(controller: _controller),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CartBloc, CartState>(
      builder: (context, cartState) {
        int itemCount = 0;
        if (cartState is CartLoaded) {
          itemCount = cartState.cart.itemCount;
        }

        // Fixed (not ScreenUtil-scaled) values on tablet, same reasoning
        // as the home screen's category circles: iPad is bigger than the
        // phone-sized design canvas .h/.sp are calibrated against, and a
        // fixed value also stays consistent between portrait/landscape.
        final isTablet = ResponsiveHelper.isTablet(context);
        final navBarHeight = isTablet ? 96.0 : 74.h;
        final navBarTopPadding = isTablet ? 24.0 : 20.h;

        return PersistentTabView(
          context,
          key: ValueKey(context.locale),
          controller: _controller,
          screens: _screens(),
          items: _navBarItems(itemCount, isTablet),
          navBarStyle: NavBarStyle.style6,
          backgroundColor: Colors.white,
          hideNavigationBarWhenKeyboardAppears: true,
          handleAndroidBackButtonPress: true,
          resizeToAvoidBottomInset: true,
          stateManagement: true,
          confineToSafeArea: true,
          navBarHeight: navBarHeight,
          padding: EdgeInsets.only(top: navBarTopPadding),
          decoration: NavBarDecoration(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(22.r),
              topRight: Radius.circular(22.r),
            ),
            colorBehindNavBar: const Color(0xFFF7F7F7),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 8,
                offset: const Offset(0, -2),
              ),
            ],
          ),
        );
      },
    );
  }

  List<PersistentBottomNavBarItem> _navBarItems(
    int cartItemCount,
    bool isTablet,
  ) {
    final textStyle = TextStyle(
      fontSize: isTablet ? 15.0 : 13.sp,
      fontFamily: 'Montserrat',
      fontWeight: FontWeight.w600,
    );

    return [
      PersistentBottomNavBarItem(
        icon: _navIcon('assets/images/home-1.png', isTablet),
        inactiveIcon: _navIcon('assets/images/home.png', isTablet),
        activeColorPrimary: const Color(0xFF3C4119),
        inactiveColorPrimary: const Color(0xFF8B8B8B),
        title: 'nav_home'.tr(),
        textStyle: textStyle,
      ),
      PersistentBottomNavBarItem(
        icon: _buildCartIcon(cartItemCount, isTablet, isActive: true),
        inactiveIcon: _buildCartIcon(cartItemCount, isTablet, isActive: false),
        activeColorPrimary: const Color(0xFF3C4119),
        inactiveColorPrimary: const Color(0xFF8B8B8B),
        title: 'nav_cart'.tr(),
        textStyle: textStyle,
      ),
      PersistentBottomNavBarItem(
        icon: _navIcon('assets/images/file-spreadsheet-1.png', isTablet),
        inactiveIcon: _navIcon('assets/images/file-spreadsheet.png', isTablet),
        activeColorPrimary: const Color(0xFF3C4119),
        inactiveColorPrimary: const Color(0xFF8B8B8B),
        title: 'nav_orders'.tr(),
        textStyle: textStyle,
      ),
      PersistentBottomNavBarItem(
        icon: _navIcon('assets/images/user-1.png', isTablet),
        inactiveIcon: _navIcon('assets/images/user.png', isTablet),
        activeColorPrimary: const Color(0xFF3C4119),
        inactiveColorPrimary: const Color(0xFF8B8B8B),
        title: 'nav_account'.tr(),
        textStyle: textStyle,
      ),
    ];
  }

  // On phone, keep the icon exactly as before (a plain Image.asset, sized
  // by however the nav bar's internal layout squeezes it). On tablet,
  // pin it to an explicit, larger fixed size — the nav bar height above
  // grows too, so without this the icon would just stay phone-sized and
  // look lost in the taller bar.
  Widget _navIcon(String asset, bool isTablet) {
    if (!isTablet) return Image.asset(asset);
    return SizedBox(
      width: 32,
      height: 32,
      child: Image.asset(asset, fit: BoxFit.contain),
    );
  }

  Widget _buildCartIcon(
    int itemCount,
    bool isTablet, {
    bool isActive = false,
  }) {
    final asset = isActive
        ? 'assets/images/cart-1.png' // 👈 your active cart asset
        : 'assets/images/cart.png'; // 👈 your inactive cart asset
    final badgeLeft = isTablet ? 22.0 : 17.w;
    final badgeTop = isTablet ? -4.0 : -3.h;
    final badgeMinSize = isTablet ? 20.0 : 16.0;
    final badgeFontSize = isTablet ? 10.0 : 8.0;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        _navIcon(asset, isTablet),
        if (itemCount > 0)
          Positioned(
            left: badgeLeft,
            top: badgeTop,
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: isTablet ? 5.0 : 4.w,
                vertical: isTablet ? 2.0 : 2.h,
              ),
              decoration: const BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
              ),
              constraints: BoxConstraints(
                minWidth: badgeMinSize,
                minHeight: badgeMinSize,
              ),
              child: Text(
                itemCount > 99 ? '99+' : '$itemCount',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: badgeFontSize,
                  fontWeight: FontWeight.w600,
                  height: 1.2,
                  decoration: TextDecoration.none,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
      ],
    );
  }
}
