part of 'deliverer_order_bloc.dart';

abstract class DelivererOrderEvent extends Equatable {
  const DelivererOrderEvent();

  @override
  List<Object> get props => [];
}

class LoadOrders extends DelivererOrderEvent {}

class AcceptOrder extends DelivererOrderEvent {
  final Order order;

  const AcceptOrder(this.order);

  @override
  List<Object> get props => [order];
}

class CompleteOrder extends DelivererOrderEvent {
  final Order order;
  final Review review;

  const CompleteOrder(this.order, this.review);

  @override
  List<Object> get props => [order, review];
}

class AcceptPendingOrder extends DelivererOrderEvent {
  final Order order;

  const AcceptPendingOrder(this.order);

  @override
  List<Object> get props => [order];
}

class UpdateOrderStatus extends DelivererOrderEvent {
  final Order order;
  final String status;

  const UpdateOrderStatus(this.order, this.status);

  @override
  List<Object> get props => [order, status];
}
