import 'package:vodovoz/domain/entities/order.dart';
import 'package:vodovoz/presentation/widgets/enums/order_status.dart';

Order? findOrderWithIdAndStatus(
    List<Order> orders, String userId, List<OrderStatus> statuses) {
  try {
    return orders.firstWhere(
      (order) =>
          order.customerId == userId &&
          statuses.toString().contains(order.status),
    );
  } catch (e) {
    return null;
  }
}
