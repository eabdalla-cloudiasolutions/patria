import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:patria/core/routing/routes.dart';
import 'package:patria/core/services/user_service.dart';
import 'package:patria/core/widgets/empty_state_widget.dart';
import 'package:patria/features/cart/presentation/manager/cart_bloc.dart';
import 'package:patria/features/cart/presentation/manager/cart_event.dart';
import 'package:patria/features/cart/presentation/views/cart_screen.dart';
import 'package:patria/features/orders/presentation/views/order_summary_screen.dart';
import 'package:patria/features/previous_orders/data/models/order_model.dart';
import 'package:patria/features/previous_orders/presentation/manager/orders_bloc.dart';
import 'package:patria/features/previous_orders/presentation/manager/orders_event.dart';
import 'package:patria/features/previous_orders/presentation/manager/orders_state.dart';
import 'package:patria/features/previous_orders/presentation/views/widgets/order_details_bottom_sheet.dart';
import 'package:patria/main.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';
import 'package:shimmer/shimmer.dart';

import 'widgets/order_card.dart';

class PreviousOrdersScreen extends StatefulWidget {
  final PersistentTabController controller;
  final int myTabIndex;

  const PreviousOrdersScreen({
    super.key,
    required this.controller,
    required this.myTabIndex,
  });

  @override
  State<PreviousOrdersScreen> createState() => _PreviousOrdersScreenState();
}

class _PreviousOrdersScreenState extends State<PreviousOrdersScreen>
    with RouteAware {
  final UserService _userService = UserService();
  bool _isLoggedIn = false;
  bool _isLoading = true;
  bool _isTabSelected = false;
  late OrdersBloc _ordersBloc;
  Timer? _pollingTimer;

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
    widget.controller.addListener(_onTabChanged);
    _startPolling();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _ordersBloc = context.read<OrdersBloc>();
    final route = ModalRoute.of(context);
    if (route != null) {
      routeObserver.subscribe(this, route);
    }
    _ordersBloc.add(LoadOrders());
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onTabChanged);
    routeObserver.unsubscribe(this);
    _pollingTimer?.cancel();
    super.dispose();
  }

  void _startPolling() {
    _pollingTimer = Timer.periodic(const Duration(seconds: 15), (_) {
      if (mounted && _isLoggedIn) {
        _ordersBloc.add(RefreshOrders());
      }
    });
  }

  void _onTabChanged() {
    if (widget.controller.index == widget.myTabIndex && !_isTabSelected) {
      _isTabSelected = true;
      _ordersBloc.add(LoadOrders());
    } else if (widget.controller.index != widget.myTabIndex) {
      _isTabSelected = false;
    }
  }

  @override
  void didPopNext() {
    _ordersBloc.add(LoadOrders());
  }

  void _showOrderDetails(OrderModel order) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => OrderDetailsBottomSheet(order: order),
    );
  }

  Future<void> _checkLoginStatus() async {
    final token = await _userService.getUserToken();
    final loggedIn = token.isNotEmpty;
    if (mounted) {
      setState(() {
        _isLoggedIn = loggedIn;
        _isLoading = false;
      });
    }
  }

  String _formatOrderDate(String isoDate) {
    try {
      final dateTime = DateTime.parse(isoDate).toLocal();
      final locale = context.locale.toString();
      final dateFormat = DateFormat('MMM d', locale);
      final timeFormat = DateFormat('h:mm a', locale);
      return '${dateFormat.format(dateTime)} · ${timeFormat.format(dateTime)}';
    } catch (e) {
      return isoDate;
    }
  }

  void _onReorder(OrderModel order) async {
    BuildContext? dialogContext;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        dialogContext = ctx;
        return const Center(child: CircularProgressIndicator());
      },
    );

    try {
      final cartBloc = context.read<CartBloc>();

      for (final item in order.items) {
        cartBloc.add(
          AddToCart(
            productId: item.productId,
            quantity: item.quantity,
            notes: item.notes,
            // ✅ Convert selectedVariants to customization map (what backend expects)
            customization: item.selectedVariants.isNotEmpty
                ? Map.fromEntries(
                    item.selectedVariants.map(
                      (v) => MapEntry(v.group, v.option),
                    ),
                  )
                : null,
          ),
        );
        await Future.delayed(const Duration(milliseconds: 50));
      }

      await Future.delayed(const Duration(milliseconds: 500));

      if (dialogContext != null && mounted) {
        Navigator.of(dialogContext!).pop();
      }

      if (mounted) {
        PersistentNavBarNavigator.pushNewScreen(
          context,
          screen: CartScreen(
            controller: widget.controller,
            fromNav: false,
            myTabIndex: 1,
          ),
          withNavBar: true,
          pageTransitionAnimation: PageTransitionAnimation.cupertino,
        );
      }
    } catch (e) {
      if (dialogContext != null && mounted) {
        Navigator.of(dialogContext!).pop();
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'reorder_failed'.tr(),
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            backgroundColor: const Color(0xFFC90000),
            duration: const Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
          ),
        );
      }
    }
  }

  void _navigateToTrackOrder(OrderModel order) {
    Navigator.of(context, rootNavigator: true).pushNamed(
      Routes.trackOrder,
      arguments: {
        'orderNumber': order.orderNumber,
        'orderId': order.id,
        'estimatedArrival': '30 min : 60 min',
        'currentStep': 0,
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
        orderId: order['orderId'],
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
          imagePath: 'assets/images/Empty Past Orders.png',
          title: 'no_orders'.tr(),
          subtitle: 'please_sign_in_to_view_orders'.tr(),
          buttonText: 'sign_in'.tr(),
          onButtonPressed: () {
            Navigator.of(
              context,
              rootNavigator: true,
            ).pushNamed(Routes.splashScreen).then((_) => _checkLoginStatus());
          },
        ),
      );
    }

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
            return RefreshIndicator(
              onRefresh: () async {
                context.read<OrdersBloc>().add(LoadOrders());
                await Future.delayed(const Duration(milliseconds: 500));
              },
              child: ListView.separated(
                padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 24.h),
                itemCount: state.orders.length,
                separatorBuilder: (_, __) => SizedBox(height: 12.h),
                itemBuilder: (_, index) {
                  final order = state.orders[index];
                  return OrderCard(
                    order: {
                      '_id': order.id,
                      'orderNumber': order.orderNumber,
                      'dateTime': _formatOrderDate(order.createdAt),
                      'status': order.status,
                      'imageUrls': order.items.map((e) => e.imageUrl).toList(),
                      'itemNames': order.items.map((e) => e.name).join(', '),
                      'itemCount': order.items.length,
                      'total': order.total,
                      'isReviewed': order.isReviewed,
                      'rating': order.rating ?? 0,
                    },
                    onTrackOrder: () => _navigateToTrackOrder(order),
                    onViewDetails: () => _showOrderDetails(order),
                    onReorder: () => _onReorder(order),
                    onRatingChanged: (_) => setState(() {}),
                  );
                },
              ),
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }
}
