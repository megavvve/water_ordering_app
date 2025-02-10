import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vodovoz/data/datasources/remote/appwrite.dart';
import 'package:vodovoz/domain/entities/order.dart';
import 'package:vodovoz/domain/repositories/geolocation_repository.dart';
import 'package:vodovoz/domain/repositories/order_repository.dart';
import 'package:vodovoz/injection_container.dart';
import 'package:vodovoz/presentation/providers/active_delivery_provider.dart';
import 'package:vodovoz/presentation/providers/order_user_bloc/order_user_event.dart';
import 'package:yandex_mapkit/yandex_mapkit.dart';
import 'package:vodovoz/presentation/providers/order_user_bloc/order_user_bloc.dart';
import 'package:vodovoz/presentation/providers/order_user_bloc/order_user_state.dart';

class MapWithDriversPage extends StatefulWidget {
  const MapWithDriversPage({super.key});

  @override
  State<MapWithDriversPage> createState() => _MapWithDriversPageState();
}

class _MapWithDriversPageState extends State<MapWithDriversPage> {

  late final YandexMapController _yandexMapController;
  Point? orderPoint;
  final AppWrite appWriteService = getIt<AppWrite>();
   final activeDeliveryProvider = getIt<ActiveDeliveryProvider>();
final orderRepo = getIt<OrderRepository>();
  final orderUserBloc = getIt<OrderUserBloc>();
  @override
  void initState() {
    super.initState();
    _initializeMapController();
  }

  Future<void> _initializeMapController() async {
      final Order? loadedOrderUser = await orderRepo.getActiveOrder();
      
    final geolocatingRepository = getIt<GeolocationRepository>();
    final geolocation = await geolocatingRepository.getGeolocation(loadedOrderUser!.id);
    
    if (geolocation != null) {
      setState(() {
        orderPoint = Point(
          latitude: double.parse(geolocation.latitude),
          longitude: double.parse(geolocation.longitude),
        );
      });
    }

  }


  @override
  Widget build(BuildContext context) {
    bool canPop = Navigator.canPop(context);
    return PopScope(
            canPop: canPop,
    onPopInvokedWithResult: (bool didPop, _) async {
      if (!didPop) {
        final bool? confirmExit = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Выход из приложения'),
            content: const Text('Вы точно хотите выйти?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Отмена'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Выйти'),
              ),
            ],
          ),
        );

        if (confirmExit ?? false) {
          if (mounted) SystemNavigator.pop();
        }
      }
    },
      child: Scaffold(
        body: BlocBuilder<OrderUserBloc, OrderUserState>(
          builder: (context, state) {
            if (state is OrderUserLoaded && orderPoint != null) {
              return Stack(
                children: [
                  YandexMap(
                    onMapCreated: (YandexMapController controller) {
                      _yandexMapController = controller;
                      _yandexMapController.moveCamera(
                        CameraUpdate.newCameraPosition(
                          CameraPosition(target: orderPoint!, zoom: 16),
                        ),
                      );
                    },
                    // mapObjects: _mapController.updatePlacemarks(
                    //   state.order,
                    //   context.read<ActiveDeliveryProvider>().deliverers,
                    //   orderPoint!,
                    // ),
                  ),
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: _buildBottomSheet(),
                  ),
                ],
              );
            } else if (state is OrderUserLoading || orderPoint == null) {
              return const Center(child: CircularProgressIndicator());
            } else {
              return const Center(child: Text('Ошибка загрузки данных'));
            }
          },
        ),
      ),
    );
  }

  Widget _buildBottomSheet() {
    return Container(
      padding: EdgeInsets.all(16.0.sp),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(16.0)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Text(
          //   // _mapController.activeDeliveryProvider.deliverers.isNotEmpty
          //   //     ? 'Есть водовозы рядом'
          //   //     : 'Нет водовозов рядом. Ждите',
          //   style: TextStyle(
          //     fontSize: 20.sp,
          //     fontWeight: FontWeight.bold,
          //   ),
          // ),
          SizedBox(height: 8.h),
          ElevatedButton(
            onPressed: () {
              // Детали заказа
            },
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.menu),
                SizedBox(width: 8),
                const Text('Посмотреть детали заказа'),
              ],
            ),
          ),
          SizedBox(height: 8.h),
          ElevatedButton(
            onPressed: () {
              context.read<OrderUserBloc>().add(CancelOrderUserEvent());
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
    );
  }
}
