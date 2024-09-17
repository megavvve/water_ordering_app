import 'package:adminkigwater/domain/entities/deliverer.dart';
import 'package:adminkigwater/domain/repositories/deliverer_repository.dart';

class UpdateDeliverer {
  final DelivererRepository delivererRepository;

  UpdateDeliverer({required this.delivererRepository});

  Future<void> call(Deliverer deliverer) async {
    return await delivererRepository.updateDeliverer(deliverer: deliverer);
  }
}
