import 'package:easy_localization/easy_localization.dart';
import 'package:erb/core/helpers/cache_helper.dart';
import 'package:erb/core/providers/favourites_notifier.dart';
import 'package:erb/core/routing/app_router.dart';
import 'package:erb/core/routing/routes.dart';
import 'package:erb/core/services/notification_service.dart';
import 'package:erb/core/services/user_service.dart';
import 'package:erb/features/cart/presentation/manager/cart_bloc.dart';
import 'package:erb/features/cart/presentation/manager/cart_event.dart';
import 'package:erb/features/home/data/repos/favorites_repo.dart';
import 'package:erb/features/home/data/repos/products_repo.dart';
import 'package:erb/features/home/presentation/manager/favorites_bloc.dart';
import 'package:erb/features/home/presentation/manager/favorites_event.dart';
import 'package:erb/features/home/presentation/manager/products_bloc.dart';
import 'package:erb/features/previous_orders/presentation/manager/orders_bloc.dart'; // ✅ import
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:provider/provider.dart';

final RouteObserver<ModalRoute> routeObserver = RouteObserver<ModalRoute>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();

  await Firebase.initializeApp();

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  await CacheHelper.init();
  await GoogleSignIn.instance.initialize(
    clientId:
        '920170611908-oe5k9mem9og4mmcc49bdfhc0leouo65o.apps.googleusercontent.com',
  );

  FirebaseMessaging.instance.onTokenRefresh.listen((newToken) async {
    final isLoggedIn = await UserService().isLoggedIn();
    if (isLoggedIn) {
      await NotificationService().registerToken(newToken);
    }
  });

  final isLoggedIn = await UserService().isLoggedIn().catchError((_) => false);

  runApp(EasyLocalization(
    supportedLocales: const [Locale('en'), Locale('ar')],
    path: 'assets/translations',
    fallbackLocale: const Locale('en'),
    child: MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => ProductsBloc(ProductsRepo())),
        BlocProvider(
            create: (_) => FavoritesBloc(favoritesRepo: FavoritesRepo())
              ..add(FetchFavorites())),
        BlocProvider(create: (_) => OrdersBloc()), // ✅ added
        BlocProvider(create: (_) => CartBloc()..add(LoadCart())), // ✅ fixed
      ],
      child: MyApp(isLoggedIn: isLoggedIn),
    ),
  ));
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
          navigatorObservers: [routeObserver],
          debugShowCheckedModeBanner: false,
          onGenerateRoute: AppRouter().generateRoute,
          initialRoute: Routes.baseLayer,
          title: 'Flutter Demo',
          theme: ThemeData(),
          localizationsDelegates: context.localizationDelegates,
          supportedLocales: context.supportedLocales,
          locale: context.locale,
        ),
      ),
    );
  }
}
