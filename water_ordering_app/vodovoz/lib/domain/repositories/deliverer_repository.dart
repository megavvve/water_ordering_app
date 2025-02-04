import 'package:vodovoz/domain/entities/deliverer.dart';
import 'package:vodovoz/domain/entities/user_model/user_model.dart';

abstract class DelivererRepository {
  Future<Deliverer?> getDeliverer(String userId);
  Future<void> saveDeliverer(Deliverer deliverer);
  Future<List<Deliverer>> getDeliverers();
  Future<List<UserModel>?> getDeliverersByIds(List<String> ids);
  Future<void> updateDelivererIfHeOutOfLine();
  Future<void> updateDeliverer(Deliverer deliverer);
  Future<List<Deliverer>> getDeliverersByWaterTypeAndIsOnline(String waterType);
}
