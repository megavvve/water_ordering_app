import 'dart:async';
import 'dart:convert';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
//import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vodovoz/data/datasources/local/local_saved_data.dart';
import 'package:vodovoz/data/datasources/remote/appwrite.dart';
import 'package:vodovoz/data/datasources/remote/push_notifications.dart';
import 'package:vodovoz/domain/entities/deliverer.dart';
import 'package:vodovoz/domain/repositories/deliverer_repository.dart';
import 'package:vodovoz/domain/usecases/get_deliverer_by_id.dart';
import 'package:vodovoz/domain/usecases/get_user_by_id.dart';
import 'package:vodovoz/domain/usecases/update_user_use_case.dart';
import 'package:vodovoz/firebase_options.dart';
import 'package:vodovoz/presentation/providers/delivery_order_bloc/deliverer_order_bloc.dart';
import 'package:vodovoz/presentation/providers/order_user_bloc/order_user_bloc.dart';
//import 'package:vodovoz/presentation/widgets/build_no_connection_overlay.dart';
import 'package:vodovoz/presentation/widgets/navigation/routes.dart';
import 'package:vodovoz/injection_container.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await setupLocator();

  // await AppWrite().getAccount().deleteSession(sessionId: 'current');
  // getIt<LocalSavedData>().clearAllData();
  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    String payloadData = jsonEncode(message.data);
    print("Got a message in foreground");
    if (message.notification != null) {
      PushNotifications.showSimpleNotification(
        title: message.notification!.title!,
        body: message.notification!.body!,
        payload: payloadData,
      );
    }
  });
  WidgetsBinding.instance.addPostFrameCallback((_) async {
    try {
      final r = await getApplicationDocumentsDirectory();
      print('Documents directory path: ${r.path}');
    } catch (e) {
      print('Error: $e');
    }
  });
  final localSavedData = getIt<LocalSavedData>();

  Deliverer? dev = await getIt<GetDelivererById>().call(
    localSavedData.getUserId(),
  );
  if (dev != null) {
    localSavedData.saveIsUserIsDeliverer(true);
  } else {
    localSavedData.saveIsUserIsDeliverer(false);
  }

  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({
    super.key,
  });

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  final navigatorKey = GlobalKey<NavigatorState>();
  late SharedPreferences _prefs;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initPrefs();
  }

  Future<void> _initPrefs() async {
    _prefs = await SharedPreferences.getInstance();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Future<void> didChangeAppLifecycleState(AppLifecycleState state) async {
    super.didChangeAppLifecycleState(state);

    print('App Lifecycle State changed: $state');
    if (state == AppLifecycleState.paused||state == AppLifecycleState.detached) {
      String? currentRoute;
      navigatorKey.currentState?.popUntil((route) {
        currentRoute = route.settings.name;
        return true;
      });
      if (currentRoute=="home") currentRoute='/';
      print(currentRoute);
      await _prefs.setString('lastRoute', currentRoute??'/');
   
    }
    try {
      await getIt<AppWrite>().getAccount().get();

      if (state == AppLifecycleState.detached) {
        print('App is being closed or detached.');
        final userId = LocalSavedData().getUserId();
        if (userId.isNotEmpty) {
          final user = await getIt<GetUserById>().call(userId);
          final deliverer = await getIt<GetDelivererById>().call(userId);

          if (user != null) {
            await getIt<UpdateUser>().call(
              user.copyWith(isOnline: false),
            );
          }

          if (deliverer != null) {
            await getIt<DelivererRepository>().updateDeliverer(
              deliverer.copyWith(isAvailable: false),
            );
          }
        }
      } else if (state == AppLifecycleState.resumed) {
        print('App is resumed.');
        final userId = LocalSavedData().getUserId();
        if (userId.isNotEmpty) {
          final user = await getIt<GetUserById>().call(userId);
          if (user != null) {
            await getIt<UpdateUser>().call(
              user.copyWith(isOnline: true),
            );
          }
        }
      }
    } catch (e) {
      print('Error in didChangeAppLifecycleState: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations(
      [
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
      ],
    );

    return MultiBlocProvider(
      providers: [
        BlocProvider<DelivererOrderBloc>(
          create: (context) => getIt<DelivererOrderBloc>(),
        ),
        BlocProvider<OrderUserBloc>(
          create: (context) => getIt<OrderUserBloc>(),
        ),
      ],
      child: ScreenUtilInit(
        designSize: const Size(375, 812),
        minTextAdapt: true,
        splitScreenMode: true,
        builder: (_, child) {
          return MaterialApp(
            navigatorKey: navigatorKey,
            routes: routes,
            title: 'VodovozApp',
            debugShowCheckedModeBanner: false,
            theme: ThemeData(
              colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
              useMaterial3: true,
            ),
            initialRoute: 'home',
            builder: (context, child) {
              return child!;
            },
          );
        },
      ),
    );
  }
}
