import 'package:vodovoz/domain/entities/deliverer.dart';
import 'package:vodovoz/domain/repositories/deliverer_repository.dart';

class GetDeliverers {
  final DelivererRepository delivererRepository;

  GetDeliverers({required this.delivererRepository});

  Future<List<Deliverer>> call() async {
    return await delivererRepository.getDeliverers();
  }
}
