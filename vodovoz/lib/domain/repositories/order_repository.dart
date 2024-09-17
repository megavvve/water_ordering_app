import 'package:vodovoz/domain/entities/order.dart';

abstract class OrderRepository {
  Future<Order?> getOrder(String orderId);
  Future<List<Order>> getOrders();
  Future<void> updateOrder(Order order);
  Future<void> addDelivererToOrder(String orderId, String delivererId);
  Future<void> deleteDelivererFromOrder(String orderId, String delivererId);
  Future<List<Order>> getOrdersByWaterType(String waterType);
  Future<Order?> getOrderByUserId(String userId);
  Future<void> addOrder(Order order);

  Future<Order?> getActiveOrder();
  Future<Order?> getOrderByOrderId(String orderId);
}
