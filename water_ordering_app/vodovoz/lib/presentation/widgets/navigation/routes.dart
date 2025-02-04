import 'package:vodovoz/main.dart';
import 'package:vodovoz/presentation/screens/driver/deliverer_balance_screen.dart';
import 'package:vodovoz/presentation/screens/driver/driver_profile_screen/driver_page.dart';
import 'package:vodovoz/presentation/screens/driver/line_order_screen/line_order_page.dart';
import 'package:vodovoz/presentation/screens/driver/order_details/order_details_page.dart';
import 'package:vodovoz/presentation/screens/driver/start_delivery_screen/start_delivery_page.dart';
import 'package:vodovoz/presentation/screens/history_screen/history_page.dart';
import 'package:vodovoz/presentation/screens/order_water/drivers_list_page/driver_list_page.dart';
import 'package:vodovoz/presentation/screens/order_water/order_accept_page/order_accept_page.dart';
import 'package:vodovoz/presentation/screens/order_water/order_redirect_page.dart';
import 'package:vodovoz/presentation/screens/order_water/push_order_page/push_order_page.dart';
import 'package:vodovoz/presentation/screens/profile_screen/profile_page.dart';
import 'package:vodovoz/presentation/screens/registration/registration_screen/registration_page.dart';
import 'package:vodovoz/presentation/screens/registration/sign_in_selection_page.dart';

final routes = {
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
  'delivererBalance': (context) => const DelivererBalanceScreen(),
};
