import 'package:adminkigwater/domain/entities/order.dart';
import 'package:adminkigwater/domain/repositories/order_repository.dart';

class AddOrder {
  final OrderRepository orderRepository;

  AddOrder({required this.orderRepository});

  Future<void> call(Order order) async {
    return await orderRepository.addOrder(order);
  }
}
