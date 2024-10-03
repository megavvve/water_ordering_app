import 'package:adminkigwater/data/datasources/local/excel_servise.dart';
import 'package:adminkigwater/domain/repositories/order_repository.dart';
import 'package:adminkigwater/presenation/screens/geo_activity_page/widgets/order_details_page.dart';
import 'package:adminkigwater/presenation/widgets/city_dropdown_search.dart';
import 'package:adminkigwater/presenation/widgets/get_cities_from_geo_list.dart';
import 'package:adminkigwater/presenation/widgets/navigation/drawer.dart';
import 'package:adminkigwater/presenation/widgets/export_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:adminkigwater/domain/entities/geolocation.dart';
import 'package:adminkigwater/domain/entities/order.dart';
import 'package:adminkigwater/domain/entities/user_model.dart';
import 'package:adminkigwater/domain/repositories/geolocation_repository.dart';
import 'package:adminkigwater/domain/usecases/get_users_use_case.dart';
import 'package:adminkigwater/injection_container.dart';
import 'package:adminkigwater/utils/enums/order_status.dart';
import 'package:intl/intl.dart';

class GeoActivityPage extends StatefulWidget {
  const GeoActivityPage({super.key});

  @override
  _GeoActivityPageState createState() => _GeoActivityPageState();
}

class _GeoActivityPageState extends State<GeoActivityPage> {
  List<Order> orders = [];
  List<Geolocation> orderGeolocations = [];
  List<UserModel> users = [];
  List<String?> cities = [];
  String? _selectedCity = 'Все города';
  DateTime? startDate;
  DateTime? endDate;

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {
    orders = await getIt<OrderRepository>().getOrders();
    orderGeolocations = await getIt<GeolocationRepository>()
        .getGeolocationsByIds(orders.map((order) => order.id).toList());
    users = await getIt<GetUsers>().call();

    cities = getCitiesFromGeoList(orderGeolocations);

    // Сортировка по алфавиту
    cities.sort((a, b) => a!.compareTo(b!));
    cities.remove('Город не указан');
    setState(() {});
  }

  Future<void> _selectDate(BuildContext context, bool isStart) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      setState(() {
        if (isStart) {
          startDate = picked;
        } else {
          endDate = picked;
        }
      });
    }
  }

  List<Order> getFilteredOrders() {
    return orders.where((order) {
      Geolocation? geolocation;
      try {
        geolocation = orderGeolocations
            .firstWhere((geo) => geo.geolocationId == order.id);
      } catch (e) {
        geolocation = null;
      }

      final cityMatches = _selectedCity == 'Все города' ||
          (geolocation != null && geolocation.address.contains(_selectedCity!));
      final orderDate = DateFormat('yyyy-MM-dd').parse(order.createdAt);
      final dateMatches =
          (startDate == null || orderDate.isAfter(startDate!)) &&
              (endDate == null || orderDate.isBefore(endDate!));
      return cityMatches && dateMatches;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final filteredOrders = getFilteredOrders();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Активность заказов и исполнение'),
        centerTitle: true,
        backgroundColor: Colors.teal,
        elevation: 0,
      ),
      drawer: getDrawer(context),
      body: Padding(
        padding: EdgeInsets.all(15.sp),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
              CityDropdownSearch(
                cities: cities,
                selectedCity: _selectedCity,
                onCitySelected: (String? city) {
                setState(() {
                  _selectedCity = city;
                });
              },
              ),
            SizedBox(height: 15.h),
            ExportButton(
              buttonText: 'Выгрузить статистику по : $_selectedCity',
              onExport: () {
                getIt<ExcelService>()
                    .exportOrdersByLocationReport(filteredOrders);
              },
            ),
            SizedBox(height: 15.h),
            Text(
              "Статистика заказов",
              style: TextStyle(fontSize: 24.sp, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 15.h),

          

            // Выбор периода
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () => _selectDate(context, true),
                  child: Text(startDate != null
                      ? DateFormat('yyyy-MM-dd').format(startDate!)
                      : "Дата начала"),
                ),
                SizedBox(
                  width: 15.w,
                ),
                ElevatedButton(
                  onPressed: () => _selectDate(context, false),
                  child: Text(endDate != null
                      ? DateFormat('yyyy-MM-dd').format(endDate!)
                      : "Дата окончания"),
                ),
              ],
            ),
            SizedBox(height: 10.h),

            Expanded(
              child: ListView.builder(
                itemCount: filteredOrders.length,
                itemBuilder: (BuildContext context, int index) {
                  final order = filteredOrders[index];
                  Geolocation? geolocation;
                  try {
                    geolocation = orderGeolocations
                        .firstWhere((geo) => geo.geolocationId == order.id);
                  } catch (e) {
                    geolocation = null;
                  }

                  return Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 100.0.w,
                      ),
                      child: Tooltip(
                        message:
                            'Статус: ${translateOrderStatus(order.status)}',
                        child: Card(
                          elevation: 4,
                          margin: EdgeInsets.symmetric(vertical: 10.h),
                          child: ListTile(
                            title: Text('Заказ № ${order.id.hashCode}'),
                            subtitle: Text.rich(
                              TextSpan(
                                children: [
                                  const TextSpan(
                                    text: 'Город: ',
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  TextSpan(
                                    text: geolocation != null
                                        ? '${geolocation.address}\n'
                                        : 'Не указан\n',
                                  ),
                                  const TextSpan(
                                    text: 'Дата: ',
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  TextSpan(
                                    text: order.createdAt,
                                  ),
                                ],
                              ),
                            ),
                            trailing: Icon(
                              order.status == OrderStatus.completed.name
                                  ? Icons.check_circle
                                  : Icons.pending,
                              color: order.status == OrderStatus.completed.name
                                  ? Colors.green
                                  : Colors.orange,
                            ),
                            onTap: () {
                              showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return OrderDetailsPage(
                                      order: order,
                                    );
                                  });
                            },
                          ),
                        ),
                      ));
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
