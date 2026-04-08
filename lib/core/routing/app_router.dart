import 'package:erb/core/routing/routes.dart';
import 'package:erb/features/account/presentation/views/edit_address_screen.dart';
import 'package:erb/features/account/presentation/views/payment_methods_screen.dart';
import 'package:erb/features/account/presentation/views/personal_information_screen.dart';
import 'package:erb/features/account/presentation/views/saved_addresses_screen.dart';
import 'package:erb/features/auth/presentation/views/splash_screen.dart';
import 'package:erb/features/base_layer/base_layer.dart';
import 'package:erb/features/cart/presentation/views/cart_screen.dart';
import 'package:erb/features/checkout/presentation/views/checkout_screen.dart';
import 'package:erb/features/checkout/presentation/views/new_address_screen.dart';
import 'package:erb/features/home/data/models/product_model.dart';
import 'package:erb/features/home/presentation/views/favourites_screen.dart';
import 'package:erb/features/home/presentation/views/home_screen.dart';
import 'package:erb/features/orders/presentation/views/order_summary_screen.dart';
import 'package:erb/features/orders/presentation/views/track_order_screen.dart';
import 'package:erb/features/previous_orders/presentation/views/previous_orders_screen.dart';
import 'package:erb/features/product/presentation/views/item_preview_screen.dart';
import 'package:flutter/material.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';

class AppRouter {
  Route? generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case Routes.splashScreen:
        return MaterialPageRoute(
          builder: (_) => const SplashScreen(),
        );

      case Routes.home:
        return MaterialPageRoute(
          builder: (_) => const Home(),
        );
      case Routes.baseLayer:
        return MaterialPageRoute(
          builder: (_) => const BaseLayer(),
        );
      case Routes.checkoutScreen:
        final args = settings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(
          builder: (_) => CheckoutScreen(
            cartItems: args['cartItems'],
            subtotal: args['subtotal'],
          ),
        );
      case Routes.personalInformation:
        return MaterialPageRoute(
          builder: (_) => const PersonalInformationScreen(),
        );
      case Routes.savedAddresses:
        return MaterialPageRoute(
          builder: (_) => const SavedAddressesScreen(),
        );
      case Routes.paymentMethods:
        return MaterialPageRoute(
          builder: (_) => const PaymentMethodsScreen(),
        );
// app_router.dart
      case Routes.orderSummary:
        final args = settings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(
          builder: (_) => OrderSummaryScreen(
            orderNumber: args['orderNumber'] as String,
            cartItems: (args['cartItems'] as List<dynamic>)
                .map((e) => Map<String, dynamic>.from(e as Map))
                .toList(), // ← explicit cast
            subtotal: (args['subtotal'] as num).toDouble(),
            deliveryFee: (args['deliveryFee'] as num).toDouble(),
            serviceFee: (args['serviceFee'] as num).toDouble(),
            deliveryAddress: args['deliveryAddress'] as String,
            paymentMethod: args['paymentMethod'] as String,
            pointsEarned: args['pointsEarned'] as int,
          ),
        );

      case Routes.trackOrder:
        final args = settings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(
          builder: (_) => TrackOrderScreen(
            orderNumber: args['orderNumber'] as String,
            estimatedArrival: args['estimatedArrival'] as String,
            minsAway: args['minsAway'] as int,
            riderName: args['riderName'] as String,
            currentStep: args['currentStep'] as int,
          ),
        );
      case Routes.editAddress:
        final args = settings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(
          builder: (_) => EditAddressScreen(address: args['address']),
        );
      // case Routes.editCard:
      //   final args = settings.arguments as Map<String, dynamic>;
      //   return MaterialPageRoute(
      //     builder: (_) => EditCardScreen(card: args['card']),
      //   );
      case Routes.previousOrders:
        final args = settings.arguments as Map<String, dynamic>;

        return MaterialPageRoute(
          builder: (_) => PreviousOrdersScreen(
            controller: args['controller'],
          ),
        );
      case Routes.itemPreview:
        // Handle ProductModel as argument
        final product = settings.arguments as ProductModel;
        return MaterialPageRoute(
          builder: (_) => ItemPreviewScreen(product: product),
        );
      case Routes.newAddressScreen:
        return MaterialPageRoute(builder: (_) => NewAddressScreen());

      case Routes.cartScreen:
        // Safely extract arguments with null check
        final args = settings.arguments as Map<String, dynamic>?;

        // Get initialCartItems with safe handling
        final initialCartItems =
            args?['initialCartItems'] as List<Map<String, dynamic>>?;

        // Create a default controller or get it from somewhere
        // You might want to get this from a provider or pass it from the main screen
        final controller = PersistentTabController(initialIndex: 2);

        return MaterialPageRoute(
          builder: (_) => CartScreen(
            controller: controller, // You need to provide this
            initialCartItems: initialCartItems ?? [],
          ),
          settings: settings, // Preserve settings
        );
      case Routes.favourites:
        return MaterialPageRoute(
          builder: (_) => const FavouritesScreen(),
        );
      default:
        return null;
    }
    return null;
  }
}
