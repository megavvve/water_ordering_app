import 'package:adminkigwater/data/datasources/local/excel_servise.dart';
import 'package:adminkigwater/domain/entities/deliverer.dart';
import 'package:adminkigwater/domain/entities/geolocation.dart';
import 'package:adminkigwater/domain/entities/user_model.dart';
import 'package:adminkigwater/domain/repositories/geolocation_repository.dart';
import 'package:adminkigwater/domain/repositories/storage_repository.dart';
import 'package:adminkigwater/domain/usecases/get_deliverers_use_case.dart';
import 'package:adminkigwater/domain/usecases/get_user_by_id.dart';
import 'package:adminkigwater/domain/usecases/update_deliverer_use_case.dart';
import 'package:adminkigwater/injection_container.dart';
import 'package:adminkigwater/presenation/screens/driver_request/widgets/deliver_card.dart';
import 'package:adminkigwater/presenation/widgets/city_dropdown_search.dart';
import 'package:adminkigwater/presenation/widgets/get_cities_from_geo_list.dart';
import 'package:adminkigwater/presenation/widgets/navigation/drawer.dart';
import 'package:adminkigwater/presenation/screens/driver_request/widgets/show_deliverer_details.dart';
import 'package:adminkigwater/presenation/widgets/export_button.dart';
import 'package:adminkigwater/presenation/widgets/search_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class DriversPage extends StatefulWidget {
  const DriversPage({super.key});

  @override
  State<StatefulWidget> createState() => _DriversPageState();
}

class _DriversPageState extends State<DriversPage> {
  Map<String, UserModel> _users = {};
  List<Deliverer> _filteredDeliverers = [];
  List<Deliverer> _allDeliverers = []; // Список для хранения всех водовозов
  List<Geolocation> geolocationList = [];
  final storageRepo = getIt<StorageRepository>();
  String? _selectedCity = 'Все города'; // Выбранный город
  List<String?> cities = []; // Список всех городов

  @override
  void initState() {
    super.initState();
    _fetchUnavailableDeliverers();
  }

  Future<void> _fetchUnavailableDeliverers() async {
    try {
      final deliverersFromApi = await getIt<GetDeliverers>().call();
      geolocationList = await getIt<GeolocationRepository>()
          .getGeolocationsByIds(
              deliverersFromApi.map((x) => x.userId).toList());

      // Разделяем водовозов на две группы
      final unavailableDeliverers = deliverersFromApi
          .where((d) => d.isAvailable == null || d.isAvailable == false)
          .toList();
      final availableDeliverers =
          deliverersFromApi.where((d) => d.isAvailable == true).toList();

      final deliverers = [...unavailableDeliverers, ...availableDeliverers];

      // Получаем уникальные города
      List<String> citiesList = getCitiesFromGeoList(geolocationList);
      citiesList.remove('Город не указан');
      // Получаем пользователей
      final userDetails = <String, UserModel>{};
      for (var deliverer in deliverers) {
        final user = await getIt<GetUserById>().call(deliverer.userId);
        userDetails[deliverer.userId] = user!;
      }

      setState(() {
        cities = citiesList;
        _users = userDetails;
        _allDeliverers = deliverers;
        _filteredDeliverers = deliverers;
      });
    } catch (e) {
      print('Error fetching deliverers: $e');
    }
  }

  void _filterDeliverers(String query) {
    setState(() {
      _filteredDeliverers = _allDeliverers.where((deliverer) {
        final user = _users[deliverer.userId];
        final name = user?.name.toLowerCase() ?? '';
        final phone = user?.phoneNumber.toLowerCase() ?? '';

        final geolocation = geolocationList.firstWhere(
          (x) => x.geolocationId == deliverer.userId,
        );

        final city = geolocation.address.toLowerCase();
        final searchQueryLower = query.toLowerCase();

        return (name.contains(searchQueryLower) ||
                phone.contains(searchQueryLower) ||
                city.contains(searchQueryLower)) &&
            (_selectedCity == 'Все города' ||
                city.contains(
                  _selectedCity!.toLowerCase(),
                ));
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final pendingDeliverers = _filteredDeliverers
        .where((d) => d.isAvailable == null || d.isAvailable == false)
        .toList();
    final confirmedDeliverers =
        _filteredDeliverers.where((d) => d.isAvailable == true).toList();

    return Scaffold(
      drawer: getDrawer(context),
      appBar: AppBar(
        title: const Text('Водовозы'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(15.sp),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              SizedBox(height: 15.h),
              CityDropdownSearch(
                cities: cities,
                selectedCity: _selectedCity,
                onCitySelected: (String? city) {
                  setState(() {
                    _selectedCity = city;
                    _filterDeliverers('');
                  });
                },
              ),

              SizedBox(height: 15.h),
              ExportButton(
                buttonText: 'Выгрузить статистику водовозов по: $_selectedCity',
                onExport: () {
                  getIt<ExcelService>()
                      .exportDriverApplicationsReport(_filteredDeliverers);
                },
              ),
              SizedBox(height: 10.h),
              SearchWidget(onSearch: _filterDeliverers),
              SizedBox(height: 10.h),
              // Заголовок для заявок на рассмотрении
              if (pendingDeliverers.isNotEmpty)
                _buildSectionHeader('Заявки на рассмотрении', Icons.pending),
              _buildDelivererList(pendingDeliverers, false),
              // Заголовок для подтвержденных водовозов
              if (confirmedDeliverers.isNotEmpty)
                _buildSectionHeader(
                    'Подтвержденные водовозы', Icons.check_circle),
              _buildDelivererList(confirmedDeliverers, true),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 10.h),
      child: Row(
        children: [
          Icon(icon, color: Colors.blue),
          SizedBox(width: 10.w),
          Text(
            title,
            style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildDelivererList(List<Deliverer> deliverers, bool isConfirmed) {
    return ListView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: deliverers.length,
      itemBuilder: (BuildContext context, int index) {
        final deliverer = deliverers[index];
        final user = _users[deliverer.userId];
        return DelivererCard(
          deliverer: deliverer,
          user: user!,
          onReview: () => showDelivererDetails(
            context,
            deliverer,
            user,
            geolocationList,
            storageRepo,
            () async {
              deliverer.isAvailable == true
                  ? deliverer.isAvailable = false
                  : deliverer.isAvailable = true;
              await getIt<UpdateDeliverer>().call(deliverer);
              Navigator.of(context).pop();
              setState(() {
                _fetchUnavailableDeliverers();
              });
            },
          ),
          index: index + 1,
          isConfirmed: isConfirmed,
        );
      },
    );
  }
}
