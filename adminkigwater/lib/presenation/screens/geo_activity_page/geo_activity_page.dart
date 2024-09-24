import 'package:adminkigwater/data/datasources/local/excel_servise.dart';
import 'package:adminkigwater/domain/repositories/order_repository.dart';
import 'package:adminkigwater/presenation/navigation/drawer.dart';
import 'package:adminkigwater/presenation/widgets/export_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:adminkigwater/domain/entities/geolocation.dart';
import 'package:adminkigwater/domain/entities/order.dart';
import 'package:adminkigwater/domain/entities/user_model.dart';
import 'package:adminkigwater/domain/repositories/geolocation_repository.dart';
import 'package:adminkigwater/domain/usecases/get_users_use_case.dart';
import 'package:adminkigwater/injection_container.dart';
import 'package:adminkigwater/presenation/screens/geo_activity_page/widgets/build_statistic_card.dart';
import 'package:adminkigwater/utils/enums/order_status.dart';

class GeoActivityPage extends StatefulWidget {
  const GeoActivityPage({super.key});

  @override
  _GeoActivityPageState createState() => _GeoActivityPageState();
}

class _GeoActivityPageState extends State<GeoActivityPage> {
  List<Order> orders = [];
  List<Geolocation> orderGeolocations = [];
  List<UserModel> users = [];
  bool sortByOrderCount = false;

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {
    orders = await getIt<OrderRepository>().getOrders();
    orderGeolocations =
        await getIt<GeolocationRepository>().getGeolocationsByIds(
      orders.map((order) => order.id).toList(),
    );
    users = await getIt<GetUsers>().call();
    setState(() {});
  }

  Map<String, Map<String, Map<String, int>>> calculateStatistics() {
    Map<String, Map<String, Map<String, int>>> stats = {};

    for (var geolocation in orderGeolocations) {
      List<String> addressParts = geolocation.address.split(',');

      if (addressParts.length >= 3) {
        String country = addressParts[0].trim();
        String region = addressParts[1].trim();
        String locality = addressParts[2].trim();

        stats[country] ??= {};
        stats[country]![region] ??= {};
        stats[country]![region]![locality] =
            (stats[country]![region]![locality] ?? 0) + 1;
      }
    }

    return stats;
  }

  Future<void> exportToExcel() async {
    print("Экспорт в Excel");
  }

  void toggleSortOrder() {
    setState(() {
      sortByOrderCount = !sortByOrderCount;
    });
  }

  void showDetailedStatistics(String location, List<Order> locationOrders) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Подробная статистика по $location'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: locationOrders.map((order) {
                return Text(
                  'Заказ №${order.id.hashCode}, адрес: ${orderGeolocations.firstWhere((x) => x.geolocationId == order.id).address}\nстатус: ${translateOrderStatus(order.status)}\n',
                );
              }).toList(),
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Закрыть'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    Map<String, Map<String, Map<String, int>>> stats = calculateStatistics();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Гео-активность заказов'),
        centerTitle: true,
      ),
      drawer: getDrawer(context),
      body: Padding(
        padding: EdgeInsets.all(20.sp),
        child: Stack(
          children: [
            SingleChildScrollView(
              // Enable vertical scrolling
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  ExportButton(
                    buttonText: 'Выгрузить статистику по геоактивности',
                    onExport: () {
                      getIt<ExcelService>().exportGeolocationStatistics(stats);
                    },
                  ),
                  SizedBox(height: 15.h),
                  Text(
                    'Всего заказов: ${orders.length}',
                    style:
                        TextStyle(fontSize: 24.sp, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 20.h),
                  Row(
                    children: [
                      buildStatisticsCard(
                          'Активные заказы',
                          orders
                              .where((x) =>
                                  x.status == OrderStatus.pending.name ||
                                  x.status ==
                                      OrderStatus.awaitingConfirmation.name ||
                                  x.status == OrderStatus.accepted.name ||
                                  x.status == OrderStatus.inProgress.name)
                              .length
                              .toString()),
                      SizedBox(width: 20.w),
                      buildStatisticsCard(
                          'Завершенные заказы',
                          orders
                              .where((x) =>
                                  x.status == OrderStatus.canceled.name ||
                                  x.status == OrderStatus.completed.name)
                              .length
                              .toString()),
                      SizedBox(width: 20.w),
                      buildStatisticsCard(
                          'Всего клиентов', users.length.toString()),
                    ],
                  ),
                  SizedBox(height: 30.h),
                  Text(
                    'Статистика по странам, регионам и городам',
                    style:
                        TextStyle(fontSize: 22.sp, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 10.h),
                  ElevatedButton(
                    onPressed: toggleSortOrder,
                    child: Text(sortByOrderCount
                        ? 'Сортировать по алфавиту'
                        : 'Сортировать по количеству заказов'),
                  ),
                  SizedBox(height: 20.h),

                  // Horizontal Scrolling
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: stats.entries.map((countryEntry) {
                        String country = countryEntry.key;
                        Map<String, Map<String, int>> regions =
                            countryEntry.value;

                        List<MapEntry<String, Map<String, int>>> sortedRegions =
                            regions.entries.toList();
                        if (sortByOrderCount) {
                          sortedRegions.sort(
                            (a, b) => b.value.values
                                .reduce((sum, element) => sum + element)
                                .compareTo(
                                  a.value.values
                                      .reduce((sum, element) => sum + element),
                                ),
                          );
                        }

                        return Padding(
                          padding: EdgeInsets.only(right: 20.w),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                country,
                                style: TextStyle(
                                  fontSize: 20.sp,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blueAccent,
                                ),
                              ),
                              SizedBox(height: 10.h),
                              ...sortedRegions.map((regionEntry) {
                                String region = regionEntry.key;
                                Map<String, int> localities = regionEntry.value;

                                return Padding(
                                  padding: EdgeInsets.only(bottom: 10.h),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        region,
                                        style: TextStyle(
                                          fontSize: 18.sp,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.green,
                                        ),
                                      ),
                                      SizedBox(height: 5.h),
                                      ...localities.entries
                                          .map((localityEntry) {
                                        String locality = localityEntry.key;
                                        int orderCount = localityEntry.value;

                                        return GestureDetector(
                                          onTap: () {
                                            List<Order> localityOrders = orders
                                                .where(
                                                  (order) =>
                                                      orderGeolocations.any(
                                                    (geo) =>
                                                        geo.address.contains(
                                                            locality) &&
                                                        order.id ==
                                                            geo.geolocationId,
                                                  ),
                                                )
                                                .toList();
                                            showDetailedStatistics(
                                                locality, localityOrders);
                                          },
                                          child: Padding(
                                            padding:
                                                EdgeInsets.only(left: 32.w),
                                            child: Text(
                                              '$locality: $orderCount заказов',
                                              style: TextStyle(
                                                fontSize: 18.sp,
                                              ),
                                            ),
                                          ),
                                        );
                                      }),
                                    ],
                                  ),
                                );
                              }),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
