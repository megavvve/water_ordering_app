import 'package:vodovoz/domain/entities/deliverer.dart';
import 'package:vodovoz/domain/repositories/deliverer_repository.dart';

class GetDelivererById {
  final DelivererRepository delivererRepository;

  GetDelivererById({required this.delivererRepository});

  Future<Deliverer?> call(String userId) async {
    return await delivererRepository.getDeliverer(userId);
  }
}
