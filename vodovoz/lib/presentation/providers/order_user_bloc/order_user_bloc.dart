import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vodovoz/data/datasources/remote/appwrite.dart';
import 'package:vodovoz/domain/entities/order.dart';
import 'package:vodovoz/domain/repositories/geolocation_repository.dart';
import 'package:vodovoz/domain/repositories/order_repository.dart';

import 'package:vodovoz/injection_container.dart';
import 'package:vodovoz/presentation/providers/active_delivery_provider.dart';
import 'package:vodovoz/presentation/providers/order_user_bloc/order_user_event.dart';
import 'package:vodovoz/presentation/providers/order_user_bloc/order_user_state.dart';

class OrderUserBloc extends Bloc<OrderUserEvent, OrderUserState> {
  final OrderRepository orderRepo = getIt<OrderRepository>();
  final GeolocationRepository geolocationRepository =
      getIt<GeolocationRepository>();
  final AppWrite appWriteService = getIt<AppWrite>();
  final activeDeliveryProvider = getIt<ActiveDeliveryProvider>();
  OrderUserBloc() : super(OrderUserInitial()) {
    on<LoadOrderUserEvent>(_onLoadOrderUser);
    on<UpdateOrderUserStatusEvent>(_onUpdateOrderUserStatus);
    on<AcceptDelivererEvent>(_onAcceptDeliverer);
    on<RejectDelivererEvent>(_onRejectDeliverer);
    on<CancelOrderUserEvent>(_onCancelOrderUser);
  }

  Future<void> _onLoadOrderUser(
    LoadOrderUserEvent event,
    Emitter<OrderUserState> emit,
  ) async {
    emit(OrderUserLoading());
    try {
      final Order? loadedOrderUser = await orderRepo.getActiveOrder();
      if (loadedOrderUser != null) {
        emit(OrderUserLoaded(loadedOrderUser));
      } else {
        emit(OrderUserInitial());
      }
    } catch (e) {
      emit(const OrderUserError('Failed to load order'));
    }
  }

  // void _subscribeToDeliverersUpdates(String waterType, String delivererId) {
  //   if (_isSubscribedToDeliverers) return; // Проверяем, если уже подписаны

  //   appWriteService.subscribeToDeliverersGeopositionsIdsUpdates(
  //     orderWaterType: waterType,
  //     delivererId: delivererId,
  //     onUpdate: () async {
  //       try {
  //         // Получаем доставщиков по типу воды и статусу онлайн
  //         final deliverers = await getIt<DelivererRepository>()
  //             .getDeliverersByWaterTypeAndIsOnline(waterType);
  //         activeDeliveryProvider.updateDeliverers(deliverers);
  //         final geolococations = await getIt<GeolocationRepository>()
  //             .getGeolocationsByDelivererIds(
  //                 deliverers.map((x) => x.userId).toList());
  //         for (final geo in geolococations) {
  //           activeDeliveryProvider.updateGeolocation(geo);
  //         }

  //         // Получаем текущее состояние
  //       } catch (e) {
  //         // Обработка ошибок получения доставщиков
  //         print('Failed to update deliverers');
  //       }
  //     },
  //   );

  //   _isSubscribedToDeliverers = true; // Устанавливаем флаг после подписки
  // }

  // void _subscribeToDeliverer(String delivererId) {
  //   appWriteService.subscribeToRealtimeForDelivererUpdate(
  //     delivererId: delivererId,
  //     onUpdate: (Deliverer updatedDelivererData) {
  //       // Update the deliverer in Bloc
  //       add(UpdateDelivererEvent(delivererData: updatedDelivererData));
  //     },
  //   );

  //   // After subscribing to the deliverer, subscribe to geolocation
  //   _subscribeToGeolocationUpdates(delivererId);
  // }

  // void _subscribeToGeolocationUpdates(String delivererId) {
  //   appWriteService.subscribeToGeolocationUpdates(
  //     delivererId,
  //     (geolocationData) {
  //       // Update the geolocation
  //       geolocationRepository.updateGeolocation(geolocationData);
  //     },
  //   );
  // }

  @override
  Future<void> close() {
    appWriteService.unsubscribeFromRealtimeUpdates();
    return super.close();
  }

  Future<void> _onUpdateOrderUserStatus(
    UpdateOrderUserStatusEvent event,
    Emitter<OrderUserState> emit,
  ) async {
    if (state is OrderUserLoaded) {
      final Order currentOrderUser = (state as OrderUserLoaded).order;
      currentOrderUser.status = event.status;
      try {
        await orderRepo.updateOrder(currentOrderUser);
        emit(OrderUserStatusUpdated());

        emit(OrderUserLoaded(currentOrderUser));
      } catch (e) {
        emit(const OrderUserError('Failed to update order status'));
      }
    }
  }

  Future<void> _onAcceptDeliverer(
    AcceptDelivererEvent event,
    Emitter<OrderUserState> emit,
  ) async {
    if (state is OrderUserLoaded) {
      final Order currentOrderUser = (state as OrderUserLoaded).order;
      currentOrderUser.idsOfPossibleDeliverers.remove(event.delivererId);
      currentOrderUser.delivererId = event.delivererId;
      currentOrderUser.status = 'accepted';
      try {
        await orderRepo.updateOrder(currentOrderUser);

        emit(OrderUserLoaded(currentOrderUser));
      } catch (e) {
        emit(const OrderUserError('Failed to accept deliverer'));
      }
    }
  }

  // Future<List<PlacemarkMapObject>> _getDelivererPlacemarks(
  //     List<String> delivererIds) async {
  //   List<PlacemarkMapObject> placemarks = [];
  //   for (String id in delivererIds) {
  //     final geolocation = await geolocationRepository.getGeolocation(id);
  //     if (geolocation != null) {
  //       placemarks.add(
  //         PlacemarkMapObject(
  //           mapId: MapObjectId('deliverer_$id'),
  //           point: Point(
  //             latitude: double.parse(geolocation.latitude),
  //             longitude: double.parse(geolocation.longitude),
  //           ),
  //           icon: PlacemarkIcon.single(
  //             PlacemarkIconStyle(
  //               image: BitmapDescriptor.fromAssetImage(
  //                   'assets/images/deliverer_truck.png'),
  //               scale: 0.75,
  //             ),
  //           ),
  //         ),
  //       );
  //     }
  //   }
  //   return placemarks;
  // }

  Future<void> _onRejectDeliverer(
    RejectDelivererEvent event,
    Emitter<OrderUserState> emit,
  ) async {
    if (state is OrderUserLoaded) {
      final Order currentOrderUser = (state as OrderUserLoaded).order;
      currentOrderUser.idsOfPossibleDeliverers.remove(event.delivererId);
      currentOrderUser.idsOfNotPossibleDeliverers.add(event.delivererId);
      try {
        await orderRepo.updateOrder(currentOrderUser);

        emit(OrderUserLoaded(currentOrderUser));
      } catch (e) {
        emit(const OrderUserError('Failed to reject deliverer'));
      }
    }
  }

  Future<void> _onCancelOrderUser(
    CancelOrderUserEvent event,
    Emitter<OrderUserState> emit,
  ) async {
    if (state is OrderUserLoaded) {
      final Order currentOrderUser = (state as OrderUserLoaded).order;
      currentOrderUser.status = 'canceled';
      try {
        await orderRepo.updateOrder(currentOrderUser);
        emit(OrderUserCanceled());
      } catch (e) {
        emit(const OrderUserError('Failed to cancel order'));
      }
    }
  } // Новый метод для удаления заказа
}
