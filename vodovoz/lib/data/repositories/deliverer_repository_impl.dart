import 'dart:async';

import 'package:appwrite/appwrite.dart';
import 'package:vodovoz/data/datasources/remote/appwrite.dart';
import 'package:vodovoz/data/datasources/local/local_saved_data.dart';
import 'package:vodovoz/domain/entities/deliverer.dart';
import 'package:vodovoz/domain/entities/user_model/user_model.dart';
import 'package:vodovoz/domain/repositories/deliverer_repository.dart';
import 'package:vodovoz/injection_container.dart';
import 'package:vodovoz/utils/constants.dart';

class DelivererRepositoryImpl implements DelivererRepository {
  late Databases database;

  DelivererRepositoryImpl() {
    final appwrite = getIt<AppWrite>();
    database = appwrite.getDataBase();
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
      try {
        await database.getDocument(
          databaseId: dbId,
          collectionId: deliverersCollectionId,
          documentId: deliverer.userId,
        );

        await database.updateDocument(
          databaseId: dbId,
          collectionId: deliverersCollectionId,
          documentId: deliverer.userId,
          data: deliverer.toJson(),
        );
      } catch (e) {
        if (e is AppwriteException && e.code == 404) {
          await database.createDocument(
            databaseId: dbId,
            collectionId: deliverersCollectionId,
            documentId: deliverer.userId,
            data: deliverer.toJson(),
          );
        } else {
          throw Exception('Failed to check existence of deliverer: $e');
        }
      }
    } catch (e) {
      throw Exception('Failed to save deliverer: $e');
    }
  }

  @override
  Future<List<Deliverer>> getDeliverers() async {
    try {
      final response = await database.listDocuments(
        databaseId: dbId,
        collectionId: deliverersCollectionId,
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
  Future<List<UserModel>?> getDeliverersByIds(List<String> ids) async {
    try {
      final response = await database.listDocuments(
        databaseId: dbId,
        collectionId: usersCollectionId,
      );

      List<UserModel> users =
          response.documents.map((doc) => UserModel.fromMap(doc.data)).toList();
      return users.where((x) => ids.contains(x.userId)).toList();
    } catch (e) {
      print('Error fetching deliverers by IDs: $e');
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

  @override
  Future<List<Deliverer>> getDeliverersByWaterTypeAndIsOnline(
      String waterType) async {
        try {
      final response = await database.listDocuments(
        databaseId: dbId,
        collectionId: deliverersCollectionId,
         queries: [Query.equal('waterType', waterType)], 
      );

      return response.documents
          .map((doc) => Deliverer.fromJson(doc.data)).where((del)=>del.isAvailable==true)
          .toList();
    } catch (e) {
      print('Error fetching deliverers: $e');
      return [];
    }
      }

  @override
  Future<void> updateDeliverer(Deliverer deliverer) async {
    try {
      await database.updateDocument(
        databaseId: dbId,
        collectionId: deliverersCollectionId,
        documentId: deliverer
            .userId, // Предположительно, в модели Deliverer есть поле id
        data: deliverer
            .toJson(), // Метод toJson() должен быть реализован в модели Deliverer для преобразования данных в Map
      );
      print("Deliverer updated successfully");
    } catch (e) {
      print("Failed to update deliverer: $e");
      throw Exception("Failed to update deliverer");
    }
  }
}
