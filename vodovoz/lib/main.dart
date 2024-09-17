import 'dart:convert';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
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
  //await AppWrite().getAccount().deleteSession(sessionId: 'current');
  //getIt<LocalSavedData>().clearAllData();

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
    Key? key,
  }) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Future<void> didChangeAppLifecycleState(AppLifecycleState state) async {
    super.didChangeAppLifecycleState(state);
    try {
      await getIt<AppWrite>().getAccount().get();
      //await AppWrite().getAccount().get();

      if (state == AppLifecycleState.detached) {
        final userId = LocalSavedData().getUserId();
        if (userId.isNotEmpty) {
          final user = await getIt<GetUserById>().call(userId);
          final deliverer = await getIt<GetDelivererById>().call(userId);
          if (user != null) {
            getIt<UpdateUser>().call(
              user.copyWith(
                isOnline: false,
              ),
            );
          }
          if (deliverer != null) {
            getIt<DelivererRepository>().updateDeliverer(
              deliverer.copyWith(
                isAvailable: false,
                waterType: '',
              ),
            );
          }
        }

        // Приложение свернуто или закрыто
        print("Приложение свернуто или закрыто");
        // Здесь можно выполнить нужное действие, например, сохранить данные
      } else if (state == AppLifecycleState.resumed) {
        final userId = LocalSavedData().getUserId();
        if (userId.isNotEmpty) {
          final user = await getIt<GetUserById>().call(userId);
          if (user != null) {
            getIt<UpdateUser>().call(
              user.copyWith(
                isOnline: true,
              ),
            );
          }
        }
        // Приложение снова активно
        print("Приложение снова активно");
        // Здесь можно выполнить действия при возобновлении приложения
      }
    } catch (e) {
      print('не получилось()');
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
          );
        },
      ),
    );
  }
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({Key? key}) : super(key: key);

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
                              //await AppWrite().getAccount().get();
                              final userId = LocalSavedData().getUserId();
                              final user = await getIt<GetUserById>().call(
                                userId,
                              );

                              if (user != null) {
                                initialRoute = 'orderingRedirect';
                                if (user.userType == UserType.deliverer.name) {
                                  final deliverer =
                                      await getIt<GetDelivererById>().call(
                                    LocalSavedData().getUserId(),
                                  );
                                  if (deliverer?.isAvailable == true) {
                                    initialRoute = 'line';
                                  } else {
                                    initialRoute = 'delivery';
                                  }
                                }
                              }
                            } catch (err) {
                              print(err);
                              initialRoute = 'signInSelection';
                            }

                            // Use the context from the Builder widget
                            SetPageWithoutBack(context, initialRoute);
                          },
                          style: btnStl,
                          child: const Text('Начать'),
                        );
                      },
                    )),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
