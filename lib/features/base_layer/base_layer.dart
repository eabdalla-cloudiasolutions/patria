import 'package:easy_localization/easy_localization.dart';
import 'package:erb/features/account/presentation/views/account_screen.dart';
import 'package:erb/features/cart/presentation/views/cart_screen.dart';
import 'package:erb/features/home/presentation/views/home_screen.dart';
import 'package:erb/features/previous_orders/presentation/views/previous_orders_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';

class BaseLayer extends StatefulWidget {
  const BaseLayer({super.key});

  @override
  State<BaseLayer> createState() => _BaseLayerState();
}

class _BaseLayerState extends State<BaseLayer> {
  final PersistentTabController _controller =
      PersistentTabController(initialIndex: 0);

  List<Widget> _screens() {
    return [
      const Home(),
      CartScreen(
        controller: _controller,
        fromNav: true, // ✅ opened via nav bar
      ),
      PreviousOrdersScreen(controller: _controller),
      AccountScreen(controller: _controller),
    ];
  }

  List<PersistentBottomNavBarItem> _navBarItems() {
    return [
      PersistentBottomNavBarItem(
        icon: const Icon(Icons.home, size: 26),
        activeColorPrimary: const Color(0xFF6B5E4B),
        inactiveColorPrimary: const Color(0xFF8B8B8B),
        title: 'nav_home'.tr(),
      ),
      PersistentBottomNavBarItem(
        icon: const Icon(Icons.shopping_cart_outlined, size: 26),
        activeColorPrimary: const Color(0xFF6B5E4B),
        inactiveColorPrimary: const Color(0xFF8B8B8B),
        title: 'nav_cart'.tr(),
      ),
      PersistentBottomNavBarItem(
        icon: const Icon(Icons.receipt_long_outlined, size: 26),
        activeColorPrimary: const Color(0xFF6B5E4B),
        inactiveColorPrimary: const Color(0xFF8B8B8B),
        title: 'nav_orders'.tr(),
      ),
      PersistentBottomNavBarItem(
        icon: const Icon(Icons.person_outline, size: 26),
        activeColorPrimary: const Color(0xFF6B5E4B),
        inactiveColorPrimary: const Color(0xFF8B8B8B),
        title: 'nav_account'.tr(),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return PersistentTabView(
      context,
      key: ValueKey(context.locale),
      controller: _controller,
      screens: _screens(),
      items: _navBarItems(),
      navBarStyle: NavBarStyle.style6,
      backgroundColor: Colors.white,
      hideNavigationBarWhenKeyboardAppears: true,
      handleAndroidBackButtonPress: true,
      resizeToAvoidBottomInset: true,
      stateManagement: true,
      confineToSafeArea: true,
      navBarHeight: 70.h,

      padding: EdgeInsets.only(
        top: 20.h,
      ), // ✅ equal top/bottom centers icons
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
  }
}
