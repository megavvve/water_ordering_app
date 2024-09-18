import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vodovoz/data/datasources/remote/appwrite.dart';
import 'package:vodovoz/domain/entities/deliverer.dart';
import 'package:vodovoz/domain/entities/geolocation.dart';
import 'package:vodovoz/domain/entities/order.dart';
import 'package:vodovoz/domain/entities/user_model/user_model.dart';

import 'package:vodovoz/domain/repositories/geolocation_repository.dart';
import 'package:vodovoz/domain/repositories/order_repository.dart';
import 'package:vodovoz/domain/repositories/user/notification_repository.dart';

import 'package:vodovoz/injection_container.dart';
import 'package:vodovoz/presentation/providers/active_delivery_provider.dart';
import 'package:vodovoz/presentation/providers/order_user_bloc/order_user_bloc.dart';
import 'package:vodovoz/presentation/providers/order_user_bloc/order_user_event.dart';
import 'package:vodovoz/presentation/providers/order_user_bloc/order_user_state.dart';
import 'package:vodovoz/presentation/screens/order_water/drivers_list_page/widget/deliverer_widget.dart';
import 'package:vodovoz/presentation/screens/order_water/drivers_list_page/widget/load_deliverers_first_time.dart';
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
  late YandexMapController mapController;
  final activeDeliveryProvider = getIt<ActiveDeliveryProvider>();
  final orderRepo = getIt<OrderRepository>();
  bool ckeckIsSubscribeOnRealtimeGeolocation = false;
  List<UserModel> possibleDeliverers = [];

  List<MapObject> placemarks = [];
  List<String> posibleDeliverersIds = [];
  List<Deliverer> delivererPossibleList = [];

  void _showDelivererPopup() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Доступные водители'),
          contentPadding: EdgeInsets.all(1.sp),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: delivererPossibleList.length,
              itemBuilder: (BuildContext context, int index) {
                final deliverer = delivererPossibleList[index];

                return DelivererWidget(
                    deliverer: deliverer,
                    onAccept: _acceptOrder,
                    onReject: _rejectOrder);
              },
            ),
          ),
          actions: [
            TextButton(
              child: const Text('Отмена'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    appWriteService.subscribeToRealtimeForClientUpdateOrder(
      onUpdate: _handleRealtimeUpdate,
    );
  }

  Future<void> _acceptOrder(UserModel deliverer) async {
    final orderBloc = context.read<OrderUserBloc>();
    final order = (orderBloc.state as OrderUserLoaded).order;

    try {
      setState(() {
        order.idsOfPossibleDeliverers.remove(deliverer.userId);
        order.delivererId = deliverer.userId;
        order.status = 'accepted';
      });

      await orderRepo.updateOrder(order);

      await getIt<NotificationRepository>().sendNotificationtoOtherUser(
        notificationTitle: 'Заказ принят',
        notificationBody: 'Клиент принял вашу заявку на доставку.',
        deviceToken: deliverer.token ?? '',
      );

      if (mounted) {
        SetPageWithoutBack(context, 'orderAccepted');
      }
    } catch (e) {
      // Логирование или отображение ошибки пользователю
      print('Ошибка при принятии заказа: $e');
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Ошибка'),
          content: Text('Не удалось принять заказ: $e'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Ок'),
            ),
          ],
        ),
      );
    }
  }

  Future<void> _rejectOrder(UserModel deliverer) async {
    final orderBloc = context.read<OrderUserBloc>();
    final order = (orderBloc.state as OrderUserLoaded).order;

    order.idsOfPossibleDeliverers.remove(deliverer.userId);
    order.idsOfNotPossibleDeliverers.add(deliverer.userId);

    await orderRepo.updateOrder(order);
    setState(() {});
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

            if (order.waterType.isNotEmpty &&
                !ckeckIsSubscribeOnRealtimeGeolocation) {
              loadDeliverers(
                  order.waterType, activeDeliveryProvider, appWriteService);
              ckeckIsSubscribeOnRealtimeGeolocation = true;
            }

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

                placemarks = [
                  PlacemarkMapObject(
                    mapId: const MapObjectId('order_location'),
                    point: orderPoint,
                    icon: PlacemarkIcon.single(
                      PlacemarkIconStyle(
                        image: BitmapDescriptor.fromAssetImage(
                          'assets/images/user_location.png',
                        ),
                        scale: 1.5,
                      ),
                    ),
                  ),
                ];
                if (posibleDeliverersIds != order.idsOfPossibleDeliverers) {
                  posibleDeliverersIds = order.idsOfPossibleDeliverers;
                  delivererPossibleList = activeDeliveryProvider.deliverers
                      .where((x) => posibleDeliverersIds.contains(x.userId))
                      .toList();
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (delivererPossibleList.isNotEmpty) {
                      _showDelivererPopup();
                    }
                  });
                }
                if (order.idsOfNotPossibleDeliverers.isNotEmpty) {
                  for (var element in order.idsOfNotPossibleDeliverers) {
                    activeDeliveryProvider.removeDeliverer(element);
                  }
                }
                return ListenableBuilder(
                  listenable: activeDeliveryProvider,
                  builder: (context1, state1) {
                    return Stack(
                      children: [
                        YandexMap(
                          onMapCreated: (YandexMapController controller) async {
                            mapController = controller;
                            (posibleDeliverersIds.isEmpty)
                                ? await controller.moveCamera(
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
                                  )
                                : await controller.moveCamera(
                                    CameraUpdate.newCameraPosition(
                                      CameraPosition(
                                        target: Point(
                                            latitude: double.parse(
                                                activeDeliveryProvider
                                                    .geolocations
                                                    .firstWhere((x) =>
                                                        x.geolocationId ==
                                                        posibleDeliverersIds
                                                            .last)
                                                    .latitude),
                                            longitude: double.parse(
                                                activeDeliveryProvider
                                                    .geolocations
                                                    .firstWhere((x) =>
                                                        x.geolocationId ==
                                                        posibleDeliverersIds
                                                            .last)
                                                    .longitude)),
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

                          if (delivererGeolocation != null) {
                            final delivererPoint = Point(
                              latitude:
                                  double.parse(delivererGeolocation.latitude),
                              longitude:
                                  double.parse(delivererGeolocation.longitude),
                            );

                            placemarks.add(
                              PlacemarkMapObject(
                                mapId: MapObjectId(
                                    'deliverer_${deliverer.userId}'),
                                onTap: (mapObject, point) {
                                  if (posibleDeliverersIds
                                      .contains(deliverer.userId)) {
                                    showDialog(
                                        context: context,
                                        builder: (BuildContext context) {
                                          return AlertDialog(
                                              contentPadding:
                                                  EdgeInsets.all(1.sp),
                                              content: SizedBox(
                                                height: 360.h,
                                                child: DelivererWidget(
                                                    deliverer: deliverer,
                                                    onAccept: _acceptOrder,
                                                    onReject: _rejectOrder),
                                              ));
                                        });
                                  }
                                },
                                point: delivererPoint,
                                icon: PlacemarkIcon.single(
                                  PlacemarkIconStyle(
                                    image: BitmapDescriptor.fromAssetImage(
                                      'assets/images/deliverer_truck.png',
                                    ),
                                    scale: 0.1,
                                  ),
                                ),
                              ),
                            );
                          }
                          return const SizedBox.shrink();
                        }).toList(),
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
                                  'Есть водовозы рядом',
                                  style: TextStyle(
                                    fontSize: 20.sp,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(height: 8.h),
                                const Text('Выбираем подходящих'),
                                SizedBox(height: 8.h),
                                ElevatedButton(
                                  onPressed: () {
                                    context
                                        .read<OrderUserBloc>()
                                        .add(CancelOrderUserEvent());
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
          }
          return const SizedBox();
        },
      ),
      endDrawer: drawer(context),
    );
  }
}
