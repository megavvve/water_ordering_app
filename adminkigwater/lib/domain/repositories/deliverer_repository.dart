import 'package:adminkigwater/domain/entities/deliverer.dart';
import 'package:adminkigwater/domain/entities/user_model.dart';

abstract class DelivererRepository {
  Future<Deliverer?> getDeliverer(String userId);
  Future<void> saveDeliverer(Deliverer deliverer);
  Future<List<Deliverer>> getDeliverers();
  Future<List<UserModel>> getDeliverersByIdsOfPossibleDeliverers(
      List<String> ids);
  Stream<List<UserModel>> getDeliverersStream(String orderId);
  Future<void> updateDelivererIfHeOutOfLine();
  Future<void> updateDeliverer({required Deliverer deliverer});
}
