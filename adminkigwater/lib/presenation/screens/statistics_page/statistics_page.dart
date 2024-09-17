import 'package:adminkigwater/data/datasources/local/excel_servise.dart';
import 'package:adminkigwater/domain/entities/order.dart';
import 'package:adminkigwater/domain/entities/user_model.dart';
import 'package:adminkigwater/domain/entities/deliverer.dart';
import 'package:adminkigwater/domain/repositories/order_repository.dart';
import 'package:adminkigwater/domain/usecases/get_deliverers_use_case.dart';
import 'package:adminkigwater/domain/usecases/get_users_use_case.dart';
import 'package:adminkigwater/injection_container.dart';
import 'package:adminkigwater/presenation/navigation/drawer.dart';
import 'package:adminkigwater/presenation/screens/statistics_page/widget/show_details_dialog.dart';
import 'package:adminkigwater/presenation/screens/statistics_page/widget/statistics_card.dart';
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
  int _newUsers = 0;
  int _activeCalls = 0;
  int _activeRegions = 0;
  int _totalDeliverers = 0;

  final orderRepo = getIt<OrderRepository>();
  List<Order> orders = [];
  List<UserModel> users = [];
  List<Deliverer> deliverers = [];

  final excelService = getIt<ExcelService>();

  @override
  void initState() {
    super.initState();
    _fetchStatistics();
  }

  Future<void> _fetchStatistics() async {
    try {
      orders = await orderRepo.getOrdersForHistory();
      users = await getIt<GetUsers>().call();
      deliverers = await getIt<GetDeliverers>().call();
      final activeOrders = await orderRepo.getOrders();

      final now = DateTime.now();
      final last30Days = now.subtract(const Duration(days: 30));

      _acceptedOrders =
          orders.where((order) => order.status == 'accepted').length;
      _completedOrders =
          orders.where((order) => order.status == 'completed').length;
      _canceledOrders =
          orders.where((order) => order.status == 'canceled').length;

      _totalUsers = users.length;
      _newUsers = users.where((user) {
        DateTime userCreatedAt;
        try {
          userCreatedAt = DateTime.parse(user.token ?? '0000-00-00');
        } catch (e) {
          userCreatedAt = DateTime(1970);
        }
        return userCreatedAt.isAfter(last30Days);
      }).length;

      _activeCalls = activeOrders.length;
      _activeRegions = _calculateActiveRegions(activeOrders);

      _totalDeliverers = deliverers.length;

      setState(() {});
    } catch (e) {
      print('Ошибка при получении статистики: $e');
    }
  }

  int _calculateActiveRegions(List<Order> activeOrders) {
    final activeRegions = <String>{};
    for (final order in activeOrders) {
      activeRegions.add(order.address);
    }
    return activeRegions.length;
  }

  @override
  Widget build(BuildContext context) {
    if (_totalUsers == 0 && _totalDeliverers == 0 && orders.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      drawer: getDrawer(context),
      appBar: AppBar(
        title: const Text('Статистика'),
        centerTitle: true,
      ),
      body: Padding(
        padding: EdgeInsets.all(15.sp),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                StatisticsCard(
                  title: 'Заказы',
                  stats: {
                    'Принято заказов': _acceptedOrders,
                    'Исполнено заказов': _completedOrders,
                    'Отменено заказов': _canceledOrders,
                  },
                  onTap: () {
                    showDetailsDialog(
                      context,
                      'Заказы',
                      const [
                        Text('Статистика по локациям'),
                        Text('Статистика по клиентам'),
                        Text('Статистика по поставщикам'),
                      ],
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
                    'Всего пользователей': _totalUsers,
                    'Водовозов': _totalDeliverers,
                    'Новых пользователей': _newUsers,
                  },
                  onTap: () {
                    showDetailsDialog(
                      context,
                      'Пользователи',
                      const [
                        Text('Статистика по локациям'),
                        Text('Статистика новых пользователей'),
                        Text('Статистика заявок водителей'),
                      ],
                      users,
                      deliverers,
                      orders,
                    );
                  },
                ),
                SizedBox(width: 15.w),
                StatisticsCard(
                  title: 'Другое',
                  stats: {
                    'Активных заказов': _activeCalls,
                    'Водовозов на линии': 0,
                    'Активных регионов': _activeRegions,
                  },
                  onTap: () {
                    showDetailsDialog(
                      context,
                      'Другое',
                      const [Text('Статистика по активным заказам и регионам')],
                      users,
                      deliverers,
                      orders,
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
