part of 'deliverer_order_bloc.dart';

abstract class DelivererOrderState extends Equatable {
  const DelivererOrderState();

  @override
  List<Object> get props => [];
}

class OrderInitial extends DelivererOrderState {}

class OrderLoading extends DelivererOrderState {}

class OrderLoaded extends DelivererOrderState {
  final List<Order> orders;

  const OrderLoaded(this.orders);

  @override
  List<Object> get props => [orders];
}

class UpdateCurrentOrder extends DelivererOrderEvent {
  const UpdateCurrentOrder();

  @override
  List<Object> get props => [];
}

class OrderAccepted extends DelivererOrderState {
  final Order order;

  const OrderAccepted(this.order);

  @override
  List<Object> get props => [order];
}

class OrderError extends DelivererOrderState {
  final String message;

  const OrderError(this.message);

  @override
  List<Object> get props => [message];
}

class OrderCompleted extends DelivererOrderState {
  final Order order;

  const OrderCompleted(this.order);

  @override
  List<Object> get props => [order];
}

class OrderAlreadyAccepted extends DelivererOrderState {
  final Order order;

  const OrderAlreadyAccepted(this.order);

  @override
  List<Object> get props => [order];
}
