import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vodovoz/data/datasources/remote/appwrite.dart';
import 'package:vodovoz/domain/entities/order.dart';
import 'package:vodovoz/domain/repositories/geolocation_repository.dart';
import 'package:vodovoz/domain/repositories/order_repository.dart';
import 'package:vodovoz/domain/repositories/user/notification_repository.dart';

import 'package:vodovoz/injection_container.dart';
import 'package:vodovoz/presentation/providers/active_delivery_provider.dart';
import 'package:vodovoz/presentation/providers/order_user_bloc/order_user_event.dart';
import 'package:vodovoz/presentation/providers/order_user_bloc/order_user_state.dart';

class OrderUserBloc extends Bloc<OrderUserEvent, OrderUserState> {
  final OrderRepository orderRepo = getIt<OrderRepository>();
  final GeolocationRepository geolocationRepository = getIt<GeolocationRepository>();
  final AppWrite appWriteService = getIt<AppWrite>();
  final activeDeliveryProvider = getIt<ActiveDeliveryProvider>();

  OrderUserBloc() : super(OrderUserInitial()) {
    on<LoadOrderUserEvent>(_onLoadOrderUser);
    on<UpdateOrderUserStatusEvent>(_onUpdateOrderUserStatus);
    on<AcceptDelivererEvent>(_onAcceptDeliverer);
    on<RejectDelivererEvent>(_onRejectDeliverer);
    on<CancelOrderUserEvent>(_onCancelOrderUser);
  }

  Future<void> _onLoadOrderUser(LoadOrderUserEvent event, Emitter<OrderUserState> emit) async {
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

  Future<void> _onUpdateOrderUserStatus(UpdateOrderUserStatusEvent event, Emitter<OrderUserState> emit) async {
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

  Future<void> _onAcceptDeliverer(AcceptDelivererEvent event, Emitter<OrderUserState> emit) async {
    if (state is OrderUserLoaded) {
      final Order currentOrderUser = (state as OrderUserLoaded).order;
      currentOrderUser.idsOfPossibleDeliverers.remove(event.delivererId);
      currentOrderUser.delivererId = event.delivererId;
      currentOrderUser.status = 'accepted';
      try {
        await orderRepo.updateOrder(currentOrderUser);
        emit(OrderUserLoaded(currentOrderUser));
        await getIt<NotificationRepository>().sendNotificationtoOtherUser(
          notificationTitle: 'Заказ принят',
          notificationBody: 'Клиент принял вашу заявку на доставку.',
          deviceToken: event.delivererToken ?? '',
        );
       
      } catch (e) {
        emit(const OrderUserError('Failed to accept deliverer'));
      }
    }
  }

  Future<void> _onRejectDeliverer(RejectDelivererEvent event, Emitter<OrderUserState> emit) async {
    if (state is OrderUserLoaded) {
      final Order currentOrderUser = (state as OrderUserLoaded).order;
      currentOrderUser.idsOfPossibleDeliverers.remove(event.delivererId);
      currentOrderUser.idsOfNotPossibleDeliverers.add(event.delivererId);
      try {
        await orderRepo.updateOrder(currentOrderUser);
        emit(OrderUserLoaded(currentOrderUser));
        await getIt<NotificationRepository>().sendNotificationtoOtherUser(
          notificationTitle: 'Заявка на доставку отменена',
          notificationBody: 'Клиент отменил вашу заявку на доставку.',
          deviceToken: event.delivererToken ?? '',
        );
      } catch (e) {
        emit(const OrderUserError('Failed to reject deliverer'));
      }
    }
  }

  Future<void> _onCancelOrderUser(CancelOrderUserEvent event, Emitter<OrderUserState> emit) async {
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
  }

  @override
  Future<void> close() {
    appWriteService.unsubscribeFromRealtimeUpdates();
    return super.close();
  }
}
