import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vodovoz/data/datasources/local/money_repository.dart';
import 'package:vodovoz/data/datasources/remote/appwrite.dart';
import 'package:vodovoz/domain/entities/deliverer.dart';
import 'package:vodovoz/domain/entities/geolocation.dart';
import 'package:vodovoz/domain/entities/order.dart';
import 'package:vodovoz/domain/entities/user_model/user_model.dart';

import 'package:vodovoz/domain/repositories/geolocation_repository.dart';
import 'package:vodovoz/domain/repositories/order_repository.dart';
import 'package:vodovoz/injection_container.dart';
import 'package:vodovoz/presentation/providers/active_delivery_provider.dart';
import 'package:vodovoz/presentation/providers/order_user_bloc/order_user_bloc.dart';
import 'package:vodovoz/presentation/providers/order_user_bloc/order_user_event.dart';
import 'package:vodovoz/presentation/providers/order_user_bloc/order_user_state.dart';
import 'package:vodovoz/presentation/screens/order_water/drivers_list_page/widget/deliverer_widget.dart';
import 'package:vodovoz/presentation/screens/order_water/drivers_list_page/widget/deliverer_widget_with_accept_reject.dart';
import 'package:vodovoz/presentation/screens/order_water/drivers_list_page/widget/load_deliverers_first_time.dart';
import 'package:vodovoz/presentation/screens/order_water/drivers_list_page/widget/order_widget.dart';
import 'package:vodovoz/presentation/screens/order_water/drivers_list_page/widget/show_deliverer_pop_up.dart';
import 'package:vodovoz/presentation/widgets/navigation/drawer.dart';
import 'package:vodovoz/presentation/widgets/navigation/set_page.dart';
import 'package:yandex_mapkit/yandex_mapkit.dart';

class DriverListPage extends StatefulWidget {
  const DriverListPage({super.key});

  @override
  State<DriverListPage> createState() => _DriverListPageState();
}

class _DriverListPageState extends State<DriverListPage> {
  final AppWrite appWriteService = getIt<AppWrite>();
  final moneyRepo = getIt<MoneyRepository>();
  late YandexMapController mapController;
  final activeDeliveryProvider = getIt<ActiveDeliveryProvider>();
  final orderRepo = getIt<OrderRepository>();
  bool ckeckIsSubscribeOnRealtimeGeolocation = false;
  List<UserModel> possibleDeliverers = [];

  List<MapObject> placemarks = [];
  List<String> posibleDeliverersIds = [];
  List<Deliverer> delivererPossibleList = [];

  @override
  void initState() {
    super.initState();
    appWriteService.subscribeToRealtimeForClientUpdateOrder(
      onUpdate: _handleRealtimeUpdate,
    );
  }

  Future<void> _acceptOrder(UserModel deliverer) async {
    context.read<OrderUserBloc>().add(
          AcceptDelivererEvent(deliverer.userId, deliverer.token),
        );
    Navigator.of(context).pop();
    if (mounted) {
      SetPageWithoutBack(context, 'orderAccepted');
    }
  }

  Future<void> _rejectOrder(UserModel deliverer) async {
    context.read<OrderUserBloc>().add(
          RejectDelivererEvent(deliverer.userId, deliverer.token),
        );
    Navigator.of(context).pop();
  }

  void _handleRealtimeUpdate() {
    getIt<OrderUserBloc>().add(LoadOrderUserEvent());
  }

