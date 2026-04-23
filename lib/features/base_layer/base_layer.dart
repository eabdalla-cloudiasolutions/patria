import 'package:easy_localization/easy_localization.dart';
import 'package:erb/features/account/presentation/views/account_screen.dart';
import 'package:erb/features/cart/presentation/manager/cart_bloc.dart';
import 'package:erb/features/cart/presentation/manager/cart_event.dart';
import 'package:erb/features/cart/presentation/manager/cart_state.dart';
import 'package:erb/features/cart/presentation/views/cart_screen.dart';
import 'package:erb/features/home/presentation/views/home_screen.dart';
import 'package:erb/features/previous_orders/presentation/views/previous_orders_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
      CartScreen(
        controller: _controller,
        fromNav: true,
        myTabIndex: 1,
      ),
      PreviousOrdersScreen(
        controller: _controller,
        myTabIndex: 2,
      ),
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

        return PersistentTabView(
          context,
          key: ValueKey(context.locale),
          controller: _controller,
          screens: _screens(),
          items: _navBarItems(itemCount),
          navBarStyle: NavBarStyle.style6,
          backgroundColor: Colors.white,
          hideNavigationBarWhenKeyboardAppears: true,
          handleAndroidBackButtonPress: true,
          resizeToAvoidBottomInset: true,
          stateManagement: true,
          confineToSafeArea: true,
          navBarHeight: 74.h,
          padding: EdgeInsets.only(top: 20.h),
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

  List<PersistentBottomNavBarItem> _navBarItems(int cartItemCount) {
    return [
      PersistentBottomNavBarItem(
        icon: Image.asset('assets/images/home-1.png'),
        inactiveIcon: Image.asset(('assets/images/home.png')),
        activeColorPrimary: const Color(0xFF6B5E4B),
        inactiveColorPrimary: const Color(0xFF8B8B8B),
        title: 'nav_home'.tr(),
        textStyle: TextStyle(
            fontSize: 13.sp,
            fontFamily: 'Montserrat',
            fontWeight: FontWeight.w600),
      ),
      PersistentBottomNavBarItem(
        icon: _buildCartIcon(cartItemCount, isActive: true), // 👈
        inactiveIcon: _buildCartIcon(cartItemCount,
            isActive:
                false), // 👈        activeColorPrimary: const Color(0xFF6B5E4B),
        activeColorPrimary: const Color(0xFF6B5E4B),
        inactiveColorPrimary: const Color(0xFF8B8B8B), title: 'nav_cart'.tr(),
        textStyle: TextStyle(
            fontSize: 13.sp,
            fontFamily: 'Montserrat',
            fontWeight: FontWeight.w600),
      ),
      PersistentBottomNavBarItem(
        icon: Image.asset('assets/images/file-spreadsheet-1.png'),
        inactiveIcon: Image.asset(('assets/images/file-spreadsheet.png')),
        activeColorPrimary: const Color(0xFF6B5E4B),
        inactiveColorPrimary: const Color(0xFF8B8B8B),
        title: 'nav_orders'.tr(),
        textStyle: TextStyle(
            fontSize: 13.sp,
            fontFamily: 'Montserrat',
            fontWeight: FontWeight.w600),
      ),
      PersistentBottomNavBarItem(
        icon: Image.asset('assets/images/user-1.png'),
        inactiveIcon: Image.asset(('assets/images/user.png')),
        activeColorPrimary: const Color(0xFF6B5E4B),
        inactiveColorPrimary: const Color(0xFF8B8B8B),
        title: 'nav_account'.tr(),
        textStyle: TextStyle(
            fontSize: 13.sp,
            fontFamily: 'Montserrat',
            fontWeight: FontWeight.w600),
      ),
    ];
  }

  Widget _buildCartIcon(int itemCount, {bool isActive = false}) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Image.asset(
          isActive
              ? 'assets/images/cart-1.png' // 👈 your active cart asset
              : 'assets/images/cart.png', // 👈 your inactive cart asset
        ),
        if (itemCount > 0)
          Positioned(
            left: 17.w,
            top: -3.h,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
              decoration: const BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
              ),
              constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
              child: Text(
                itemCount > 99 ? '99+' : '$itemCount',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 8,
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
