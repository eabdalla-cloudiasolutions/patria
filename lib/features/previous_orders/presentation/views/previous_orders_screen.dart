import 'package:easy_localization/easy_localization.dart';
import 'package:erb/core/routing/routes.dart';
import 'package:erb/core/services/user_service.dart';
import 'package:erb/core/widgets/empty_state_widget.dart';
import 'package:erb/features/orders/presentation/views/order_summary_screen.dart';
import 'package:erb/features/previous_orders/presentation/manager/orders_bloc.dart';
import 'package:erb/features/previous_orders/presentation/manager/orders_event.dart';
import 'package:erb/features/previous_orders/presentation/manager/orders_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';
import 'package:shimmer/shimmer.dart';

import 'widgets/order_card.dart';

class PreviousOrdersScreen extends StatefulWidget {
  final PersistentTabController controller;

  const PreviousOrdersScreen({super.key, required this.controller});

  @override
  State<PreviousOrdersScreen> createState() => _PreviousOrdersScreenState();
}

class _PreviousOrdersScreenState extends State<PreviousOrdersScreen> {
  final UserService _userService = UserService();
  bool _isLoggedIn = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _checkLoginStatus(); // refresh after returning from login
  }

  Future<void> _checkLoginStatus() async {
    final token = await _userService.getUserToken();
    final userEmail = await _userService.getUserEmail();
    final loggedIn = token.isNotEmpty && userEmail.isNotEmpty;

    if (mounted) {
      setState(() {
        _isLoggedIn = loggedIn;
        _isLoading = false;
      });
    }
  }

  void _navigateToTrackOrder(Map<String, dynamic> order) {
    Navigator.of(context, rootNavigator: true).pushNamed(
      Routes.trackOrder,
      arguments: {
        'orderNumber': order['orderNumber'],
        'estimatedArrival': '3:00 PM',
        'minsAway': 15,
        'riderName': 'Ahmed Mohamed',
        'currentStep': 2,
      },
    );
  }

  void _navigateToOrderDetails(Map<String, dynamic> order) {
    PersistentNavBarNavigator.pushNewScreen(
      context,
      screen: OrderSummaryScreen(
        orderNumber: order['orderNumber'],
        subtotal: order['total'],
        deliveryFee: 25.0,
        deliveryAddress: '',
        paymentMethod: '',
        pointsEarned: 0,
        cartItems: [],
        serviceFee: 32.0,
      ),
      withNavBar: true,
      pageTransitionAnimation: PageTransitionAnimation.cupertino,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Color(0xFFF7F7F7),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (!_isLoggedIn) {
      return Scaffold(
        backgroundColor: const Color(0xFFF7F7F7),
        appBar: AppBar(
          backgroundColor: const Color(0xFFF7F7F7),
          elevation: 0,
          leading: GestureDetector(
            onTap: () => widget.controller.jumpToTab(0),
            child: const Icon(Icons.arrow_back),
          ),
          title: Text(
            'previous_orders'.tr(),
            style: TextStyle(
              color: Colors.black,
              fontSize: 18.sp,
              fontFamily: 'Montserrat',
              fontWeight: FontWeight.w600,
              letterSpacing: 0.36,
            ),
          ),
          centerTitle: true,
        ),
        body: EmptyStateWidget(
          imagePath:
              'assets/images/Empty Past Orders.png', // use your own asset
          title: 'no_orders'.tr(),
          subtitle: 'please_sign_in_to_view_orders'.tr(),
          buttonText: 'sign_in'.tr(),
          onButtonPressed: () {
            Navigator.of(context, rootNavigator: true)
                .pushNamed(Routes.splashScreen)
                .then((_) => _checkLoginStatus());
          },
        ),
      );
    }

    // Logged‑in user – show BLoC content
    return BlocProvider(
      create: (_) => OrdersBloc()..add(LoadOrders()),
      child: Scaffold(
        backgroundColor: const Color(0xFFF7F7F7),
        appBar: AppBar(
          backgroundColor: const Color(0xFFF7F7F7),
          elevation: 0,
          leading: GestureDetector(
            onTap: () => widget.controller.jumpToTab(0),
            child: const Icon(Icons.arrow_back),
          ),
          title: Text(
            'previous_orders'.tr(),
            style: TextStyle(
              color: Colors.black,
              fontSize: 18.sp,
              fontFamily: 'Montserrat',
              fontWeight: FontWeight.w600,
              letterSpacing: 0.36,
            ),
          ),
          centerTitle: true,
        ),
        body: BlocBuilder<OrdersBloc, OrdersState>(
          builder: (context, state) {
            if (state is OrdersLoading) {
              return ListView.separated(
                padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 24.h),
                itemCount: 3,
                separatorBuilder: (_, __) => SizedBox(height: 12.h),
                itemBuilder: (_, __) => Shimmer.fromColors(
                  baseColor: Colors.grey.shade300,
                  highlightColor: Colors.grey.shade100,
                  child: Container(
                    height: 120.h,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15.r),
                    ),
                  ),
                ),
              );
            }

            if (state is OrdersError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline,
                        size: 48, color: Color(0xFFCACBD4)),
                    SizedBox(height: 12.h),
                    Text(
                      state.message,
                      style: TextStyle(
                          color: const Color(0xFF8B8B8B), fontSize: 14.sp),
                    ),
                    SizedBox(height: 12.h),
                    ElevatedButton(
                      onPressed: () =>
                          context.read<OrdersBloc>().add(LoadOrders()),
                      child: Text('retry'.tr()),
                    ),
                  ],
                ),
              );
            }

            if (state is OrdersLoaded && state.orders.isEmpty) {
              return EmptyStateWidget(
                imagePath: 'assets/images/Empty Past Orders.png',
                title: 'no_orders'.tr(),
                subtitle: 'start_shopping'.tr(),
                buttonText: 'browse_menu'.tr(),
                onButtonPressed: () {
                  widget.controller.jumpToTab(0);
                },
              );
            }

            if (state is OrdersLoaded) {
              return ListView.separated(
                padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 24.h),
                itemCount: state.orders.length,
                separatorBuilder: (_, __) => SizedBox(height: 12.h),
                itemBuilder: (_, index) {
                  final order = state.orders[index];
                  return OrderCard(
                    order: {
                      'orderNumber': order.orderNumber,
                      'dateTime': order.createdAt,
                      'status': order.status,
                      'imageUrls': order.items.map((e) => e.imageUrl).toList(),
                      'itemNames': order.items.map((e) => e.name).join(', '),
                      'itemCount': order.items.length,
                      'total': order.total,
                    },
                    onTrackOrder: () => _navigateToTrackOrder({
                      'orderNumber': order.orderNumber,
                    }),
                    onViewDetails: () => _navigateToOrderDetails({
                      'orderNumber': order.orderNumber,
                      'total': order.total,
                    }),
                    onReorder: () {
                      // TODO: implement reorder
                    },
                  );
                },
              );
            }

            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }
}