  @override
  void dispose() {
    appWriteService.unsubscribeFromRealtimeUpdates();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocBuilder<OrderUserBloc, OrderUserState>(
        builder: (context, state) {
          if (state is OrderUserLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else if (state is OrderUserLoaded) {
            Order order = state.order;

            return FutureBuilder<Geolocation?>(
              future: getIt<GeolocationRepository>().getGeolocation(order.id),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData) {
                  return const Center(
                    child: Text('Не удалось загрузить геолокацию'),
                  );
                }

                final orderGeolocation = snapshot.data!;
                final orderPoint = Point(
                  latitude: double.parse(orderGeolocation.latitude),
                  longitude: double.parse(orderGeolocation.longitude),
                );
                if (order.waterType.isNotEmpty &&
                    !ckeckIsSubscribeOnRealtimeGeolocation) {
                  loadDeliverers(order.waterType, activeDeliveryProvider,
                      appWriteService, orderPoint);
                  ckeckIsSubscribeOnRealtimeGeolocation = true;
                }
                placemarks = [
                  PlacemarkMapObject(
                    opacity: 1,
                    mapId: const MapObjectId('order_location'),
                    point: orderPoint,
                    icon: PlacemarkIcon.single(
                      PlacemarkIconStyle(
                        image: BitmapDescriptor.fromAssetImage(
                          'assets/images/user_location.png',
                        ),
                        scale: 2,
                        anchor: Offset(
                          0.5,
                          0.9,
                        ),
                      ),
                    ),
                  ),
                ];
                if (posibleDeliverersIds != order.idsOfPossibleDeliverers) {
                  posibleDeliverersIds = order.idsOfPossibleDeliverers;
                  delivererPossibleList =
                      activeDeliveryProvider.deliverers.where((x) {
                    print('Checking deliverer userId: ${x.userId}');

                    return posibleDeliverersIds.contains(x.userId) &&
                        !order.idsOfNotPossibleDeliverers.contains(x.userId);
                  }).toList();
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (delivererPossibleList.isNotEmpty) {
                      showDelivererPopup(context, delivererPossibleList,
                          _acceptOrder, _rejectOrder, order, moneyRepo);
                    }
                  });
                }
               
                return ListenableBuilder(
                  listenable: activeDeliveryProvider,
                  builder: (context1, state1) {
                     if (order.idsOfNotPossibleDeliverers.isNotEmpty) {
                  for (var element in order.idsOfNotPossibleDeliverers) {
                    activeDeliveryProvider.removeDeliverer(element);
                  }
                }

                    final hasOrderPlacemark = placemarks.any(
                      (placemark) => placemark.mapId.value == 'order_location',
                    );

                    // Если метка заказа отсутствует, добавляем её
                    if (!hasOrderPlacemark) {
                      placemarks.add(
                        PlacemarkMapObject(
                          opacity: 1,
                          mapId: MapObjectId('order_location'),
                          point: orderPoint,
                          icon: PlacemarkIcon.single(
                            PlacemarkIconStyle(
                              image: BitmapDescriptor.fromAssetImage(
                                'assets/images/user_location.png',
                              ),
                              scale: 2,
                              anchor: const Offset(0.5, 0.9),
                            ),
                          ),
                        ),
                      );
                    }

                    // Обновляем список меток доставщиков, удаляя устаревшие
                    placemarks.removeWhere((placemark) =>
                        placemark.mapId.value != 'order_location' &&
                        !activeDeliveryProvider.deliverers.any((d) =>
                            'deliverer_${d.userId}' == placemark.mapId.value));

                    return Stack(
                      children: [
                        YandexMap(
                          onMapCreated: (YandexMapController controller) async {
                            mapController = controller;

                            await controller.moveCamera(
                              CameraUpdate.newCameraPosition(
                                CameraPosition(
                                  target: orderPoint,
                                  zoom: 16,
                                ),
                              ),
                              animation: const MapAnimation(
                                type: MapAnimationType.linear,
                                duration: 2,
                              ),
                            );
                          },
                          mapObjects: placemarks,
                        ),
                        ...activeDeliveryProvider.deliverers.map((deliverer) {
                          final geolocationList = activeDeliveryProvider
                              .geolocations
                              .where((x) => x.geolocationId == deliverer.userId)
                              .toList();
                          final delivererGeolocation = geolocationList.isEmpty
                              ? null
                              : geolocationList.first;
                          if (delivererGeolocation == null) {activeDeliveryProvider.checkGeolocationPresence(deliverer.userId);}

                          if (delivererGeolocation != null) {
                            final delivererPoint = Point(
                              latitude:
                                  double.parse(delivererGeolocation.latitude),
                              longitude:
                                  double.parse(delivererGeolocation.longitude),
                            );

                            placemarks.add(
                              PlacemarkMapObject(
                                opacity: (order.idsOfPossibleDeliverers
                                            .contains(deliverer.userId) &&
                                        !order.idsOfNotPossibleDeliverers
                                            .contains(
                                          deliverer.userId,
                                        ))
                                    ? 0.8
                                    : 0.5,
                                mapId: MapObjectId(
                                    'deliverer_${deliverer.userId}'),
                                onTap: (mapObject, point) {
                                  if (order.idsOfPossibleDeliverers
                                          .contains(deliverer.userId) &&
                                      !order.idsOfNotPossibleDeliverers
                                          .contains(
                                        deliverer.userId,
                                      )) {
                                    showDialog(
                                        context: context,
                                        builder: (BuildContext context) {
                                          return AlertDialog(
                                            contentPadding:
                                                EdgeInsets.all(1.sp),
                                            content:
                                                DelivererWidgetWithAcceptReject(
                                              deliverer: deliverer,
                                              price: moneyRepo
                                                  .getOrderPriceWithPotentialDeliverer(
                                                order,
                                                deliverer,
                                              ),
                                              onAccept: _acceptOrder,
                                              onReject: _rejectOrder,
                                            ),
                                          );
                                        });
                                  } else {
                                    showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return AlertDialog(
                                          contentPadding: EdgeInsets.all(1.sp),
                                          content: DelivererWidget(
                                            deliverer: deliverer,
                                          ),
                                        );
                                      },
                                    );
                                  }
                                },
                                point: delivererPoint,
                                icon: PlacemarkIcon.single(
                                  PlacemarkIconStyle(
                                    image: BitmapDescriptor.fromAssetImage(
                                      !(order.idsOfPossibleDeliverers
                                                  .contains(deliverer.userId) &&
                                              !order.idsOfNotPossibleDeliverers
                                                  .contains(
                                                deliverer.userId,
                                              ))
                                          ? 'assets/images/deliverer_truck.png'
                                          : 'assets/images/mark.png',
                                    ),
                                    scale: (order.idsOfPossibleDeliverers
                                                .contains(deliverer.userId) &&
                                            !order.idsOfNotPossibleDeliverers
                                                .contains(
                                              deliverer.userId,
                                            ))
                                        ? 0.4
                                        : 0.08,
                                  ),
                                ),
                              ),
                            );
                          }
                          return const SizedBox.shrink();
                        }),
                        Positioned(
                          bottom: 0,
                          left: 0,
                          right: 0,
                          child: Container(
                            padding: EdgeInsets.all(16.0.sp),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.vertical(
                                top: Radius.circular(16.0.sp),
                              ),
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  activeDeliveryProvider.deliverers.isNotEmpty
                                      ? 'Есть водовозы рядом'
                                      : 'Нет водовозов рядом. Ждите',
                                  style: TextStyle(
                                    fontSize: 20.sp,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(height: 8.h),
                                ElevatedButton(
                                  onPressed: () {
                                    showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return AlertDialog(
                                          contentPadding: EdgeInsets.all(1.sp),
                                          content: OrderDetailsWidget(
                                            order: order,
                                          ),
                                        );
                                      },
                                    );
                                  },
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(Icons.menu),
                                      SizedBox(width: 8.w),
                                      const Text('Посмотреть детали заказа'),
                                    ],
                                  ),
                                ),
                                SizedBox(height: 8.h),
                                ElevatedButton(
                                  onPressed: () {
                                    context.read<OrderUserBloc>().add(
                                          CancelOrderUserEvent(),
                                        );
                                  },
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(Icons.cancel),
                                      SizedBox(width: 8.w),
                                      const Text('Отменить заказ'),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                );
              },
            );
          } else if (state is OrderUserCanceled) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              SetPageWithoutBack(context, 'orderingRedirect');
            });
          }
          return Center(
            child: const CircularProgressIndicator(),
          );
        },
      ),
      endDrawer: drawer(context),
    );
  }
}
