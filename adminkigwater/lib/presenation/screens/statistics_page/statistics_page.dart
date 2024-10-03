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
import 'package:adminkigwater/presenation/widgets/city_dropdown_search.dart';
import 'package:adminkigwater/presenation/widgets/get_cities_from_geo_list.dart';
import 'package:adminkigwater/presenation/widgets/navigation/drawer.dart';
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
  List<String?> cities = [];
  List<Geolocation> allGeolocations =
      []; // Список всех геолокаций (заказы и доставщики)
  String? _selectedLocation; // Выбранная геолокация
  List<Order> filteredOrders = [];
  List<UserModel> filteredUsers = [];
  List<Deliverer> filteredDeliverers = [];

  final orderRepo = getIt<OrderRepository>();
  List<Order> orders = [];
  List<UserModel> users = [];
  List<Deliverer> deliverers = [];
  List<Geolocation> ordersGeolocations = []; // Геолокации заказов
  List<Geolocation> delivererGeolocations = []; // Геолокации доставщиков
  List<Geolocation> usersGeolocations = [];

  final excelService = getIt<ExcelService>();

  @override
  void initState() {
    super.initState();
    _fetchStatistics(); // Загружаем общую статистику при инициализации
  }

  // Метод для получения общей статистики с сервера
  // Метод для получения общей статистики с сервера
  Future<void> _fetchStatistics() async {
    try {
      orders = await orderRepo.getOrders();
      users = await getIt<GetUsers>().call();
      deliverers = await getIt<GetDeliverers>().call();

      // Получаем геолокации заказов
      ordersGeolocations = await getIt<GeolocationRepository>()
          .getGeolocationsByIds(orders.map((x) => x.id).toList());

      // Получаем геолокации доставщиков
      delivererGeolocations = await getIt<GeolocationRepository>()
          .getGeolocationsByIds(deliverers.map((d) => d.userId).toList());
      usersGeolocations = await getIt<GeolocationRepository>()
          .getGeolocationsByIds(users.map((d) => d.userId).toList());

      allGeolocations = [
        ...ordersGeolocations,
        ...usersGeolocations,
 
      ];

      // Получаем уникальные города
      List<String> citiesList = getCitiesFromGeoList(allGeolocations);
      citiesList.remove('Город не указан');

      // Рассчитываем начальную статистику
      _calculateStatistics(_selectedLocation);

      setState(() {
        cities = citiesList;
      });
    } catch (e) {
      print('Ошибка при получении статистики: $e');
    }
  }

  void _calculateStatistics(String? selectedLocation) {
    bool showAllCities =
        selectedLocation == null || selectedLocation == "Все города";

    // Фильтруем заказы по выбранной геолокации
    filteredOrders = orders.where((order) {
      if (showAllCities) return true;
      Geolocation? orderGeolocation;
      try {
        orderGeolocation = ordersGeolocations.firstWhere(
          (geo) =>
              geo.geolocationId == order.id &&
              geo.address.contains(selectedLocation),
        );
      } catch (e) {
        orderGeolocation = null;
      }
      return orderGeolocation != null;
    }).toList();

    // Фильтруем доставщиков по выбранной геолокации
    filteredDeliverers = deliverers.where((deliverer) {
      if (showAllCities) return true;
      Geolocation? delivererGeolocation;
      try {
        delivererGeolocation = delivererGeolocations.firstWhere(
          (geo) =>
              geo.geolocationId == deliverer.userId &&
              geo.address.contains(selectedLocation),
        );
      } catch (e) {
        delivererGeolocation = null;
      }
      return delivererGeolocation != null;
    }).toList();

    // Фильтруем пользователей по выбранной геолокации
    filteredUsers = users.where((user) {
      if (showAllCities) return true;
      Geolocation? userGeolocation;
      try {
        userGeolocation = usersGeolocations.firstWhere(
          (geo) =>
              geo.geolocationId == user.userId &&
              geo.address.contains(selectedLocation),
        );
      } catch (e) {
        userGeolocation = null;
      }
      return userGeolocation != null;
    }).toList();

    // Подсчитываем количество заказов и пользователей
    _acceptedOrders = filteredOrders
        .where((order) =>
            order.status == OrderStatus.accepted.name ||
            order.status == OrderStatus.inProgress.name ||
            order.status == OrderStatus.pending.name ||
            order.status == OrderStatus.awaitingConfirmation.name)
        .length;

    _completedOrders = filteredOrders
        .where((order) => order.status == OrderStatus.completed.name)
        .length;

    _canceledOrders = filteredOrders
        .where((order) => order.status == OrderStatus.canceled.name)
        .length;

    _totalUsers = filteredUsers
        .where((user) => user.userType == UserType.user.name)
        .length;

    _totalDeliverers = filteredDeliverers.length;
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
                child: Column(
                  children: [
                    // Dropdown для выбора геолокации
                    CityDropdownSearch(
                      cities: cities,
                      selectedCity: _selectedLocation,
                      onCitySelected: (String? location) {
                        setState(() {
                          _selectedLocation = location;
                        });

                        // Загружаем статистику для выбранной геолокации
                        _calculateStatistics(location);
                      },
                    ),

                    SizedBox(height: 30.h),

                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        StatisticsCard(
                          title: 'Заказы',
                          stats: {
                            'Всего заказов': _acceptedOrders +
                                _completedOrders +
                                _canceledOrders,
                            'Активных заказов': _acceptedOrders,
                            'Завершенных заказов': _completedOrders,
                            'Отменено заказов': _canceledOrders,
                          },
                          onTap: () {
                            showDetailsDialog(
                              context,
                              'Заказы',
                              filteredUsers,
                              filteredDeliverers,
                              filteredOrders,
                            );
                          },
                        ),
                        SizedBox(width: 15.w),
                        StatisticsCard(
                          title: 'Пользователи',
                          stats: {
                            'Всего пользователей':
                                _totalUsers + _totalDeliverers,
                            'Водовозов': _totalDeliverers,
                            'Заказщиков': _totalUsers,
                          },
                          onTap: () {
                            showDetailsDialog(
                              context,
                              'Пользователи',
                              filteredUsers,
                              filteredDeliverers,
                              filteredOrders,
                            );
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
