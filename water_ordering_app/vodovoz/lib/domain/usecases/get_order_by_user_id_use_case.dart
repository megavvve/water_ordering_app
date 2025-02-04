import 'package:vodovoz/domain/entities/order.dart';
import 'package:vodovoz/domain/repositories/order_repository.dart';

class GetOrderByUserId {
  final OrderRepository orderRepository;

  GetOrderByUserId({required this.orderRepository});

  Future<Order?> call(String userId) async {
    return await orderRepository.getOrderByUserId(userId);
  }
}
