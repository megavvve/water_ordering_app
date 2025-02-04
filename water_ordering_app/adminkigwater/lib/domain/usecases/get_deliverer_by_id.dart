import 'package:adminkigwater/data/datasources/local/local_saved_data.dart';
import 'package:adminkigwater/domain/entities/deliverer.dart';
import 'package:adminkigwater/domain/repositories/deliverer_repository.dart';

class GetDelivererById {
  final DelivererRepository delivererRepository;

  GetDelivererById({required this.delivererRepository});

  Future<Deliverer?> call() async {
    return await delivererRepository.getDeliverer(LocalSavedData().getUserId());
  }
}
