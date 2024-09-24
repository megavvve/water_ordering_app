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
import 'package:adminkigwater/presenation/navigation/drawer.dart';
import 'package:adminkigwater/presenation/screens/driver_request/widgets/show_deliverer_details.dart';
import 'package:adminkigwater/presenation/widgets/export_button.dart';
import 'package:adminkigwater/presenation/widgets/search_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class DriverRequestsPage extends StatefulWidget {
  const DriverRequestsPage({super.key});

  @override
  State<StatefulWidget> createState() => _DriverRequestsPageState();
}

class _DriverRequestsPageState extends State<DriverRequestsPage> {
  List<Deliverer> _unavailableDeliverers = [];
  Map<String, UserModel> _users = {};
  List<Deliverer> _filteredDeliverers = [];
  List<Geolocation> geolocationList = [];
  final storageRepo = getIt<StorageRepository>();

  @override
  void initState() {
    super.initState();
    _fetchUnavailableDeliverers();
  }

  Future<void> _fetchUnavailableDeliverers() async {
    try {
      // Получаем всех доставщиков
      final deliverers = await getIt<GetDeliverers>().call();
      geolocationList = await getIt<GeolocationRepository>()
          .getGeolocationsByIds(deliverers.map((x) => x.userId).toList());
      // Фильтруем доставщиков, у которых isAvailable == null или false
      final unavailableDeliverers = deliverers
          .where((d) => d.isAvailable == null || d.isAvailable == false)
          .toList();

      // Кэшируем информацию о пользователях
      final userDetails = <String, UserModel>{};
      for (var deliverer in unavailableDeliverers) {
        final user = await getIt<GetUserById>().call(deliverer.userId);
        userDetails[deliverer.userId] = user!;
      }

      setState(() {
        _unavailableDeliverers = unavailableDeliverers;
        _users = userDetails;
        _filteredDeliverers = unavailableDeliverers;
      });
    } catch (e) {
      print('Error fetching deliverers: $e');
    }
  }

  void _filterDeliverers(String query) {
    setState(() {
      _filteredDeliverers = _unavailableDeliverers.where((deliverer) {
        final user = _users[deliverer.userId];
        final name = user?.name.toLowerCase() ?? '';
        final phone = user?.phoneNumber.toLowerCase() ?? '';

        // Проверяем, существует ли геолокация для данного доставщика
        final geolocation = geolocationList.firstWhere(
          (x) => x.geolocationId == deliverer.userId,
        );

        final city = geolocation.address.toLowerCase();
        final searchQueryLower = query.toLowerCase();

        // Фильтруем по имени, телефону или городу
        return name.contains(searchQueryLower) ||
            phone.contains(searchQueryLower) ||
            city.contains(searchQueryLower);
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: getDrawer(context),
      appBar: AppBar(
        title: const Text('Заявки водовозов'),
        centerTitle: true,
      ),
      body: (_filteredDeliverers.isNotEmpty ||
              _unavailableDeliverers.isNotEmpty)
          ? Padding(
              padding: EdgeInsets.all(15.sp),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(
                    height: 15.h,
                  ),
                  ExportButton(
                    buttonText:
                        'Выгрузить статистику по всем заявкам водовозов',
                    onExport: () {
                      getIt<ExcelService>()
                          .exportDriverApplicationsReport(_filteredDeliverers);
                    },
                  ),
                  SizedBox(
                    height: 15.h,
                  ),
                  SearchWidget(
                    onSearch: _filterDeliverers,
                  ),
                  SizedBox(height: 10.h),
                  Padding(
                    padding: EdgeInsets.only(right: 345.w),
                    child: _buildHeader(),
                  ),
                  Expanded(
                    child: ListView.builder(
                      itemCount: _filteredDeliverers.length,
                      itemBuilder: (BuildContext context, int index) {
                        final deliverer = _filteredDeliverers[index];
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
                              deliverer.isAvailable = true;
                              await getIt<UpdateDeliverer>().call(deliverer);

                              // ignore: use_build_context_synchronously
                              Navigator.of(context).pop();
                              setState(() {
                                _fetchUnavailableDeliverers();
                              });
                            },
                          ),
                          index: index + 1,
                        );
                      },
                    ),
                  ),
                ],
              ),
            )
          : const Center(
              child: CircularProgressIndicator(),
            ),
    );
  }
}

Widget _buildHeader() {
  return Card(
    child: Row(
      children: [
        _buildHeaderItem('№', 1),
        _buildHeaderItem('ФИО', 3),
        _buildHeaderItem('Телефон', 3),
        _buildHeaderItem('Регион', 4),
      ],
    ),
  );
}

Widget _buildHeaderItem(String title, int flex) {
  return Expanded(
    flex: (flex == 2 || flex == 4)
        ? 3
        : (flex == 3)
            ? 2
            : flex,
    child: Padding(
      padding: EdgeInsets.all(3.sp),
      child: OutlinedButton(
        onPressed: () {},
        child: Text(title, style: TextStyle(fontSize: 18.sp)),
      ),
    ),
  );
}
