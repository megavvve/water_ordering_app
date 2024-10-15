import 'dart:async';
import 'dart:convert';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:vodovoz/data/datasources/local/local_saved_data.dart';
import 'package:vodovoz/data/datasources/remote/appwrite.dart';
import 'package:vodovoz/data/datasources/remote/push_notifications.dart';
import 'package:vodovoz/domain/repositories/deliverer_repository.dart';
import 'package:vodovoz/domain/usecases/get_deliverer_by_id.dart';
import 'package:vodovoz/domain/usecases/get_user_by_id.dart';
import 'package:vodovoz/domain/usecases/update_user_use_case.dart';
import 'package:vodovoz/firebase_options.dart';
import 'package:vodovoz/presentation/providers/delivery_order_bloc/deliverer_order_bloc.dart';
import 'package:vodovoz/presentation/providers/order_user_bloc/order_user_bloc.dart';
import 'package:vodovoz/presentation/screens/driver/order_details/order_details_page.dart';
import 'package:vodovoz/presentation/screens/order_water/order_accept_page/order_accept_page.dart';
import 'package:vodovoz/presentation/screens/registration/sign_in_selection_page.dart';
import 'package:vodovoz/presentation/widgets/build_no_connection_overlay.dart';
import 'package:vodovoz/presentation/widgets/enums/user_type.dart';
import 'package:vodovoz/presentation/widgets/navigation/set_page.dart';
import 'package:vodovoz/presentation/screens/order_water/order_redirect_page.dart';
import 'package:vodovoz/injection_container.dart';
import 'package:vodovoz/presentation/screens/driver/driver_profile_screen/driver_page.dart';
import 'package:vodovoz/presentation/screens/history_screen/history_page.dart';
import 'package:vodovoz/presentation/screens/driver/line_order_screen/line_order_page.dart';
import 'package:vodovoz/presentation/screens/order_water/drivers_list_page/driver_list_page.dart';
import 'package:vodovoz/presentation/screens/profile_screen/profile_page.dart';
import 'package:vodovoz/presentation/screens/order_water/push_order_page/push_order_page.dart';
import 'package:vodovoz/presentation/screens/registration/registration_screen/registration_page.dart';
import 'package:vodovoz/presentation/screens/driver/start_delivery_screen/start_delivery_page.dart';
import 'package:vodovoz/utils/input_decorations.dart';

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

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({
    super.key,
  });

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  late final StreamSubscription<InternetStatus> _subscription;
  bool _isInternetConnected = true;

  @override
  void initState() {
    super.initState();
    _subscription =
        InternetConnection().onStatusChange.listen((InternetStatus status) {
      switch (status) {
        case InternetStatus.connected:
          setState(() {
            _isInternetConnected = true;
          });
          break;
        case InternetStatus.disconnected:
          setState(() {
            _isInternetConnected = false;
          });
          break;
      }
    });
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _subscription.cancel();
    super.dispose();
  }

  @override
  Future<void> didChangeAppLifecycleState(AppLifecycleState state) async {
    super.didChangeAppLifecycleState(state);

    print('App Lifecycle State changed: $state');

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
            routes: {
              'home': (context) => const MyHomePage(),
              'reg': (context) => const RegistrationPage(),
              'profile': (context) => const ProfilePage(),
              'pushOrder': (context) => const PushOrderPage(),
              'driver': (context) => const DriverPage(),
              'delivery': (context) => const StartDeliveryPage(),
              'line': (context) => const LineOrderPage(),
              'history': (context) => const HistoryPage(),
              'driversList': (context) => const DriverListPage(),
              'orderingRedirect': (context) => const OrderStatusRedirectPage(),
              'orderDetailsDeliverer': (context) => const OrderDetailsPage(),
              'orderAccepted': (context) => const OrderAcceptedPage(),
              'signInSelection': (context) => const SignInSelectionPage(),
            },
            title: 'VodovozApp',
            debugShowCheckedModeBanner: false,
            theme: ThemeData(
              colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
              useMaterial3: true,
            ),
            initialRoute: 'home',
            builder: (context, child) {
              if (!_isInternetConnected) {
                return buildNoConnectionOverlay(child!, context);
              }
              return child!;
            },
          );
        },
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final localSavedData = getIt<LocalSavedData>();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.blueAccent, Colors.white, Colors.blueAccent],
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(5, 100, 5, 5),
                child: Text(
                  'Доставка воды',
                  style: TextStyle(fontSize: 34.sp, color: Colors.white),
                ),
              ),
              Padding(
                padding: EdgeInsets.all(5.sp),
                child: SizedBox(
                  width: 300.w,
                  child: Image.asset('assets/images/mark.png'),
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(vertical: 40.h, horizontal: 20.w),
                child: SizedBox(
                  height: 60.h,
                  width: 300.w,
                  child: Builder(
                    builder: (context) {
                      return FilledButton(
                        onPressed: () async {
                          String initialRoute = 'profile';
                          try {
                            await getIt<AppWrite>().getAccount().get();

                            final userId = localSavedData.getUserId();
                            final user = await getIt<GetUserById>().call(
                              userId,
                            );

                            if (user != null) {
                              initialRoute = 'orderingRedirect';
                              if (user.userType == UserType.deliverer.name) {
                                final deliverer =
                                    await getIt<GetDelivererById>().call(
                                  localSavedData.getUserId(),
                                );

                                if (deliverer?.isAvailable == true &&
                                    deliverer!.waterType.isNotEmpty) {
                                  initialRoute = 'line';
                                } else {
                                  initialRoute = 'delivery';
                                }
                                localSavedData.saveIsUserIsDeliverer(true);
                              }
                            }
                          } catch (err) {
                            print(err);
                            try {
                              await getIt<GetDelivererById>().call(
                                localSavedData.getUserId(),
                              );
                              localSavedData.saveIsUserIsDeliverer(true);
                            } catch (e) {
                              localSavedData.saveIsUserIsDeliverer(false);
                            }
                            initialRoute = 'signInSelection';
                          }

                          SetPageWithoutBack(context, initialRoute);
                        },
                        style: btnStl,
                        child: const Text('Начать'),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
