import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:patria/core/helpers/cache_helper.dart';
import 'package:patria/core/notifications/notification_navigation.dart';
import 'package:patria/core/providers/favourites_notifier.dart';
import 'package:patria/core/routing/app_router.dart';
import 'package:patria/core/routing/routes.dart';
import 'package:patria/core/services/notification_service.dart';
import 'package:patria/core/services/user_service.dart';
import 'package:patria/features/cart/presentation/manager/cart_bloc.dart';
import 'package:patria/features/cart/presentation/manager/cart_event.dart';
import 'package:patria/features/home/data/repos/favorites_repo.dart';
import 'package:patria/features/home/data/repos/products_repo.dart';
import 'package:patria/features/home/presentation/manager/favorites_bloc.dart';
import 'package:patria/features/home/presentation/manager/favorites_event.dart';
import 'package:patria/features/home/presentation/manager/products_bloc.dart';
import 'package:patria/features/previous_orders/presentation/manager/orders_bloc.dart';
import 'package:patria/firebase_options.dart';
import 'package:provider/provider.dart';

final RouteObserver<ModalRoute> routeObserver = RouteObserver<ModalRoute>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  await CacheHelper.init();

  // ✅ Patria Firebase Google Sign-In client IDs
  await GoogleSignIn.instance.initialize(
    clientId: Platform.isIOS
        ? '789058511912-s8ait6j5rlpsgrtlan4m5auaos1v4kao.apps.googleusercontent.com'
        : '789058511912-sm9p3q8morh5672qthbnbd54el13gcud.apps.googleusercontent.com',
    serverClientId:
        '789058511912-rlafs37ljd2qqeracgjvkb78enqpa0s1.apps.googleusercontent.com',
  );

  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

  await NotificationService().init();

  // ✅ Register token on every app start
  final token = await FirebaseMessaging.instance.getToken();
  if (token != null) {
    final isLoggedIn = await UserService().isLoggedIn().catchError(
      (_) => false,
    );
    if (isLoggedIn) {
      await NotificationService().registerToken(token);
    }
  }

  // ✅ Handle future token refreshes
  FirebaseMessaging.instance.onTokenRefresh.listen((newToken) async {
    final isLoggedIn = await UserService().isLoggedIn();
    if (isLoggedIn) {
      await NotificationService().registerToken(newToken);
    }
  });

  final isLoggedIn = await UserService().isLoggedIn().catchError((_) => false);

  runApp(
    EasyLocalization(
      supportedLocales: const [Locale('en'), Locale('ar')],
      path: 'assets/translations',
      fallbackLocale: const Locale('en'),
      child: MultiBlocProvider(
        providers: [
          BlocProvider(create: (_) => ProductsBloc(ProductsRepo())),
          BlocProvider(
            create: (_) =>
                FavoritesBloc(favoritesRepo: FavoritesRepo())
                  ..add(FetchFavorites()),
          ),
          BlocProvider(create: (_) => OrdersBloc()),
          BlocProvider(create: (_) => CartBloc()..add(LoadCart())),
        ],
        child: MyApp(isLoggedIn: isLoggedIn),
      ),
    ),
  );
}

class MyApp extends StatelessWidget {
  final bool isLoggedIn;

  const MyApp({super.key, required this.isLoggedIn});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(394, 852),
      minTextAdapt: true,
      splitScreenMode: true,
      child: ChangeNotifierProvider(
        create: (_) => FavouritesNotifier(),
        child: MaterialApp(
          navigatorKey: navigatorKey,
          navigatorObservers: [routeObserver],
          debugShowCheckedModeBanner: false,
          onGenerateRoute: AppRouter().generateRoute,
          initialRoute: Routes.baseLayer,
          title: 'Patria',
          theme: ThemeData(),
          localizationsDelegates: context.localizationDelegates,
          supportedLocales: context.supportedLocales,
          locale: context.locale,
        ),
      ),
    );
  }
}
