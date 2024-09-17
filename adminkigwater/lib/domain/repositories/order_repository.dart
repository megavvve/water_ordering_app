import 'package:adminkigwater/domain/entities/order.dart';

abstract class OrderRepository {
  Future<Order?> getOrder(String orderId);
  Future<List<Order>> getOrders();
  Future<void> updateOrder(Order order);
  Future<void> addDelivererToOrder(String orderId, String delivererId);
  Future<void> deleteDelivererFromOrder(String orderId, String delivererId);
  Future<List<Order>> getOrdersByWaterType(String waterType);
  Future<Order?> getOrderByUserId(String userId);
  Future<List<Order>> getOrdersForHistory();
  Future<void> addOrder(Order order);
}
