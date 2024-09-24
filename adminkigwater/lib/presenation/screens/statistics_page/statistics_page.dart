import 'package:adminkigwater/data/datasources/local/excel_servise.dart';
import 'package:adminkigwater/domain/entities/geolocation.dart';
import 'package:adminkigwater/domain/entities/order.dart';
import 'package:adminkigwater/domain/entities/user_model.dart';
import 'package:adminkigwater/domain/entities/deliverer.dart';
import 'package:adminkigwater/domain/repositories/geolocation_repository.dart';
import 'package:adminkigwater/domain/repositories/order_repository.dart';
import 'package:adminkigwater/domain/usecases/get_deliverers_use_case.dart';
import 'package:adminkigwater/domain/usecases/get_users_use_case.dart';
import 'package:adminkigwater/injection_container.dart';
import 'package:adminkigwater/presenation/navigation/drawer.dart';
import 'package:adminkigwater/presenation/screens/statistics_page/widget/show_details_dialog.dart';
import 'package:adminkigwater/presenation/screens/statistics_page/widget/statistics_card.dart';
import 'package:adminkigwater/utils/enums/order_status.dart';
import 'package:adminkigwater/utils/enums/user_type.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class StatisticsPage extends StatefulWidget {
  const StatisticsPage({super.key});

  @override
  State<StatefulWidget> createState() => _StatisticsPageState();
}

class _StatisticsPageState extends State<StatisticsPage> {
  int _acceptedOrders = 0;
  int _completedOrders = 0;
  int _canceledOrders = 0;
  int _totalUsers = 0;
  int _totalDeliverers = 0;

  final orderRepo = getIt<OrderRepository>();
  List<Order> orders = [];
  List<UserModel> users = [];
  List<Deliverer> deliverers = [];
  List<Geolocation> ordersGeolocations = [];

  final excelService = getIt<ExcelService>();

  @override
  void initState() {
    super.initState();
    _fetchStatistics();
  }

  Future<void> _fetchStatistics() async {
    try {
      orders = await orderRepo.getOrders();
      users = await getIt<GetUsers>().call();
      deliverers = await getIt<GetDeliverers>().call();
      ordersGeolocations = await getIt<GeolocationRepository>()
          .getGeolocationsByIds(orders.map((x) => x.id).toList());

      _acceptedOrders = orders
          .where((order) =>
              order.status == OrderStatus.accepted.name ||
              order.status == OrderStatus.inProgress.name||order.status == OrderStatus.pending.name ||
              order.status == OrderStatus.awaitingConfirmation.name)
          .length;
      _completedOrders = orders
          .where((order) => order.status == OrderStatus.completed.name)
          .length;
      _canceledOrders = orders
          .where((order) => order.status == OrderStatus.canceled.name)
          .length;

      _totalUsers =
          users.where((user) => user.userType == UserType.user.name).length;
      _totalDeliverers = deliverers.length;

      setState(() {});
    } catch (e) {
      print('Ошибка при получении статистики: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: getDrawer(context),
      appBar: AppBar(
        title: const Text('Статистика'),
        centerTitle: true,
      ),
      body: (users.isEmpty && deliverers.isEmpty && orders.isEmpty)
          ? const Center(child: CircularProgressIndicator())
          : Center(
              child: Padding(
                padding: EdgeInsets.all(15.sp),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    StatisticsCard(
                      title: 'Заказы',
                      stats: {
                        'Всего заказов': orders.length,
                        'Активных заказов': _acceptedOrders,
                        'Завершенных заказов': _completedOrders,
                        'Отменено заказов': _canceledOrders,
                      },
                      onTap: () {
                        showDetailsDialog(
                          context,
                          'Заказы',
                          users,
                          deliverers,
                          orders,
                        );
                      },
                    ),
                    SizedBox(width: 15.w),
                    StatisticsCard(
                      title: 'Пользователи',
                      stats: {
                        'Всего пользователей': users.length,
                        'Водовозов': _totalDeliverers,
                        'Заказщиков': _totalUsers,
                      },
                      onTap: () {
                        showDetailsDialog(
                          context,
                          'Пользователи',
                          users,
                          deliverers,
                          orders,
                        );
                      },
                    ),
                    SizedBox(width: 15.w),
              
                    // StatisticsCard(
                    //   title: 'Другое',
                    //   stats: {
                    //     'Активных заказов': _activeCalls,
                    //     'Водовозов на линии': 0,
                    //     'Активных регионов': _activeRegions,
                    //   },
                    //   onTap: () {
                    //     showDetailsDialog(
                    //       context,
                    //       'Другое',
                    //       const [
                    //         Text('Статистика по активным заказам и регионам')
                    //       ],
                    //       users,
                    //       deliverers,
                    //       orders,
                    //     );
                    //   },
                    // ),
                  ],
                ),
              ),
            ),
    );
  }
}
