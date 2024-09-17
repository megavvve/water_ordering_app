import 'dart:typed_data';

import 'package:adminkigwater/domain/entities/deliverer.dart';
import 'package:adminkigwater/domain/entities/user_model.dart';
import 'package:adminkigwater/domain/repositories/storage_repository.dart';
import 'package:adminkigwater/domain/usecases/get_deliverers_use_case.dart';
import 'package:adminkigwater/domain/usecases/get_user_by_id.dart';
import 'package:adminkigwater/domain/usecases/update_deliverer_use_case.dart';
import 'package:adminkigwater/injection_container.dart';
import 'package:adminkigwater/presenation/screens/driver_request/widgets/deliver_card.dart';
import 'package:adminkigwater/presenation/screens/driver_request/widgets/search_bar.dart';
import 'package:adminkigwater/presenation/navigation/drawer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class DriverRequestsPage extends StatefulWidget {
  const DriverRequestsPage({super.key});

  @override
  State<StatefulWidget> createState() => _DriverRequestsPageState();
}

class _DriverRequestsPageState extends State<DriverRequestsPage> {
  List<Deliverer> _unavailableDeliverers = [];
  Map<String, UserModel> _users = {}; // Map to cache user details by userId
  List<Deliverer> _filteredDeliverers = [];
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

      // Фильтруем доставщиков, у которых isAvailable == null или false
      final unavailableDeliverers = deliverers
          .where((d) => d.isAvailable == null || d.isAvailable == false)
          .toList();

      // Кэшируем информацию о пользователях
      final userDetails = <String, UserModel>{};
      for (var deliverer in unavailableDeliverers) {
        print(deliverer.userId);
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
        final city = user?.city.toLowerCase() ?? '';
        final searchQueryLower = query.toLowerCase();
        return name.contains(searchQueryLower) ||
            phone.contains(searchQueryLower) ||
            city.contains(searchQueryLower);
      }).toList();
    });
  }

  void showDelivererDetails(
      BuildContext context, Deliverer deliverer, UserModel user) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Детали доставщика'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('ФИО: ${user.name}'),
                Text('Телефон: ${user.phoneNumber}'),
                Text('Регион: ${user.city}'),
                FutureBuilder<Uint8List?>(
                  future:
                      storageRepo.getVodovozPhoto(deliverer.userId, "carPhoto"),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const CircularProgressIndicator();
                    } else if (snapshot.hasError || !snapshot.hasData) {
                      return const Text('Ошибка загрузки фото');
                    } else {
                      return SizedBox(
                        height: 400.h, // высота изображения
                        child: Image.memory(snapshot.data!),
                      );
                    }
                  },
                ),
                FutureBuilder<Uint8List?>(
                  future:
                      storageRepo.getVodovozPhoto(deliverer.userId, "sorPhoto"),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const CircularProgressIndicator();
                    } else if (snapshot.hasError || !snapshot.hasData) {
                      return const Text('Ошибка загрузки фото');
                    } else {
                      return SizedBox(
                        height: 400.h, // высота изображения
                        child: Image.memory(snapshot.data!),
                      );
                    }
                  },
                ),
                FutureBuilder<Uint8List?>(
                  future: storageRepo.getVodovozPhoto(
                      deliverer.userId, "licensePhoto"),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const CircularProgressIndicator();
                    } else if (snapshot.hasError || !snapshot.hasData) {
                      return const Text('Ошибка загрузки фото');
                    } else {
                      return SizedBox(
                        height: 400.h, // высота изображения
                        child: Image.memory(snapshot.data!),
                      );
                    }
                  },
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Закрыть'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Принять'),
              onPressed: () async {
                deliverer.isAvailable = true;
                await getIt<UpdateDeliverer>().call(deliverer);
                Navigator.of(context).pop();
                setState(() {
                  _fetchUnavailableDeliverers();
                });
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: getDrawer(context),
      appBar: AppBar(
        title: const Text('Заявки продавцов'),
        centerTitle: true,
      ),
      body: (_filteredDeliverers.isNotEmpty)
          ? Padding(
              padding: EdgeInsets.all(15.sp),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SearchWidget(
                    onSearch: _filterDeliverers,
                  ),
                  SizedBox(height: 10.h),
                  _buildHeader(),
                  Expanded(
                    child: ListView.builder(
                      itemCount: _filteredDeliverers.length,
                      itemBuilder: (BuildContext context, int index) {
                        final deliverer = _filteredDeliverers[index];
                        final user = _users[deliverer.userId];
                        return DelivererCard(
                          deliverer: deliverer,
                          user: user!,
                          onReview: () =>
                              showDelivererDetails(context, deliverer, user),
                          index: index + 1,
                        );
                      },
                    ),
                  ),
                ],
              ),
            )
          : const Center(
              child: Text('Заявок доставщиков пока нет'),
            ),
    );
  }
}

Widget _buildHeader() {
  return Card(
    child: Row(
      children: [
        _buildHeaderItem('№', 50),
        _buildHeaderItem('ФИО', 230),
        _buildHeaderItem('Телефон', 150),
        _buildHeaderItem('Регион', 150),
      ],
    ),
  );
}

Widget _buildHeaderItem(String title, double width) {
  return Padding(
    padding: EdgeInsets.all(3.sp),
    child: SizedBox(
      width: width.w,
      child: OutlinedButton(
        onPressed: () {},
        child: Text(title, style: TextStyle(fontSize: 18.sp)),
      ),
    ),
  );
}
