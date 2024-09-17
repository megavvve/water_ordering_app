import 'package:adminkigwater/data/datasources/remote/appwrite.dart';
import 'package:adminkigwater/injection_container.dart';
import 'package:adminkigwater/presenation/screens/admins_page/admins_page.dart';
import 'package:adminkigwater/presenation/screens/auth_page.dart';
import 'package:adminkigwater/presenation/screens/driver_request/driver_request.dart';
import 'package:adminkigwater/presenation/screens/geo_add_page.dart';
import 'package:adminkigwater/presenation/screens/statistics_page/statistics_page.dart';
import 'package:adminkigwater/presenation/screens/user_page/user_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart'; // Убедитесь, что вы добавили appwrite package в pubspec.yaml

Future<void> main() async {
  //await AppWrite().getAccount().deleteSession(sessionId: 'current');
  setupLocator();
  bool isAuthenticated;
  try {
    await AppWrite().getAccount().get();
    isAuthenticated = true;
  } catch (err) {
    isAuthenticated = false;
  }

  String initialRoute = isAuthenticated ? 'admins' : 'login';
  runApp(
    MyApp(
      initialRoute: initialRoute,
    ),
  );
}

class MyApp extends StatelessWidget {
  final String initialRoute;
  const MyApp({super.key, required this.initialRoute});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
        designSize: const Size(1920, 1080),
        minTextAdapt: true,
        splitScreenMode: true,
        builder: (context, snapshot) {
          return MaterialApp(
            routes: {
              'geo': (context) => const GeoAddPage(),
              'users': (context) => const UsersPage(),
              'stats': (context) => const StatisticsPage(),
              'driverReq': (context) => const DriverRequestsPage(),
              'admins': (context) => const AdminsPage(),
              'login': (context) => AuthPage(),
            },
            initialRoute: initialRoute,
            title: 'KigWater',
            theme: ThemeData(
              colorScheme: ColorScheme.fromSeed(seedColor: Colors.cyan),
              useMaterial3: false,
            ),
            home: AuthPage(),
          );
        });
  }
}
