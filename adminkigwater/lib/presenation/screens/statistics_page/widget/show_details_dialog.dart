import 'package:adminkigwater/domain/entities/deliverer.dart';
import 'package:adminkigwater/domain/entities/order.dart';
import 'package:adminkigwater/domain/entities/user_model.dart';
import 'package:adminkigwater/presenation/screens/statistics_page/widget/widgets_for_show_detail_statistic.dart';
import 'package:flutter/material.dart';

void showDetailsDialog(
  BuildContext context,
  String title,
  List<UserModel> users,
  List<Deliverer> drivers,
  List<Order> orders,
) {
  List<Widget> tabs;

  if (title == 'Заказы') {
    tabs = const [
      Text('Всего заказов'),
      Text('Статистика по активным заказам'),
      Text('Статистика по завершенным заказам'),
      Text('Статистика по отмененным заказам'),
    ];
  } else if (title == 'Пользователи') {
    tabs = const [
      Text('Статистика по всем пользователям'),
      Text('Статистика по водовозам'),
      Text('Статистика по заказщикам'),
    ];
  } else {
    tabs = [const Text('Неизвестная категория')];
  }

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
                tabs: tabs.map((tab) => Tab(child: tab)).toList(),
              ),
            ),
            body: TabBarView(
              children: [
                if (title == 'Заказы') ...[
                  AllOrdersTab(orders: orders),
                  ActiveOrdersByClientsTab(orders: orders),
                  CompletedOrdersBySuppliersTab(orders: orders),
                  OrdersByCanceledTab(orders: orders), // Добавляем вкладку для отмененных заказов
                ] else if (title == 'Пользователи') ...[
                  AllUsersTab(users: users),
                  DeliverersStatsTab(drivers: drivers),
                  ClientsStatsTab(users: users, orders: orders,),
                ] else ...[
                  const Center(child: Text('Нет данных для отображения')),
                ],
              ],
            ),
            // floatingActionButton: FloatingActionButton.extended(
            //   onPressed: () async {
            //     int currentIndex = DefaultTabController.of(context).index;
            //     final excelService = getIt<ExcelService>();
            //     if (title == 'Заказы') {
            //       switch (currentIndex) {
            //         case 0:
            //           await excelService.exportOrdersByLocationReport(orders);
            //           break;
            //         case 1:
            //           await excelService.exportOrdersByClientsReport(orders);
            //           break;
            //         case 2:
            //           await excelService.exportOrdersBySuppliersReport(orders);
            //           break;
            //         case 3:
            //           //await excelService.exportOrdersByCanceledReport(orders);
            //           break;
            //         default:
            //           break;
            //       }
            //     } else if (title == 'Пользователи') {
            //       switch (currentIndex) {
            //         case 0:
            //           await excelService.exportUsersByLocationReport(users);
            //           break;
            //         case 1:
            //           //await excelService.exportDeliverersStatsReport(drivers);
            //           break;
            //         case 2:
            //           //await excelService.exportClientsStatsReport(users);
            //           break;
            //         default:
            //           break;
            //       }
            //     }
            //   },
            //   label: const Text('Выгрузить'),
            // ),
          ),
        ),
      );
    },
  );
}
