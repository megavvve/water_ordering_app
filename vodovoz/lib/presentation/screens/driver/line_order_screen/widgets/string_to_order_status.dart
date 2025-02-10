import 'package:vodovoz/utils/enums/order_status.dart';

OrderStatus stringToOrderStatus(String status) {
  switch (status) {
    case 'pending':
      return OrderStatus.pending;
    case 'inProgress':
      return OrderStatus.inProgress;
    case 'completed':
      return OrderStatus.completed;
    case 'canceled':
      return OrderStatus.canceled;
    case 'awaitingConfirmation':
      return OrderStatus.awaitingConfirmation;
    case 'accepted':
      return OrderStatus.accepted;
    default:
      return OrderStatus.pending;
  }
}

String orderStatusToString(OrderStatus status) {
  switch (status) {
    case OrderStatus.pending:
      return 'pending';
    case OrderStatus.inProgress:
      return 'inProgress';
    case OrderStatus.completed:
      return 'completed';
    case OrderStatus.canceled:
      return 'canceled';
    case OrderStatus.awaitingConfirmation:
      return 'awaitingConfirmation';
    case OrderStatus.accepted:
      return 'accepted';
  }
}
