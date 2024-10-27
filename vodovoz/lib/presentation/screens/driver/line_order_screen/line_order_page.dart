import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vodovoz/data/datasources/local/local_saved_data.dart';
import 'package:vodovoz/data/datasources/remote/appwrite.dart';
import 'package:vodovoz/data/datasources/remote/geo_service.dart';
import 'package:vodovoz/domain/entities/deliverer.dart';
import 'package:vodovoz/domain/entities/order.dart';
import 'package:vodovoz/domain/repositories/deliverer_repository.dart';
import 'package:vodovoz/domain/repositories/geolocation_repository.dart';
import 'package:vodovoz/domain/repositories/order_repository.dart';
import 'package:vodovoz/domain/repositories/user/user_repository.dart';
import 'package:vodovoz/injection_container.dart';
import 'package:vodovoz/presentation/providers/delivery_order_bloc/deliverer_order_bloc.dart';
import 'package:vodovoz/presentation/screens/driver/line_order_screen/widgets/order_card.dart';
import 'package:vodovoz/presentation/screens/driver/line_order_screen/widgets/show_cancel_dialogue.dart';
import 'package:vodovoz/presentation/widgets/enums/user_type.dart';
import 'package:vodovoz/presentation/widgets/navigation/drawer.dart';
import 'package:flutter/scheduler.dart';
import 'package:vodovoz/presentation/widgets/navigation/set_page.dart';

import 'package:geolocator/geolocator.dart';
import 'package:vodovoz/utils/constants.dart';

class LineOrderPage extends StatefulWidget {
  const LineOrderPage({super.key});

  @override
  LineOrderPageState createState() => LineOrderPageState();
}

class LineOrderPageState extends State<LineOrderPage> {
  late DelivererOrderBloc delivererOrderBloc;
  final AppWrite appWriteService = getIt<AppWrite>();
  final GeolocationRepository geolocationRepository =
      getIt<GeolocationRepository>();
  final delivererRepo = getIt<DelivererRepository>();
  late StreamSubscription<Position> positionStreamSubscription;
  final userRepo = getIt<UserRepository>();
  double searchRadiusInKm = constantInitRadiusToFindOrdersByDeliverers; 

  @override
  void initState() {
    super.initState();

    _checkPermissions();

    appWriteService.subscribeToRealtimeForDelivererLoadOrders(
        onUpdate: _handleRealtimeUpdate);

    delivererOrderBloc = getIt<DelivererOrderBloc>()..add(LoadOrders());
    _updateUSerNameONDeliverer();
  }

  Future<void> _updateUSerNameONDeliverer() async {
    final deliverer = await userRepo.getUserById(LocalSavedData().getUserId());
    if (deliverer != null) {
      userRepo
          .updateUser(deliverer.copyWith(userType: UserType.deliverer.name));
    }
  }

  Future<void> _checkPermissions() async {
    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
     
        _showPermissionDeniedMessage();
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Handle permission denied permanently scenario
      _showPermissionDeniedMessage(isPermanentlyDenied: true);
      return;
    }

