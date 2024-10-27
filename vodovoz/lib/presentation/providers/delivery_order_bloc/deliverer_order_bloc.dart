import 'package:appwrite/appwrite.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:vodovoz/data/datasources/local/local_saved_data.dart';
import 'package:vodovoz/data/datasources/remote/appwrite.dart';
import 'package:vodovoz/domain/entities/order.dart';
import 'package:vodovoz/domain/entities/user_model/rating/review.dart';
import 'package:vodovoz/domain/repositories/user/notification_repository.dart';
import 'package:vodovoz/domain/repositories/order_repository.dart';
import 'package:vodovoz/domain/repositories/user/rating_repository.dart';
import 'package:vodovoz/domain/usecases/get_user_by_id.dart';
import 'package:vodovoz/injection_container.dart';
import 'package:vodovoz/presentation/widgets/enums/order_status.dart';
import 'package:vodovoz/utils/constants.dart';

part 'deliverer_order_event.dart';
part 'deliverer_order_state.dart';

class DelivererOrderBloc
    extends Bloc<DelivererOrderEvent, DelivererOrderState> {
  final OrderRepository orderRepository = getIt<OrderRepository>();
  final AppWrite appWrite = getIt<AppWrite>();
  final String currentUserId = LocalSavedData().getUserId();

  DelivererOrderBloc() : super(OrderInitial()) {
    on<LoadOrders>(_onLoadOrders);
    on<AcceptOrder>(_onAcceptOrder);
    on<UpdateOrderStatus>(_onUpdateOrderStatus);
    on<AcceptPendingOrder>(_onAcceptPendingOrder);
    on<UpdateCurrentOrder>(_onUpdateCurrentOrder);
    on<CompleteOrder>(_onCompleteOrder);
    on<RejectPendingOrder>(_onRejectPendingOrder);
    on<CancelOrder>(_onCancelOrderWithReview);
    on<RejectAcceptedOrder>(_onRejectAcceptedOrder);
  }

  Future<void> _onLoadOrders(
    LoadOrders event,
    Emitter<DelivererOrderState> emit,
  ) async {
    emit(OrderLoading());
    try {
      final orders = await orderRepository.getOrders();

      // Check for any orders already accepted by the current user
      Order? acceptedOrder;
      try {
        acceptedOrder = orders.firstWhere(
          (order) =>
              (order.delivererId == currentUserId &&
                  order.status == OrderStatus.accepted.name) ||
              (order.delivererId == currentUserId &&
                  order.status == OrderStatus.inProgress.name),
        );
      } catch (e) {
        acceptedOrder = null;
      }

      // Check if there is any canceled order where isFinish == false
      Order? canceledOrder;
      try {
        canceledOrder = orders.firstWhere(
          (order) =>
              order.delivererId == currentUserId &&
              order.status == OrderStatus.canceled.name &&
              order.isFinish == false,
        );
      } catch (e) {
        canceledOrder = null;
      }

      if (canceledOrder != null) {
        try {
          final reviews = await getIt<RatingRepository>()
              .getReviews(userId: canceledOrder.customerId);
          reviews.firstWhere((x) =>
              x.isReviewForCanceledOrder == true &&
              x.orderId == canceledOrder?.id);
        } catch (e) {
          emit(
            OrderCanceled(
              canceledOrder,
            ),
          );
          return;
        }
      }

      if (acceptedOrder != null) {
        emit(OrderAlreadyAccepted(acceptedOrder));
        return;
      }

      final filteredOrders = orders
          .where((order) =>
              (order.status == OrderStatus.pending.name ||
                  order.status == OrderStatus.awaitingConfirmation.name) &&
              order.customerId != currentUserId &&
              !order.idsOfNotPossibleDeliverers.contains(currentUserId))
          .where(
            (x) =>
                x.waterType == getIt<LocalSavedData>().getDelivererWaterType(),
          )
          .toList();

      emit(OrderLoaded(filteredOrders));
    } catch (e) {
      emit(
        OrderError(
          'Failed to load orders: $e',
        ),
      );
    }
  }

  Future<void> _onAcceptOrder(
    AcceptOrder event,
    Emitter<DelivererOrderState> emit,
  ) async {
    final order = event.order;
    try {
      order.delivererId = currentUserId;
      order.status = OrderStatus.accepted.name;
      await orderRepository.updateOrder(order);
      emit(OrderAccepted(order));
    } catch (e) {
      emit(OrderError('Failed to accept order: $e'));
    }
  }

  Future<void> _onCancelOrderWithReview(
    CancelOrder event,
    Emitter<DelivererOrderState> emit,
  ) async {
    emit(OrderLoading());

    try {
      final order = event.order;
      final review = Review(
        id: ID.unique(),
        toWhomUserId: order.customerId,
        fromWhomUserId: currentUserId,
        orderId: order.id,
        rating: 0,
        isDeliverer: false,
        comment: event.reason,
        date: dateTimeCorrectForm,
        isReviewForCanceledOrder: true,
      );
      await getIt<RatingRepository>().addReview(review: review);

      await orderRepository.updateOrder(
        order.copyWith(
          status: 'canceled',
        ),
      );

      emit(OrderCanceled(order));
    } catch (e) {
      emit(OrderError('Ошибка при отмене заказа: $e'));
    }
  }

  Future<void> _onAcceptPendingOrder(
      AcceptPendingOrder event, Emitter<DelivererOrderState> emit) async {
    final order = event.order;
    final state = this.state;
    try {
      final copyOrder = order;
      order.idsOfPossibleDeliverers.add(currentUserId);
      order.status = OrderStatus.awaitingConfirmation.name;
      await orderRepository.updateOrder(order);
      final userModelForNotification =
          await getIt<GetUserById>().call(order.customerId);
      await getIt<NotificationRepository>().sendNotificationtoOtherUser(
        notificationTitle: textForNotificationTitleFromDeliverer,
        notificationBody: textForNotificationTitleFromDeliverer,
        deviceToken: userModelForNotification?.token ?? '',
      );
      if (state is OrderLoaded) {
        List<Order> ordersList = state.orders;
        ordersList.remove(copyOrder);
        ordersList.add(order);
        emit(
          OrderLoaded(
            ordersList,
          ),
        );
      }
    } catch (e) {
      emit(
        OrderError(
          'Failed to accept order: $e',
        ),
      );
    }
  }

  Future<void> _onRejectPendingOrder(
      RejectPendingOrder event, Emitter<DelivererOrderState> emit) async {
    final order = event.order;

    final state = this.state;
    try {
      final userId = getIt<LocalSavedData>().getUserId();
      final copyOrder = order;
      order.idsOfPossibleDeliverers.remove(userId);
      order.idsOfNotPossibleDeliverers.add(userId);

      await getIt<OrderRepository>().updateOrder(order);
      if (state is OrderLoaded) {
        List<Order> ordersList = state.orders;
        ordersList.remove(copyOrder);

        emit(
          OrderLoaded(
            ordersList,
          ),
        );
      }
    } catch (e) {
      emit(
        OrderError(
          'Failed to accept order: $e',
        ),
      );
    }
  }

  Future<void> _onRejectAcceptedOrder(
      RejectAcceptedOrder event, Emitter<DelivererOrderState> emit) async {
    Order order = event.order;

    try {
      order.delivererId = '';
      order.status = OrderStatus.pending.name;
      final userId = getIt<LocalSavedData>().getUserId();

      order.idsOfPossibleDeliverers.remove(userId);
      order.idsOfNotPossibleDeliverers.add(userId);

      await getIt<OrderRepository>().updateOrder(order);
    final userModelForNotification =
          await getIt<GetUserById>().call(order.customerId);
      await getIt<NotificationRepository>().sendNotificationtoOtherUser(
        notificationTitle: 'Отказ от заказа',
        notificationBody: 'Доставщик отказался от заказа',
        deviceToken: userModelForNotification?.token ?? '',
      );
      emit(
        OrderReject(
          order,
        ),
      );
    } catch (e) {
      emit(
        OrderError(
          'Failed to reject order: $e',
        ),
      );
    }
  }

  Future<void> _onUpdateCurrentOrder(
    UpdateCurrentOrder event,
    Emitter<DelivererOrderState> emit,
  ) async {
    Order? currentOrder;

    if (state is OrderAlreadyAccepted) {
      currentOrder = (state as OrderAlreadyAccepted).order;
      currentOrder = await orderRepository.getOrder(currentOrder.id);
      emit(OrderAlreadyAccepted(currentOrder!));
    }
  }

  Future<void> _onCompleteOrder(
    CompleteOrder event,
    Emitter<DelivererOrderState> emit,
  ) async {
    final order = event.order;
    final Review review = event.review;

    try {
      order.status = OrderStatus.completed.name;
      await orderRepository.updateOrder(order);

      await getIt<RatingRepository>().addReviewForRating(review: review);

      emit(OrderCompleted(order));
    } catch (e) {
      emit(OrderError('Failed to complete order: $e'));
    }
  }

  Future<void> _onUpdateOrderStatus(
    UpdateOrderStatus event,
    Emitter<DelivererOrderState> emit,
  ) async {
    Order order = event.order;
    final status = event.status;

    try {
      await orderRepository.updateOrder(order.copyWith(status: status));
      // Re-emit the current state to trigger UI updates
      if (state is OrderLoaded) {
        final orders = (state as OrderLoaded).orders;
        emit(OrderLoaded(orders));
      } else if (state is OrderAccepted) {
        emit(OrderAccepted(order));
      }
    } catch (e) {
      emit(OrderError('Failed to update order status: $e'));
    }
  }
}
