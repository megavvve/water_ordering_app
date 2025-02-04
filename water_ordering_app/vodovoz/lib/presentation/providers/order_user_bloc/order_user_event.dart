import 'package:equatable/equatable.dart';
import 'package:vodovoz/domain/entities/deliverer.dart';
import 'package:vodovoz/domain/entities/geolocation.dart';
import 'package:yandex_mapkit/yandex_mapkit.dart';

abstract class OrderUserEvent extends Equatable {
  const OrderUserEvent();

  @override
  List<Object> get props => [];
}

class LoadOrderUserEvent extends OrderUserEvent {}

class OrderUserDeliverersUpdatedEvent extends OrderUserEvent {
  final List<PlacemarkMapObject> delivererPlacemarks;

  const OrderUserDeliverersUpdatedEvent(this.delivererPlacemarks);
}

class UpdateOrderUserStatusEvent extends OrderUserEvent {
  final String status;

  const UpdateOrderUserStatusEvent(this.status);

  @override
  List<Object> get props => [status];
}

class LoadCurrentOrderEvent extends OrderUserEvent {}

class AcceptDelivererEvent extends OrderUserEvent {
  final String delivererId;
  final String? delivererToken;

  const AcceptDelivererEvent(this.delivererId, this.delivererToken);

  @override
  List<Object> get props => [delivererId];
}

class UpdateDelivererLocationEvent extends OrderUserEvent {
  final Geolocation newLocation;
  const UpdateDelivererLocationEvent(this.newLocation);
}

class RejectDelivererEvent extends OrderUserEvent {
  final String delivererId;
    final String? delivererToken;

  const RejectDelivererEvent(this.delivererId, this.delivererToken);

  @override
  List<Object> get props => [delivererId];
}

class UpdateDelivererEvent extends OrderUserEvent {
  final Deliverer delivererData;

  const UpdateDelivererEvent({required this.delivererData});

  @override
  List<Object> get props => [delivererData];
}

class CancelOrderUserEvent extends OrderUserEvent {}
