import 'package:vodovoz/domain/entities/order.dart';
import 'package:vodovoz/domain/repositories/order_repository.dart';

class GetOrder {
  final OrderRepository orderRepository;

  GetOrder({required this.orderRepository});

  Future<Order?> call(String orderId) async {
    return await orderRepository.getOrder(orderId);
  }
}