    // If permissions are granted, subscribe to geolocation updates
    _subscribeToLocationUpdates();
  }

  void _subscribeToLocationUpdates() {
    positionStreamSubscription = Geolocator.getPositionStream().listen(
      (Position position) async {
        final geolocation = await geolocationRepository
            .getGeolocation(LocalSavedData().getUserId());
        if (geolocation != null) {
          String currentLatitude = position.latitude.toString();
          String currentLongitude = position.longitude.toString();
          if (geolocation.latitude != currentLatitude &&
              currentLongitude != geolocation.longitude) {
            final currentAddressFromLatLng = await getIt<GeoService>()
                .getAddressFromLatLng(position.latitude, position.longitude);
            await geolocationRepository.updateGeolocation(
              geolocation.copyWith(
                address: currentAddressFromLatLng,
                latitude: currentLatitude,
                longitude: currentLongitude,
              ),
            );
          }
        }
      },
    );
  }

  void _showPermissionDeniedMessage({bool isPermanentlyDenied = false}) {
    String message = isPermanentlyDenied
        ? "В разрешениях на определение местоположения отказано навсегда. Пожалуйста, включите их в настройках."
        : "В разрешениях на определение местоположения отказано. Пожалуйста, разрешите продолжить доступ";

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
  }

  void _handleRealtimeUpdate() {
    getIt<DelivererOrderBloc>().add(LoadOrders());
  }

  @override
  void dispose() {
    // Unsubscribe when the widget is disposed
    appWriteService.unsubscribeFromRealtimeUpdates();
    positionStreamSubscription.cancel();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.blueAccent, Colors.blueGrey],
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          centerTitle: true,
          title: Text(
            'Список текущих заказов',
            style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w400,
                fontSize: 20.sp),
          ),
          backgroundColor: Colors.transparent,
        ),
        endDrawer: drawer(context),
        body: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.0.w),
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.all(8.0.sp),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Радиус поиска (км): ',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18.sp,
                      ),
                    ),
                    SizedBox(
                      width: 5.w,
                    ),
                    DropdownButton<double>(
                      value: searchRadiusInKm,
                      dropdownColor: Colors.white,
                      items: [5, 10, 15, 20, 25].map((int value) {
                        return DropdownMenuItem<double>(
                          value: value.toDouble(),
                          child: Text(value.toString()),
                        );
                      }).toList(),
                      onChanged: (newValue) {
                        setState(() {
                          searchRadiusInKm = newValue!;
                        });
                      },
                    ),
                  ],
                ),
              ),
              Expanded(
                child: BlocBuilder<DelivererOrderBloc, DelivererOrderState>(
                  builder: (context1, state) {
                    if (state is OrderLoading) {
                      return const Center(
                        child: CircularProgressIndicator(color: Colors.white),
                      );
                    } else if (state is OrderError) {
                      return Center(
                        child: Text(
                          'Ошибка: ${state.message}',
                          style: const TextStyle(color: Colors.white),
                        ),
                      );
                    } else if (state is OrderAlreadyAccepted) {
                      SchedulerBinding.instance.addPostFrameCallback((_) {
                        SetPageWithoutBack(context, 'orderDetailsDeliverer');
                      });
                      return const SizedBox.shrink();
                    } else if (state is OrderLoaded) {
                      return FutureBuilder<Position>(
                        future: getIt<GeoService>().determinePosition(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Center(
                              child: CircularProgressIndicator(
                                color: Colors.white,
                              ),
                            );
                          } else if (snapshot.hasError) {
                            return Center(
                              child: Text(
                                'Ошибка: ${snapshot.error}',
                              ),
                            );
                          } else if (snapshot.hasData) {
                            final userPosition = snapshot.data!;

                            return FutureBuilder<List<Order>>(
                              future: getIt<GeoService>().searchOrdersNearby(
                                orders: state.orders,
                                searchRadiusInKm: searchRadiusInKm,
                                userPosition: userPosition,
                              ),
                              builder: (context, snapshot) {
                                if (snapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return const Center(
                                    child: CircularProgressIndicator(
                                        color: Colors.white),
                                  );
                                } else if (snapshot.hasError) {
                                  return Center(
                                    child: Text(
                                      'Ошибка: ${snapshot.error}',
                                    ),
                                  );
                                } else if (snapshot.hasData &&
                                    snapshot.data!.isNotEmpty) {
                                  final nearbyOrders = snapshot.data!;
                                  return CustomScrollView(
                                    slivers: [
                                      SliverPadding(
                                        padding: EdgeInsets.symmetric(
                                          horizontal: 16.0.w,
                                          vertical: 12.0.h,
                                        ),
                                        sliver: SliverList(
                                          delegate: SliverChildBuilderDelegate(
                                            (context, index) {
                                              Order order = nearbyOrders[index];
                                              return Padding(
                                                padding: EdgeInsets.symmetric(
                                                  vertical: 8.0.h,
                                                ),
                                                child: OrderCard(
                                                  order: order,
                                                  onAccept: () async {
                                                    delivererOrderBloc.add(
                                                      AcceptPendingOrder(
                                                        order,
                                                      ),
                                                    );
                                                  },
                                                  onReject: () {
                                                    showCancelDialog(
                                                      context,
                                                      order,
                                                      (Order order,
                                                          String status) async {
                                                        delivererOrderBloc.add(
                                                          RejectPendingOrder(
                                                              order),
                                                        );
                                                      },
                                                    );
                                                  },
                                                ),
                                              );
                                            },
                                            childCount: nearbyOrders.length,
                                          ),
                                        ),
                                      ),
                                    ],
                                  );
                                } else {
                                  return Center(
                                    child: Text(
                                      'Нет заказов в выбранном радиусе',
                                      style: TextStyle(
                                          color: Colors.white, fontSize: 20.sp),
                                    ),
                                  );
                                }
                              },
                            );
                          } else {
                            return const Center(
                              child: Text(
                                'Не удалось определить позицию',
                              ),
                            );
                          }
                        },
                      );
                    } else if (state is OrderCanceled) {
                      final canceledOrder = state.order;

                      WidgetsBinding.instance.addPostFrameCallback((_) {
                           Navigator.of(context);
                        SetPageWithoutBack(context, 'delivery');

                        // Показываем всплывающее окно с информацией об отменённом заказе
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: Text('Заказ отменён'),
                              content: Text(
                                  'Заказ под номером: ${canceledOrder.id.hashCode} был отменён пользователем.'),
                              actions: <Widget>[
                                TextButton(
                                  onPressed: () {
                                    Navigator.of(context)
                                        .pop(); // Закрыть диалог
                                  },
                                  child: Text('Закрыть'),
                                ),
                              ],
                            );
                          },
                        );

                        // Обновляем статус завершенности заказа
                        getIt<OrderRepository>().updateOrder(
                          canceledOrder.copyWith(
                            isFinish: true,
                          ),
                        );
                      });
                    }

                    return const Center(child: CircularProgressIndicator());
                  },
                ),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  padding: EdgeInsets.zero,
                ),
                onPressed: () async {
                  final Deliverer? deliverer = await delivererRepo
                      .getDeliverer(LocalSavedData().getUserId());
                  if (deliverer != null) {
                    delivererRepo.updateDeliverer(
                      deliverer.copyWith(isAvailable: false,),
                    );
                  }
                  SetPageWithoutBack(context, 'delivery');
                },
                child: Ink(
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Colors.red, Colors.orange],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16.sp),
                  ),
                  child: Container(
                    constraints:
                        BoxConstraints(maxHeight: 50.h, maxWidth: 300.w),
                    alignment: Alignment.center,
                    child: Text(
                      'Уйти с линии', //TODO delivery
                      style: TextStyle(fontSize: 18.sp, color: Colors.white),
                    ),
                  ),
                ),
              ),
              SizedBox(
                height: 50.h,
              )
            ],
          ),
        ),
      ),
    );
  }
}
