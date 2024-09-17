import 'package:adminkigwater/data/datasources/local/excel_servise.dart';
import 'package:adminkigwater/domain/entities/deliverer.dart';
import 'package:adminkigwater/domain/entities/order.dart';
import 'package:adminkigwater/domain/entities/user_model.dart';
import 'package:adminkigwater/injection_container.dart';
import 'package:adminkigwater/presenation/screens/statistics_page/widget/widgets_for_show_detail_statistic.dart';
import 'package:flutter/material.dart';

void showDetailsDialog(
  BuildContext context,
  String title,
  List<Widget> tabs,
  List<UserModel> users,
  List<Deliverer> drivers,
  List<Order> orders,
) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return Dialog(
        child: DefaultTabController(
          length: tabs.length,
          child: Scaffold(
            appBar: AppBar(
              title: Text(title),
              centerTitle: true,
              bottom: TabBar(
                tabs: List.generate(
                  tabs.length,
                  (index) => Tab(
                    text: _getTabText(title, index),
                    icon: const Icon(Icons.info_outline),
                  ),
                ),
              ),
            ),
            body: TabBarView(
              children: [
                if (title == 'Заказы') ...[
                  OrdersByLocationTab(orders: orders),
                  OrdersByClientsTab(orders: orders),
                  OrdersBySuppliersTab(orders: orders),
                ] else if (title == 'Пользователи') ...[
                  UsersByLocationTab(users: users),
                  NewUsersTab(users: users),
                  DriverApplicationsTab(drivers: drivers),
                ] else if (title == 'Другое') ...[
                  ActiveOrdersByRegionsTab(orders: orders),
                ],
              ],
            ),
            floatingActionButton: FloatingActionButton.extended(
              onPressed: () async {
                int currentIndex = DefaultTabController.of(context).index;
                final excelService = getIt<ExcelService>();
                if (title == 'Заказы') {
                  switch (currentIndex) {
                    case 0:
                      await excelService.exportOrdersByLocationReport(orders);
                      break;
                    case 1:
                      await excelService.exportOrdersByClientsReport(orders);
                      break;
                    case 2:
                      await excelService.exportOrdersBySuppliersReport(orders);
                      break;
                    default:
                      break;
                  }
                } else if (title == 'Пользователи') {
                  switch (currentIndex) {
                    case 0:
                      await excelService.exportUsersByLocationReport(users);
                      break;
                    case 1:
                      await excelService.exportNewUsersReport(users);
                      break;
                    case 2:
                      await excelService
                          .exportDriverApplicationsReport(drivers);
                      break;
                    default:
                      break;
                  }
                } else if (title == 'Другое') {
                  await excelService.exportActiveOrdersByRegionsReport(orders);
                }
              },
              label: const Text('Выгрузить'),
            ),
          ),
        ),
      );
    },
  );
}

String _getTabText(String title, int index) {
  if (title == 'Заказы') {
    switch (index) {
      case 0:
        return 'По локации';
      case 1:
        return 'По клиентам';
      case 2:
        return 'По поставщикам';
      default:
        return 'Unknown';
    }
  } else if (title == 'Пользователи') {
    switch (index) {
      case 0:
        return 'По локации';
      case 1:
        return 'Новые пользователи';
      case 2:
        return 'Заявки водителей';
      default:
        return 'Unknown';
    }
  } else if (title == 'Другое') {
    return 'Статистика по активным заказам и регионам';
  } else {
    return 'Unknown';
  }
}
