import 'package:flutter/material.dart';
import 'package:patria/core/routing/routes.dart';
import 'package:patria/features/account/presentation/views/edit_address_screen.dart';
import 'package:patria/features/account/presentation/views/payment_methods_screen.dart';
import 'package:patria/features/account/presentation/views/personal_information_screen.dart';
import 'package:patria/features/account/presentation/views/saved_addresses_screen.dart';
import 'package:patria/features/account/presentation/views/widgets/privacy_screen.dart';
import 'package:patria/features/account/presentation/views/widgets/terms_screen.dart';
import 'package:patria/features/auth/presentation/views/splash_screen.dart';
import 'package:patria/features/base_layer/base_layer.dart';
import 'package:patria/features/cart/presentation/views/cart_screen.dart';
import 'package:patria/features/checkout/presentation/views/checkout_screen.dart';
import 'package:patria/features/checkout/presentation/views/new_address_screen.dart';
import 'package:patria/features/home/data/models/product_model.dart';
import 'package:patria/features/home/presentation/views/favourites_screen.dart';
import 'package:patria/features/home/presentation/views/home_screen.dart';
import 'package:patria/features/orders/presentation/views/order_summary_screen.dart';
import 'package:patria/features/orders/presentation/views/track_order_screen.dart';
import 'package:patria/features/previous_orders/presentation/views/previous_orders_screen.dart';
import 'package:patria/features/product/presentation/views/item_preview_screen.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';

class AppRouter {
  Route? generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case Routes.splashScreen:
        return MaterialPageRoute(builder: (_) => const SplashScreen());

      case Routes.home:
        return MaterialPageRoute(builder: (_) => const Home());

      case Routes.baseLayer:
        return MaterialPageRoute(builder: (_) => const BaseLayer());

      case Routes.checkoutScreen:
        final args = settings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(
          builder: (_) => CheckoutScreen(
            cartItems: args['cartItems'],
            subtotal: args['subtotal'],
            discount: args['discount'] ?? 0,
            voucherCode: args['voucherCode'],
            specialRequests: args['specialRequests'],
          ),
        );

      case Routes.personalInformation:
        return MaterialPageRoute(
          builder: (_) => const PersonalInformationScreen(),
        );

      case Routes.savedAddresses:
        return MaterialPageRoute(builder: (_) => const SavedAddressesScreen());

      case Routes.paymentMethods:
        return MaterialPageRoute(builder: (_) => const PaymentMethodsScreen());

      case Routes.orderSummary:
        final args = settings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(
          builder: (_) => OrderSummaryScreen(
            orderNumber: args['orderNumber'],
            orderId: args['orderId'] ?? '',
            cartItems: args['cartItems'],
            subtotal: args['subtotal'],
            deliveryFee: args['deliveryFee'],
            deliveryAddress: args['deliveryAddress'],
            paymentMethod: args['paymentMethod'],
            pointsEarned: args['pointsEarned'],
            note: args['note'],
            discount: (args['discount'] as double?) ?? 0, // ← add this
          ),
        );

      case Routes.trackOrder:
        final args = settings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(
          builder: (_) => TrackOrderScreen(
            orderNumber: args['orderNumber'],
            orderId: args['orderId'],
            estimatedArrival: args['estimatedArrival'] ?? '30 min - 60 min',
            currentStep: args['currentStep'] ?? 0,
          ),
        );

      case Routes.editAddress:
        final args = settings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(
          builder: (_) => EditAddressScreen(address: args['address']),
        );

      case Routes.previousOrders:
        final args = settings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(
          builder: (_) => PreviousOrdersScreen(
            controller: args['controller'],
            myTabIndex: args['myTabIndex'] ?? 0,
          ),
        );

      case Routes.itemPreview:
        final args = settings.arguments;
        if (args is ProductModel) {
          return MaterialPageRoute(
            builder: (_) => ItemPreviewScreen(product: args),
          );
        } else if (args is Map<String, dynamic>) {
          return MaterialPageRoute(
            builder: (_) => ItemPreviewScreen.fromArguments(args),
          );
        } else {
          return MaterialPageRoute(builder: (_) => const SizedBox.shrink());
        }

      case Routes.newAddressScreen:
        return MaterialPageRoute(builder: (_) => NewAddressScreen());

      case Routes.cartScreen:
        final args = settings.arguments as Map<String, dynamic>?;
        final controller = args?['controller'] as PersistentTabController?;
        final fromNav = args?['fromNav'] as bool? ?? false;
        final myTabIndex = args?['myTabIndex'] as int? ?? 2;
        return MaterialPageRoute(
          builder: (_) => CartScreen(
            controller: controller,
            fromNav: fromNav,
            myTabIndex: myTabIndex,
          ),
          settings: settings,
        );

      case Routes.favourites:
        return MaterialPageRoute(builder: (_) => const FavouritesScreen());

      case Routes.terms:
        return MaterialPageRoute(builder: (_) => const TermsScreen());

      case Routes.privacy:
        return MaterialPageRoute(builder: (_) => const PrivacyScreen());

      default:
        return null;
    }
  }
}
