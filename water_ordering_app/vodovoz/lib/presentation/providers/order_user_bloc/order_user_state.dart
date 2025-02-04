import 'package:equatable/equatable.dart';
import 'package:vodovoz/domain/entities/order.dart';

abstract class OrderUserState extends Equatable {
  const OrderUserState();

  @override
  List<Object?> get props => [];
}

class OrderUserInitial extends OrderUserState {}

class OrderUserLoading extends OrderUserState {}

class OrderUserLoaded extends OrderUserState {
  final Order order;

  const OrderUserLoaded(
    this.order,
  );
}

class OrderUserError extends OrderUserState {
  final String message;

  const OrderUserError(this.message);

  @override
  List<Object?> get props => [message];
}

class OrderUserStatusUpdated extends OrderUserState {}

class OrderUserCanceled extends OrderUserState {}
