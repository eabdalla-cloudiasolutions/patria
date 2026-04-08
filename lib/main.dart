import 'package:easy_localization/easy_localization.dart';
import 'package:erb/core/helpers/cache_helper.dart';
import 'package:erb/core/providers/favourites_notifier.dart';
import 'package:erb/core/routing/app_router.dart';
import 'package:erb/core/routing/routes.dart';
import 'package:erb/core/services/notification_service.dart';
import 'package:erb/core/services/user_service.dart';
import 'package:erb/features/home/data/repos/products_repo.dart';
import 'package:erb/features/home/presentation/manager/products_bloc.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();

  await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey:
          'AIzaSyAbV9nVBnnfeTubKxsfOPXa-SMyhct4a_Y', // from <key>API_KEY</key>
      appId:
          '1:729560635185:ios:d560c8b4ffc1cea7180210', // from <key>GOOGLE_APP_ID</key>
      messagingSenderId: '729560635185', // from <key>GCM_SENDER_ID</key>
      projectId: 'erbapp-b62c3', // from <key>PROJECT_ID</key>
      iosBundleId: 'com.cloudiasolutions.erb',
    ),
  );

  // ✅ LOCK ORIENTATION
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  await CacheHelper.init();
  await GoogleSignIn.instance.initialize(
    clientId:
        '88148957283-oe5kvqlelp2lfl1sdfoj58m9kihpdmpf.apps.googleusercontent.com',
  );

  // ✅ ATTACH TOKEN REFRESH LISTENER (BEFORE CHECKING LOGIN STATE)
  FirebaseMessaging.instance.onTokenRefresh.listen((newToken) async {
    print('FCM token refreshed: $newToken');
    final isLoggedIn = await UserService().isLoggedIn();
    if (isLoggedIn) {
      await NotificationService().registerToken(newToken);
    }
  });

  // ✅ CHECK IF USER IS ALREADY LOGGED IN
  final isLoggedIn = await UserService().isLoggedIn().catchError((_) => false);

  runApp(EasyLocalization(
    supportedLocales: const [Locale('en'), Locale('ar')],
    path: 'assets/translations',
    fallbackLocale: const Locale('en'),
    child: MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => ProductsBloc(ProductsRepo())),
      ],
      child: MyApp(isLoggedIn: isLoggedIn),
    ),
  ));
}

class MyApp extends StatelessWidget {
  final bool isLoggedIn;

  const MyApp({super.key, required this.isLoggedIn});
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(394, 852),
      minTextAdapt: true,
      splitScreenMode: true,
      child: ChangeNotifierProvider(
        create: (_) => FavouritesNotifier(),
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          onGenerateRoute: AppRouter().generateRoute,
          initialRoute: Routes.baseLayer, // ✅
          title: 'Flutter Demo',
          theme: ThemeData(),
          localizationsDelegates: context.localizationDelegates, // ✅
          supportedLocales: context.supportedLocales, // ✅
          locale: context.locale,
          // home: SplashScreen(),
        ),
      ),
    );
  }
}
