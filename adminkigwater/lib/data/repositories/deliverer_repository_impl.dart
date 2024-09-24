import 'dart:async';

import 'package:adminkigwater/data/datasources/remote/appwrite.dart';
import 'package:adminkigwater/data/datasources/local/local_saved_data.dart';
import 'package:adminkigwater/domain/entities/deliverer.dart';
import 'package:adminkigwater/domain/entities/order.dart';
import 'package:adminkigwater/domain/entities/user_model.dart';
import 'package:adminkigwater/domain/repositories/deliverer_repository.dart';
import 'package:adminkigwater/injection_container.dart';
import 'package:adminkigwater/utils/constants.dart';
import 'package:appwrite/appwrite.dart';

class DelivererRepositoryImpl implements DelivererRepository {
  late Databases database;
  late Realtime realtime;

  DelivererRepositoryImpl() {
    final appwrite = getIt<AppWrite>();
    database = appwrite.getDataBase();
    realtime = appwrite.getRealtime();
  }
  @override
  Future<Deliverer?> getDeliverer(String userId) async {
    try {
      final response = await database.getDocument(
        databaseId: dbId,
        collectionId: deliverersCollectionId,
        documentId: userId,
      );
      return Deliverer.fromJson(response.data);
    } catch (e) {
      print('Error fetching deliverer: $e');
      return null;
    }
  }

  @override
  Future<void> saveDeliverer(Deliverer deliverer) async {
    try {
      await database.createDocument(
        databaseId: dbId,
        collectionId: deliverersCollectionId,
        documentId: deliverer.userId,
        data: deliverer.toJson(),
      );
      print('Deliverer saved successfully');
    } catch (e) {
      print('Failed to save deliverer: $e');
      throw Exception('Failed to save deliverer');
    }
  }

  @override
  Future<void> updateDeliverer({required Deliverer deliverer}) async {
    try {
      // Обновляем документ в базе данных Appwrite
      await database.updateDocument(
        databaseId: dbId,
        collectionId: deliverersCollectionId,
        documentId: deliverer.userId,
        data: deliverer.toJson(),
      );
      print('Deliverer updated successfully.');
    } on AppwriteException catch (e) {
      print('Failed to update deliverer: ${e.message}');
      throw Exception('Failed to update deliverer: ${e.message}');
    }
  }

  @override
  Future<List<Deliverer>> getDeliverers() async {
    try {
      final response = await database.listDocuments(
        databaseId: dbId,
        collectionId: deliverersCollectionId,
          queries: [
          Query.limit(5000),
        ]
      );

      return response.documents
          .map((doc) => Deliverer.fromJson(doc.data))
          .toList();
    } catch (e) {
      print('Error fetching deliverers: $e');
      return [];
    }
  }

  @override
  Future<List<UserModel>> getDeliverersByIdsOfPossibleDeliverers(
      List<String> ids) async {
    try {
      final response = await database.listDocuments(
        databaseId: dbId,
        collectionId: usersCollectionId,
        queries: [Query.equal('userId', ids)],
      );

      return response.documents
          .map((doc) => UserModel.fromMap(doc.data))
          .toList();
    } catch (e) {
      print('Error fetching deliverers by IDs: $e');
      return [];
    }
  }

  @override
  Stream<List<UserModel>> getDeliverersStream(String orderId) {
    final controller = StreamController<List<UserModel>>();

    RealtimeSubscription deliverersSubscription = realtime.subscribe(
        ['databases.$dbId.collections.$deliverersCollectionId.documents']);

    deliverersSubscription.stream.listen((event) async {
      if (event.events.contains('database.documents.create') ||
          event.events.contains('database.documents.update') ||
          event.events.contains('database.documents.delete')) {
        final deliverers = await _fetchDeliverers(orderId);
        controller.add(deliverers);
      }
    });

    return controller.stream;
  }

  Future<List<UserModel>> _fetchDeliverers(String orderId) async {
    final order = await _getOrder(orderId);
    final idsOfPossibleDeliverers = order?.idsOfPossibleDeliverers;

    final List<UserModel> deliverersList = [];
    for (final id in idsOfPossibleDeliverers!) {
      final delivererData = await database.getDocument(
        databaseId: dbId,
        collectionId: deliverersCollectionId,
        documentId: id,
      );
      deliverersList.add(UserModel.fromMap(delivererData.data));
    }

    return deliverersList;
  }

  Future<Order?> _getOrder(String orderId) async {
    try {
      final response = await database.getDocument(
        databaseId: dbId,
        collectionId: ordersCollectionId,
        documentId: orderId,
      );
      return Order.fromMap(response.data);
    } catch (e) {
      print('Error fetching order: $e');
      return null;
    }
  }

  @override
  Future<void> updateDelivererIfHeOutOfLine() async {
    Deliverer? deliverer = await getDeliverer(LocalSavedData().getUserId());
    if (deliverer != null) {
      deliverer.isAvailable = false;
      await saveDeliverer(deliverer);
    }
  }
}
